// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiSignatureWallet {
    struct Transaction {
        uint txnId;
        address payable recipient;
        uint approvalCount;
        uint amount;
        bool approved;
        bool executed;
    }

    address[] public owners;

    mapping(uint => Transaction) public transactions;

    mapping(uint => mapping(address => bool)) votedOwner;

    mapping(address => bool) isOwner;

    uint[] public txn_id;

    uint public nextTxnId = 1;

    uint public requiredApprovals;

    // --> Events
    event Deposit(address indexed sender, uint amount);
    event WithdrawalRequested(
        uint indexed txn,
        address indexed recipient,
        uint amount
    );
    event Approval(uint indexed txnId, address indexed sender);
    event WithdrawalExecuted(
        uint indexed txn,
        address indexed recipient,
        uint amount
    );

    // --> Modifiers
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner of this contract");
        _;
    }

    modifier transactionExists(uint _txn) {
        require(_txn > 0 && _txn < nextTxnId, "Transaction does not exist");
        _;
    }

    modifier notExecuted(uint _txn) {
        require(!transactions[_txn].executed, " Transaction already executed");
        _;
    }

    modifier notApprovedBySender(uint _txn) {
        require(!votedOwner[_txn][msg.sender], "Already voted");
        _;
    }

    //constructor that sets original owners
    constructor(address[] memory _owners) {
        require(_owners.length >= 3, "All least three owners needed");

        owners = _owners;

        for (uint i = 0; i < _owners.length; i++) {
            isOwner[_owners[i]] = true;
        }

        requiredApprovals = (owners.length / 2) + 1;
    }

    // anyone should be able to pay to the contract
    function depositFunds() external payable {
        require(msg.value > 0, "amount must be greater than zero");
        emit Deposit(msg.sender, msg.value);
    }

    // widrawal request made and moves to the pool
    function withdrawalRequest(
        uint _amount,
        address payable _recipient
    ) external onlyOwner {
        require(_amount > 0, "Amount must be geater than Zero");
        require(address(this).balance > 0, "Insufficient contract Balance");

        uint txnId_ = nextTxnId++;

        transactions[txnId_] = Transaction({
            txnId: txnId_,
            recipient: _recipient,
            approvalCount: 0,
            approved: false,
            amount: _amount,
            executed: false
        });

        emit WithdrawalRequested(txnId_, _recipient, _amount);
    }

    // owners get to approve requests
    function approveWithdrawalRequest(
        uint _txn
    )
        external
        onlyOwner
        transactionExists(_txn)
        notExecuted(_txn)
        notApprovedBySender(_txn)
    {
        Transaction storage txn = transactions[_txn];
        votedOwner[_txn][msg.sender] = true;
        txn.approvalCount++;

        emit Approval(_txn, msg.sender);

        if (txn.approvalCount >= requiredApprovals) {
            txn.approved = true;
        }
    }

    // withdraw transaction
    function withdrawFunds(uint _txn) external {
        Transaction storage txn = transactions[_txn];
        require(txn.approved, "Transaction not approved yet");

        txn.executed = true;

        (bool success, ) = payable(txn.recipient).call{value: txn.amount}(" ");
        require(success, "Transfer failed");

        emit WithdrawalExecuted(_txn, txn.recipient, txn.amount);
    }

    function contractBalance() external view returns (uint) {
        return address(this).balance;
    }

    fallback() external payable {}

    receive() external payable {}
}
