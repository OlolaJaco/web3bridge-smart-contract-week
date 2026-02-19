// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyERC20 {

    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    address public owner;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;
    }

    // Implementing Minting to a new address and increasing the total supply 
    function mint(address to, uint256 amount) public {
        require(msg.sender == owner, "Only owner can mint new token ");
        totalSupply = totalSupply + amount;
        balanceOf[to] = balanceOf[to] + amount;
    }

    // Adding Basic Transfer
    function transfer(address to, uint256 amount) public returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient balance");
        require(to != address(0), "Address zero detected");
        balanceOf[msg.sender] = balanceOf[msg.sender] - amount;
        balanceOf[to] = balanceOf[to] + amount;
        return true;
    }

    // Handling approval and allowing spender transfer on your behalf

    function approve( address spender, uint256 amount ) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        require(balanceOf[from] >= amount, "Insufficient balance");
        require(to != address(0), "Address zero detected");
        if (msg.sender != from ) {
            require(allowance[from][msg.sender] >= amount, "Insufficinet allowance");
            allowance[from][msg.sender] -= amount;
        }        
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }

}