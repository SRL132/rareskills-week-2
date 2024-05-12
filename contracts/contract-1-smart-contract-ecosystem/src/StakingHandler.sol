// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRewardToken} from "./interfaces/IRewardToken.sol";

contract StakingHandler is IERC721Receiver {
    using SafeERC20 for IERC20;

    error StakingHandler__WrongNFT();
    error StakingHandler__ZeroAmountStaked();

    //STORAGE
    address immutable i_nft;
    address immutable i_rewardToken;

    //REWARD CONFIG
    uint256 public constant STAKING_REWARD = 10;
    uint256 public constant STAKING_REWARD_PERIOD = 1 days;
    uint256 public constant BLOCKS_IN_A_DAY = 7200;

    uint256 s_lastRewardBlock = block.number;
    uint256 s_accRewardPerToken;

    //EVENTS
    event StakingWithdrawn(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );

    event NFTStaked(address indexed user, uint256 tokenId, uint256 timestamp);
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

    constructor(address _nft, address _rewardToken) {
        i_nft = _nft;
        i_rewardToken = _rewardToken;
    }

    //EXTERNAL FUNCTIONS
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external override returns (bytes4) {
        if (msg.sender != i_nft) {
            revert StakingHandler__WrongNFT();
        }

        _updatePool(true);
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

    function withdrawStakingRewards() external {
        _updatePool(false);
        if (s_userToUserInfo[msg.sender].amount == 0) {
            revert StakingHandler__ZeroAmountStaked();
        }
        uint256 withdrawableAmount = s_accRewardPerToken -
            s_userToUserInfo[msg.sender].rewardDebt;

        s_userToUserInfo[msg.sender].rewardDebt = s_accRewardPerToken;
        --s_userToUserInfo[msg.sender].amount;
        IERC20(i_rewardToken).safeTransfer(msg.sender, withdrawableAmount);

        emit StakingWithdrawn(msg.sender, withdrawableAmount, block.number);
    }

    function withdrawNFT() external {
        if (s_userToUserInfo[msg.sender].amount == 0) {
            revert StakingHandler__ZeroAmountStaked();
        }
        _updatePool(false);
        IRewardToken(i_rewardToken).mint(address(this), 10);
        IERC721(i_nft).safeTransferFrom(address(this), msg.sender, 0);

        emit StakingWithdrawn(msg.sender, 0, block.number);
    }

    //VIEW FUNCTIONS
    function getStakedTokens(
        address _user
    ) external view returns (uint256[] memory) {
        return s_userToStakedTokens[_user];
    }

    //INTERNAL FUNCTIONS
    function _updatePool(bool _isDeposit) internal {
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

        uint256 rewardToMint = ((block.number - s_lastRewardBlock) *
            STAKING_REWARD) / BLOCKS_IN_A_DAY;

        if (_isDeposit) {
            --tokenSupplyStaked;
        }

        s_accRewardPerToken += rewardToMint / tokenSupplyStaked;
        if (tokenSupplyStaked > 0) {
            emit TestWithdrawCalculationsInUpdate(s_accRewardPerToken);
        }
        IRewardToken(i_rewardToken).mint(address(this), rewardToMint);
        s_lastRewardBlock = block.number;
    }
}
