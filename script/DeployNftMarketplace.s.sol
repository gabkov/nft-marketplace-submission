// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

import {Script, console} from "forge-std/Script.sol";
import {NftMarketplace} from "../src/NftMarketplace.sol";

contract DeployNftMarketplace is Script {
    NftMarketplace public nftm;
    // enabled by default on anvil
    address defaultCreate2Deployer = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function setUp() public {}

    function run() public {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        bytes32 salt = keccak256("gabkov");

        bytes memory creationCode = type(NftMarketplace).creationCode;

        address computedAddress = Create2.computeAddress(salt, keccak256(creationCode), defaultCreate2Deployer);

        address deployedAddress = Create2.deploy(0, salt, creationCode);

        // deployed address is 0x74Cc559668850DE1FE54Bd74cBD9b6925CAdEECD
        assert(computedAddress == deployedAddress);
        console.log("Computed Contract Address:", computedAddress);
        console.log("Deployed Contract Address:", deployedAddress);

        vm.stopBroadcast();
    }
}
