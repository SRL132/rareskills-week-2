// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RewardToken} from "../src/RewardToken.sol";

contract RewardTokenTest is Test {
    RewardToken public rewardToken;

    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");

    function setUp() public {
        vm.startPrank(owner);
        rewardToken = new RewardToken();
        vm.stopPrank();
    }

    function testInitialSupply() public view {
        assertEq(rewardToken.balanceOf(owner), 0);
    }

    function testIfNotEventHandlerCannotMint() public {
        vm.startPrank(user);
        vm.expectRevert();
        rewardToken.mint(user, 100);
        vm.stopPrank();
        assertEq(rewardToken.balanceOf(user), 0);
    }

    function testHas18Decimals() public view {
        assertEq(rewardToken.decimals(), 18);
    }

    function testOnlyOwnerCanSetStakingHandler() public {
        vm.prank(user);
        vm.expectRevert();
        rewardToken.setStakingHandler(user);
    }
}
