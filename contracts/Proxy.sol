// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./IENS.sol";
import "./IProxy.sol";

contract Proxy is IProxy, AccessControl {
    IENS public ens;
    IRegistrar public registrar;
    INameWrapper public nameWrapper;

    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");
    bytes32 constant public TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

    constructor(
        address _ensAddress,
        address _registrarAddress,
        address _nameWrapperAddress
    ) {
        ens = IENS(_ensAddress);
        registrar = IRegistrar(_registrarAddress);
        nameWrapper = INameWrapper(_nameWrapperAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function checkPermission(
        address sender,
        bool _isWrapped
    ) external override view {
        if (_isWrapped) {
            require(nameWrapper.isApprovedForAll(sender, address(this)), "Insufficient operator permission");
        } else {
            require(ens.isApprovedForAll(sender, address(this)), "Insufficient operator permission");
        }
    }

    function registerSubDomain(
        bytes32 parentNode,
        string memory label,
        address owner,
        address resolver,
        uint64 ttl,
        bool _isWrapped
    ) external override onlyRole(WHITELIST_ROLE){
        bytes32 _label = keccak256(bytes(label));
        require(ens.owner(keccak256(abi.encodePacked(_label, parentNode))) == address(0), "Domain already registered");
        if (_isWrapped) {
            nameWrapper.setSubnodeRecord(parentNode, label, owner, resolver, ttl, 0, 0);
        } else {
            ens.setSubnodeRecord(parentNode, _label, owner, resolver, ttl);
        }
    }

    function isNodeOwner(
        uint256 tokenId,
        address sender,
        bool _isWrapped
    ) external view override returns (bool) {
        if (_isWrapped) {
            return nameWrapper.ownerOf(tokenId) == sender;
        }
        return registrar.ownerOf(tokenId) == sender;
    }

    function ensNode(string calldata label) public pure override returns (bytes32) {
        return keccak256(abi.encodePacked(TLD_NODE, keccak256(bytes(label))));
    }

    function isWrapped(bytes32 node) external view override returns (bool) {
        return nameWrapper.ownerOf(uint256(node)) != address(0) &&
        ens.owner(node) == address(nameWrapper);
    }

    function addToWhitelist(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(WHITELIST_ROLE, _address);
    }

    function removeFromWhitelist(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(WHITELIST_ROLE, _address);
    }
}
