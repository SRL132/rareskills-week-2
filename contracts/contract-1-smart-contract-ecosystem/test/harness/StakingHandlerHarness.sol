// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import {StakingHandler} from "../../src/StakingHandler.sol";

contract StakingHandlerHardness is StakingHandler {
    constructor(
        address nft,
        address rewardToken
    ) StakingHandler(nft, rewardToken) {}

    function updateRewards_HARNESS(bool isDeposit) public {
        _updateRewards(isDeposit);
    }
}
