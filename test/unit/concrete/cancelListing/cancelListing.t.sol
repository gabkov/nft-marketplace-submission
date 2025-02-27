// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "../../../NftMarketplace.t.sol";

contract CancelListingTest is NftMarketplaceTest {
    function setUp() public override {
        super.setUp();
    }

    function test_WhenCallerIsNotOwner() external {
        // It should revert with {NotTokenOwner}

        vm.prank({msgSender: bob});
        vm.expectRevert(INftMarketPlace.NotTokenOwner.selector);
        nftm.cancelListing(mockNft, token1);
    }

    modifier whenCallerIsTheOwner() {
        vm.startPrank({msgSender: alice});
        _;
    }

    function test_WhenItemIsNotListed() external whenCallerIsTheOwner {
        // It should revert with {ListingNotFound}

        vm.expectRevert(abi.encodeWithSelector(INftMarketPlace.ListingNotFound.selector, mockNft, 0));
        nftm.cancelListing(mockNft, token1);
    }

    function test_WhenItemIsListed() external whenCallerIsTheOwner {
        // It should delete the listing
        // It should emit {ListingCancelled} event

        MockNft(mockNft).approve(address(nftm), token1);
        nftm.listItem(mockNft, token1, 1 ether);

        // verify that it was listed
        (address seller, uint256 price) = getSellerAndPrice(mockNft, token1);
        assertEq(seller, alice);
        assertEq(price, 1 ether);

        vm.expectEmit();
        emit INftMarketPlace.ListingCancelled(mockNft, token1);
        nftm.cancelListing(mockNft, token1);

        (seller, price) = getSellerAndPrice(mockNft, token1);
        assertEq(seller, address(0));
        assertEq(price, 0);
    }

    function testGas_cancelListing() external whenCallerIsTheOwner {
        MockNft(mockNft).approve(address(nftm), token1);
        nftm.listItem(mockNft, token1, 1 ether);

        nftm.cancelListing(mockNft, token1);
        vm.snapshotGasLastCall("cancelListing");
    }
}
