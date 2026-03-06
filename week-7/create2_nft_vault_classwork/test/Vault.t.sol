// test/Vault.t.sol
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VaultFactory.sol";
import "../src/VaultNFT.sol";
import "../src/Vault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract VaultTest is Test {
    VaultFactory factory;
    VaultNFT nft;

    // Mainnet token addresses
    address constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address constant DAI  = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    // A known USDC whale (Binance hot wallet) – you may need to update this if balance changes
    address constant WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;

    address user = address(0x1234);

    function setUp() public {
        // Fork mainnet at a recent block (you can adjust block number if needed)
        vm.createSelectFork("mainnet", 17_000_000);

        // Deploy NFT and Factory
        nft = new VaultNFT();
        factory = new VaultFactory(address(nft));
        nft.setFactory(address(factory));

        // Give user some USDC from whale
        vm.startPrank(WHALE);
        IERC20(USDC).transfer(user, 1000 * 10**6); // 1000 USDC (6 decimals)
        vm.stopPrank();
    }

    function testCreateVault() public {
        uint256 amount = 100 * 10**6; // 100 USDC

        vm.startPrank(user);
        IERC20(USDC).approve(address(factory), amount);
        address vault = factory.createVault(USDC, amount);
        vm.stopPrank();

        // Vault deployed and recorded
        assertTrue(vault.code.length > 0);
        assertEq(factory.tokenToVault(USDC), vault);

        // Check vault state
        Vault v = Vault(vault);
        assertEq(v.totalDeposited(), amount);
        assertEq(v.deposits(user), amount);

        // NFT minted
        uint256 tokenId = 1; // first mint
        assertEq(nft.ownerOf(tokenId), user);
        assertEq(nft.tokenAddressOf(tokenId), USDC);
        assertEq(nft.vaultAddressOf(tokenId), vault);

        // Optional: log tokenURI to see the SVG
        string memory uri = nft.tokenURI(tokenId);
        console.log("NFT metadata URI:", uri);
    }

    function testDepositAgain() public {
        // First create vault with 100 USDC
        uint256 initial = 100 * 10**6;
        vm.startPrank(user);
        IERC20(USDC).approve(address(factory), initial);
        address vault = factory.createVault(USDC, initial);

        // Then deposit additional 50 USDC directly to vault
        uint256 extra = 50 * 10**6;
        IERC20(USDC).approve(vault, extra);
        Vault(vault).deposit(extra);
        vm.stopPrank();

        Vault v = Vault(vault);
        assertEq(v.totalDeposited(), initial + extra);
        assertEq(v.deposits(user), initial + extra);
    }

    function testCannotCreateSameTokenTwice() public {
        uint256 amount = 100 * 10**6;
        vm.startPrank(user);
        IERC20(USDC).approve(address(factory), amount);
        factory.createVault(USDC, amount);

        // Second attempt should revert
        vm.expectRevert("Vault already exists");
        factory.createVault(USDC, amount);
        vm.stopPrank();
    }
}