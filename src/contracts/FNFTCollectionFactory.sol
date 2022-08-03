// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./interfaces/IFNFTCollectionFactory.sol";
import "./interfaces/IOwnable.sol";
import "./interfaces/IVaultManager.sol";
import "./proxy/BeaconProxy.sol";
import "./proxy/BeaconUpgradeable.sol";
import "./util/Pausable.sol";

// Authors: @0xKiwi_ and @alexgausman.

contract FNFTCollectionFactory is
    IFNFTCollectionFactory,
    Pausable,
    BeaconUpgradeable
{
    mapping(uint256 => VaultFees) private _vaultFees;

    uint64 public override factoryMintFee;
    uint64 public override factoryRandomRedeemFee;
    uint64 public override factoryRandomSwapFee;
    uint64 public override factoryTargetRedeemFee;

    IVaultManager public override vaultManager;
    uint64 public override factoryTargetSwapFee;

    address public override eligibilityManager;
    uint256 public override flashLoanFee;

    /// @notice the maximum auction length
    uint256 public override maxAuctionLength;

    /// @notice the minimum auction length
    uint256 public override minAuctionLength;

    /// @notice the % bid increase required for a new bid
    uint256 public override minBidIncrease;

    function __FNFTCollectionFactory_init(address _vaultManager, address _fnftCollection) external override initializer {
        if (_vaultManager == address(0)) revert ZeroAddress();
        if (_fnftCollection == address(0)) revert ZeroAddress();
        __Pausable_init();
        __BeaconUpgradeable__init(_fnftCollection);
        vaultManager = IVaultManager(_vaultManager);
        factoryMintFee = uint64(0.1 ether);
        factoryRandomRedeemFee = uint64(0.05 ether);
        factoryTargetRedeemFee = uint64(0.1 ether);
        factoryRandomSwapFee = uint64(0.05 ether);
        factoryTargetSwapFee = uint64(0.1 ether);
        maxAuctionLength = 2 weeks;
        minAuctionLength = 3 days;
        minBidIncrease = 500; // 5%
    }

    function createVault(
        address _assetAddress,
        bool is1155,
        bool allowAllItems,
        string memory _name,
        string memory _symbol
    ) external virtual override returns (address) {
        onlyOwnerIfPaused(0);
        if (childImplementation() == address(0)) revert ZeroAddress();
        IVaultManager _vaultManager = vaultManager;
        address fnftCollection = _deployVault(_name, _symbol, _assetAddress, is1155, allowAllItems);
        uint vaultId = _vaultManager.addVault(fnftCollection);
        emit VaultCreated(vaultId, msg.sender, fnftCollection, _assetAddress, _name, _symbol);
        return fnftCollection;
    }

    function setEligibilityManager(address _eligibilityManager) external virtual override onlyOwner {
        emit EligibilityManagerUpdated(eligibilityManager, _eligibilityManager);
        eligibilityManager = _eligibilityManager;
    }

    function vaultFees(uint256 vaultId) external view virtual override returns (uint256, uint256, uint256, uint256, uint256) {
        VaultFees memory fees = _vaultFees[vaultId];
        if (fees.active) {
            return (
                uint256(fees.mintFee),
                uint256(fees.randomRedeemFee),
                uint256(fees.targetRedeemFee),
                uint256(fees.randomSwapFee),
                uint256(fees.targetSwapFee)
            );
        }

        return (uint256(factoryMintFee), uint256(factoryRandomRedeemFee), uint256(factoryTargetRedeemFee), uint256(factoryRandomSwapFee), uint256(factoryTargetSwapFee));
    }

    function disableVaultFees(uint256 vaultId) public virtual override {
        if (msg.sender != owner()) {
            address vaultAddr = vaultManager.vault(vaultId);
            if (msg.sender != vaultAddr) revert NotVault();
        }
        delete _vaultFees[vaultId];
        emit VaultFeesDisabled(vaultId);
    }

    function setFactoryFees(
        uint256 _factoryMintFee,
        uint256 _factoryRandomRedeemFee,
        uint256 _factoryTargetRedeemFee,
        uint256 _factoryRandomSwapFee,
        uint256 _factoryTargetSwapFee,
        uint256 _flashLoanFee
    ) public virtual override onlyOwner {
        if (_factoryMintFee > 0.5 ether) revert FeeTooHigh();
        if (_factoryRandomRedeemFee > 0.5 ether) revert FeeTooHigh();
        if (_factoryTargetRedeemFee > 0.5 ether) revert FeeTooHigh();
        if (_factoryRandomSwapFee > 0.5 ether) revert FeeTooHigh();
        if (_factoryTargetSwapFee > 0.5 ether) revert FeeTooHigh();
        if (_flashLoanFee > 500) revert FeeTooHigh();

        factoryMintFee = uint64(_factoryMintFee);
        factoryRandomRedeemFee = uint64(_factoryRandomRedeemFee);
        factoryTargetRedeemFee = uint64(_factoryTargetRedeemFee);
        factoryRandomSwapFee = uint64(_factoryRandomSwapFee);
        factoryTargetSwapFee = uint64(_factoryTargetSwapFee);
        flashLoanFee = _flashLoanFee;

        emit FactoryFeesUpdated(
            _factoryMintFee,
            _factoryRandomRedeemFee,
            _factoryTargetRedeemFee,
            _factoryRandomSwapFee,
            _factoryTargetSwapFee,
            _flashLoanFee
        );
    }

    function setFactoryThresholds(
        uint256 _maxAuctionLength,
        uint256 _minAuctionLength,
        uint256 _minBidIncrease
    ) public virtual override onlyOwner {
        if (_minAuctionLength < 1 days || _minAuctionLength >= maxAuctionLength) revert MinAuctionLengthOutOfBounds();
        if (_maxAuctionLength > 8 weeks || _maxAuctionLength <= minAuctionLength) revert MaxAuctionLengthOutOfBounds();

        if (_minBidIncrease > 1000 || _minBidIncrease < 100) revert MinBidIncreaseOutOfBounds();

        maxAuctionLength = _maxAuctionLength;
        minAuctionLength = _minAuctionLength;
        minBidIncrease = _minBidIncrease;

        emit FactoryThresholdsUpdated(_maxAuctionLength, _minAuctionLength, _minBidIncrease);
    }

    function setVaultFees(
        uint256 vaultId,
        uint256 _mintFee,
        uint256 _randomRedeemFee,
        uint256 _targetRedeemFee,
        uint256 _randomSwapFee,
        uint256 _targetSwapFee
    ) public virtual override {
        if (msg.sender != owner()) {
            address vaultAddr = vaultManager.vault(vaultId);
            if (msg.sender != vaultAddr) revert NotVault();
        }
        if (_mintFee > 0.5 ether) revert FeeTooHigh();
        if (_randomRedeemFee > 0.5 ether) revert FeeTooHigh();
        if (_targetRedeemFee > 0.5 ether) revert FeeTooHigh();
        if (_randomSwapFee > 0.5 ether) revert FeeTooHigh();
        if (_targetSwapFee > 0.5 ether) revert FeeTooHigh();

        _vaultFees[vaultId] = VaultFees(
            true,
            uint64(_mintFee),
            uint64(_randomRedeemFee),
            uint64(_targetRedeemFee),
            uint64(_randomSwapFee),
            uint64(_targetSwapFee)
        );
        emit VaultFeesUpdated(vaultId, _mintFee, _randomRedeemFee, _targetRedeemFee, _randomSwapFee, _targetSwapFee);
    }

    /// @dev 0x042f186c == FNFTCollection.__FNFTCollection_init.selector
    function _deployVault(
        string memory name,
        string memory symbol,
        address _assetAddress,
        bool is1155,
        bool allowAllItems
    ) internal returns (address) {
        bytes memory _initializationCalldata = abi.encodeWithSelector(
            0x042f186c,
            name,
            symbol,
            msg.sender,
            _assetAddress,
            is1155,
            allowAllItems
        );

        address newBeaconProxy = address(new BeaconProxy(address(this), _initializationCalldata));

        // Owner for administrative functions.
        IOwnable(newBeaconProxy).transferOwnership(owner());

        return newBeaconProxy;
    }
}