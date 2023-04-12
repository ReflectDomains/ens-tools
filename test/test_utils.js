const {ethers} = require("hardhat");

async function main() {
    const Test = await ethers.getContractFactory("Test");
    const test = await Test.deploy();

    console.log("test contract address: ", test.address);
    // const node = ethers.utils.namehash("reflect.eth");
    // const label1 = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("helloworld001"));
    // tokenID: 75697473970914694694878956018669570074168920701940220921270890409198548436729
    // console.log(ethers.BigNumber.from(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("reflect"))))
    // console.log("pack string: ", await test.testEncodePacked(ethers.utils.formatBytes32String("hello world")));
    // console.log("ethers   tokenId",ethers.BigNumber.from(ethers.utils.keccak256(ethers.utils.toUtf8Bytes("reflect.eth"))))
    // console.log("contract tokenId: ", await test.tokenId("reflect"));
    // console.log("ethers namehash: ", ethers.utils.namehash("reflect.eth"));
    // console.log("contract namehash: ", await test.ethNamehash("reflect"));
    // console.log("ethers namehash: ", ethers.utils.namehash("wys"));
    // console.log("contract namehash: ", await test.namehash("wys"));
    // console.log("pack string: ", await test.testEncodePacked(ethers.utils.formatBytes32String("hello world")))
    // 0x8e61896c7e52e78251d83eb88de8a51e3256f8ef9e9d06844386144c64cda878
    console.log("ethers label: ", ethers.utils.namehash("python.reflect03.eth"));
    console.log("contract label: ", await test.label("python"));
    console.log("contract label: ", await test.keccak256("python", test.address));
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});