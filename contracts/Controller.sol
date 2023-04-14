// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IENS.sol";
import "./IProxy.sol";

interface IERC20 {
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
}

contract Controller is Ownable {
    enum DOMAIN_STATUS {
        UNKNOWN, // indicate domain was not registered
        OPENED, // open register
        CLOSED   // close register
    }

    enum DOMAIN_VERSION {
        V1,
        V2
    }

    struct DomainMeta {
        DOMAIN_STATUS status; // domain status
        DOMAIN_VERSION version; // domain version
        string ensDomain;        // string type ens domain. eg: reflect.eth
        address owner;           // address who registered this domain
        address beneficiary;     // beneficiary address to receive payment
        mapping(address => uint256) amountRaised; // not use now
        uint256 tokenId;
    }

    enum PRICING_MODE {
        FIXED, // fixed price
        BY_DIGIT // calculate price by subdomain digit
    }

    struct Pricing {
        PRICING_MODE mode; // pricing mode
        uint256[] prices;  // prices by digit
        address token;     // payment token address
    }

    uint256 public feePercentage; // contract fee percentage
    IProxy public proxy; // ens proxy address
    mapping(bytes32 => DomainMeta) public NodeMeta; // node => domain meta
    mapping(bytes32 => Pricing) public NodePricing; // node => pricing
    mapping(address => bool) public AvailablePayments; // available payment token

    event OpenRegister(address indexed owner, string ensDomain);
    event RegisterSubdomain(address indexed owner, string domain);

    constructor(
        uint256 _feePercentage,
        address _proxy,
        address[] memory _paymentTokens
    ) {
        feePercentage = _feePercentage;
        proxy = IProxy(_proxy);
        for (uint256 i = 0; i < _paymentTokens.length; i++) {
            AvailablePayments[_paymentTokens[i]] = true;
        }
    }

    function _checkPricing(Pricing[] memory pricing) internal view{
        require(pricing.length > 0, "Pricing is empty");
        for (uint256 i = 0; i < pricing.length; i++) {
            require(AvailablePayments[pricing[i].token] == true, "Invalid payment token");
            if ((pricing[i].mode == PRICING_MODE.FIXED && pricing[i].prices.length != 1) ||
                (pricing[i].mode == PRICING_MODE.BY_DIGIT && pricing[i].prices.length != 3)
            ) {revert("Invalid pricing");}
        }
    }

    function _setPricing(bytes32 node, Pricing[] memory pricing) internal {
        for (uint256 i = 0; i < pricing.length; i++) {
            bytes32 pricingHash = keccak256(abi.encodePacked(node, pricing[i].token));
            NodePricing[pricingHash] = pricing[i];
        }
    }

    function setPricing(bytes32 node, Pricing[] memory pricing) external {
        _checkPricing(pricing);
        DomainMeta storage domainMeta = NodeMeta[node];
        require(domainMeta.status != DOMAIN_STATUS.UNKNOWN, "Domain Unknown");
        require(proxy.isNodeOwner(
                domainMeta.tokenId,
                msg.sender,
                domainMeta.version == DOMAIN_VERSION.V2
            ), "Insufficient permission");

        for (uint256 i = 0; i < pricing.length; i++) {
            bytes32 pricingHash = keccak256(abi.encodePacked(node, pricing[i].token));
            NodePricing[pricingHash] = pricing[i];
        }
    }

    function setBeneficiary(bytes32 node, address beneficiary) external {
        DomainMeta storage domainMeta = NodeMeta[node];
        require(domainMeta.status != DOMAIN_STATUS.UNKNOWN, "Domain Unknown");
        require(proxy.isNodeOwner(
                domainMeta.tokenId,
                msg.sender,
                domainMeta.version == DOMAIN_VERSION.V2
            ), "Insufficient permission");
        domainMeta.beneficiary = beneficiary;
    }

    function setDomainStatus(bytes32 node, DOMAIN_STATUS domainStatus) external {
        require(domainStatus > DOMAIN_STATUS.UNKNOWN, "Domain Status Unknown");
        DomainMeta storage domainMeta = NodeMeta[node];
        require(domainMeta.status != DOMAIN_STATUS.UNKNOWN, "Domain Unknown");
        require(proxy.isNodeOwner(
                domainMeta.tokenId,
                msg.sender,
                domainMeta.version == DOMAIN_VERSION.V2
            ), "Insufficient permission");
        if (domainMeta.status != domainStatus) {
            domainMeta.status = domainStatus;
        }
    }

    function setDomainVersion(bytes32 node, DOMAIN_VERSION domainVersion) external {
        require(domainVersion > DOMAIN_VERSION.V1, "Invalid domain version");
        DomainMeta storage domainMeta = NodeMeta[node];
        require(domainMeta.status != DOMAIN_STATUS.UNKNOWN, "Domain Unknown");
        require(proxy.isNodeOwner(
                domainMeta.tokenId,
                msg.sender,
                domainMeta.version == DOMAIN_VERSION.V2
            ), "Insufficient permission");
        if (domainMeta.version != domainVersion) {
            domainMeta.version = domainVersion;
        }
    }

    function openRegister(
        string calldata label,
        address beneficiary,
        Pricing[] memory pricing
    ) external {
        _checkPricing(pricing);
        bytes32 node = proxy.ensNode(label);
        bool isWrapped = proxy.isWrapped(node);
        uint256 tokenId = isWrapped ? uint256(node) : uint256(keccak256(bytes(label)));
        proxy.checkPermission(node, msg.sender, isWrapped);
        require(proxy.isNodeOwner(tokenId, msg.sender, isWrapped), "Insufficient permission");

        _setPricing(node, pricing);
        DomainMeta storage domainMeta = NodeMeta[node];
        domainMeta.status = DOMAIN_STATUS.OPENED;
        domainMeta.version = isWrapped ? DOMAIN_VERSION.V1 : DOMAIN_VERSION.V2;
        domainMeta.ensDomain = string(abi.encodePacked(label, ".eth"));
        domainMeta.owner = msg.sender;
        domainMeta.beneficiary = beneficiary;
        domainMeta.tokenId = tokenId;
        emit OpenRegister(msg.sender, domainMeta.ensDomain);
    }

    function _calculatePayment(bytes32 node, uint256 subdomainLength, address token) internal view returns (uint256){
        Pricing memory pricing = NodePricing[keccak256(abi.encodePacked(node, token))];
        require(pricing.token == token, "Invalid payment token");
        if (pricing.mode == PRICING_MODE.FIXED) {
            return pricing.prices[0];
        }
        return (3 <= subdomainLength && subdomainLength <= 4) ? pricing.prices[subdomainLength % 3] : pricing.prices[2];
    }

    function registerSubdomain(
        string calldata domain,
        string memory subdomain,
        address owner,
        address resolver,
        uint64 ttl,
        address token,
        uint256 amount
    ) external {
        uint256 length = bytes(subdomain).length;
        require(length >= 3, "Invalid subdomain length");

        bytes32 node = proxy.ensNode(domain);
        DomainMeta storage domainMeta = NodeMeta[node];
        require(domainMeta.status == DOMAIN_STATUS.OPENED, "Register not open");

        IERC20 paymentToken = IERC20(token);
        require(_calculatePayment(node, length, token) == amount, "Invalid payment amount");
        uint256 feeAmount = (amount * feePercentage) / 100;
        if (amount > 0) {
            require(paymentToken.transferFrom(
                    msg.sender,
                    address(this),
                    feeAmount
                ), "Transfer fee failed");
            require(paymentToken.transferFrom(
                    msg.sender,
                    address(domainMeta.beneficiary),
                    amount - feeAmount
                ), "Transfer payment failed");
        }

        proxy.registerSubDomain(
            node,
            subdomain,
            owner,
            resolver,
            ttl,
            domainMeta.version == DOMAIN_VERSION.V2
        );
        emit RegisterSubdomain(owner, string(abi.encodePacked(subdomain, ".", domainMeta.ensDomain)));
    }

    function getPricing(bytes32[] calldata pricingHash) external view returns (Pricing[] memory){
        Pricing[] memory pricing = new Pricing[](pricingHash.length);
        for (uint256 i = 0; i < pricingHash.length; i++) {
            pricing[i] = NodePricing[pricingHash[i]];
        }
        return pricing;
    }

    //===================== contract api =========================

    function updateFeePercentage(uint256 _feePercentage) public onlyOwner {
        feePercentage = _feePercentage;
    }

    function updateProxyAddress(address _proxyAddress) public onlyOwner {
        proxy = IProxy(_proxyAddress);
    }
}
