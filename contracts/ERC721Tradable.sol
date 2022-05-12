// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import 'openzeppelin-solidity/contracts/token/ERC721/ERC721.sol';
import 'openzeppelin-solidity/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import 'openzeppelin-solidity/contracts/access/Ownable.sol';
import 'openzeppelin-solidity/contracts/utils/math/SafeMath.sol';
import 'openzeppelin-solidity/contracts/utils/Strings.sol';

import './ContentMixin.sol';
import './NativeMetaTransaction.sol';

contract OwnableDelegateProxy {}

contract ProxyRegistry {
  mapping(address => OwnableDelegateProxy) public proxies;
}

/**
 * @title ERC721Tradable
 * ERC721Tradable - ERC721 contract that whitelists a trading address, and has minting functionality.
 */
abstract contract ERC721Tradable is
  ContextMixin,
  ERC721Enumerable,
  NativeMetaTransaction,
  Ownable
{
  using SafeMath for uint256;

  ERC721 _oldTokenContract = ERC721(0x4ef107a154CB7580c686C239Ed9F92597A42b961);
  address proxyRegistryAddress;
  uint256 private _currentTokenId = 1000;

  mapping(uint256 => string) private _tokenURIs;
  mapping(string => bool) private _tokenURIUsed;

  constructor(
    string memory _name,
    string memory _symbol,
    address _proxyRegistryAddress
  ) ERC721(_name, _symbol) {
    proxyRegistryAddress = _proxyRegistryAddress;
    _initializeEIP712(_name);
  }

  /**
   * @dev Mints a token to an address with a tokenURI.
   * @param _tokenURI IPFS uri for token
   * @param _v signature
   * @param _r signature
   * @param _s signature
   */
  function mintToken(
    string memory _tokenURI,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) public {
    address _owner = owner();
    require(bytes(_tokenURI).length > 0, "Token URI cannot be empty");
    require(
      _verifySigner(_owner, _tokenURI, _v, _r, _s),
      'owner should sign tokenURI'
    );
    require(_tokenURIUsed[_tokenURI] == false, 'tokenURI already used');
    uint256 newTokenId = _currentTokenId.add(1);
    _tokenURIs[newTokenId] = _tokenURI;
    _tokenURIUsed[_tokenURI] = true;
    _mint(msg.sender, newTokenId);
    _currentTokenId++;
  }

  function migrateToken(
    uint _tokenId
  ) public {
    // lookup the token from the old contract
    string memory _oldTokenURI = _oldTokenContract.tokenURI(_tokenId);
    require(bytes(_oldTokenURI).length > 0, "Old Token URI cannot be empty");

    _oldTokenContract.safeTransferFrom(msg.sender, address(0), _tokenId);
    
    require(_tokenURIUsed[_oldTokenURI] == false, 'tokenURI already used');
    require(bytes(_tokenURIs[_tokenId]).length == 0, 'token already migrated');
    _tokenURIs[_tokenId] = _oldTokenURI;
    _tokenURIUsed[_oldTokenURI] = true;
    _mint(msg.sender, _tokenId);
    _currentTokenId++;
  }

  function tokenURI(uint256 _tokenId)
    public
    view
    override
    returns (string memory)
  {
    return _tokenURIs[_tokenId];
  }

  /**
   * Override isApprovedForAll to whitelist user's OpenSea proxy accounts to enable gas-less listings.
   */
  function isApprovedForAll(address owner, address operator)
    public
    view
    override(ERC721, IERC721)
    returns (bool)
  {
    if (block.chainid == 1 || block.chainid == 4) {
      // Whitelist OpenSea proxy contract for easy trading.
      ProxyRegistry proxyRegistry = ProxyRegistry(proxyRegistryAddress);
      if (address(proxyRegistry.proxies(owner)) == operator) {
        return true;
      }

      return super.isApprovedForAll(owner, operator);
    } else if (block.chainid == 137 || block.chainid == 80001) {
      return address(0x58807baD0B376efc12F5AD86aAc70E78ed67deaE) == operator;
    }
    return false;
  }

  /**
   * This is used instead of msg.sender as transactions won't be sent by the original token owner, but by OpenSea.
   */
  function _msgSender() internal view override returns (address sender) {
    return ContextMixin.msgSender();
  }

  function _verifySigner(
    address _signer,
    string memory _message,
    uint8 _v,
    bytes32 _r,
    bytes32 _s
  ) internal view returns (bool) {
    address messageSigner = ecrecover(
      keccak256(abi.encodePacked(this, _message)),
      _v,
      _r,
      _s
    );
    return messageSigner == _signer;
  }
}
