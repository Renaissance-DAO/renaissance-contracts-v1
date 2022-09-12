// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "../proxy/IBeacon.sol";
import "./IVaultManager.sol";

interface IFNFTCollectionFactory is IBeacon {
  struct VaultFees {
      bool active;
      uint64 mintFee;
      uint64 randomRedeemFee;
      uint64 targetRedeemFee;
      uint64 randomSwapFee;
      uint64 targetSwapFee;
      uint64 bidFee;
  }

  // Read functions.
  function vaultManager() external view returns (IVaultManager);

  function eligibilityManager() external view returns (address);

  function factoryMintFee() external view returns (uint64);

  function factoryRandomRedeemFee() external view returns (uint64);

  function factoryTargetRedeemFee() external view returns (uint64);

  function factoryRandomSwapFee() external view returns (uint64);

  function factoryTargetSwapFee() external view returns (uint64);

  function factoryBidFee() external view returns (uint64);

  function vaultFees(uint256 vaultId) external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

  function flashLoanFee() external view returns (uint256);

  function maxAuctionLength() external view returns (uint256);

  function minAuctionLength() external view returns (uint256);

  function minBidIncrease() external view returns (uint256);

  // Write functions.
  function __FNFTCollectionFactory_init(address _vaultManager, address _fnftCollection) external;

  function createVault(
      address _assetAddress,
      bool is1155,
      bool allowAllItems,
      string calldata _name,
      string calldata _symbol
  ) external returns (address);

  function setEligibilityManager(address _eligibilityManager) external;

  function setFactoryFees(
    uint256 _factoryMintFee,
    uint256 _factoryRandomRedeemFee,
    uint256 _factoryTargetRedeemFee,
    uint256 _factoryRandomSwapFee,
    uint256 _factoryTargetSwapFee,
    uint256 _factoryBidFee,
    uint256 _flashLoanFee
  ) external;

  function setFactoryThresholds(
      uint256 _maxAuctionLength,
      uint256 _minAuctionLength,
      uint256 _minBidIncrease
  ) external;

  function setVaultFees(
      uint256 vaultId,
      uint256 _mintFee,
      uint256 _randomRedeemFee,
      uint256 _targetRedeemFee,
      uint256 _randomSwapFee,
      uint256 _bidFee,
      uint256 _targetSwapFee
  ) external;

  function disableVaultFees(uint256 vaultId) external;

  event FactoryThresholdsUpdated(uint256 maxAuctionLength, uint256 minAuctionLength, uint256 minBidIncrease);
  event EligibilityManagerUpdated(address oldEligManager, address newEligManager);
  event VaultCreated(uint256 indexed vaultId, address curator, address vaultAddress, address assetAddress, string name, string symbol);
  event VaultFeesUpdated(uint256 vaultId, uint256 mintFee, uint256 randomRedeemFee, uint256 targetRedeemFee, uint256 randomSwapFee, uint256 targetSwapFee, uint256 bidFee);
  event VaultFeesDisabled(uint256 vaultId);
  event FactoryFeesUpdated(uint256 mintFee, uint256 randomRedeemFee, uint256 targetRedeemFee, uint256 randomSwapFee, uint256 targetSwapFee, uint256 bidFee, uint256 flashLoanFee);

  error NotVault();
  error FeeTooHigh();
  error MaxAuctionLengthOutOfBounds();
  error MinAuctionLengthOutOfBounds();
  error MinBidIncreaseOutOfBounds();
  error ZeroAddress();
}
