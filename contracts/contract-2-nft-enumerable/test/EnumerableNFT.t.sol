// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EnumerableNFT} from "../src/EnumerableNFT.sol";
import {NFTInfo} from "../src/NFTInfo.sol";

contract EnumerableNFTTest is Test {
    EnumerableNFT public enumerableNFT;
    NFTInfo public nftInfo;

    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");

    function setUp() public {
        vm.startPrank(owner);
        enumerableNFT = new EnumerableNFT();
        nftInfo = new NFTInfo(address(enumerableNFT));
        vm.stopPrank();
    }

    function testInitialSupply() public view {
        assertEq(enumerableNFT.totalSupply(), 0);
    }

    function testCanMint() public {
        vm.prank(owner);
        enumerableNFT.mint(owner, 1);
        assertEq(enumerableNFT.totalSupply(), 1);
    }

    function testCanGetOwnedTokens() public {
        vm.prank(owner);
        enumerableNFT.mint(owner, 1);
        enumerableNFT.mint(owner, 2);
        enumerableNFT.mint(owner, 3);
        uint256[] memory ownedTokens = enumerableNFT.getOwnedTokens(owner);
        assertEq(ownedTokens.length, 3);
        assertEq(ownedTokens[0], 1);
        assertEq(ownedTokens[1], 2);
        assertEq(ownedTokens[2], 3);
    }

    function testCanGetPrimeBalance() public {
        vm.startPrank(user);
        enumerableNFT.mint(user, 1);
        enumerableNFT.mint(user, 2);
        enumerableNFT.mint(user, 3);
        enumerableNFT.mint(user, 4);
        enumerableNFT.mint(user, 5);
        enumerableNFT.mint(user, 6);
        enumerableNFT.mint(user, 7);
        enumerableNFT.mint(user, 8);
        enumerableNFT.mint(user, 9);
        enumerableNFT.mint(user, 10);
        enumerableNFT.mint(user, 11);
        enumerableNFT.mint(user, 12);
        enumerableNFT.mint(user, 13);
        enumerableNFT.mint(user, 14);
        enumerableNFT.mint(user, 15);
        enumerableNFT.mint(user, 16);
        enumerableNFT.mint(user, 17);
        enumerableNFT.mint(user, 18);
        enumerableNFT.mint(user, 19);
        enumerableNFT.mint(user, 20);
        vm.stopPrank();
        assertEq(nftInfo.primeBalanceOf(user), 8);
    }

    function testCanGetPrimeBalanceWithNoPrimes() public {
        vm.startPrank(user);
        enumerableNFT.mint(user, 1);
        enumerableNFT.mint(user, 4);
        enumerableNFT.mint(user, 6);
        enumerableNFT.mint(user, 8);
        enumerableNFT.mint(user, 9);
        enumerableNFT.mint(user, 10);
        enumerableNFT.mint(user, 12);
        enumerableNFT.mint(user, 14);
        enumerableNFT.mint(user, 15);
        enumerableNFT.mint(user, 16);
        enumerableNFT.mint(user, 18);
        enumerableNFT.mint(user, 20);
        vm.stopPrank();
        assertEq(nftInfo.primeBalanceOf(user), 0);
    }
}
