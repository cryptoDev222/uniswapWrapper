const { ethers, upgrades } = require("hardhat");

async function main() {
  const OrgV2 = await ethers.getContractFactory("UniSwap3WrapperV2");
  console.log("Upgrading Wrapper...");

  await upgrades.upgradeProxy(
    "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0",
    OrgV2
  ); //TO-DO: should change it to upgradable contract deployed address

  console.log("Wrapper upgraded");
}

main();