// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EnumerableNFT} from "../src/EnumerableNFT.sol";
import {NFTInfo} from "../src/NFTInfo.sol";

contract EnumerableNFTTest is Test {
    EnumerableNFT public enumerableNFT;
    NFTInfo public nftInfo;

    address owner = makeAddr("OWNER");

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

        assertEq(enumerableNFT.totalSupply(), 1);
    }
}
