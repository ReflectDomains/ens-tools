// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers} = require("hardhat");

const usdtAddress = "0x80258a9230383763E2A1ECa4B5675b49fdBEECbd";
const proxy_address = "0x95D6eFC280420dC124aC6AC5732793F9F06b225f"
const feePercentage = 3;

async function main() {
    // deploy controller
    const Controller = await ethers.getContractFactory("Controller");
    const controller = await Controller.deploy(feePercentage, proxy_address, [usdtAddress]);
    console.log("controller address: ", controller.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
