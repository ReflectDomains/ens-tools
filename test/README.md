## reflect ens tool

### 合约地址(goerli网络)

- Controller: 0xE34cBa16DA84B8167162972eB4460657cCDCB696
- Proxy: 0x3dED020313b2a22875cbeB57dEb55F3b6aa10914
- TestUSTD: 0x80258a9230383763E2A1ECa4B5675b49fdBEECbd

### 合约简介：

- Controller.sol: 域名托管, 购买入口
- Proxy.sol: 域名权限管理, 注册请求转发
- TestUSTD: 测试erc20token支付

### 域名托管前置条件:

    域名托管api: openRegister, 目前仅支持二级域名(reflect.eth), 可以直接在goerli.etherscan.io完成设置
    需要域名owner设置proxy合约为operator(调用setApprovalForAll方法)
    旧版ens授权合约地址(goerli测试网): 0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e
    新版ens授权合约地址(goerli测试网): 0x114D4603199df73e7D157787f8778E21fCd13066

```javascript
// 完成代码参考test/test_mint.js
// mode: 0->fixed price, 1 by-digit
// token: erc20 合约 address
// prices: 一个数组, 如果pricing mode为fixed, 该数组只能有一个元素, 
//   如果pricing mode为by-digit, 该数组需有三个元素3, 4, 4+ -> prices[0], prices[1], prices[2]
// 
// 合约源码
/**
 enum PRICING_MODE {
     FIXED, // fixed price
     BY_DIGIT // calculate price by subdomain digit
 }
 struct Pricing {
     PRICING_MODE mode; // pricing mode
     uint256[] prices;  // prices list
     address token;     // payment token address
 }
 * */
const pricing = [
    {
        "mode": 1,
        "token": usdt.address,
        "prices": [ethers.BigNumber.from(30000), ethers.BigNumber.from(20000), ethers.BigNumber.from(10000)],
    },
]
// label 需要托管的二级域名eg: wys-test.eth如需托管, label参数为wys-test, 合约会补齐.eth后缀
// beneficiary 域名收款账户
// pricin 域名定价
/**
 function openRegister(
    string calldata label,
    address beneficiary,
    Pricing[] memory pricing
 ) external
 * **/

await controller.openRegister("wys-test", beneficiary, pricing);

// 价格查询接口
// function getPricing(bytes32[] calldata pricingHash) external view returns (Pricing[] memory)
// 该参数为域名的namehash+支付token地址的keccake256hash值可以参考test_integration.js的pricingHash函数
// 完整代码参考test_integration.js line 156-182
```

### 域名注册前置条件:

    域名注册api: registerSubdomain
    需要先approve所需支付的token到controller合约

### 域名注册demo：
```javascript
// 完整代码参考test_mint.js
await usdt.mint(signer.address, 300000); // 获取测试usdt币
await usdt.approve(controller.address, 300000); // 授权usdt支付额度到controller合约
await controller.registerSubdomain("wys-test", "tidb", beneficiary, resolver, 0, usdt.address, 20000, {
    gasPrice: ethers.utils.parseUnits("30", "gwei"),
    gasLimit: 200000
});

// 合约源码:
// domain 二级域名
// subdomain 二级域名下属子域名
// owner 子域名的所有者
// resolver 固定为ens默认resolver: 0xd7a4F6473f32aC2Af804B3686AE8F1932bC35750
// ttl 直接传0
// token 完成支付的erc20 token地址
// amount 所需支付token数量
/**
 function registerSubdomain(
    string calldata domain, 
    string memory subdomain,
    address owner,
    address resolver,
    uint64 ttl,
    address token,
    uint256 amount
 )
 **/ 
```
