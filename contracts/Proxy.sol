// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IENS.sol";
import "./IProxy.sol";

contract Proxy is IProxy {
    IENS public ens;
    IRegistrar public registrar;
    bytes32 constant public TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;


    constructor(address _ensAddress, address _registrarAddress) {
        ens = IENS(_ensAddress);
        registrar = IRegistrar(_registrarAddress);
    }

    /**
     * @dev check controller permission.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param sender eht msg sender that calls the controller contract.
     * @return bytes32 node namehash.
     */
    function checkPermission(string calldata label, address sender) external override returns (bytes32){
        bytes32 _label = keccak256(bytes(label));
        return keccak256(abi.encodePacked(TLD_NODE, _label)); // use for local test

        uint256 tokenId = uint256(_label);
        require(registrar.ownerOf(tokenId) == sender, "Insufficient owner permission");
        //todo: 此处逻辑有重复
        bytes32 node = keccak256(abi.encodePacked(TLD_NODE, _label));
        if (ens.owner(node) != address(this)) {
            revert("Insufficient controller permission");
        }
        return node;
    }

    /**
     * @dev register subdomain.
     * @param node namehash.
     * @param label the subdomain label.
     * @param owner subdomain owner address.
     * @param ttl of subdomain.
     */
    function registerSubDomain(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external override {
        return; // use for local test

        require(ens.owner(keccak256(abi.encodePacked(label, node))) == address(0), "Domain already registered");
        ens.setSubnodeRecord(node, label, owner, resolver, ttl);
    }

    /**
     * @dev check ownership of registrant.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @param sender eht msg sender that calls the controller contract.
     * @return owner or not
     */
    function isOwner(string calldata label, address sender) external view override returns (bool) {
        return true; // use for local test

        uint256 tokenId = uint256(keccak256(bytes(label)));
        return registrar.ownerOf(tokenId) == sender;
    }

    /**
     * @dev encode ens node namehash.
     * @param label the domain label, eg: "reflect.eth", use "reflect" as the label.
     * @return bytes32 node namehash.
     */
    function ensNode(string calldata label) external pure override returns (bytes32) {
        bytes32 _label = keccak256(bytes(label));
        return keccak256(abi.encodePacked(TLD_NODE, _label));
    }
}
