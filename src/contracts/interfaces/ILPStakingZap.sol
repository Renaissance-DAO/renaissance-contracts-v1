// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./IWETH.sol";
import "./ILPStaking.sol";
import "./IVaultManager.sol";
import "./IUniswapV2Router.sol";

interface ILPStakingZap {
    function WETH() external returns(IWETH);

    function vaultManager() external returns(IVaultManager);

    function router() external returns(IUniswapV2Router);

    function lpStaking() external returns(ILPStaking);

    function lpLockTime() external returns(uint256);

    function assignLPStakingContract() external;

    function rescue(address token) external;

    function setLPLockTime(uint256 _lpLockTime) external;

    function stakeLiquidityETH(
		uint256 vaultId,
        uint256 minTokenIn,
        uint256 wethIn,
        address to
	) external payable returns (uint256, uint256, uint256);

    function stakeLiquidityWETH(
		uint256 vaultId,
        uint256 minTokenIn,
        uint256 minWethIn,
        uint256 wethIn,
        address to
	) external returns (uint256, uint256, uint256);

    function unlockAndRemoveLiquidityETH(
        uint256 vaultId,
        uint256 amount,
        uint256 minTokenOut,
        uint256 minEthOut,
        address to
    ) external returns (uint256, uint256);

    function unlockAndRemoveLiquidityWETH(
        uint256 vaultId,
        uint256 amount,
        uint256 minTokenOut,
        uint256 minEthOut,
        address to
    ) external returns (uint256, uint256);

    event UserStaked(uint256 indexed vaultId, address indexed sender, uint256 count, uint256 lpBalance, uint256 timelockUntil);
    event LPLockTimeUpdated(uint256 oldLockTime, uint256 newLockTime);

    error CallFailed();
    error IdenticalAddress();
    error InvalidDestination();
    error LockTooLong();
    error NotExcluded();
    error NotZeroAddress();
    error OnlyWETH();
    error ZeroAddress();
}
