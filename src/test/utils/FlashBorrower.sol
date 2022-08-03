pragma solidity 0.8.13;

import "@openzeppelin/contracts-upgradeable/interfaces/IERC3156FlashLenderUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC3156FlashBorrowerUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

contract FlashBorrower {
    IERC3156FlashLenderUpgradeable vault;
    bytes32 private constant _RETURN_VALUE = keccak256("ERC3156FlashBorrower.onFlashLoan");

    constructor(address _vault) {
      vault = IERC3156FlashLenderUpgradeable(_vault);
    }

    function goodFlashLoan(uint256 amount) external {
      vault.flashLoan(
        IERC3156FlashBorrowerUpgradeable(address(this)),
        address(vault),
        amount,
        ""
      );
    }

    function badFlashLoan(uint256 amount) external {
      vault.flashLoan(
        IERC3156FlashBorrowerUpgradeable(address(this)),
        address(vault),
        amount,
        "0x1"
      );
    }

    function onFlashLoan(address, address token, uint256 amount, uint256 fee, bytes calldata data) external returns (bytes32) {
      if (data.length == 0) {
        IERC20Upgradeable(token).approve(address(vault), amount + fee);
      }

      return _RETURN_VALUE;
    }
}