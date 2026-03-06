const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {

    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";  //Address for Token A
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // Address for Token B
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Uinswap Address
    const USDCHolder = "0xf584F8728B874a6a5c7A8d4d387C9aae9172D621"; // EOA with live money


    await helpers.impersonateAccount(USDCHolder);

    const impersonatedSigner = await ethers.getSigner(USDCHolder);

    const amountUSDC = ethers.parseUnits("10000", 6); // Amount Desired for address A
  const amountDAIMin = ethers.parseUnits("9000", 18); // Amount expected after slippage tolerance (Stop loss)

    const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // Deadline of 10 Minutes


    const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner );
    const DAI = await ethers.getContractAt( "IERC20", DAIAddress, impersonatedSigner );
    const ROUTER = await ethers.getContractAt( "IUniswapV2Router", UNIRouter, impersonatedSigner );


    // Approving uniswap to spend from the wallet
    await USDC.approve(UNIRouter, amountUSDC);
    // await DAI.approve(UNIRouter, amountDAIMin);

    // Getting the balance of the impersonated signer before the swap
    const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
    const daiBalBefore = await DAI.balanceOf(impersonatedSigner.address);

    const path = [USDCAddress, DAIAddress]

    console.log("==========BEFORE==========");
    console.log("USDC Balance befoe adding liquidity:", ethers.formatUnits(usdcBalBefore, 6));
    console.log("DAI Balance before adding liquidity:", ethers.formatUnits(daiBalBefore, 18));

    const tx = await ROUTER.swapExactTokensForTokens( amountUSDC, amountDAIMin, path, impersonatedSigner.address, deadline);

    await tx.wait();

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    const daiBalAfter = await DAI.balanceOf(impersonatedSigner.address);

    console.log("==========AFTER==========");
    console.log("USDC Balance after adding liquidity:", ethers.formatUnits(usdcBalAfter, 6));
  console.log("DAI Balance after adding liquidity:", ethers.formatUnits(daiBalAfter, 18));

  console.log("Liquidity added successfully!");
  console.log("=========================================================");
  const usdcUsed = usdcBalBefore - usdcBalAfter;
  const daiUsed = daiBalAfter - daiBalBefore;

  console.log("USDC USED:", ethers.formatUnits(usdcUsed, 6));
  console.log("DAI USED:", ethers.formatUnits(daiUsed, 18));
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
})