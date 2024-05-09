// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {IERC721Receiver} from "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {ERC20 as erc20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract StakingHandler is IERC721Receiver {
    address immutable i_nft;
    address immutable i_royaltyToken;

    event StakingWithdrawn(address indexed user, uint256 amount);
    event NFTStaked(address indexed user, uint256 tokenId);

    constructor(address _nft, address _royaltyToken) {
        i_nft = _nft;
        i_royaltyToken = _royaltyToken;
    }

    //EXTERNAL FUNCTIONS

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        emit NFTStaked(from, tokenId);
        return this.onERC721Received.selector;
    }

    function withdrawStakingRewards() external {
        // Implement this function
        IERC721(i_nft).safeTransferFrom(msg.sender, address(0), 0);
        erc20(i_royaltyToken).transfer(msg.sender, 0);

        emit StakingWithdrawn(msg.sender, 0);
    }

    // HELPER FUNCTIONS
    function _calculateStakingRewards() internal view returns (uint256) {
        // Implement this function
        return 0;
    }
}
