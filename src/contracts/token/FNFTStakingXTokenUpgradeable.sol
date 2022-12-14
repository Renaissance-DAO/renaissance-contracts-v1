// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./ERC20Upgradeable.sol";

// XTokens let you come in with some vault tokens, and leave with more! The longer you stay, the more vault tokens you get.
//
// This contract handles swapping to and from xSushi, SushiSwap's staking token.
contract FNFTStakingXTokenUpgradeable is OwnableUpgradeable, ERC20Upgradeable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 internal constant MAX_TIMELOCK = 2592000;
    IERC20Upgradeable public baseToken;

    mapping(address => uint256) internal timelock;

    event Timelocked(address user, uint256 until);

    error LockTooLong();
    error UserIsLocked();

    function __FNFTStakingXToken_init(address _baseToken, string memory name, string memory symbol) public initializer {
        __Ownable_init();
        __ERC20_init(name, symbol);
        baseToken = IERC20Upgradeable(_baseToken);
    }

    function burnXTokens(address who, uint256 _share) external onlyOwner returns (uint256) {
        // Gets the amount of xToken in existence
        uint256 totalShares = totalSupply();
        // Calculates the amount of base tokens the xToken is worth
        uint256 what = (_share * baseToken.balanceOf(address(this))) / totalShares;
        _burn(who, _share);
        baseToken.safeTransfer(who, what);
        return what;
    }

    // Needs to be called BEFORE new base tokens are deposited.
    function mintXTokens(address account, uint256 _amount, uint256 timelockLength) external onlyOwner returns (uint256) {
        // Gets the amount of Base Token locked in the contract
        uint256 totalBaseToken = baseToken.balanceOf(address(this));
        // Gets the amount of xTokens in existence
        uint256 totalShares = totalSupply();
        // If no xTokens exist, mint it 1:1 to the amount put in
        if (totalShares == 0 || totalBaseToken == 0) {
            _timelockMint(account, _amount, timelockLength);
            return _amount;
        }
        // Calculate and mint the amount of xTokens the base tokens are worth. The ratio will change overtime, as xTokens are burned/minted and base tokens deposited + gained from fees / withdrawn.
        else {
            uint256 what = (_amount * totalShares) / totalBaseToken;
            _timelockMint(account, what, timelockLength);
            return what;
        }
    }

    function timelockUntil(address account) external view returns (uint256) {
        return timelock[account];
    }

    function timelockAccount(address account, uint256 timelockLength) public onlyOwner {
        if (timelockLength >= MAX_TIMELOCK) revert LockTooLong();
        uint256 timelockFinish = block.timestamp + timelockLength;
        if (timelockFinish > timelock[account]) {
            timelock[account] = timelockFinish;
            emit Timelocked(account, timelockFinish);
        }
    }

    function _burn(address who, uint256 amount) internal override {
        if (timelock[who] >= block.timestamp) revert UserIsLocked();
        super._burn(who, amount);
    }

    function _timelockMint(address account, uint256 amount, uint256 timelockLength) internal {
        timelockAccount(account, timelockLength);
        _mint(account, amount);
    }

    function _transfer(address from, address to, uint256 value) internal override {
        if (timelock[from] >= block.timestamp) revert UserIsLocked();
        super._transfer(from, to, value);
    }
}