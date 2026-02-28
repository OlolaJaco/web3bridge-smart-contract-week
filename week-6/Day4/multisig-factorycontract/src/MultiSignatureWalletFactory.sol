// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSignatureWallet.sol";  // adjust the path if needed

contract MultiSignatureWalletFactory {
    // Array to keep track of all deployed multisig contracts
    address[] public deployedMultisigs;

    // Event emitted when a new multisig is created
    event MultisigCreated(address indexed multisigAddress, address[] owners);

    // Deploy a new Multisig contract
    function createMultisig(address[] calldata _owners) external returns (address) {
        // Deploy a new instance of Multisig
        MultiSignatureWallet newMultisig = new MultiSignatureWallet(_owners);
        
        // Get the address of the newly deployed contract
        address multisigAddress = address(newMultisig);
        
        // Store it (optional)
        deployedMultisigs.push(multisigAddress);
        
        // Emit an event
        emit MultisigCreated(multisigAddress, _owners);
        
        return multisigAddress;
    }

    // Get all deployed multisig addresses (read‑only)
    function getDeployedMultisigs() external view returns (address[] memory) {
        return deployedMultisigs;
    }
}