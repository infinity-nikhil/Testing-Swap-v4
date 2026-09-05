// script/DeployToken.s.sol

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {Token} from "../src/Token.sol";

contract DeployToken is Script {

    function run() external returns (Token token) {

        vm.startBroadcast();

        token = new Token(
            msg.sender,
            1_000_000,
            "My Poken",
            "MPK"
        );

        vm.stopBroadcast();
    }
}