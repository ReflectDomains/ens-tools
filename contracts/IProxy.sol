// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract IProxy {
    function checkPermission(bytes32 node, address sender, bool isWrapped) external view virtual;

    function registerSubDomain(
        bytes32 parentNode,
        string memory label,
        address owner,
        address resolver,
        uint64 ttl,
        bool isWrapped
    ) external virtual;

    function isNodeOwner(uint256 tokenId, address sender, bool isWrapped) external view virtual returns (bool);

    function ensNode(string calldata label) external pure virtual returns (bytes32);

    function isWrapped(bytes32 node) external view virtual returns (bool);
}
