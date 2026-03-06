const helpers = require("@nomicfoundation/hardhat-network-helpers");
import { ethers } from "hardhat";

const main = async () => {
  const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";  //Address for Token A
  const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F"; // Address for Token B
  const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D"; // Uinswap Address
  const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621"; // EOA with live money

  await helpers.impersonateAccount(USDCHolder); // funtions to inpersonnate the EOA
  const impersonatedSigner = await ethers.getSigner(USDCHolder); // variable of the EOA

  const amountUSDC = ethers.parseUnits("10000", 6); // Amount Desired for address A
  const amountDAI = ethers.parseUnits("10000", 18); // Amount Desired for address B
  const amountUSDCMin = ethers.parseUnits("9000", 6); // Amount expected after slippage tolerance (Stop loss)
  const amountDAIMin = ethers.parseUnits("9000", 18); // Amount expected after slippage tolerance (Stop loss)
  const deadline = Math.floor(Date.now() / 1000) + 60 * 10; // Deadline of 10 Minutes


  // Contract Instances
  const USDC = await ethers.getContractAt( "IERC20", USDCAddress, impersonatedSigner ); 
  const DAI = await ethers.getContractAt( "IERC20", DAIAddress, impersonatedSigner );
  const ROUTER = await ethers.getContractAt( "IUniswapV2Router", UNIRouter, impersonatedSigner );

  // Approving Uniswap to spend from the wallet
  await USDC.approve(UNIRouter, amountUSDC);
  await DAI.approve(UNIRouter, amountDAI);

  // Getting the balance of the inpersonated signer before the swap
  const usdcBalBefore = await USDC.balanceOf(impersonatedSigner.address);
  const daiBalBefore = await DAI.balanceOf(impersonatedSigner.address);
  console.log(
    "=================Before========================================"
  );

  console.log("USDC Balance before adding liquidity:", Number(usdcBalBefore));
  console.log("DAI Balance before adding liquidity:", Number(daiBalBefore));

  // Calling the main addLiquidity function arguments from the interface
  const tx = await ROUTER.addLiquidity(
    USDCAddress,
    DAIAddress,
    amountUSDC,
    amountDAI,
    amountUSDCMin,
    amountDAIMin,
    impersonatedSigner.address,
    deadline
  );

  await tx.wait(); // calling it

  // Getting the balances after the swap
  const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
  const daiBalAfter = await DAI.balanceOf(impersonatedSigner.address);
  console.log("=================After========================================");
  console.log("USDC Balance after adding liquidity:", Number(usdcBalAfter));
  console.log("DAI Balance after adding liquidity:", Number(daiBalAfter));

  console.log("Liquidity added successfully!");
  console.log("=========================================================");
  const usdcUsed = usdcBalBefore - usdcBalAfter;
  const daiUsed = daiBalBefore - daiBalAfter;

  console.log("USDC USED:", ethers.formatUnits(usdcUsed, 6));
  console.log("DAI Rec:", ethers.formatUnits(daiUsed, 18));
};

// The whole script is initilized
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
