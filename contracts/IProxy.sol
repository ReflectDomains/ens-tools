// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

abstract contract IProxy {
    function checkPermission(string calldata label, address sender) external virtual returns (bytes32);

    function registerSubDomain(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external virtual {}

    function isOwner(string calldata label, address sender) external view virtual returns (bool);

    function ensNode(string calldata label) external pure virtual returns (bytes32);
}
