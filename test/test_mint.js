const {ethers} = require("hardhat");

async function main() {
    // const node = ethers.utils.namehash("reflect.eth");
    // const label1 = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("helloworld001"));
    const owner = "0xf15e0eDf9f53B06671bDD4F48E014eb2048E1986"
    const beneficiary = "0x3c37496E4cB8cc14913caDec6dD3EBf828f19C51"
    const resolver = "0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750"
    const proxy_address = "0x70Ca34ECDd341A30A111215070304Dc931D98dB9"
    const controller_address = "0xA1EF2b86f7c409dE9775B22929880EDf11FfD072"

    // tokenID: 75697473970914694694878956018669570074168920701940220921270890409198548436729
    // console.log(ethers.BigNumber.from(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("reflect"))))
    const [signer] = await ethers.getSigners();
    const Controller = await ethers.getContractFactory("Controller");
    const controller = await Controller.attach(controller_address).connect(signer);
    // console.log(await controller.Domains(ethers.utils.namehash("hellogolang.eth")));

    // await controller.openRegister("hellogolang", beneficiary, {gasLimit: 300000});
    await controller.registerSubdomain(ethers.utils.namehash("hellogolang.eth"), "wjy", beneficiary, resolver, 0, {gasLimit: 200000});
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});