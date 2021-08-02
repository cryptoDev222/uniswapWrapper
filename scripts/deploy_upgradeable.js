const { ethers, upgrades } = require("hardhat");

async function main() {
  const [account] = await ethers.getSigners();

  const Wrapper = await ethers.getContractFactory("UniSwap3Wrapper");
  const wrapper = await upgrades.deployProxy(Wrapper, [account.address], {
    initializer: "initiate",
  });

  await wrapper.deployed();

  console.log("Wrapper deployed to:", org.address);
}

main();
