//SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/// @notice An implementation of Wrapped Ether. 
/// @author Anderson Singh. 
contract WETH is ERC20 {

    constructor(uint256 _wethAmount) ERC20("Wrapped Ether", "WETH") {
        _mint(msg.sender, _wethAmount);
    }

    /// @dev mint tokens for sender based on amount of ether sent. 
    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    /// @dev withdraw ether based on requested amount and user balance. 
    function withdraw(uint _amount) external {
        require(balanceOf(msg.sender) >= _amount, "insufficient balance.");
        _burn(msg.sender, _amount);
        payable(msg.sender).transfer(_amount);
    }
}