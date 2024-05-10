// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {RoyaltyToken} from "../src/RoyaltyToken.sol";
import {StakingHandler} from "../src/StakingHandler.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NFTTest is Test {
    //CONTRACTS
    NFT public nft;
    RoyaltyToken public royaltyToken;
    StakingHandler public stakingHandler;

    //MERKLE TREE
    bytes32 public root;
    bytes32[] leafs;
    bytes32[] public layer2;
    bytes32[] public proof;
    address proofAddress = user1;

    //DISCOUNT USERS
    address user1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address user2 = 0x2d886570A0dA04885bfD6eb48eD8b8ff01A0eb7e;
    address user3 = 0xed857ac80A9cc7ca07a1C213e79683A1883df07B;
    address user4 = 0x690B9A9E9aa1C9dB991C7721a92d351Db4FaC990;

    //MOCK VARS
    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");
    uint256 public constant MAX_SUPPLY = 1_000;
    uint256 MOCK_TOKEN_ID = 0;

    function setUp() public {
        address[] memory usersWithDiscount = new address[](4);
        usersWithDiscount[0] = user1;
        usersWithDiscount[1] = user2;
        usersWithDiscount[2] = user3;
        usersWithDiscount[3] = user4;

        leafs.push(keccak256(abi.encodePacked(usersWithDiscount[0])));
        leafs.push(keccak256(abi.encodePacked(usersWithDiscount[1])));
        leafs.push(keccak256(abi.encodePacked(usersWithDiscount[2])));
        leafs.push(keccak256(abi.encodePacked(usersWithDiscount[3])));

        layer2.push(keccak256(abi.encodePacked(leafs[0], leafs[1])));
        layer2.push(keccak256(abi.encodePacked(leafs[2], leafs[3])));

        root = keccak256(abi.encodePacked(layer2[1], layer2[0]));

        proof = [leafs[1], layer2[1]];
        vm.startPrank(owner);
        nft = new NFT(root);
        royaltyToken = new RoyaltyToken(address(nft));
        stakingHandler = new StakingHandler(
            address(nft),
            address(royaltyToken)
        );
        vm.stopPrank();
        vm.deal(user, 500);
        vm.deal(user1, 500);
    }

    function testInitialSupply() public view {
        assertEq(nft.balanceOf(owner), 0);
    }

    //MINT
    function testCanMint() public {
        vm.prank(user);
        nft.buy{value: 100}(MOCK_TOKEN_ID);
        assertEq(nft.balanceOf(user), 1);
    }

    function testCannotMintWithoutEnoughMoney() public {
        vm.prank(user);
        vm.expectRevert();
        nft.buy{value: 10}(MOCK_TOKEN_ID);
    }

    function testCannotMintSameIndexTwice() public {
        vm.prank(user);
        nft.buy{value: 100}(MOCK_TOKEN_ID);
        vm.expectRevert();
        nft.buy{value: 100}(MOCK_TOKEN_ID);
    }

    function testCannotMintMoreThanMaxSupply() public {
        vm.prank(user);
        vm.expectRevert();
        nft.buy{value: 100}(MAX_SUPPLY);
    }

    function testCannotMintWithDiscountIfAddressNotInMerkleTree(
        address _user
    ) public {
        vm.startPrank(_user);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscount{value: 20}(0, 1, proof);
        vm.stopPrank();
    }

    function testCanMintWithDiscountIfAddressInMerkleTree() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        assertEq(nft.balanceOf(user1), 1);
        vm.stopPrank();
    }

    function testCannotMintWithDiscountIfNotEnoughMoney() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        proof[0] = bytes32(0);
        vm.expectRevert();
        nft.buyWithDiscount{value: 10}(MOCK_TOKEN_ID, 1, proof);
        vm.stopPrank();
    }

    //WITHDRAW
    function testOnlyOwnerCanWithdrawFunds() public {
        vm.prank(user);
        nft.buy{value: 100}(MOCK_TOKEN_ID);
        vm.expectRevert();
        nft.withdrawFunds();
        vm.prank(owner);
        nft.withdrawFunds();
    }

    //OWNERSHIP TESTS
    function testCanTransferOwnership() public {
        vm.prank(owner);
        nft.transferOwnership(user);
        vm.prank(user);
        nft.acceptOwnership();
        assertEq(nft.owner(), user);
    }

    function testCannotTransferOwnershipIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert();
        nft.transferOwnership(user2);
    }

    function testCannotAcceptOwnershipIfNotPendingOwner() public {
        vm.prank(owner);
        nft.transferOwnership(user);
        vm.prank(user2);
        vm.expectRevert();
        nft.acceptOwnership();
    }
}
