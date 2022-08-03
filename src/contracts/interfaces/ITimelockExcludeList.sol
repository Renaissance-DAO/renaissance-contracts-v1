// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface ITimelockExcludeList {
    function isExcluded(address addr, uint256 vaultId) external view returns (bool);
}