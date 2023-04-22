const {ethers} = require("hardhat");

const usdtAddress = "0x80258a9230383763E2A1ECa4B5675b49fdBEECbd";
const owner = "0xf15e0eDf9f53B06671bDD4F48E014eb2048E1986"
const beneficiary = "0x3c37496E4cB8cc14913caDec6dD3EBf828f19C51"
const resolver = "0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750"
const proxy_address = "0x3dED020313b2a22875cbeB57dEb55F3b6aa10914"
const controller_address = "0xE34cBa16DA84B8167162972eB4460657cCDCB696"

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
    const Proxy = await ethers.getContractFactory("Proxy");
    const proxy = await Proxy.attach(proxy_address).connect(signer);
    const USDT = await ethers.getContractFactory("TestUSDT");
    const usdt = await USDT.attach(usdtAddress).connect(signer);

    // await proxy.addToWhitelist(controller_address);

    // const usdtPricingHash = pricingHash("hellogolang", usdtAddress);
    // console.log("node usdt pricing: ", await controller.getPricing([usdtPricingHash]));
    const pricing = [
        {
            "mode": 1,
            "token": usdt.address,
            "prices": [ethers.BigNumber.from(30000), ethers.BigNumber.from(20000), ethers.BigNumber.from(10000)],
        },
    ]

    // await controller.openRegister("wys-test", beneficiary, pricing);
    // await usdt.mint(signer.address, 300000);
    // await usdt.approve(controller.address, 300000);
    await controller.registerSubdomain("wys-test", "tidb", beneficiary, resolver, 0, usdt.address, 20000, {
        gasPrice: ethers.utils.parseUnits("30", "gwei"),
        gasLimit: 200000
    });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});