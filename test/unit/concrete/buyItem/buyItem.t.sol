// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "test/NftMarketplace.t.sol";

contract BuyItemTest is NftMarketplaceTest {
    function setUp() public override {
        super.setUp();
    }

    function test_WhenItemIsNotListed() external {
        // It should revert with {ListingNotFound}

        vm.prank({msgSender: bob});
        vm.expectRevert(abi.encodeWithSelector(INftMarketPlace.ListingNotFound.selector, mockNft, 0));
        nftm.buyItem{value: 1 ether}(mockNft, token1);
    }

    modifier whenItemIsListed() {
        vm.startPrank({msgSender: alice});

        MockNft(mockNft).approve(address(nftm), token1);
        nftm.listItem(mockNft, token1, 1 ether);

        vm.stopPrank();
        _;
    }

    function test_WhenMsgValueIsLessThanPrice() external whenItemIsListed {
        // It should revert with {InsufficientPayment}

        vm.prank({msgSender: bob});
        vm.expectRevert(abi.encodeWithSelector(INftMarketPlace.InsufficientPayment.selector, 1 ether, 0.5 ether));
        nftm.buyItem{value: 0.5 ether}(mockNft, token1);
    }

    function test_WhenMsgValueIsSufficient() external whenItemIsListed {
        // It should remove the listing
        // It should transfer the nft to the buyer
        // It should add the msg value to proceeds for the seller
        // It should emit {ItemBought} event

        // validate seller is the owner pre buyItem
        address prevOwner = MockNft(mockNft).ownerOf(token1);
        assertEq(prevOwner, alice);

        // validate marketplace balance
        uint256 marketplacePrevBalance = address(nftm).balance;
        assertEq(marketplacePrevBalance, 0);

        vm.prank({msgSender: bob});

        vm.expectEmit();
        emit INftMarketPlace.ItemBought(mockNft, token1, bob, 1 ether);
        nftm.buyItem{value: 1 ether}(mockNft, token1);

        // nft transfered
        address newOwner = MockNft(mockNft).ownerOf(token1);
        assertEq(newOwner, bob);

        // price paid
        uint256 marketplaceAfterBalance = address(nftm).balance;
        assertEq(marketplaceAfterBalance, 1 ether);

        // proceeds added
        assertEq(nftm.proceeds(alice), 1 ether);

        /// listing removed
        (address seller, uint256 price) = getSellerAndPrice(mockNft, token1);
        assertEq(seller, address(0));
        assertEq(price, 0);
    }

    function testGas_buyItem() external whenItemIsListed {
        vm.prank({msgSender: bob});
        nftm.buyItem{value: 1 ether}(mockNft, token1);
        vm.snapshotGasLastCall("buyItem");
    }
}
