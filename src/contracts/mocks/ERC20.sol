//SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";

contract MockERC20Upgradeable is ERC20Upgradeable {
    function __MockERC20Upgradeable_init(string calldata _name, string calldata _symbol) external initializer {
        __ERC20_init(_name, _symbol);
    }

    function mint(address to, uint256 amount) external payable {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external payable {
        _burn(from, amount);
    }
}