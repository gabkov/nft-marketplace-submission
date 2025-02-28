// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

import {Script, console} from "forge-std/Script.sol";
import {NftMarketplace, INftMarketplace} from "../src/NftMarketplace.sol";
import {MockNft} from "../test/mocks/MockNft.sol";

contract DeployAndListNft is Script {
    NftMarketplace public nftm;
    MockNft public mockNft;
    
    // enabled by default on anvil
    address defaultCreate2Deployer = 0x4e59b44847b379578588920cA78FbF26c0B4956C;

    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.rememberKey(privateKey);

        bytes32 salt = keccak256("gabkov");
        
        vm.startBroadcast(privateKey);

        // deploy marketplace
        address nftmAddress = deployMarketPlace(salt); // 0x233Db55118f182a1EF26d4946b8fF3B4dFba5B0B
        nftm = NftMarketplace(payable(nftmAddress));

        // deploy nft
        address mockNftAddress = deployMockNFT(salt, deployer); // 0x01E52044416A5190845490bB65B9684718B481d1
        mockNft = MockNft(payable(mockNftAddress));

        // list nft on markeplace
        mintAndListNft(deployer);
        
        vm.stopBroadcast();
    }

    function deployMarketPlace(bytes32 salt) internal returns(address){
        bytes memory creationCode = type(NftMarketplace).creationCode;

        address computedAddress = Create2.computeAddress(salt, keccak256(creationCode), defaultCreate2Deployer);
        address deployedAddress = Create2.deploy(0, salt, creationCode);

        assert(computedAddress == deployedAddress);
        console.log("Computed NftMarketplace Address:", computedAddress);
        console.log("Deployed NftMarketplace Address:", deployedAddress);

        return deployedAddress;
    }

    function deployMockNFT(bytes32 salt, address deployer) internal returns(address){
        bytes memory constructorArgs = abi.encode(deployer); 
        bytes memory creationCode = abi.encodePacked(type(MockNft).creationCode, constructorArgs);

        address computedAddress = Create2.computeAddress(salt, keccak256(creationCode), defaultCreate2Deployer);
        address deployedAddress = Create2.deploy(0, salt, creationCode);
        
        assert(computedAddress == deployedAddress);
        console.log("Computed MockNft Address:", computedAddress);
        console.log("Deployed MockNft Address:", deployedAddress);

        return deployedAddress;
    }

    function mintAndListNft(address deployer) internal {
        // mint nft & approve
        uint256 tokenId = mockNft.safeMint(deployer);
        mockNft.approve(address(nftm), tokenId);
        
        // list nft
        nftm.listItem(address(mockNft), tokenId, 1 ether);

        // validate listing
        INftMarketplace.Listing memory listing = nftm.listings(address(mockNft), tokenId);
        assert(listing.seller == deployer);
        assert(listing.price == 1 ether);
    }
}
