// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {StakingHandler} from "../src/StakingHandler.sol";

contract StakingHandlerTest is Test {
    NFT public nft;
    RewardToken public rewardToken;
    StakingHandler public stakingHandler;

    uint256 public constant MAX_SUPPLY = 1_000;
    uint256 public constant BLOCKS_IN_A_DAY = 7200;
    uint256 public constant REWARD_TOKEN_PRECISION = 10e18;
    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");
    address user2 = makeAddr("USER2");
    address artist = makeAddr("ARTIST");
    address merkleTreeUser = makeAddr("MERKLE_TREE_USER");
    bytes32 merkleRoot = keccak256("merkleRoot");

    function setUp() public {
        vm.startPrank(owner);
        nft = new NFT(merkleRoot, artist);
        rewardToken = new RewardToken();
        stakingHandler = new StakingHandler(address(nft), address(rewardToken));
        rewardToken.setStakingHandler(address(stakingHandler));

        vm.stopPrank();
        vm.deal(user, 500);
        vm.deal(user2, 500);
        vm.deal(owner, 500);
    }

    function testInitialSupply() public view {
        assertEq(nft.balanceOf(owner), 0);
    }

    //MINT
    function testCanReceiveNFT() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.transferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
        assertEq(nft.balanceOf(user), 0);
    }

    function testCanWithdrawStakingRewards() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        stakingHandler.withdrawStakingRewards();
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(user), 10 * REWARD_TOKEN_PRECISION);
    }

    function testCanWithdrawNFT() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        stakingHandler.withdrawNFT(0);
        vm.stopPrank();
        assertEq(nft.balanceOf(user), 1);
    }

    function testCannotWithdrawNFTIfNotStaker() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
        vm.startPrank(owner);
        nft.buy{value: 100}(1);
        nft.safeTransferFrom(owner, address(stakingHandler), 1);
        vm.expectRevert();
        stakingHandler.withdrawNFT(0);
        vm.stopPrank();
    }
    function testCanWithdrawProportionalRewardsIfMultipleUsersSameBlock()
        public
    {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
        vm.startPrank(user2);
        nft.buy{value: 100}(1);
        nft.safeTransferFrom(user2, address(stakingHandler), 1);
        vm.stopPrank();
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        vm.prank(user);
        stakingHandler.withdrawStakingRewards();
        vm.prank(user2);
        stakingHandler.withdrawStakingRewards();

        assertEq(rewardToken.totalSupply(), 10 * REWARD_TOKEN_PRECISION);
        assertEq(rewardToken.balanceOf(user), 5 * REWARD_TOKEN_PRECISION);
        assertEq(rewardToken.balanceOf(user2), 5 * REWARD_TOKEN_PRECISION);
    }

    function testCanWithdrawProportionalRewardsIfMultipleUsersDifferentBlocks()
        public
    {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        vm.startPrank(user2);
        nft.buy{value: 100}(1);
        nft.safeTransferFrom(user2, address(stakingHandler), 1);
        vm.stopPrank();
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        vm.prank(user);
        stakingHandler.withdrawStakingRewards();
        vm.prank(user2);
        stakingHandler.withdrawStakingRewards();

        assertEq(rewardToken.totalSupply(), 20 * REWARD_TOKEN_PRECISION);
        assertEq(rewardToken.balanceOf(user), 15 * REWARD_TOKEN_PRECISION);
        assertEq(rewardToken.balanceOf(user2), 5 * REWARD_TOKEN_PRECISION);
    }

    function testWithDrawRewardsAfterHalfADay() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.roll(block.number + BLOCKS_IN_A_DAY / 2);
        stakingHandler.withdrawStakingRewards();
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(user), 5 * REWARD_TOKEN_PRECISION);
    }

    function testWithdrawAfterQuarterOfADay() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.roll(block.number + BLOCKS_IN_A_DAY / 4);
        stakingHandler.withdrawStakingRewards();
        vm.stopPrank();
        uint256 reward = (2 * REWARD_TOKEN_PRECISION) +
            (REWARD_TOKEN_PRECISION / 2);
        assertEq(rewardToken.balanceOf(user), reward);
    }

    function testGetStakedTokens() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
        uint256[] memory stakedTokens = stakingHandler.getStakedTokens(user);

        assertEq(stakedTokens.length, 1);
    }

    function testUserDepositsTwiceAndWithdraws() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        nft.buy{value: 100}(1);
        nft.safeTransferFrom(user, address(stakingHandler), 1);
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        stakingHandler.withdrawStakingRewards();
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(user), 10 * REWARD_TOKEN_PRECISION);
    }

    function testUserDepositsThreeNFTWithdrawsOneThenWithdrawRewards() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        nft.buy{value: 100}(1);
        nft.safeTransferFrom(user, address(stakingHandler), 1);
        nft.buy{value: 100}(2);
        nft.safeTransferFrom(user, address(stakingHandler), 2);
        stakingHandler.withdrawNFT(0);
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        stakingHandler.withdrawStakingRewards();
        assertEq(rewardToken.balanceOf(user), 10 * REWARD_TOKEN_PRECISION);
        assertEq(nft.balanceOf(user), 1);
        vm.roll(block.number + BLOCKS_IN_A_DAY);
        stakingHandler.withdrawStakingRewards();
        assertEq(rewardToken.balanceOf(user), 20 * REWARD_TOKEN_PRECISION);
        vm.stopPrank();
    }
}
