// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import {Ownable, Ownable2Step} from "@openzeppelin/contracts/access/Ownable2Step.sol";
import "@openzeppelin/contracts/utils/structs/Bitmaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
//Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
contract NFT is ERC165, ERC721, ERC2981, Ownable, Ownable2Step {
    error NFT__InvalidData();
    error NFT__AmountOverMaximum();
    error NFT__NotEnoughMoney();
    error NFT__WithdrawFailed();

    //STORAGE

    //CONSTANTS
    uint80 public constant MAX_SUPPLY = 1_000;
    uint96 public constant ROYALTY_REWARD_RATE = 250;
    uint40 public constant REDUCED_PRICE = 20;
    uint40 public constant REGULAR_PRICE = 100;

    //MERKLE TREE
    bytes32 private immutable s_merkleRoot;

    //OWNER
    address s_pendingOwner;

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

    function mint(uint256 _index) external payable {
        if (_index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }

        if (msg.value < REDUCED_PRICE) {
            revert NFT__NotEnoughMoney();
        }
        _mint(msg.sender, _index);
    }

    function mintWithDiscount(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata _proof
    ) external payable {
        if (index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }
        if (msg.value < REDUCED_PRICE) {
            revert NFT__NotEnoughMoney();
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

        _mint(msg.sender, index);
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

    //INTERNAL

    function _transferOwnership(
        address _newOwner
    ) internal override(Ownable, Ownable2Step) {
        s_pendingOwner = address(0);
        super._transferOwnership(_newOwner);
    }
}
