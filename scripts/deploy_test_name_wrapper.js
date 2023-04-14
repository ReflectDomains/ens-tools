const {ethers} = require("hardhat");

const nwAddress = "0x114D4603199df73e7D157787f8778E21fCd13066";

async function main() {
    // deploy controller
    const TNW = await ethers.getContractFactory("TestNameWrapper");
    const testNameWrapper = await TNW.deploy(nwAddress);
    console.log("TestNameWrapper address: ", testNameWrapper.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});