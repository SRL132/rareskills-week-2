// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract RewardToken is ERC20 {
    error RewardToken__OnlyStakingHandlerCanMint();
    error RewardToken__OnlyOwnerCanSetStakingHandler();

    address immutable i_owner;
    address s_stakingHandler;
    uint256 private _decimals = 18;

    constructor() ERC20("RewardToken", "RT") {
        i_owner = msg.sender;
    }

    function mint(address _to, uint256 _amount) external {
        if (msg.sender != s_stakingHandler) {
            revert RewardToken__OnlyStakingHandlerCanMint();
        }
        _mint(_to, _amount);
    }

    function setStakingHandler(address _stakingHandler) external {
        if (msg.sender != i_owner) {
            revert RewardToken__OnlyOwnerCanSetStakingHandler();
        }
        s_stakingHandler = _stakingHandler;
    }

    function decimals() public view override returns (uint8) {
        return uint8(_decimals);
    }
}
