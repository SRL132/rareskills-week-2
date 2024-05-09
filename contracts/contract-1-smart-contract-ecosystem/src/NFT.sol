// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import {ERC165} from "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/utils/structs/Bitmaps.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
//Addresses in a merkle tree can mint NFTs at a discount. Use the bitmap methodology described above. Use openzeppelin’s bitmap, don’t implement it yourself.
contract NFT is ERC165, ERC721, ERC2981 {
    error NFT__InvalidData();
    error NFT__AmountOverMaximum();

    //STORAGE

    //CONSTANTS
    uint80 public constant MAX_SUPPLY = 1_000;
    uint96 public constant ROYALTY_REWARD_RATE = 250;
    uint40 public constant REDUCED_PRICE = 20;
    uint40 public constant REGULAR_PRICE = 100;

    //MERKLE TREE
    BitMaps.BitMap private s_merkleRoots;
    bytes32 private immutable s_merkleRoot;

    //FUNCTIONS

    constructor(bytes32 _merkleRoot) ERC721("MerkleNFT", "MNFT") {
        _setDefaultRoyalty(msg.sender, ROYALTY_REWARD_RATE);
        s_merkleRoot = _merkleRoot;
        BitMaps.set(s_merkleRoots, 0);
    }

    //EXTERNAL
    function supportsInterface(
        bytes4 _interfaceId
    ) public view override(ERC165, ERC721, ERC2981) returns (bool) {
        return super.supportsInterface(_interfaceId);
    }

    function mint(uint256 _index) external {
        if (_index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }
        _mint(msg.sender, _index);
    }

    function mintWithDiscount(
        uint256 index,
        address account,
        uint256 amount,
        bytes32[] calldata proof
    ) external {
        if (index >= MAX_SUPPLY) {
            revert NFT__AmountOverMaximum();
        }
        bytes32 node = keccak256(abi.encodePacked(index, account, amount));
        if (!MerkleProof.verify(proof, s_merkleRoot, node)) {
            revert NFT__InvalidData();
        }

        _mint(msg.sender, index);
    }
}
