// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

interface IMultiProxyController {
    function deployerUpdateProxy(bytes32 key, address proxy) external;
}