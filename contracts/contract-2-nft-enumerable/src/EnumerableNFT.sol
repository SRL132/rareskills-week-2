// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;
import {IERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/// @title EnumerableNFT
/// @author Sergi Roca Laguna
/// @notice This contract allows users to mint a maximum of NFTs with IDs [1, 100] and retrieve information about them
/// @dev This contract inherits from ERC721 and IERC721Enumerable for gas optimization
contract EnumerableNFT is ERC721, IERC721Enumerable {
    error EnumerableNFT__OutOfBoundsIndex(uint256 index);
    error EnumerableNFT__TotalSupplyReached();
    error EnumerableNFT__OutOfBoundsTokenId();

    //OWNERSHIP TRACKING
    mapping(address => uint256[]) private s_ownedTokens;
    mapping(uint256 => uint256) private s_ownedTokensIndex;
    uint256[] private s_allTokens;
    mapping(uint256 => uint256) private s_allTokensIndex;

    //CONSTANTS
    uint256 public constant MAX_SUPPLY = 20;
    uint256 public constant MAX_TOKEN_ID = 100;

    /// @dev Initializes the contract by setting a name and a symbol
    constructor() ERC721("EnumerableNFT", "ENFT") {}

    /// @notice Retrieves the total supply of NFTs
    /// @dev Calls the length function from the s_allTokens array
    /// @return The total number of tokens minted
    function totalSupply() public view override returns (uint256) {
        return s_allTokens.length;
    }

    /// @notice Mints a new NFT with a given ID and assigns it to a given user
    /// @dev Mints a new NFT with the given ID and assigns it to the given user
    /// @param _to The address of the user that will own the minted NFT
    /// @param _tokenId The ID of the minted NFT
    function mint(address _to, uint256 _tokenId) external {
        if (totalSupply() >= MAX_SUPPLY) {
            revert EnumerableNFT__TotalSupplyReached();
        }

        if (_tokenId == 0 || _tokenId > MAX_TOKEN_ID) {
            revert EnumerableNFT__OutOfBoundsTokenId();
        }
        _safeMint(_to, _tokenId);
        s_allTokensIndex[_tokenId] = s_allTokens.length;
        s_allTokens.push(_tokenId);
        s_ownedTokens[_to].push(_tokenId);
        s_ownedTokensIndex[_tokenId] = s_ownedTokens[_to].length;
    }

    /// @notice Retrieves the token ID of an NFT owned by a given user at a given index
    /// @dev Calls the getOwnedTokens function to retrieve the list of owned tokens and then returns the token at the given index
    /// @param _owner The address of the user whose owned NFT ID will be retrieved
    /// @param _index The index of the owned NFT ID to retrieve
    /// @return The token ID of the NFT owned by the user at the given index
    function tokenOfOwnerByIndex(
        address _owner,
        uint256 _index
    ) public view override returns (uint256) {
        if (_index >= balanceOf(_owner)) {
            revert EnumerableNFT__OutOfBoundsIndex(_index);
        }
        return s_ownedTokens[_owner][_index];
    }

    /// @notice Retrieves the token ID of an NFT at a given index
    /// @dev Returns the token ID at the given index from the s_allTokens array
    /// @param _index The index of the NFT ID to retrieve
    /// @return The token ID of the NFT at the given index
    function tokenByIndex(
        uint256 _index
    ) public view override returns (uint256) {
        if (_index >= totalSupply()) {
            revert EnumerableNFT__OutOfBoundsIndex(_index);
        }
        return s_allTokens[_index];
    }

    /// @notice Retrieves the list of NFT IDs owned by a given user
    /// @dev Returns the list of owned tokens for the given user
    /// @param _owner The address of the user whose owned NFT IDs will be retrieved
    /// @return The list of NFT IDs owned by the user
    function getOwnedTokens(
        address _owner
    ) public view returns (uint256[] memory) {
        return s_ownedTokens[_owner];
    }
}
