const {ethers} = require("hardhat");
const {expect} = require("chai");

const ensAddress = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e";
const registrarAddress = "0x57f1887a8BF19b14fC0dF6Fd9B2acc9Af147eA85";
const resolver = "0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750"
const feePercentage = 3;

describe("test integration", function () {
    let usdt, usdc, proxy, controller;
    let user1, user2, user3;

    before(async () => {
        [user1, user2, user3] = await ethers.provider.listAccounts();
        // deploy usdt
        const USDT = await ethers.getContractFactory("TestUSDT");
        usdt = await USDT.deploy("USDT", "USDT");
        console.log("usdt address: ", usdt.address);
        // deploy usdc
        const USDC = await ethers.getContractFactory("TestUSDT");
        usdc = await USDC.deploy("USDC", "USDC");
        console.log("usdc address: ", usdc.address);
        // deploy proxy
        const Proxy = await ethers.getContractFactory("Proxy");
        proxy = await Proxy.deploy(ensAddress, registrarAddress);
        console.log("proxy address: ", proxy.address);
        // deploy controller
        const Controller = await ethers.getContractFactory("Controller");
        controller = await Controller.deploy(feePercentage, proxy.address, [usdt.address, usdc.address]);
        console.log("controller address: ", controller.address);
    })

    pricingHash = function (label, token) {
        const hash = ethers.utils.keccak256(
            ethers.utils.solidityPack(["string", "address"], [label, token])
        );

        return ethers.utils.hexlify(hash);
    }

    // it("test payment address", async function () {
    //     expect(await controller.AvailablePayments(usdt.address), "usdt payment address err").to.be.true;
    //     expect(await controller.AvailablePayments(usdc.address), "usdc payment address err").to.be.true;
    // })
    //
    // it("test node register with invalid domain", async function () {
    //     const pricing = [
    //         {
    //             "mode": 0,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(100000000)],
    //         },
    //     ]
    //     await controller.openRegister("reflect", user1, pricing);
    //     await expect(controller.registerSubdomain("reflect", "ab", user2, resolver, 0, usdt.address, 100000000)).to.be.revertedWith("Invalid subdomain length")
    // })
    //
    // it("test node register with closed domain", async function () {
    //     const pricing = [
    //         {
    //             "mode": 0,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(100000000)],
    //         },
    //     ]
    //     await controller.openRegister("reflect", user1, pricing);
    //     await expect(controller.registerSubdomain("reflect01", "wys", user2, resolver, 0, usdt.address, 100000000)).to.be.revertedWith("Register not open")
    // })
    //
    // it("test node register with insufficient allowance", async function () {
    //     const pricing = [
    //         {
    //             "mode": 0,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(100000000)],
    //         },
    //     ]
    //     await controller.openRegister("reflect", user1, pricing);
    //     await expect(controller.registerSubdomain("reflect", "wys", user2, resolver, 0, usdt.address, 100000000)).to.be.revertedWith("ERC20: insufficient allowance")
    // })
    //
    // it("test node register with invalid token", async function () {
    //     const pricing = [
    //         {
    //             "mode": 0,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(100000000)],
    //         },
    //     ]
    //     await controller.openRegister("reflect", user1, pricing);
    //     await expect(controller.registerSubdomain("reflect", "wys", user2, resolver, 0, usdc.address, 100000000)).to.be.revertedWith("Invalid payment token")
    // })
    //
    it("test node register with invalid amount", async function () {
        const pricing = [
            {
                "mode": 1,
                "token": usdt.address,
                "prices": [ethers.BigNumber.from(30000), ethers.BigNumber.from(20000), ethers.BigNumber.from(10000)],
            },
        ]
        await controller.openRegister("hellogolang", user2, pricing);
        await controller.registerSubdomain("hellogolang", "golang", user2, resolver, 0, usdt.address, 10000);
    })
    //
    // it("test node register with fix pricing", async function () {
    //     const pricing = [
    //         {
    //             "mode": 0,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(100000000)],
    //         },
    //     ]
    //
    //     await controller.openRegister("reflect", user2, pricing);
    //     await usdt.mint(user1, 100000000);
    //     await usdt.approve(controller.address, 100000000);
    //     expect(await usdt.balanceOf(controller.address)).eq(0);
    //     expect(await usdt.balanceOf(user1)).eq(100000000);
    //     expect(await usdt.balanceOf(user2)).eq(0);
    //     controller.registerSubdomain("reflect", "wys", user2, resolver, 0, usdt.address, 100000000);
    //     expect(await usdt.balanceOf(controller.address)).eq(3000000);
    //     expect(await usdt.balanceOf(user1)).eq(0);
    //     expect(await usdt.balanceOf(user2)).eq(97000000);
    // })


    // it("test node register with digit pricing", async function () {
    //     const pricing = [
    //         {
    //             "mode": 1,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(300000000), ethers.BigNumber.from(200000000), ethers.BigNumber.from(100000000)],
    //         },
    //     ]
    //
    //     await controller.openRegister("reflect", user2, pricing);
    //     await usdt.mint(user1, 200000000);
    //     await usdt.approve(controller.address, 200000000);
    //     expect(await usdt.balanceOf(controller.address)).eq(0);
    //     expect(await usdt.balanceOf(user1)).eq(200000000);
    //     expect(await usdt.balanceOf(user2)).eq(0);
    //     await controller.registerSubdomain("reflect", "haha", user2, resolver, 0, usdt.address, 200000000);
    //     expect(await usdt.balanceOf(controller.address)).eq(6000000);
    //     expect(await usdt.balanceOf(user1)).eq(0);
    //     expect(await usdt.balanceOf(user2)).eq(194000000);
    // })
    //
    // it("test node pricing", async function () {
    //     const pricing = [
    //         {
    //             "mode": 0,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(100000000)],
    //         },
    //         {
    //             "mode": 1,
    //             "token": usdc.address,
    //             "prices": [ethers.BigNumber.from(300000000), ethers.BigNumber.from(200000000), ethers.BigNumber.from(100000000)],
    //         }
    //     ]
    //     await controller.openRegister("reflect", user1, pricing);
    //     const node = ethers.utils.namehash("reflect.eth");
    //     // console.log("node meta: ", await controller.NodeMeta(node));
    //     const newPricing = [
    //         {
    //             "mode": 1,
    //             "token": usdt.address,
    //             "prices": [ethers.BigNumber.from(300000000), ethers.BigNumber.from(200000000), ethers.BigNumber.from(100000000)],
    //         }
    //     ]
    //     await controller.updatePricing("reflect", newPricing);
    //     const usdtPricingHash = pricingHash("reflect", usdt.address);
    //     // console.log("node usdt pricing: ", await controller.NodePricing(usdtPricingHash));
    //     const usdcPricingHash = pricingHash("reflect", usdt.address);
    //     // console.log("node usdc pricing: ", await controller.NodePricing(usdcPricingHash));
    // })
})

async function main() {


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});