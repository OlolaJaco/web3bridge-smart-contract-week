// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Vault.sol";
import "./VaultNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultFactory {
    address public immutable nft;
    mapping(address => address) public tokenToVault; // token => vault

    event VaultCreated(address indexed token, address indexed vault, address indexed creator, uint256 tokenId);

    constructor(address _nft) {
        nft = _nft;
    }

    function createVault(address token, uint256 initialDeposit) external returns (address vault) {
        require(token != address(0), "Zero token");
        require(initialDeposit > 0, "Zero deposit");

        bytes32 salt = keccak256(abi.encodePacked(token));
        // Compute expected address to check existence
        bytes memory bytecode = abi.encodePacked(type(Vault).creationCode, abi.encode(token, address(this)));
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode))
        );
        address predicted = address(uint160(uint(hash)));
        require(predicted.code.length == 0, "Vault already exists");

        // Deploy with CREATE2
        vault = address(new Vault{salt: salt}(token, address(this)));

        // Transfer initial deposit from user to vault
        IERC20(token).transferFrom(msg.sender, vault, initialDeposit);

        // Update vault's internal accounting
        Vault(vault).depositFromFactory(msg.sender, initialDeposit);

        // Mint NFT
        uint256 tokenId = VaultNFT(nft).mint(msg.sender, token, vault);

        tokenToVault[token] = vault;
        emit VaultCreated(token, vault, msg.sender, tokenId);
    }

    // Helper to get the deterministic vault address without deploying
    function getVaultAddress(address token) external view returns (address) {
        bytes32 salt = keccak256(abi.encodePacked(token));
        bytes memory bytecode = abi.encodePacked(type(Vault).creationCode, abi.encode(token, address(this)));
        bytes32 hash = keccak256(
            abi.encodePacked(bytes1(0xff), address(this), salt, keccak256(bytecode))
        );
        return address(uint160(uint(hash)));
    }
}