// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRewardToken} from "./interfaces/IRewardToken.sol";

/// @title A contract that handles staking of NFTs and rewards users with a reward token
/// @author Sergi Roca Laguna
/// @notice This contract allows users to stake NFTs and receive rewards in a reward token
/// @dev This contract inherits from IERC721Receiver
contract StakingHandler is IERC721Receiver {
    using SafeERC20 for IERC20;

    error StakingHandler__WrongNFT();
    error StakingHandler__ZeroAmountStaked();
    error StakingHandler__NotTokenOwner();

    //STORAGE
    address immutable i_nft;
    address immutable i_rewardToken;

    //REWARD CONFIG
    uint256 public constant STAKING_REWARD = 10;
    uint256 public constant STAKING_REWARD_PERIOD = 1 days;
    uint256 public constant BLOCKS_IN_A_DAY = 7200;
    uint256 public constant REWARD_TOKEN_PRECISION = 10e18;

    uint256 s_lastRewardBlock = block.number;
    uint256 s_accRewardPerToken;

    //EVENTS
    event StakingWithdrawn(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event NFTStaked(address indexed user, uint256 tokenId, uint256 timestamp);
    event NFTWithdrawn(
        address indexed user,
        uint256 tokenId,
        uint256 timestamp
    );
    event TestWithdrawCalculationsInUpdate(uint256 accRewardPerToken);
    event TestTokenSupplyStaked(uint256 tokenSupplyStaked);

    //STAKING
    mapping(address user => mapping(uint256 tokenId => StakingState))
        public s_userToTokenToStakingState;

    mapping(address user => uint256[] tokenIds) public s_userToStakedTokens;

    mapping(address user => UserInfo) public s_userToUserInfo;

    //STRUCTS
    struct StakingState {
        uint256 startedBlock;
        uint256 startingAccRewardPerToken;
    }

    struct UserInfo {
        uint256 amount;
        uint256 rewardDebt;
    }

    /// @notice Initializes the contract with the NFT and reward token addresses
    /// @dev Initializes the contract with the NFT and reward token addresses
    /// @param _nft The address of the NFT contract
    /// @param _rewardToken The address of the reward token contract
    constructor(address _nft, address _rewardToken) {
        i_nft = _nft;
        i_rewardToken = _rewardToken;
    }

    //EXTERNAL FUNCTIONS

    /// @notice Receives an NFT and stakes it for the sender
    /// @dev Receives an NFT and stakes it for the sender
    /// @param _operator The address of the user that sent the NFT
    /// @param _from The address of the user that sent the NFT
    /// @param _tokenId The ID of the NFT that was sent
    /// @param _data Additional data sent with the NFT
    /// @return The ERC721Received selector
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        if (msg.sender != i_nft) {
            revert StakingHandler__WrongNFT();
        }

        _updateRewards(true);
        unchecked {
            ++s_userToUserInfo[_operator].amount;
        }
        s_userToUserInfo[_operator].rewardDebt += s_accRewardPerToken;
        s_userToTokenToStakingState[_operator][_tokenId] = StakingState(
            block.number,
            s_accRewardPerToken
        );

        s_userToStakedTokens[_operator].push(_tokenId);

        emit NFTStaked(_operator, _tokenId, block.number);
        return this.onERC721Received.selector;
    }

    /// @notice Withdraws the staking rewards for the sender
    /// @dev Withdraws the corresponding minted ERC20 minted tokens for the sender
    function withdrawStakingRewards() external {
        _updateRewards(false);
        if (s_userToUserInfo[msg.sender].amount == 0) {
            revert StakingHandler__ZeroAmountStaked();
        }
        uint256 withdrawableAmount = s_accRewardPerToken -
            s_userToUserInfo[msg.sender].rewardDebt;

        s_userToUserInfo[msg.sender].rewardDebt = s_accRewardPerToken;
        IERC20(i_rewardToken).safeTransfer(msg.sender, withdrawableAmount);

        emit StakingWithdrawn(msg.sender, withdrawableAmount, block.number);
    }

    /// @notice Withdraws the NFT staked by the sender
    /// @dev Withdraws the NFT staked by the sender
    function withdrawNFT(uint256 _tokenId) external {
        if (s_userToUserInfo[msg.sender].amount == 0) {
            revert StakingHandler__ZeroAmountStaked();
        }

        if (
            s_userToTokenToStakingState[msg.sender][_tokenId].startedBlock == 0
        ) {
            revert StakingHandler__NotTokenOwner();
        }

        --s_userToUserInfo[msg.sender].amount;

        IERC721(i_nft).safeTransferFrom(address(this), msg.sender, 0);

        emit NFTWithdrawn(msg.sender, _tokenId, block.number);
    }

    //VIEW FUNCTIONS

    /// @notice Retrieves the staked tokens of a given user
    /// @dev Retrieves the staked tokens of a given user address
    /// @param _user The address of the user whose staked tokens will be retrieved
    /// @return An array of token IDs representing the staked tokens of the user
    function getStakedTokens(
        address _user
    ) external view returns (uint256[] memory) {
        return s_userToStakedTokens[_user];
    }

    //INTERNAL FUNCTIONS

    /// @dev Updates the rewards by minting new reward tokens and updating storage variables accordingly
    /// @param _isDeposit A boolean that indicates if the update is due to a deposit or not
    function _updateRewards(bool _isDeposit) internal {
        if (block.number <= s_lastRewardBlock) {
            return;
        }

        uint256 tokenSupplyStaked = IERC721(i_nft).balanceOf(address(this));

        emit TestTokenSupplyStaked(tokenSupplyStaked);

        if (tokenSupplyStaked == 0) {
            s_lastRewardBlock = block.number;
            return;
        }
        if (s_lastRewardBlock == 0) {
            s_lastRewardBlock = block.number;
            return;
        }

        uint256 elapsedBlocks = block.number - s_lastRewardBlock;
        uint256 totalReward = elapsedBlocks * STAKING_REWARD;

        uint256 rewardToMint = (totalReward * REWARD_TOKEN_PRECISION) /
            BLOCKS_IN_A_DAY;
        uint256 remainder = (totalReward * REWARD_TOKEN_PRECISION) %
            BLOCKS_IN_A_DAY;

        rewardToMint += remainder;
        if (_isDeposit) {
            --tokenSupplyStaked;
        }

        s_accRewardPerToken += (rewardToMint / tokenSupplyStaked);
        if (tokenSupplyStaked > 0) {
            emit TestWithdrawCalculationsInUpdate(s_accRewardPerToken);
        }
        IRewardToken(i_rewardToken).mint(address(this), rewardToMint);
        s_lastRewardBlock = block.number;
    }
}
