// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/Bitmaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Contracts that represents an NFT that allows users to buy, claim and stake NFTs and take advantages of discounts
/// @author Sergi Roca Laguna
/// @notice This contract allows users to buy, claim and stake NFTs and take advantages of discounts
/// @dev This contract inherits from ERC721, ERC2981, Ownable and Ownable2Step
contract NFT is ERC721, ERC2981, Ownable, Ownable2Step {
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

    /// @notice Initializes the contract with the merkle root and the artist address
    /// @dev Initializes the contract with the merkle root and the artist address
    /// @param _merkleRoot The merkle root of the merkle tree
    /// @param _artist The address of the artist that will receive the royalties
    constructor(
        bytes32 _merkleRoot,
        address _artist
    ) ERC721("MerkleNFT", "MNFT") Ownable(msg.sender) {
        _setDefaultRoyalty(_artist, ROYALTY_REWARD_RATE);
        s_merkleRoot = _merkleRoot;
    }

    //EXTERNAL

    /// @notice Sets the address of the staking handler contract, this address will use this ERC20 as staing rewards
    /// @dev Allows the owner to set the address of the staking handler contract, which will mint and transfer these ERC20 tokens to the stakers
    /// @param _stakingHandler The address of the staking handler contract
    function setStakingHandler(address _stakingHandler) external onlyOwner {
        s_stakingHandler = _stakingHandler;
    }

    /// @notice Buys an NFT with a given ID
    /// @dev Mints an NFT with the given ID and assigns it to the sender
    /// @param _tokenId The ID of the NFT to buy
    function buy(
        uint256 _tokenId
    ) external payable applyBuyChecks(_tokenId, REGULAR_PRICE) {
        _mint(msg.sender, _tokenId);

        emit Bought(msg.sender, _tokenId, msg.value);
    }

    /// @notice Buys an NFT with a given ID and a discount
    /// @dev Mints an NFT with the given ID and assigns it to the sender
    /// @param _tokenId The ID of the NFT to buy
    /// @param _index The index of the discount
    /// @param _proof The merkle proof of the discount to validate if the message sender is eligible for the discount
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

    /// @notice Buys an NFT with a given ID and stakes it
    /// @dev Mints an NFT with the given ID and assigns it to the contract, then transfers it to the staking handler
    /// @param _tokenId The ID of the NFT to buy
    function buyAndStake(
        uint256 _tokenId
    ) external payable applyBuyChecks(_tokenId, REGULAR_PRICE) {
        _mint(address(this), _tokenId);
        _safeTransfer(address(this), address(s_stakingHandler), _tokenId);

        emit BoughtAndStaked(msg.sender, _tokenId, msg.value);
    }

    /// @notice Buys an NFT with a given ID and a discount and stakes it
    /// @dev Mints an NFT with the given ID and assigns it to the contract, then transfers it to the staking handler
    /// @param _tokenId The ID of the NFT to buy
    /// @param _index The index of the discount
    /// @param _proof The merkle proof of the discount to validate if the message sender is eligible for the discount
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

    /// @notice Withdraws the funds from the contract
    /// @dev Allows the owner to withdraw the funds from the contract
    function withdrawFunds() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");

        if (!success) {
            revert NFT__WithdrawFailed();
        }
    }

    //PUBLIC

    ///@inheritdoc ERC2981
    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    ///@notice Allows the owner to transfer the ownership of the contract
    ///@dev Allows the owner to transfer the ownership of the to another addresss. The new owner must accept the ownership before becoming the owner
    ///@param _newOwner The address of the new owner
    function transferOwnership(
        address _newOwner
    ) public override(Ownable, Ownable2Step) onlyOwner {
        s_pendingOwner = _newOwner;
    }

    ///@notice Allows the pending owner to accept the ownership of the contract
    ///@dev Allows the pending owner to accept the ownership of the contract, which has been set via the transferOwnership function
    function acceptOwnership() public override(Ownable2Step) onlyPendingOwner {
        _transferOwnership(msg.sender);
    }

    ///@notice Checks if a given number has been claimed by a discount user
    ///@dev Checks if a given number has been claimed by a discount user
    ///@param _index The index of the discount
    function isClaimed(uint256 _index) public view returns (bool) {
        return s_claimedBitMap.get(_index);
    }

    //INTERNAL
    ///@dev Sets the owner of the contract
    ///@param _newOwner The address of the new owner
    function _transferOwnership(
        address _newOwner
    ) internal override(Ownable, Ownable2Step) {
        s_pendingOwner = address(0);
        super._transferOwnership(_newOwner);
    }
}
