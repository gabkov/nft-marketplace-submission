// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "../../../NftMarketplace.t.sol";

contract UpdateListingTest is NftMarketplaceTest {
    function setUp() public override {
        super.setUp();
    }

    function test_WhenCallerIsNotOwner() external {
        // It should revert with {NotTokenOwner}

        vm.prank({msgSender: bob});
        vm.expectRevert(INftMarketplace.NotTokenOwner.selector);
        nftm.updateListing(mockNft, token1, 2 ether);
    }

    modifier whenCallerIsTheOwner() {
        vm.startPrank({msgSender: alice});
        _;
    }

    function test_WhenItemIsNotListed() external whenCallerIsTheOwner {
        // It should revert with {ListingNotFound}

        vm.expectRevert(abi.encodeWithSelector(INftMarketplace.ListingNotFound.selector, mockNft, 0));
        nftm.updateListing(mockNft, token1, 2 ether);
    }

    modifier whenItemIsListed() {
        MockNft(mockNft).approve(address(nftm), token1);
        nftm.listItem(mockNft, token1, 1 ether);
        _;
    }

    function test_WhenNewPriceIs0() external whenCallerIsTheOwner whenItemIsListed {
        // It should revert with {ZeroPrice}

        vm.expectRevert(INftMarketplace.ZeroPrice.selector);
        nftm.updateListing(mockNft, token1, 0);
    }

    function test_WhenNewPriceIsAbove0() external whenCallerIsTheOwner whenItemIsListed {
        // It should update price
        // It should emit {ListingUpdated} event

        vm.expectEmit();
        emit INftMarketplace.ListingUpdated(mockNft, token1, 1 ether, 2 ether);
        nftm.updateListing(mockNft, token1, 2 ether);

        (address seller, uint256 price) = getSellerAndPrice(mockNft, token1);
        assertEq(seller, alice);
        assertEq(price, 2 ether);
    }

    function testGas_updateListing() external whenCallerIsTheOwner whenItemIsListed {
        nftm.updateListing(mockNft, token1, 2 ether);
        vm.snapshotGasLastCall("updateListing");
    }
}
