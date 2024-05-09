// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {EnumerableNFT} from "../src/EnumerableNFT.sol";

contract EnumerableNFTTest is Test {
    EnumerableNFT public enumerableNFT;
    address owner = makeAddr("OWNER");

    function setUp() public {
        enumerableNFT = new EnumerableNFT();
    }
}
