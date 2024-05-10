// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/structs/Bitmaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

//Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
contract NFT is
    ERC165,
    ERC721,
    ERC2981,
    Ownable,
    Ownable2Step,
    ReentrancyGuard
{
    using BitMaps for BitMaps.BitMap;

    error NFT__InvalidData();
    error NFT__AmountOverMaximum();
    error NFT__NotEnoughMoney();
    error NFT__WithdrawFailed();
    error NFT__AlreadyClaimed();

    //STORAGE

    //CONSTANTS
    uint80 public constant MAX_SUPPLY = 1_000;
    uint96 public constant ROYALTY_REWARD_RATE = 250;
    uint40 public constant REDUCED_PRICE = 20;
    uint40 public constant REGULAR_PRICE = 100;

    //MERKLE TREE
    bytes32 private immutable s_merkleRoot;

    //BITMAP   EnumerableMap? https://docs.openzeppelin.com/contracts/4.x/api/utils#BitMaps
    BitMaps.BitMap private s_claimedBitMap;

    //OWNER
    address s_pendingOwner;

    //EVENTS
    event BoughtWithDiscount(
        address indexed user,
        uint256 indexed index,
        uint256 amount
    );

    //STAKING
    address immutable i_stakingHandler;

    event Bought(address indexed user, uint256 indexed index, uint256 amount);

    //FUNCTIONS
    modifier onlyPendingOwner() {
        address sender = _msgSender();
        if (s_pendingOwner != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _;
    }

    constructor(
        bytes32 _merkleRoot
    ) ERC721("MerkleNFT", "MNFT") Ownable(msg.sender) {
        _setDefaultRoyalty(msg.sender, ROYALTY_REWARD_RATE);
        s_merkleRoot = _merkleRoot;
    }

    //EXTERNAL
    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC165, ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    function buy(uint256 _index) external payable {
        if (_index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }

        if (isClaimed(_index)) {
            revert NFT__AlreadyClaimed();
        }

        if (msg.value < REDUCED_PRICE) {
            revert NFT__NotEnoughMoney();
        }

        s_claimedBitMap.setTo(_index, true);
        _mint(msg.sender, _index);

        emit Bought(msg.sender, _index, msg.value);
    }

    function buyWithDiscount(
        uint256 index,
        uint256 amount,
        bytes32[] calldata _proof
    ) external payable nonReentrant {
        if (index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }

        if (msg.value < REDUCED_PRICE) {
            revert NFT__NotEnoughMoney();
        }

        if (isClaimed(index)) {
            revert NFT__AlreadyClaimed();
        }

        if (
            !MerkleProof.verify(
                _proof,
                s_merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            )
        ) {
            revert NFT__InvalidData();
        }
        s_claimedBitMap.setTo(index, true);
        _mint(msg.sender, index);
        emit BoughtWithDiscount(msg.sender, index, amount);
    }

    function buyAndTransfer(uint256 index, address to) external payable {
        if (index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }

        if (isClaimed(index)) {
            revert NFT__AlreadyClaimed();
        }

        if (msg.value < REGULAR_PRICE) {
            revert NFT__NotEnoughMoney();
        }

        s_claimedBitMap.setTo(index, true);
        _mint(to, index);
        safeTransferFrom(msg.sender, to, index, "");

        emit Bought(to, index, msg.value);
    }

    function buyWithDiscountAndTransfer(
        uint256 index,
        uint256 amount,
        bytes32[] memory _proof,
        address transferTo
    ) external payable nonReentrant {
        if (index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }

        if (msg.value < REDUCED_PRICE) {
            revert NFT__NotEnoughMoney();
        }

        if (isClaimed(index)) {
            revert NFT__AlreadyClaimed();
        }

        if (
            !MerkleProof.verify(
                _proof,
                s_merkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            )
        ) {
            revert NFT__InvalidData();
        }
        s_claimedBitMap.setTo(index, true);
        _mint(msg.sender, index);
        safeTransferFrom(msg.sender, transferTo, index, "");
        emit BoughtWithDiscount(msg.sender, index, amount);
    }

    function withdrawFunds() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        if (!success) {
            revert NFT__WithdrawFailed();
        }
    }

    //PUBLIC

    function transferOwnership(
        address _newOwner
    ) public override(Ownable, Ownable2Step) onlyOwner {
        s_pendingOwner = _newOwner;
    }

    function acceptOwnership() public override(Ownable2Step) onlyPendingOwner {
        _transferOwnership(msg.sender);
    }

    function isClaimed(uint256 index) public view returns (bool) {
        return s_claimedBitMap.get(index);
    }

    //INTERNAL

    function _transferOwnership(
        address _newOwner
    ) internal override(Ownable, Ownable2Step) {
        s_pendingOwner = address(0);
        super._transferOwnership(_newOwner);
    }
}
