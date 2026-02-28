// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract MultiSignatureWallet {


  struct Transaction {
    uint txnId;
    uint approvalCount;
    uint amount;
    bool approved;
  }
    

    address[] public  owners;

    Transaction[] withdrawalRequests;

    mapping (address => mapping(uint => bool)) votedOwner;

    uint public txn_id;



    //constructor that sets original owners
    constructor(address[] memory _owners) {
      require(_owners.length >= 3, "All least three owners needed");

      owners = _owners;
    }

    // anyone should be able to pay to the contract
    function depositFunds() external payable   {
      require(msg.value > 0, "amount must be greater than zero");
    }

    // widrawal request made and moves to the pool
    function withdrawalRequest( uint _amount) external {
      txn_id = txn_id + 1;

      Transaction memory transaction = Transaction({ txnId: txn_id, approvalCount: 0, approved: false, amount: _amount });

      withdrawalRequests.push(transaction);

      txn_id = txn_id + 1;

    }

    // owners get to approve requests
    function approveWithdrawalRequest(uint _txn) external  {

      for (uint i; i < withdrawalRequests.length; i++) 
      {
      require(withdrawalRequests[i].txnId == _txn, "Transaction does not exist");

      if(!votedOwner[msg.sender][withdrawalRequests[i].txnId = _txn]){
        withdrawalRequests[i].approvalCount = withdrawalRequests[i].approvalCount + 1 ;

        withdrawalRequests[i].approvalCount >= 3 ? withdrawalRequests[i].approved = true:  false ;
      }
      }

      withdrawFunds();

    }

    
    // withdraw transaction
    function withdrawFunds() private {
        for (uint i; i < withdrawalRequests.length; i++) 
      {
          if (withdrawalRequests[i].approved == true ) {
            (bool success, ) = payable(msg.sender).call{ value: withdrawalRequests[i].amount }(" ");
            require(success);
          }
      }
    }



    function contractBalance() external view returns(uint) {
      return address(this).balance;
    }

    
      fallback() external payable { }
      receive() external payable { }

}