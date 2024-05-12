// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @title A token that represents rewards for staking
/// @author Sergi Roca Laguna
/// @notice This contract represents a token that can be minted by a staking handler
/// @dev This contract inherits from ERC20
contract RewardToken is ERC20 {
    error RewardToken__OnlyStakingHandlerCanMint();
    error RewardToken__OnlyOwnerCanSetStakingHandler();

    address immutable i_owner;
    address s_stakingHandler;
    uint256 private _decimals = 18;

    /// @dev Initializes the contract by setting a name and a symbol
    constructor() ERC20("RewardToken", "RT") {
        i_owner = msg.sender;
    }

    /// @notice Mints a given amount of tokens to a given address
    /// @dev Mints a given amount of tokens to a given address
    /// @param _to The address that will receive the minted tokens
    /// @param _amount The amount of tokens to mint
    function mint(address _to, uint256 _amount) external {
        if (msg.sender != s_stakingHandler) {
            revert RewardToken__OnlyStakingHandlerCanMint();
        }
        _mint(_to, _amount);
    }

    /// @notice Sets the address of the staking handler contract, this address will use this ERC20 as staing rewards
    /// @dev Sets the address of the staking handler contract, which will mint and transfer these ERC20 tokens to the stakers
    /// @param _stakingHandler The address of the staking handler contract
    function setStakingHandler(address _stakingHandler) external {
        if (msg.sender != i_owner) {
            revert RewardToken__OnlyOwnerCanSetStakingHandler();
        }
        s_stakingHandler = _stakingHandler;
    }

    /// @notice Retrieves the number of decimals used by the token
    /// @dev Returns the number of decimals used by the token
    function decimals() public view override returns (uint8) {
        return uint8(_decimals);
    }
}
