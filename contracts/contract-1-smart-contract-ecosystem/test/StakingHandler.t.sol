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
        nft.transferFrom(user, address(stakingHandler), 0);
        stakingHandler.withdrawStakingRewards();
        vm.stopPrank();
    }

    function testGetStakedTokens() public {
        vm.startPrank(user);
        nft.buy{value: 100}(0);
        nft.safeTransferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
        uint256[] memory stakedTokens = stakingHandler.getStakedTokens(user);

        assertEq(stakedTokens.length, 1);
    }
}
