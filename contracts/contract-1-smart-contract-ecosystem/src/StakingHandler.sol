// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IRewardToken} from "./interfaces/IRewardToken.sol";

//24 hours = 86400 seconds
//10 erc20 per day if 1 token staked
//1 erc20 per day if
//TODO: Implement the staking rewards algorithm with rewards proportional to how many users were on each
contract StakingHandler is IERC721Receiver {
    error StakingHandler__WrongNFT();

    //STORAGE
    address immutable i_nft;
    address immutable i_rewardToken;

    //REWARD CONFIG
    uint256 public constant STAKING_REWARD = 10;
    uint256 public constant STAKING_REWARD_PERIOD = 1 days;
    uint256 public constant REWARDS_PER_DAY = 10;

    //EVENTS
    event StakingWithdrawn(
        address indexed user,
        uint256 amount,
        uint256 timestamp
    );
    event NFTStaked(address indexed user, uint256 tokenId, uint256 timestamp);

    //STAKING
    mapping(address user => mapping(uint256 tokenId => StakingState))
        public s_userToTokenToStakingState;

    mapping(uint256 blockNumber => uint256[] tokenIds)
        public s_stakedTokensPerBlock;

    mapping(address user => uint256[] tokenIds) public s_userToStakedTokens;

    //STRUCTS
    struct StakingState {
        uint256 startedBlock;
    }

    constructor(address _nft, address _rewardToken) {
        i_nft = _nft;
        i_rewardToken = _rewardToken;
    }

    //EXTERNAL FUNCTIONS
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        if (msg.sender != i_nft) {
            revert StakingHandler__WrongNFT();
        }

        s_userToTokenToStakingState[operator][tokenId] = StakingState(
            block.number
        );

        s_stakedTokensPerBlock[block.number].push(tokenId);
        s_userToStakedTokens[operator].push(tokenId);
        emit NFTStaked(operator, tokenId, block.number);
        return this.onERC721Received.selector;
    }

    function withdrawStakingRewards() external {
        IRewardToken(i_rewardToken).mint(address(this), 10);
        IERC721(i_nft).safeTransferFrom(address(this), msg.sender, 0);
        //   IRewardToken(i_rewardToken).transfer(msg.sender, 10);

        emit StakingWithdrawn(msg.sender, 0, block.number);
    }

    function withdrawStakingRewardsAndNFT(uint256[] memory _tokenIds) external {
        IRewardToken(i_rewardToken).mint(address(this), 10);
        IERC721(i_nft).safeTransferFrom(address(this), msg.sender, 0);
        //   IRewardToken(i_rewardToken).transfer(msg.sender, 10);

        emit StakingWithdrawn(msg.sender, 0, block.number);
    }

    // HELPER FUNCTIONS
    function _calculateStakingRewards() internal view returns (uint256) {
        // Implement this function
        return 0;
    }
    //VIEW FUNCTIONS
    function getStakedTokens(
        address _user
    ) external view returns (uint256[] memory) {
        return s_userToStakedTokens[_user];
    }
}
