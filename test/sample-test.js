const { expect } = require("chai");
const { forkFrom } = require("../forkFrom");
const { Signer } = require("ethers");

describe("Wrapper", function () {
  let uniSwap3Wrapper;
  let account;

  before(async function () {
    [account] = await ethers.getSigners();
    this.timeout(60000);
    await forkFrom(12926077);

    const UniSwap3Wrapper = await ethers.getContractFactory("UniSwap3Wrapper");
    uniSwap3Wrapper = await UniSwap3Wrapper.deploy();
    await uniSwap3Wrapper.deployed();
    console.log("uniSwap3Wrapper deployed to:", uniSwap3Wrapper.address);
  });

  it("Should Mint successfully", async function () {
    await uniSwap3Wrapper.initiate(account.address);
    await uniSwap3Wrapper.mint({
      token0: account.address,
      token1: account.address,
      fee: 50,
      tickLower: 30,
      tickUpper: 20,
      amount0Desired: 20,
      amount1Desired: 20,
      amount0Min: 2,
      amount1Min: 2,
      deadline: 60000000000,
    });
  }).timeout(600000);
});
