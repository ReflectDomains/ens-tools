// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const {ethers} = require("hardhat");

const ensAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";
const registrarAddress = "0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85";
const nameWrapperAddress = "0x114D4603199df73e7D157787f8778E21fCd13066"
const usdtAddress = "0x80258a9230383763E2A1ECa4B5675b49fdBEECbd";
const feePercentage = 3;

async function main() {
    // deploy usdt
    // const USDT = await ethers.getContractFactory("TestUSDT");
    // const usdt = await USDT.deploy("REFLECT-USDT", "REFLECT-USDT");
    // console.log("usdt address: ", usdt.address);
    // deploy proxy
    const Proxy = await ethers.getContractFactory("Proxy");
    const proxy = await Proxy.deploy(ensAddress, registrarAddress, nameWrapperAddress);
    console.log("proxy address: ", proxy.address);
    // deploy controller
    const Controller = await ethers.getContractFactory("Controller");
    const controller = await Controller.deploy(feePercentage, proxy.address, [usdtAddress]);
    console.log("controller address: ", controller.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
