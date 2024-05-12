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

    constructor() ERC721("EnumerableNFT", "ENFT") {}

    function _increaseBalance(address account, uint256 value) internal {}

    function totalSupply() public view override returns (uint256) {
        return s_allTokens.length;
    }

    function mint(address to, uint256 tokenId) external {
        if (totalSupply() >= 20) {
            revert EnumerableNFT__TotalSupplyReached();
        }

        if (tokenId == 0 || tokenId > MAX_SUPPLY) {
            revert EnumerableNFT__OutOfBoundsTokenId();
        }
        _mint(to, tokenId);
        s_allTokensIndex[tokenId] = s_allTokens.length;
        s_allTokens.push(tokenId);
        s_ownedTokens[to].push(tokenId);
        s_ownedTokensIndex[tokenId] = s_ownedTokens[to].length;
    }

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) public view override returns (uint256) {
        if (index >= balanceOf(owner)) {
            revert EnumerableNFT__OutOfBoundsIndex(index);
        }
        return s_ownedTokens[owner][index];
    }

    function tokenByIndex(
        uint256 index
    ) public view override returns (uint256) {
        if (index >= totalSupply()) {
            revert EnumerableNFT__OutOfBoundsIndex(index);
        }
        return s_allTokens[index];
    }

    function getOwnedTokens(
        address owner
    ) public view returns (uint256[] memory) {
        return s_ownedTokens[owner];
    }
}
