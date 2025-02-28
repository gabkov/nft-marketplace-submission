// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "../../../NftMarketplace.t.sol";

contract ListItemTest is NftMarketplaceTest {
    function setUp() public override {
        super.setUp();
    }

    function test_WhenCallerIsNotOwner() external {
        // It should revert with {NotTokenOwner}

        vm.prank({msgSender: bob});
        vm.expectRevert(INftMarketplace.NotTokenOwner.selector);
        nftm.listItem(mockNft, token1, 1 ether);
    }

    modifier whenCallerIsTheOwner() {
        vm.startPrank({msgSender: alice});
        _;
    }

    function test_WhenThePriceIs0() external whenCallerIsTheOwner {
        // It should revert with {ZeroPrice}

        vm.expectRevert(INftMarketplace.ZeroPrice.selector);
        nftm.listItem(mockNft, token1, 0);
    }

    modifier whenThePriceIsMoreThan0() {
        _;
    }

    function test_WhenNftIsNotApprovedForListing() external whenCallerIsTheOwner whenThePriceIsMoreThan0 {
        // It should revert with {TokenNotApprovedForListing}

        vm.expectRevert(INftMarketplace.TokenNotApprovedForListing.selector);
        nftm.listItem(mockNft, token1, 1 ether);
    }

    modifier whenNftIsApprovedForListing() {
        MockNft(mockNft).approve(address(nftm), token1);
        _;
    }

    function test_WhenListingAlreadyExists()
        external
        whenCallerIsTheOwner
        whenThePriceIsMoreThan0
        whenNftIsApprovedForListing
    {
        // It should revert with {ListingAlreadyExists}

        nftm.listItem(mockNft, token1, 1 ether);

        vm.expectRevert(abi.encodeWithSelector(INftMarketplace.ListingAlreadyExists.selector, mockNft, 0));
        nftm.listItem(mockNft, token1, 1 ether);
    }

    function test_WhenListingDoesNotExist()
        external
        whenCallerIsTheOwner
        whenThePriceIsMoreThan0
        whenNftIsApprovedForListing
    {
        // It should create the listing
        // It should emit {ItemListed} event

        vm.expectEmit();
        emit INftMarketplace.ItemListed(mockNft, token1, alice, 1 ether);
        nftm.listItem(mockNft, token1, 1 ether);

        (address seller, uint256 price) = getSellerAndPrice(mockNft, token1);
        assertEq(seller, alice);
        assertEq(price, 1 ether);
    }

    function testGas_listItem() external whenCallerIsTheOwner whenNftIsApprovedForListing whenThePriceIsMoreThan0 {
        nftm.listItem(mockNft, token1, 1 ether);
        vm.snapshotGasLastCall("listItem");
    }
}
