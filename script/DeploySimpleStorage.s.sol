// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;


import {Script} from "forge-std/Script.sol";
import {SimpleStorage} from "../src/SimpleStorage.sol";

contract DeploySimpleStorage is Script {
    function run() external returns (SimpleStorage) {

        //cheatcode
        vm.startBroadcast();// key word in forge-std; only forge KW
        //sent to RPS everything after this line; any transaction that we want to send
        SimpleStorage simpleStorage = new SimpleStorage();// new creates a new contract
        vm.stopBroadcast();
        return simpleStorage;
// In foundry if not specified RPC URL(Anvil is not running) it will deploy on a temporary Anvil chain

    }
}