// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract EnumerableNFT is ERC721, IERC721Enumerable {
    error EnumerableNFT__OutOfBoundsIndex(uint256 index);
    error EnumerableNFT__TotalSupplyReached();
    error EnumerableNFT__OutOfBoundsTokenId();

    mapping(address => uint256[]) private s_ownedTokens;
    mapping(uint256 => uint256) private s_ownedTokensIndex;

    uint256[] private s_allTokens;
    mapping(uint256 => uint256) private s_allTokensIndex;
    uint256 public constant MAX_SUPPLY = 20;
    uint256 public constant MAX_TOKEN_ID = 100;

    constructor() ERC721("EnumerableNFT", "ENFT") {}

    function _increaseBalance(address account, uint256 value) internal {}

    function totalSupply() public view override returns (uint256) {
        return s_allTokens.length;
    }

    function mint(address _to, uint256 _tokenId) external {
        if (totalSupply() >= 20) {
            revert EnumerableNFT__TotalSupplyReached();
        }

        if (_tokenId == 0 || _tokenId > MAX_TOKEN_ID) {
            revert EnumerableNFT__OutOfBoundsTokenId();
        }
        _mint(_to, _tokenId);
        s_allTokensIndex[_tokenId] = s_allTokens.length;
        s_allTokens.push(_tokenId);
        s_ownedTokens[_to].push(_tokenId);
        s_ownedTokensIndex[_tokenId] = s_ownedTokens[_to].length;
    }

    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    ) public view override returns (uint256) {
        if (_index >= balanceOf(_owner)) {
            revert EnumerableNFT__OutOfBoundsIndex(_index);
        }
        return s_ownedTokens[_owner][_index];
    }

    function tokenByIndex(
        uint256 _index
    ) public view override returns (uint256) {
        if (_index >= totalSupply()) {
            revert EnumerableNFT__OutOfBoundsIndex(_index);
        }
        return s_allTokens[_index];
    }

    function getOwnedTokens(
        address _owner
    ) public view returns (uint256[] memory) {
        return s_ownedTokens[_owner];
    }
}
