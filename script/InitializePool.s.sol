// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

contract InitializePool is Script {

    address constant POOL_MANAGER =
        0xE03A1074c86CFeDd5C142C4F04F1a1536e203543;

    address constant MPK =
        0x987d4bF8299aedFaBe630f3f78BF65a254758150;

    address constant MTK =
        0xE898A770065856562c2C2fA899e79Ad48eB5116A;

    uint24 constant FEE = 3000;
    int24 constant TICK_SPACING = 60;

    uint160 constant SQRT_PRICE_X96 =
        79228162514264337593543950336;

    function run() external {

        PoolKey memory key = PoolKey({
            currency0: Currency.wrap(MPK),
            currency1: Currency.wrap(MTK),
            fee: FEE,
            tickSpacing: TICK_SPACING,
            hooks: IHooks(address(0))
        });

        vm.startBroadcast();

        IPoolManager(POOL_MANAGER).initialize(
            key,
            SQRT_PRICE_X96
        );

        vm.stopBroadcast();
    }
}