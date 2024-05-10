// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {RoyaltyToken} from "../src/RoyaltyToken.sol";
import {StakingHandler} from "../src/StakingHandler.sol";

contract StakingHandlerTest is Test {
    NFT public nft;
    RoyaltyToken public royaltyToken;
    StakingHandler public stakingHandler;

    uint256 public constant MAX_SUPPLY = 1_000;
    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");
    address user2 = makeAddr("USER2");
    address merkleTreeUser = makeAddr("MERKLE_TREE_USER");
    bytes32 merkleRoot = keccak256("merkleRoot");

    function setUp() public {
        vm.startPrank(owner);
        nft = new NFT(merkleRoot);
        royaltyToken = new RoyaltyToken(address(nft));
        stakingHandler = new StakingHandler(
            address(nft),
            address(royaltyToken)
        );
        vm.stopPrank();
        vm.deal(user, 500);
    }

    function testInitialSupply() public view {
        assertEq(nft.balanceOf(owner), 0);
    }

    //MINT
    function testCanReceiveNFT() public {
        vm.startPrank(user);
        nft.mint{value: 100}(0);
        nft.transferFrom(user, address(stakingHandler), 0);
        vm.stopPrank();
    }

    function testCanWithdrawStakingRewards() public {
        vm.startPrank(user);
        nft.mint{value: 100}(0);
        nft.transferFrom(user, address(stakingHandler), 0);
        stakingHandler.withdrawStakingRewards();
        vm.stopPrank();
    }
}
