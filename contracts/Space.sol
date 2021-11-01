// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Space
 */
contract SpaceTest is ERC721Tradable {
    constructor(address _proxyRegistryAddress)
        ERC721Tradable("SpaceTest", "SPC", _proxyRegistryAddress)
    {}
}
