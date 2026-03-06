// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

interface IVault {
    function totalDeposited() external view returns (uint256);

    function token() external view returns (address);
}

contract VaultNFT is ERC721, Ownable {
    using Strings for uint256;
    using Strings for address;

    address public factory;
    uint256 private _nextTokenId = 1;
    mapping(uint256 => address) public tokenAddressOf;
    mapping(uint256 => address) public vaultAddressOf;

    modifier onlyFactory() {
        require(msg.sender == factory, "Only factory");
        _;
    }

    constructor() ERC721("VaultNFT", "vNFT") Ownable(msg.sender) {}

    function setFactory(address _factory) external onlyOwner {
        factory = _factory;
    }

    function mint(
        address to,
        address token,
        address vault
    ) external onlyFactory returns (uint256 tokenId) {
        tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        tokenAddressOf[tokenId] = token;
        vaultAddressOf[tokenId] = vault;
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(_ownerOf(tokenId) != address(0), "Nonexistent token");

        address token = tokenAddressOf[tokenId];
        address vault = vaultAddressOf[tokenId];
        uint256 total = IVault(vault).totalDeposited();
        string memory symbol = IERC20Metadata(token).symbol();
        string memory name = IERC20Metadata(token).name();
        uint8 decimals = IERC20Metadata(token).decimals();

        // Format total with decimals (simple: show as integer part)
        string memory totalFormatted = (total / 10 ** decimals).toString();

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 250">',
                '<defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">'
                '<stop offset="0%" style="stop-color:#1a1a2e"/>'
                '<stop offset="100%" style="stop-color:#16213e"/>'
                "</linearGradient></defs>",
                '<rect width="400" height="250" fill="url(#bg)" rx="20"/>',
                '<rect x="10" y="10" width="380" height="230" rx="15" fill="none" stroke="#e94560" stroke-width="2"/>',
                _buildSvgText(name, symbol, token, vault, totalFormatted),
                "</svg>"
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Vault NFT #',
                        tokenId.toString(),
                        '", "description": "NFT representing a vault for a specific ERC20 token.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(svg)),
                        '"}'
                    )
                )
            )
        );

        return string(abi.encodePacked("data:application/json;base64,", json));
    }

    function _buildSvgText(
        string memory name,
        string memory symbol,
        address token,
        address vault,
        string memory totalFormatted
    ) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<text x="200" y="50" font-family="Arial" font-size="18" fill="#e94560" text-anchor="middle" font-weight="bold">Vault for ',
                name,
                " (",
                symbol,
                ")</text>",
                '<text x="200" y="90" font-family="monospace" font-size="11" fill="#a8a8b3" text-anchor="middle">Token: ',
                token.toHexString(),
                "</text>",
                '<text x="200" y="120" font-family="monospace" font-size="11" fill="#a8a8b3" text-anchor="middle">Vault: ',
                vault.toHexString(),
                "</text>",
                '<text x="200" y="170" font-family="Arial" font-size="22" fill="#0f3460" text-anchor="middle" font-weight="bold">',
                totalFormatted,
                " ",
                symbol,
                "</text>",
                '<text x="200" y="210" font-family="Arial" font-size="12" fill="#e94560" text-anchor="middle">Total Deposited</text>'
            )
        );
    }
}
