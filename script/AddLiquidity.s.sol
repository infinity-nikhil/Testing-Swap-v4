// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";

import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {IPositionManager} from "v4-periphery/src/interfaces/IPositionManager.sol";
import {Actions} from "v4-periphery/src/libraries/Actions.sol";
import {LiquidityAmounts} from "v4-periphery/src/libraries/LiquidityAmounts.sol";

import {IAllowanceTransfer} from "permit2/src/interfaces/IAllowanceTransfer.sol";

import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";


contract AddLiquidity is Script {

    // -----------------------------
    // Uniswap v4 Sepolia
    // -----------------------------

    address constant POSITION_MANAGER =
        0x429ba70129df741B2Ca2a85BC3A2a3328e5c09b4;

    address constant PERMIT2 =
        0x000000000022D473030F116dDEE9F6B43aC78BA3;


    // -----------------------------
    // Your tokens
    // -----------------------------

    address constant MPK =
        0x987d4bF8299aedFaBe630f3f78BF65a254758150;

    address constant MTK =
        0xE898A770065856562c2C2fA899e79Ad48eB5116A;


    // -----------------------------
    // Pool configuration
    // -----------------------------

    uint24 constant FEE = 3000;
    int24 constant TICK_SPACING = 60;

    int24 constant TICK_LOWER = -600;
    int24 constant TICK_UPPER = 600;


    // -----------------------------
    // Amounts
    // -----------------------------

    uint256 constant AMOUNT0 = 100 ether; //Here ether means 10^18 just to avoid decimals 
    uint256 constant AMOUNT1 = 100 ether;


    function run() external {

        vm.startBroadcast();


        // =========================================
        // 1. Create the PoolKey
        // =========================================

        PoolKey memory poolKey = PoolKey({
            currency0: Currency.wrap(MPK),
            currency1: Currency.wrap(MTK),
            fee: FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(0))
        });


        // =========================================
        // 2. Approve Permit2 to spend our tokens
        // =========================================

        IERC20(MPK).approve(   //Here in approve we haven't specified the amount ??
            PERMIT2,            // Yeah we specify that bleow in params 
            type(uint256).max
        );

        IERC20(MTK).approve(        // It is only the permission you can pull tokens 
            PERMIT2,
            type(uint256).max
        );


        // =========================================
        // 3. Approve PositionManager through Permit2
        // =========================================

        IAllowanceTransfer(PERMIT2).approve(
            MPK,
            POSITION_MANAGER,
            type(uint160).max,
            type(uint48).max
        );

        IAllowanceTransfer(PERMIT2).approve(
            MTK,
            POSITION_MANAGER,
            type(uint160).max,
            type(uint48).max
        );


        // =========================================
        // 4. Calculate sqrt prices for our range
        // =========================================

        uint160 sqrtPriceCurrent =
            TickMath.getSqrtPriceAtTick(0);

        uint160 sqrtPriceLower =
            TickMath.getSqrtPriceAtTick(TICK_LOWER);

        uint160 sqrtPriceUpper =
            TickMath.getSqrtPriceAtTick(TICK_UPPER);


        // =========================================
        // 5. Calculate liquidity
        // =========================================

        uint128 liquidity =
            LiquidityAmounts.getLiquidityForAmounts(
                sqrtPriceCurrent,
                sqrtPriceLower,
                sqrtPriceUpper,
                AMOUNT0,
                AMOUNT1
            );


        // =========================================
        // 6. Tell PositionManager what to do
        // =========================================

        bytes memory actions = abi.encodePacked(
            uint8(Actions.MINT_POSITION),
            uint8(Actions.SETTLE_PAIR)
        );


        bytes[] memory params = new bytes[](2);


        // MINT_POSITION
        params[0] = abi.encode(
            poolKey,
            TICK_LOWER,
            TICK_UPPER,
            liquidity,
            uint128(AMOUNT0),
            uint128(AMOUNT1),
            msg.sender,
            ""
        );


        // SETTLE_PAIR
        params[1] = abi.encode(
            poolKey.currency0,
            poolKey.currency1
        );


        // =========================================
        // 7. Execute
        // =========================================

        IPositionManager(POSITION_MANAGER).modifyLiquidities(    //the main call happens here 
            abi.encode(actions, params),
            block.timestamp + 3600
        );


        vm.stopBroadcast();
    }
}