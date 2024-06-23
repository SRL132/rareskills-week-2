// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {NFT} from "../src/NFT.sol";
import {RewardToken} from "../src/RewardToken.sol";
import {StakingHandler} from "../src/StakingHandler.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Create2.sol";

contract NFTTest is Test {
    using Create2 for bytes32;

    //CONTRACTS
    NFT public nft;
    RewardToken public rewardToken;
    StakingHandler public stakingHandler;

    //MERKLE TREE
    bytes32 public root;
    bytes32[] leafs;
    bytes32[] public layer2;
    bytes32[] public proof;
    address proofAddress = user1;
    uint256 public constant AMOUNT_PROMISED = 3;

    //DISCOUNT USERS
    address user1 = 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2;
    address user2 = 0x2d886570A0dA04885bfD6eb48eD8b8ff01A0eb7e;
    address user3 = 0xed857ac80A9cc7ca07a1C213e79683A1883df07B;
    address user4 = 0x690B9A9E9aa1C9dB991C7721a92d351Db4FaC990;

    //MOCK VARS
    address owner = makeAddr("OWNER");
    address user = makeAddr("USER");
    address artist = makeAddr("ARTIST");
    uint256 public constant MAX_SUPPLY = 1_000;
    uint256 MOCK_TOKEN_ID = 0;
    uint256 public constant EXPECTED_ROYALTY = 2;

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
        nft = new NFT(root, artist);
        rewardToken = new RewardToken();
        stakingHandler = new StakingHandler(address(nft), address(rewardToken));
        rewardToken.setStakingHandler(address(stakingHandler));
        nft.setStakingHandler(address(stakingHandler));
        vm.stopPrank();
        vm.deal(user, 500);
        vm.deal(user1, 500);
    }

    function testInitialSupply() public view {
        assertEq(nft.balanceOf(owner), 0);
    }

    function testCanBuy() public {
        vm.prank(user);
        nft.buy{value: 100}(MOCK_TOKEN_ID);
        assertEq(nft.balanceOf(user), 1);
    }

    function testCannotBuyWithoutEnoughMoney() public {
        vm.prank(user);
        vm.expectRevert();
        nft.buy{value: 10}(MOCK_TOKEN_ID);
    }

    function testCannotBuySameIndexTwice() public {
        vm.prank(user);
        nft.buy{value: 100}(MOCK_TOKEN_ID);
        vm.expectRevert();
        nft.buy{value: 100}(MOCK_TOKEN_ID);
    }

    function testCannotBuyWithDiscountIfAddressNotInMerkleTree() public {
        vm.prank(user);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscount{value: 20}(0, 1, proof);
    }

    function testCanBuyWithDiscountIfAddressInMerkleTree() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        assertEq(nft.balanceOf(user1), 1);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountIfSameIndexTwice() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        vm.expectRevert();
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID + 1, 1, proof);
        assertEq(nft.balanceOf(user1), 1);
        vm.stopPrank();
    }

    function testCannotBuyTokenIdOverMaxSupply() public {
        vm.startPrank(user1);
        vm.expectRevert();
        nft.buy{value: 100}(MAX_SUPPLY + 1);
        vm.stopPrank();
    }

    function testCanBuyWithDiscount() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        assertEq(nft.balanceOf(user1), 1);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountIfIndexIsMax() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscount{value: 20}(MAX_SUPPLY + 1, 1, proof);
        vm.stopPrank();
    }

    function testCannotBuyIfValueBelowPrice() public {
        vm.startPrank(user1);
        vm.expectRevert();
        nft.buy{value: 10}(MOCK_TOKEN_ID);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountIfValueBelowPrice() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscount{value: 10}(MOCK_TOKEN_ID, 1, proof);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountIfIndexTooLarge() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        vm.expectRevert();
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID + 1, 4, proof);
        assertEq(nft.balanceOf(user1), 1);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountIfNotEnoughMoney() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        proof[0] = bytes32(0);
        vm.expectRevert();
        nft.buyWithDiscount{value: 10}(MOCK_TOKEN_ID, 1, proof);
        vm.stopPrank();
    }

    function testCanBuyAndStake() public {
        vm.prank(user);
        nft.buyAndStake{value: 100}(MOCK_TOKEN_ID);
        assertEq(nft.balanceOf(user), 0);
        uint256[] memory stakedTokens = stakingHandler.getStakedTokens(user);
        assertEq(stakedTokens.length, 1);
    }

    function testCanBuyAndStakeWithDiscount() public {
        vm.deal(user1, 500);
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscountAndStake{value: 20}(MOCK_TOKEN_ID, 1, proof);
        assertEq(nft.balanceOf(user1), 0);
        uint256[] memory stakedTokens = stakingHandler.getStakedTokens(user1);
        assertEq(stakedTokens.length, 1);
        vm.stopPrank();
    }

    function testCannotBuyAndStakeIfNotEnoughMoney() public {
        vm.startPrank(user);
        vm.expectRevert();
        nft.buyAndStake{value: 10}(MOCK_TOKEN_ID);
        vm.stopPrank();
    }

    function testCannotBuyAndStakeIfTokenIdOverMaxSupply() public {
        vm.startPrank(user);
        vm.expectRevert();
        nft.buyAndStake{value: 100}(MAX_SUPPLY + 1);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountAndStakeIfNotEnoughMoney() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscountAndStake{value: 10}(MOCK_TOKEN_ID, 1, proof);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountAndStakeIfTokenIdOverMaxSupply() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscountAndStake{value: 20}(MAX_SUPPLY + 1, 1, proof);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountAndStakeIfAlreayClaimed() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscountAndStake{value: 20}(MOCK_TOKEN_ID, 1, proof);
        vm.expectRevert(NFT.NFT__AlreadyClaimed.selector);
        nft.buyWithDiscountAndStake{value: 20}(MOCK_TOKEN_ID, 1, proof);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountAndStakeIfNotInMerkleTree() public {
        vm.startPrank(user);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        vm.expectRevert();
        nft.buyWithDiscountAndStake{value: 20}(MOCK_TOKEN_ID, 2, proof);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountAndStakeIfIndexTooLarge() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscountAndStake{value: 20}(MOCK_TOKEN_ID, 1, proof);
        vm.expectRevert();
        nft.buyWithDiscountAndStake{value: 20}(MOCK_TOKEN_ID + 1, 4, proof);
        assertEq(nft.balanceOf(user1), 0);
        vm.stopPrank();
    }

    function testCannotBuyWithDiscountIfAlreayClaimed() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        vm.expectRevert(NFT.NFT__AlreadyClaimed.selector);
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
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
        assertEq(address(owner).balance, 100);
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

    //ROYALTY

    function testGetRoyaltyInfo() public {
        vm.prank(user);
        nft.buy{value: 100}(MOCK_TOKEN_ID);
        nft.royaltyInfo(MOCK_TOKEN_ID, 100);
        (address receiver, uint256 royalty) = nft.royaltyInfo(
            MOCK_TOKEN_ID,
            100
        );
        assertEq(receiver, artist);
        assertEq(royalty, EXPECTED_ROYALTY);
    }
    //VIEW
    function testIsClaimed() public {
        vm.startPrank(user1);
        proof[0] = leafs[1];
        proof[1] = layer2[1];
        nft.buyWithDiscount{value: 20}(MOCK_TOKEN_ID, 1, proof);
        assert(
            nft.isClaimed(
                uint256(keccak256(abi.encodePacked(user1, uint256(1))))
            )
        );
        vm.stopPrank();
    }

    function testSupportsInterface() public view {
        assert(nft.supportsInterface(0x80ac58cd));
    }

    function testCanDeployNft() public {
        NFT nft = new NFT(root, artist);
        assertEq(nft.owner(), address(this));
    }
}
