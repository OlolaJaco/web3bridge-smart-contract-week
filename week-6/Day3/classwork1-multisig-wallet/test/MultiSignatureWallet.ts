import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("MultiSignatureWallet", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  const deployMultiSignatureWalletFixture = async () => {

    // Contracts are deployed using the first signer/account by default
    const [owner, addr1, addr2, addr3] = await hre.ethers.getSigners();

    const owners = [addr1.address, addr2.address, addr3.address, owner.address];


    const myMultiSignatureWallet = await hre.ethers.deployContract("MultiSignatureWallet", [owners]);


    return { myMultiSignatureWallet, owner, addr1, addr2, addr3 };
  }

  it("Should be able to deposit ether", async () => {
    const { myMultiSignatureWallet } = await loadFixture(deployMultiSignatureWalletFixture);

    const depositAmount = hre.ethers.parseEther("100");

    await myMultiSignatureWallet.depositFunds({ value: depositAmount });

    expect( await myMultiSignatureWallet.contractBalance()).to.equals(depositAmount);
  });

  it("should make withdrawal request", async () => {
    const { myMultiSignatureWallet, addr1 } = await loadFixture(deployMultiSignatureWalletFixture);

    const depositAmount = hre.ethers.parseEther("100");

    await myMultiSignatureWallet.depositFunds({ value: depositAmount });

    const withdrawalAmount = hre.ethers.parseEther("10");

    await expect ( myMultiSignatureWallet.withdrawalRequest(withdrawalAmount, addr1.address)).to.emit(myMultiSignatureWallet, "WithdrawalRequested").withArgs(1, addr1.address, withdrawalAmount);

    const txn = await myMultiSignatureWallet.transactions(1);
    expect(txn.txnId).to.equals(1);
    expect(txn.recipient).to.equals(addr1.address);
    expect(txn.amount).to.equals(withdrawalAmount);
    expect(txn.approvalCount).to.equals(0);
    expect(txn.approved).to.equals(false);
    expect(txn.executed).to.equals(false);

  })

  it("should approve withdrawal requests", async () => {
    const { myMultiSignatureWallet, owner, addr1, addr2, addr3 } = await loadFixture(deployMultiSignatureWalletFixture);

    const depositAmount = hre.ethers.parseEther("100");

    await myMultiSignatureWallet.depositFunds({ value: depositAmount });

    const withdrawalAmount = hre.ethers.parseEther("10");

    await expect ( myMultiSignatureWallet.withdrawalRequest(withdrawalAmount, addr1.address)).to.emit(myMultiSignatureWallet, "WithdrawalRequested").withArgs(1, addr1.address, withdrawalAmount);

    await expect ( myMultiSignatureWallet.approveWithdrawalRequest(1)).to.emit(myMultiSignatureWallet, "Approval").withArgs(1, owner);
    
    const txn = await myMultiSignatureWallet.transactions(1);
    expect(txn.txnId).to.equals(1);
    expect(txn.approved).to.equals(false);
    expect(txn.executed).to.equals(false);

    await myMultiSignatureWallet.connect(addr2).approveWithdrawalRequest(1);
    await myMultiSignatureWallet.connect(addr3).approveWithdrawalRequest(1);

    const txnAfter = await myMultiSignatureWallet.transactions(1);
    expect(txnAfter.approvalCount).to.equal(3);
    expect(txnAfter.approved).to.equal(true);

  })

  it("should revert withdrawal if txn is not approved yet", async () => {
  const { myMultiSignatureWallet, addr1 } = await loadFixture(deployMultiSignatureWalletFixture);

  const depositAmount = hre.ethers.parseEther("100");
  const withdrawalAmount = hre.ethers.parseEther("10");

  await myMultiSignatureWallet.depositFunds({ value: depositAmount });
  await myMultiSignatureWallet.withdrawalRequest(withdrawalAmount, addr1.address);

  await expect(myMultiSignatureWallet.withdrawFunds(1)).to.be.revertedWith(
    "Transaction not approved yet"
  );
});

it("should withdraw funds after required approvals", async () => {
  const { myMultiSignatureWallet, addr1, addr2, addr3, owner } =
    await loadFixture(deployMultiSignatureWalletFixture);

  const depositAmount = hre.ethers.parseEther("100");
  const withdrawalAmount = hre.ethers.parseEther("10");

  await myMultiSignatureWallet.depositFunds({ value: depositAmount });
  await myMultiSignatureWallet.withdrawalRequest(withdrawalAmount, addr1.address);

  await myMultiSignatureWallet.connect(owner).approveWithdrawalRequest(1);
  await myMultiSignatureWallet.connect(addr2).approveWithdrawalRequest(1);
  await myMultiSignatureWallet.connect(addr3).approveWithdrawalRequest(1);

  await expect(myMultiSignatureWallet.connect(addr2).withdrawFunds(1))
    .to.emit(myMultiSignatureWallet, "WithdrawalExecuted")
    .withArgs(1, addr1.address, withdrawalAmount);

  await expect(
    myMultiSignatureWallet.connect(addr2).withdrawFunds(1)
  ).to.be.reverted; // optional safety check on second call in your current logic

  const txn = await myMultiSignatureWallet.transactions(1);
  expect(txn.executed).to.equal(true);
  expect(await myMultiSignatureWallet.contractBalance()).to.equal(
    depositAmount - withdrawalAmount
  );
});

});
