// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./ERC721Tradable.sol";

/**
 * @title Space
 */
contract Space is ERC721Tradable {
    constructor(address _proxyRegistryAddress)
        ERC721Tradable("Space", "SPC", _proxyRegistryAddress)
    {}
}
