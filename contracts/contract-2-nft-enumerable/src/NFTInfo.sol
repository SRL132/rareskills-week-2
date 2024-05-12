// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {EnumerableNFT} from "./EnumerableNFT.sol";

/// @title Contract that retrieves information about an NFT
/// @author Sergi Roca Laguna
/// @notice You can use this contract to get information about an NFT
/// @dev This contract is meant to be used with an NFT contract that inherits from EnumerableNFT
contract NFTInfo {
    address public immutable i_nft;

    /// @notice The constructor only stores the address of the NFT contract
    /// @dev The NFT takes the address of the EnumerableNFT contract
    /// @param _nft The address of the NFT contract the info will be retrieved from
    constructor(address _nft) {
        i_nft = _nft;
    }

    /// @notice Retrieves the total supply of the NFTs with Prime IDs owned by a given user
    /// @dev Calls the totalSupply function from the EnumerableNFT contract
    /// @param _account The address of the user whose owned NFT IDs will be retrieved from
    /// @return The total number of tokens owned by the user which have prime numbers as ID
    function primeBalanceOf(address _account) external view returns (uint256) {
        unchecked {
            uint256[] memory ownedTokens = EnumerableNFT(i_nft).getOwnedTokens(
                _account
            );
            uint256 ownedTokensLength = ownedTokens.length;
            uint256 balance = 0;
            uint256 i = 0;

            do {
                if (_isPrimeNumber(ownedTokens[i])) {
                    ++balance;
                }
                ++i;
            } while (i < ownedTokensLength);

            return balance;
        }
    }

    /// @notice Helper function to check if a number is prime
    /// @dev Checks if a number is prime
    /// @param _number The number to check if it is prime
    /// @return True if the number is prime, false otherwise
    function _isPrimeNumber(uint256 _number) internal pure returns (bool) {
        unchecked {
            if (_number < 2) {
                return false;
            }

            if (_number == 2 || _number == 3) {
                return true;
            }

            if (_number % 2 == 0 || _number % 3 == 0) {
                return false;
            }

            uint256 i = 5;
            while (i * i <= _number) {
                if (_number % i == 0 || _number % (i + 2) == 0) {
                    return false;
                }
                i += 6;
            }

            return true;
        }
    }
}
