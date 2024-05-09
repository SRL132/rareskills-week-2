// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {RoyaltyToken} from "../src/RoyaltyToken.sol";
import {StakingHandler} from "../src/StakingHandler.sol";

contract NFTTest is Test {
    NFT public nft;
    RoyaltyToken public royaltyToken;
    StakingHandler public stakingHandler;

    uint256 public constant FIXED_SUPPLY = 1_000;
    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");
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
    }

    function testInitialSupply() public view {
        assertEq(nft.balanceOf(owner), 0);
    }

    function testCanMint() public {
        vm.prank(user);
        nft.mint(0);
        assertEq(nft.balanceOf(user), 1);
    }

    function testCannotMintSameIndexTwice() public {
        vm.prank(user);
        nft.mint(0);
        vm.expectRevert();
        nft.mint(0);
    }

    function testCannotMintMoreThanMaxSupply() public {
        vm.prank(user);
        vm.expectRevert();
        nft.mint(FIXED_SUPPLY);
    }

    function testCannotMintWithDiscountIfAddressNotInMerkleTree() public {
        vm.startPrank(user);
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bytes32(0);
        vm.expectRevert();
        nft.mintWithDiscount(0, user, 1, proof);
        vm.stopPrank();
    }

    function testCanMintWithDiscountIfAddressInMerkleTree() public {
        vm.startPrank(merkleTreeUser);
        bytes32[] memory proof = new bytes32[](1);
        proof[0] = bytes32(0);
        nft.mintWithDiscount(0, merkleTreeUser, 1, proof);
        assertEq(nft.balanceOf(merkleTreeUser), 1);
        vm.stopPrank();
    }
}
