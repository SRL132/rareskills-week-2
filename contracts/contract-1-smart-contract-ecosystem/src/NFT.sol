// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/Bitmaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract NFT is ERC165, ERC721, ERC2981, Ownable, Ownable2Step {
    using BitMaps for BitMaps.BitMap;

    error NFT__InvalidData();
    error NFT__AmountOverMaximum();
    error NFT__NotEnoughMoney();
    error NFT__WithdrawFailed();
    error NFT__AlreadyClaimed();

    //STORAGE

    //CONSTANTS
    uint256 public constant MAX_SUPPLY = 1_000;
    uint256 public constant REDUCED_PRICE = 20;
    uint256 public constant REGULAR_PRICE = 100;
    uint96 public constant ROYALTY_REWARD_RATE = 250;
    uint256 public constant PROMISED_AMOUNT = 3;
    uint256 public constant MAX_DISCOUNT_TOKENS_AMOUNT = 3 * 256;

    //MERKLE TREE
    bytes32 private immutable s_merkleRoot;

    //BITMAP
    BitMaps.BitMap private s_claimedBitMap;

    //OWNER
    address s_pendingOwner;

    //EVENTS
    event BoughtWithDiscount(
        address indexed user,
        uint256 indexed index,
        uint256 amount
    );

    event BoughtAndStaked(
        address indexed user,
        uint256 indexed index,
        uint256 amount
    );

    //STAKING
    address s_stakingHandler;

    //ROYALTIES
    RoyaltyInfo private s_royalties;
    uint256 private constant ROYALTEE_FEE_DENOMINATOR = 10_000;
    uint256 private constant ROYALTIES_FEE_PRECISION = 10e18;

    //EVENTS
    event Bought(address indexed user, uint256 indexed index, uint256 amount);

    //FUNCTIONS
    modifier onlyPendingOwner() {
        address sender = _msgSender();
        if (s_pendingOwner != sender) {
            revert OwnableUnauthorizedAccount(sender);
        }
        _;
    }

    modifier applyBuyChecks(uint256 _tokenId, uint256 _price) {
        if (_tokenId >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }

        if (msg.value < _price) {
            revert NFT__NotEnoughMoney();
        }

        _;
    }

    modifier applyDiscountChecks(uint256 _index, bytes32[] calldata _proof) {
        if (_index > PROMISED_AMOUNT) {
            revert NFT__AmountOverMaximum();
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

        _;
    }

    constructor(
        bytes32 _merkleRoot,
        address _artist
    ) ERC721("MerkleNFT", "MNFT") Ownable(msg.sender) {
        _setDefaultRoyalty(_artist, ROYALTY_REWARD_RATE);
        s_merkleRoot = _merkleRoot;
    }

    //EXTERNAL
    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC165, ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    function setStakingHandler(address _stakingHandler) external onlyOwner {
        s_stakingHandler = _stakingHandler;
    }

    function buy(
        uint256 _tokenId
    ) external payable applyBuyChecks(_tokenId, REGULAR_PRICE) {
        _mint(msg.sender, _tokenId);

        emit Bought(msg.sender, _tokenId, msg.value);
    }

    function buyWithDiscount(
        uint256 _tokenId,
        uint256 _index,
        bytes32[] calldata _proof
    )
        external
        payable
        applyBuyChecks(_tokenId, REDUCED_PRICE)
        applyDiscountChecks(_index, _proof)
    {
        uint256 calculatedIndex = uint256(
            keccak256(abi.encodePacked(msg.sender, _index))
        );

        if (isClaimed(calculatedIndex)) {
            revert NFT__AlreadyClaimed();
        }
        s_claimedBitMap.set(calculatedIndex);
        _mint(msg.sender, _tokenId);
        emit BoughtWithDiscount(msg.sender, _tokenId, msg.value);
    }

    function buyAndStake(
        uint256 _tokenId
    ) external payable applyBuyChecks(_tokenId, REGULAR_PRICE) {
        _mint(address(this), _tokenId);
        _safeTransfer(address(this), address(s_stakingHandler), _tokenId);

        emit BoughtAndStaked(msg.sender, _tokenId, msg.value);
    }

    function buyWithDiscountAndStake(
        uint256 _tokenId,
        uint256 _index,
        bytes32[] calldata _proof
    )
        external
        payable
        applyBuyChecks(_tokenId, REDUCED_PRICE)
        applyDiscountChecks(_index, _proof)
    {
        uint256 calculatedIndex = uint256(
            keccak256(abi.encodePacked(msg.sender, _index))
        );

        if (isClaimed(calculatedIndex)) {
            revert NFT__AlreadyClaimed();
        }
        s_claimedBitMap.set(calculatedIndex);
        _mint(address(this), _tokenId);
        _safeTransfer(address(this), address(s_stakingHandler), _tokenId);

        emit BoughtAndStaked(msg.sender, _tokenId, msg.value);
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
