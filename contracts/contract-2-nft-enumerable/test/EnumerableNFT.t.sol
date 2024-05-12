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

    uint256 public constant PRIME_NUMBERS_BETWEEN_1_AND_20 = 8;

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
        assertEq(nftInfo.primeBalanceOf(user), PRIME_NUMBERS_BETWEEN_1_AND_20);
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

    function testCanGetPrimeBalanceTenToTen() public {
        vm.startPrank(user);
        enumerableNFT.mint(user, 10);
        enumerableNFT.mint(user, 20);
        enumerableNFT.mint(user, 30);
        enumerableNFT.mint(user, 40);
        enumerableNFT.mint(user, 50);
        enumerableNFT.mint(user, 60);
        enumerableNFT.mint(user, 70);
        enumerableNFT.mint(user, 80);
        enumerableNFT.mint(user, 90);
        enumerableNFT.mint(user, 100);
        enumerableNFT.mint(user, 15);
        enumerableNFT.mint(user, 25);
        enumerableNFT.mint(user, 35);
        enumerableNFT.mint(user, 45);
        enumerableNFT.mint(user, 55);
        enumerableNFT.mint(user, 65);
        enumerableNFT.mint(user, 75);
        enumerableNFT.mint(user, 85);
        enumerableNFT.mint(user, 97);
        enumerableNFT.mint(user, 68);
        vm.stopPrank();
        assertEq(nftInfo.primeBalanceOf(user), 1);
    }
}
