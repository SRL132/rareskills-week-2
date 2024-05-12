// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
interface IRewardToken {
    function mint(address to, uint256 amount) external;

    function transfer(address to, uint256 amount) external;
}
