//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mock1155 is ERC1155 {
    constructor() ERC1155("https://renaissancelab.art/token/") {
    }

    function mint(address _to, uint256 _id, uint256 _amount) external {
        _mint(_to, _id, _amount, "");
    }
}