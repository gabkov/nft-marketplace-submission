// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "forge-std/Test.sol";
import {NftMarketPlace, INftMarketPlace} from "src/NftMarketplace.sol";
import {MockNft} from "./mocks/MockNft.sol";

abstract contract NftMarketplaceTest is Test {
    INftMarketPlace public nftm;
    address public mockNft;

    address payable owner;
    address payable alice;
    address payable bob;

    uint256 token1;
    uint256 token2;

    function setUp() public virtual {
        owner = payable(makeAddr({name: "owner"}));
        alice = payable(makeAddr({name: "alice"}));
        bob = payable(makeAddr({name: "bob"}));

        nftm = new NftMarketPlace();
        mockNft = address(new MockNft(owner));

        vm.prank({msgSender: owner});
        token1 = MockNft(mockNft).safeMint(alice);
        vm.prank({msgSender: owner});
        token2 = MockNft(mockNft).safeMint(alice);
    }

    function getSellerAndPrice(address nft, uint256 tokenId) public returns (address, uint256) {
        INftMarketPlace.Listing memory listing = nftm.listings(mockNft, token1);
        return (listing.seller, listing.price);
    }
}
