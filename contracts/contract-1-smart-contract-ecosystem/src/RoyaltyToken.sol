// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RoyaltyToken is ERC20 {
    address immutable i_nft;

    constructor(address _nft) ERC20("RoyaltyToken", "RT") {
        i_nft = _nft;
    }
}
