// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./IENS.sol";
import "./IProxy.sol";

contract Proxy is IProxy {
    IENS public ens;
    IRegistrar public registrar;
    INameWrapper public nameWrapper;
    bytes32 constant public TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;


    constructor(
        address _ensAddress,
        address _registrarAddress,
        address _nameWrapperAddress
    ) {
        ens = IENS(_ensAddress);
        registrar = IRegistrar(_registrarAddress);
        nameWrapper = INameWrapper(_nameWrapperAddress);
    }


    function checkPermission(
        bytes32 node,
        address sender,
        bool isWrapped
    ) external override view {
        return;
        // for local test
        if (isWrapped) {
            require(nameWrapper.isApprovedForAll(sender, address(this)), "Insufficient operator permission");
        } else {
            require(ens.owner(node) == address(this), "Insufficient controller permission");
        }
    }

    function registerSubDomain(
        bytes32 parentNode,
        string memory label,
        address owner,
        address resolver,
        uint64 ttl,
        bool isWrapped
    ) external override {
        return;
        // for local test
        bytes32 _label = keccak256(bytes(label));
        require(ens.owner(keccak256(abi.encodePacked(_label, parentNode))) == address(0), "Domain already registered");
        if (isWrapped) {
            nameWrapper.setSubnodeRecord(parentNode, label, owner, resolver, ttl, 0, 0);
        } else {
            ens.setSubnodeRecord(parentNode, _label, owner, resolver, ttl);
        }
    }


    function isNodeOwner(
        uint256 tokenId,
        address sender,
        bool isWrapped
    ) external view override returns (bool) {
        return true;
        // for local test
        if (isWrapped) {
            return nameWrapper.ownerOf(tokenId) == sender;
        }
        return registrar.ownerOf(tokenId) == sender;
    }

    function ensNode(string calldata label) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(TLD_NODE, keccak256(bytes(label))));
    }

    function isWrapped(bytes32 node) external view override returns (bool) {
        return false;
        // for local test
        return nameWrapper.ownerOf(uint256(node)) != address(0) &&
        ens.owner(node) == address(nameWrapper);
    }
}
