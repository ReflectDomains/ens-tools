// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IENS {
    function owner(bytes32 node) external view returns (address);
    function setSubnodeRecord(
        bytes32 node,
        bytes32 label,
        address owner,
        address resolver,
        uint64 ttl
    ) external;
    function isApprovedForAll(
        address owner,
        address operator
    ) external view returns (bool);
}

interface IRegistrar {
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function reclaim(uint256 id, address owner) external;
    function approve(address to, uint256 tokenId) external;
}
