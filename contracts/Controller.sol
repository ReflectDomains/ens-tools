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
    enum SUBDOMAIN_STATUS {
        UNKNOWN, // indicate domain was not registered
        OPENED, // open register
        CLOSED   // close register
    }

    struct DomainMeta {
        SUBDOMAIN_STATUS status; // domain status
        address owner;           // address who registered this domain
        string ensDomain;        // string type ens domain. eg: reflect.eth
        mapping(address => uint256) amountRaised; // not use now
        address beneficiary;     // beneficiary address to receive payment
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

    event OpenRegister(address indexed owner, string indexed ensDomain);
    event RegisterSubdomain(address indexed owner, string indexed domain);

    constructor(uint256 _feePercentage, address _proxy, address[] memory _paymentTokens) {
        feePercentage = _feePercentage;
        proxy = IProxy(_proxy);
        for (uint256 i = 0; i < _paymentTokens.length; i++) {
            AvailablePayments[_paymentTokens[i]] = true;
        }
    }

    //===================== domain owner api =========================
    /**
     * @dev update node pricing:
     *      insert new policies and update existing pricing policies have the same token address.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param pricing list of pricing policies.
     */
    function updatePricing(string calldata label, Pricing[] memory pricing) public {
        require(proxy.isOwner(label, msg.sender), "Insufficient owner permission");
        require(pricing.length > 0, "Invalid pricing");

        for (uint256 i = 0; i < pricing.length; i++) {
            require(AvailablePayments[pricing[i].token] == true, "Invalid payment token");
            if ((pricing[i].mode == PRICING_MODE.FIXED && pricing[i].prices.length != 1) ||
                (pricing[i].mode == PRICING_MODE.BY_DIGIT && pricing[i].prices.length != 3)
            ) {revert("Invalid pricing");}

            bytes32 pricingHash = keccak256(abi.encodePacked(label, pricing[i].token));
            NodePricing[pricingHash] = pricing[i];
        }
    }

    /**
     * @dev update beneficiary address.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param beneficiary address to receive payment.
     */
    function updateBeneficiary(string calldata label, address beneficiary) external {
        require(proxy.isOwner(label, msg.sender), "Insufficient owner permission");
        bytes32 node = proxy.ensNode(label);
        DomainMeta storage domainMeta = NodeMeta[node];
        if (domainMeta.status != SUBDOMAIN_STATUS.UNKNOWN) {
            domainMeta.beneficiary = beneficiary;
        }
    }

    /**
     * @dev open register:
            need to set the proxy contract address to controller before calling this method,
            because proxy contract will check owner permission.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param beneficiary address to receive payment.
     * @param pricing list of pricing policies.
     */
    function openRegister(string calldata label, address beneficiary, Pricing[] memory pricing) external {
        updatePricing(label, pricing);
        bytes32 node = proxy.checkPermission(label, msg.sender);
        string memory ensDomain = string(abi.encodePacked(label, ".eth"));
        DomainMeta storage domainMeta = NodeMeta[node];
        domainMeta.status = SUBDOMAIN_STATUS.OPENED;
        domainMeta.owner = msg.sender;
        domainMeta.ensDomain = ensDomain;
        domainMeta.beneficiary = beneficiary;
        emit OpenRegister(msg.sender, ensDomain);
    }

    /**
     * @dev close register.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     */
    function closeRegister(string calldata label) external {
        require(proxy.isOwner(label, msg.sender), "Insufficient owner permission");
        bytes32 node = proxy.ensNode(label);
        DomainMeta storage domainMeta = NodeMeta[node];
        if (domainMeta.status == SUBDOMAIN_STATUS.OPENED) {
            domainMeta.status = SUBDOMAIN_STATUS.CLOSED;
        }
    }

    //===================== register api =========================
    /**
     * @dev register subdomain:
            need to approve allowance of payment token to proxy address before calling this method,
     * @param domain the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param subdomain the subdomain label, eg: "test.reflect.eth", use "test" as the label.
     * @param owner the subdomain owner address.
     * @param resolver the ens domain resolver.
     * @param ttl the ens domain ttl.
     * @param token payment token address.
     * @param amount payment token amount.
     */
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
        require(domainMeta.status == SUBDOMAIN_STATUS.OPENED, "Register not open");

        IERC20 paymentToken = IERC20(token);
        require(_calculatePayment(domain, length, token) == amount, "Invalid payment amount");
        uint256 feeAmount = (amount * feePercentage) / 100;
        if (amount > 0) {
            require(paymentToken.transferFrom(msg.sender, address(this), feeAmount), "Transfer fee failed");
            require(paymentToken.transferFrom(msg.sender, address(domainMeta.beneficiary), amount - feeAmount), "Transfer payment failed");
        }

        proxy.registerSubDomain(node, keccak256(bytes(subdomain)), owner, resolver, ttl);
        emit RegisterSubdomain(owner, string(abi.encodePacked(subdomain, ".", domainMeta.ensDomain)));
    }

    //===================== register api =========================
    /**
     * @dev calculate payment amount.
     * @param domain the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param subdomainLength the subdomain length.
     * @param token payment token address.
     * @return payment amount of registered pricing.
     */
    function _calculatePayment(string calldata domain, uint256 subdomainLength, address token) internal view returns (uint256){
        Pricing memory pricing = NodePricing[keccak256(abi.encodePacked(domain, token))];
        require(pricing.token == token, "Invalid payment token");
        if (pricing.mode == PRICING_MODE.FIXED) {
            return pricing.prices[0];
        }
        if (3 <= subdomainLength && subdomainLength <= 4) {
            return pricing.prices[subdomainLength % 3];
        } else {
            return pricing.prices[2];
        }
    }

    //===================== contract api =========================

    function updateFeePercentage(uint256 _feePercentage) public onlyOwner {
        feePercentage = _feePercentage;
    }

    function updateProxyAddress(address _proxyAddress) public onlyOwner {
        proxy = IProxy(_proxyAddress);
    }
}
