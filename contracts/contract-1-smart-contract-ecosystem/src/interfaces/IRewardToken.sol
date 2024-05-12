// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;
interface IRewardToken {
    function mint(address _to, uint256 _amount) external;

    function transfer(address _to, uint256 _amount) external;
}
