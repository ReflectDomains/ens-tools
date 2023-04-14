pragma solidity ^0.8.0;

import "@ensdomains/ens-contracts/contracts/wrapper/NameWrapper.sol";

contract TestNameWrapper {
    INameWrapper public nameWrapper;

    constructor(address _nameWrapperAddress) {
        nameWrapper = INameWrapper(_nameWrapperAddress);
    }

    function setSubnodeRecord(
        bytes32 parentNode,
        string memory label,
        address owner,
        address resolver,
        uint64 ttl,
        uint32 fuses,
        uint64 expiry
    ) public returns (bytes32 node) {
        return nameWrapper.setSubnodeRecord(
        parentNode,
        label,
        owner,
        resolver,
        ttl,
        fuses,
        expiry
        );
    }
}
