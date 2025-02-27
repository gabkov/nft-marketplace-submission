// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "../../../NftMarketplace.t.sol";

contract WithdrawProceedsTest is NftMarketplaceTest {
    function setUp() public override {
        super.setUp();

        vm.startPrank({msgSender: alice});
    }

    function test_WhenProceedsBalanceIs0() external {
        // It should revert with {NoProceeds}

        vm.expectRevert(abi.encodeWithSelector(INftMarketplace.NoProceeds.selector, alice));
        nftm.withdrawProceeds();
    }

    modifier whenProceedsBalanceIsGreaterThan0() {
        MockNft(mockNft).approve(address(nftm), token1);
        nftm.listItem(mockNft, token1, 1 ether);

        vm.stopPrank();

        vm.prank({msgSender: bob});
        nftm.buyItem{value: 1 ether}(mockNft, token1);

        vm.startPrank({msgSender: alice});
        _;
    }

    function test_WhenTheTransferToTheCallerFails() external whenProceedsBalanceIsGreaterThan0 {
        // It should revert with {WithdrawFailed}

        // set alice's balance to the maximum possible value so overflow will trigger a revert
        vm.deal(alice, type(uint256).max);

        vm.expectRevert(INftMarketplace.WithdrawFailed.selector);
        nftm.withdrawProceeds();
    }

    function test_WhenTheTransferIsSuccessful() external whenProceedsBalanceIsGreaterThan0 {
        // It should delete proceeds for the caller
        // It should send the correct amount to the caller
        // It should emit {ProceedsWithdrawn} event

        // validate proceeds and balance
        assertEq(nftm.proceeds(alice), 1 ether);

        uint256 preBalance = alice.balance;
        assertEq(preBalance, 10 ether);

        vm.expectEmit();
        emit INftMarketplace.ProceedsWithdrawn(alice, 1 ether);
        nftm.withdrawProceeds();

        assertEq(nftm.proceeds(alice), 0 ether);

        uint256 afterBalance = alice.balance;
        assertEq(afterBalance, preBalance + 1 ether);
    }

    function testGas_withdrawProceeds() external whenProceedsBalanceIsGreaterThan0 {
        nftm.withdrawProceeds();
        vm.snapshotGasLastCall("withdrawProceeds");
    }
}
