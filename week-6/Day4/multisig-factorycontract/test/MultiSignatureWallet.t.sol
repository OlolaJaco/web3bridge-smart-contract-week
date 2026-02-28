// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {MultiSignatureWallet} from "../src/MultiSignatureWallet.sol";

contract MultiSignatureWalletTest is Test {
    MultiSignatureWallet wallet;

    address owner1 = vm.addr(1);
    address owner2 = vm.addr(2);
    address owner3 = vm.addr(3);
    address user = vm.addr(4);

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiSignatureWallet(owners);
    }

    function testConstructorStoresOwners() public view {
        assertEq(wallet.owners(0), owner1);
        assertEq(wallet.owners(1), owner2);
        assertEq(wallet.owners(2), owner3);
    }

    function testConstructorRevertsIfOwnersAreLessThanThree() public {
        address[] memory owners = new address[](2);
        owners[0] = owner1;
        owners[1] = owner2;

        vm.expectRevert("All least three owners needed");
        new MultiSignatureWallet(owners);
    }

    function testDepositFundsRevertsOnZeroAmount() public {
        vm.prank(user);
        vm.expectRevert("amount must be greater than zero");
        wallet.depositFunds{value: 0}();
    }

    function testDepositFundsIncreasesContractBalance() public {
        vm.deal(user, 5 ether);

        vm.prank(user);
        wallet.depositFunds{value: 2 ether}();

        assertEq(wallet.contractBalance(), 2 ether);
    }

    function testWithdrawalRequestIncrementsTxnIdByTwo() public {
        vm.prank(user);
        wallet.withdrawalRequest(1 ether);

        // In current contract logic txn_id is incremented twice per request.
        assertEq(wallet.txn_id(), 2);
    }

    function testApproveWithdrawalRevertsForUnknownTransactionId() public {
        vm.prank(user);
        wallet.withdrawalRequest(1 ether);

        vm.prank(user);
        vm.expectRevert("Transaction does not exist");
        wallet.approveWithdrawalRequest(999);
    }

    function testApproveThreeTimesBySameAddressTriggersWithdrawal() public {
        vm.deal(user, 5 ether);
        vm.prank(user);
        wallet.depositFunds{value: 3 ether}();

        vm.prank(user);
        wallet.withdrawalRequest(1 ether);

        address attacker = vm.addr(99);
        uint256 startBalance = attacker.balance;

        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);
        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);
        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);

        assertEq(attacker.balance, startBalance + 1 ether);
        assertEq(address(wallet).balance, 2 ether);
    }

    function testApprovedTransactionCanBeWithdrawnMoreThanOnce() public {
        vm.deal(user, 5 ether);
        vm.prank(user);
        wallet.depositFunds{value: 3 ether}();

        vm.prank(user);
        wallet.withdrawalRequest(1 ether);

        address attacker = vm.addr(100);
        uint256 startBalance = attacker.balance;

        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);
        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);
        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);
        vm.prank(attacker);
        wallet.approveWithdrawalRequest(1);

        assertEq(attacker.balance, startBalance + 2 ether);
        assertEq(address(wallet).balance, 1 ether);
    }
}
