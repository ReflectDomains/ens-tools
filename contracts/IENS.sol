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
}

interface INameWrapper {
    function setSubnodeRecord(
        bytes32 parentNode,
        string memory label,
        address owner,
        address resolver,
        uint64 ttl,
        uint32 fuses,
        uint64 expiry
    ) external returns (bytes32 node);

    function isApprovedForAll(
        address account,
        address operator
    ) external view returns (bool);

    function ownerOf(uint256 id) external view returns (address);
}
