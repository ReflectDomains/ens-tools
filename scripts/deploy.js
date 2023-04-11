// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const ensAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";
const registrarAddress = "0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85";
const feePercentage = 3;

async function main() {
    const Proxy = await hre.ethers.getContractFactory("Proxy");
    const proxy = await Proxy.deploy(ensAddress, registrarAddress);

    await proxy.deployed();
    console.log("proxy address: ", proxy.address);

    const Controller = await hre.ethers.getContractFactory("Controller");
    const controller = await Controller.deploy(feePercentage, proxy.address);
    await controller.deployed();
    console.log("controller address: ", controller.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
