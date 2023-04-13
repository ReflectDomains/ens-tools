const {ethers} = require("hardhat");

const usdtAddress = "0x80258a9230383763E2A1ECa4B5675b49fdBEECbd";
const owner = "0xf15e0eDf9f53B06671bDD4F48E014eb2048E1986"
const beneficiary = "0x3c37496E4cB8cc14913caDec6dD3EBf828f19C51"
const resolver = "0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750"
const proxy_address = "0x66694ed0C6d6ec887fD15D88550887A0db27F6E0"
const controller_address = "0x28C497d63243D73B32ad32f9F5b277fD0B38f0EB"
// const controller_address = "0xBC2697d7A9E44f115719D6Bb2642bBa10460425F"

pricingHash = function (label, token) {
    const hash = ethers.utils.keccak256(
        ethers.utils.solidityPack(["string", "address"], [label, token])
    );

    return ethers.utils.hexlify(hash);
}

async function main() {
    const [signer] = await ethers.getSigners();
    const Controller = await ethers.getContractFactory("Controller");
    const controller = await Controller.attach(controller_address).connect(signer);
    const USDT = await ethers.getContractFactory("TestUSDT");
    const usdt = await USDT.attach(usdtAddress).connect(signer);

    // const usdtPricingHash = pricingHash("hellogolang", usdtAddress);
    // console.log("node usdt pricing: ", await controller.getPricing([usdtPricingHash]));
    const pricing = [
        {
            "mode": 1,
            "token": usdt.address,
            "prices": [ethers.BigNumber.from(30000), ethers.BigNumber.from(20000), ethers.BigNumber.from(10000)],
        },
    ]

    await controller.openRegister("hellogolang", beneficiary, pricing);
    await usdt.mint(signer.address, 30000);
    await usdt.approve(controller.address, 30000);
    await controller.registerSubdomain("hellogolang", "ruby", beneficiary, resolver, 0, usdt.address, 20000);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});