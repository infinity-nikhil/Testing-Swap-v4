// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {IUnlockCallback} from "v4-core/interfaces/callback/IUnlockCallback.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {BalanceDelta, BalanceDeltaLibrary} from "v4-core/types/BalanceDelta.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";

contract Miniswap is IUnlockCallback {
    using BalanceDeltaLibrary for BalanceDelta;
    using SafeERC20 for IERC20;

    IPoolManager public immutable poolManager;

    error Expired();
    error Slippage();
    error NotPoolManager();

    event Swapped(address indexed user, address tokenIn, address tokenOut, uint256 amountIn, uint256 amountOut);

    constructor(address poolManager_) {
        poolManager = IPoolManager(poolManager_);
    }

    function swap(PoolKey calldata key, bool zeroForOne, uint256 amountIn, uint256 minOut, uint256 deadline)
        external
        returns (uint256 amountOut)
    {
        if (block.timestamp > deadline) revert Expired();
        if (minOut == 0) revert Slippage();

        address tokenIn = Currency.unwrap(zeroForOne ? key.currency0 : key.currency1);
        address tokenOut = Currency.unwrap(zeroForOne ? key.currency1 : key.currency0);

        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);

        bytes memory result = poolManager.unlock(abi.encode(key, zeroForOne, amountIn, msg.sender));
        amountOut = abi.decode(result, (uint256));
        if (amountOut < minOut) revert Slippage();

        emit Swapped(msg.sender, tokenIn, tokenOut, amountIn, amountOut);
    }

    function unlockCallback(bytes calldata data) external returns (bytes memory) {
        if (msg.sender != address(poolManager)) revert NotPoolManager();

        (PoolKey memory key, bool zeroForOne, uint256 amountIn, address to) =
            abi.decode(data, (PoolKey, bool, uint256, address));

        uint160 limit = zeroForOne ? TickMath.MIN_SQRT_PRICE + 1 : TickMath.MAX_SQRT_PRICE - 1;
        BalanceDelta d = poolManager.swap(key, IPoolManager.SwapParams(zeroForOne, -int256(amountIn), limit), "");

        uint256 received;
        if (zeroForOne) {
            uint256 owed = uint256(uint128(-d.amount0()));
            received = uint256(uint128(d.amount1()));
            poolManager.sync(key.currency0);
            IERC20(Currency.unwrap(key.currency0)).safeTransfer(address(poolManager), owed);
            poolManager.settle();
            poolManager.take(key.currency1, to, received);
        } else {
            uint256 owed = uint256(uint128(-d.amount1()));
            received = uint256(uint128(d.amount0()));
            poolManager.sync(key.currency1);
            IERC20(Currency.unwrap(key.currency1)).safeTransfer(address(poolManager), owed);
            poolManager.settle();
            poolManager.take(key.currency0, to, received);
        }

        return abi.encode(received);
    }
}