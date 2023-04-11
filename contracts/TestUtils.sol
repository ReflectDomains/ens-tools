// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract Test {
    bytes32 constant public TLD_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

    function testEncodePacked(bytes32 param) external pure returns (string memory){
        return string(abi.encodePacked(param, " haha", ".eth"));
    }

    function tokenId(string calldata param) external pure returns (uint256) {
        return uint256(keccak256(bytes(param)));
    }

    function ethNamehash(string calldata param) external pure returns (bytes32) {
        bytes32 _label = keccak256(bytes(param));
        return keccak256(abi.encodePacked(TLD_NODE, _label));
    }

    function namehash(string calldata param) external pure returns (bytes32) {
        bytes32 labelHash = keccak256(bytes(param));
        bytes32 nodeHash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        bytes memory rootNode = abi.encodePacked(nodeHash, labelHash);
        return keccak256(rootNode);
    }

    function label(string calldata param) external pure returns (bytes32) {
        return keccak256(bytes(param));
    }

    function keccak256(string calldata param, address token) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(param, token));
    }
}
