const {ethers} = require("hardhat");

const tnwAddress = "0x9aD647a4fb99fAdbD66987A1679107910c554B3d";
const owner = "0xf15e0eDf9f53B06671bDD4F48E014eb2048E1986";
const resolver = "0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750";

async function main() {
    const [signer] = await ethers.getSigners();
    const TestNameWrapper = await ethers.getContractFactory("TestNameWrapper");
    const tnw = await TestNameWrapper.attach(tnwAddress).connect(signer);
    const parent = ethers.utils.namehash("hellogolang.eth");

    await tnw.setSubnodeRecord(parent, "assembly", owner, resolver, 0, 0, 0)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});