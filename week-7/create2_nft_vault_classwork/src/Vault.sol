// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Vault {
    address public immutable token;
    address public immutable factory;
    uint public totalDeposited;
    mapping (address => uint) public deposits;

    event Deposited(address indexed user, uint amount);

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    constructor(address _token, address _factory) {
        token = _token;
        factory = _factory;
    }

    // can only be called by factory during vault creation
    // Tokens are already transferred by the factory before calling this
    function depositFromFactory(address user, uint amount) external onlyFactory {
        totalDeposited += amount;
        deposits[user] += amount;
        emit Deposited(user, amount);
    }

    // Public deposit function for later additions
    function deposit(uint amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        totalDeposited += amount;
        deposits[msg.sender] += amount;
        emit Deposited (msg.sender, amount);
    }

}