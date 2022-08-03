//SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../VaultManager.sol";
import "../FNFTCollectionFactory.sol";
import "../FeeDistributor.sol";
import "../FNFTStaking.sol";
import "../LPStaking.sol";
import "../StakingTokenProvider.sol";
import "./AdminUpgradeabilityProxy.sol";
import "./IMultiProxyController.sol";
import "../interfaces/IOwnable.sol";

contract Deployer is Ownable {
    event ProxyDeployed(
        bytes32 indexed identifier,
        address logic,
        address creator
    );

    error NoController();

    IMultiProxyController public proxyController;

    bytes32 constant public FNFT_COLLECTION_FACTORY = bytes32(0x464e4654436f6c6c656374696f6e466163746f72790000000000000000000000);
    bytes32 constant public VAULT_MANAGER = bytes32(0x5661756c744d616e616765720000000000000000000000000000000000000000);
    bytes32 constant public FEE_DISTRIBUTOR = bytes32(0x4665654469737472696275746f72000000000000000000000000000000000000);
    bytes32 constant public INVENTORY_STAKING = bytes32(0x496e76656e746f72795374616b696e6700000000000000000000000000000000);
    bytes32 constant public LP_STAKING = bytes32(0x4c505374616b696e670000000000000000000000000000000000000000000000);
    bytes32 constant public STAKING_TOKEN_PROVIDER = bytes32(0x5374616b696e67546f6b656e50726f7669646572000000000000000000000000);

    // Gov

    function setProxyController(address _proxyController) external onlyOwner {
        proxyController = IMultiProxyController(_proxyController);
    }

    /// @notice the function to deploy FeeDistributor
    /// @param _logic the implementation
    function deployFeeDistributor(address _logic, address vaultManager, address lpStaking, address treasury) external onlyOwner returns (address feeDistributor) {
        if (address(proxyController) == address(0)) revert NoController();

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            FeeDistributor.__FeeDistributor_init.selector,
            vaultManager,
            lpStaking,
            treasury
        );

        feeDistributor = address(new AdminUpgradeabilityProxy(_logic, msg.sender, _initializationCalldata));
        IOwnable(feeDistributor).transferOwnership(msg.sender);

        proxyController.deployerUpdateProxy(FEE_DISTRIBUTOR, feeDistributor);

        emit ProxyDeployed(FEE_DISTRIBUTOR, feeDistributor, msg.sender);
    }

    /// @notice the function to deploy FNFTCollectionFactory
    /// @param _logic the implementation
    function deployVaultManager(
        address _logic,
        address _weth,
        address _ifoFactory,
        address _priceOracle
    ) external onlyOwner returns (address vaultManager) {
        if (address(proxyController) == address(0)) revert NoController();

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            VaultManager.__VaultManager_init.selector,
            _weth,
            _ifoFactory,
            _priceOracle
        );

        vaultManager = address(new AdminUpgradeabilityProxy(_logic, msg.sender, _initializationCalldata));
        IOwnable(vaultManager).transferOwnership(msg.sender);

        proxyController.deployerUpdateProxy(VAULT_MANAGER, vaultManager);

        emit ProxyDeployed(VAULT_MANAGER, vaultManager, msg.sender);
    }

    /// @notice the function to deploy FNFTCollectionFactory
    /// @param _logic the implementation
    /// @param _vaultManager variable needed for FNFTCollectionFactory
    function deployFNFTCollectionFactory(
        address _logic,
        address _vaultManager,
        address _fnftCollection
    ) external onlyOwner returns (address factory) {
        if (address(proxyController) == address(0)) revert NoController();

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            FNFTCollectionFactory.__FNFTCollectionFactory_init.selector,
            _vaultManager,
            _fnftCollection
        );

        factory = address(new AdminUpgradeabilityProxy(_logic, msg.sender, _initializationCalldata));
        IOwnable(factory).transferOwnership(msg.sender);

        proxyController.deployerUpdateProxy(FNFT_COLLECTION_FACTORY, factory);

        emit ProxyDeployed(FNFT_COLLECTION_FACTORY, factory, msg.sender);
    }

    /// @notice the function to deploy LPStaking
    /// @param _logic the implementation
    function deployLPStaking(address _logic, address vaultManager, address stakingTokenProvider) external onlyOwner returns (address lpStaking) {
        if (address(proxyController) == address(0)) revert NoController();

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            LPStaking.__LPStaking__init.selector,
            vaultManager,
            stakingTokenProvider
        );

        lpStaking = address(new AdminUpgradeabilityProxy(_logic, msg.sender, _initializationCalldata));
        IOwnable(lpStaking).transferOwnership(msg.sender);

        proxyController.deployerUpdateProxy(LP_STAKING, lpStaking);

        emit ProxyDeployed(LP_STAKING, lpStaking, msg.sender);
    }

    /// @notice the function to deploy FNFTStaking
    /// @param _logic the implementation
    function deployFNFTStaking(address _logic, address fnftCollectionFactory) external onlyOwner returns (address fnftStaking) {
        if (address(proxyController) == address(0)) revert NoController();

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            FNFTStaking.__FNFTStaking_init.selector,
            fnftCollectionFactory
        );

        fnftStaking = address(new AdminUpgradeabilityProxy(_logic, msg.sender, _initializationCalldata));
        IOwnable(fnftStaking).transferOwnership(msg.sender);

        proxyController.deployerUpdateProxy(INVENTORY_STAKING, fnftStaking);

        emit ProxyDeployed(INVENTORY_STAKING, fnftStaking, msg.sender);
    }

    /// @notice the function to deploy StakingTokenProvider
    /// @param _logic the implementation
    function deployStakingTokenProvider(address _logic, address uniswapV2Factory, address defaultPairedToken, string memory defaultPrefix) external onlyOwner returns (address stakingTokenProvider) {
        if (address(proxyController) == address(0)) revert NoController();

        bytes memory _initializationCalldata = abi.encodeWithSelector(
            StakingTokenProvider.__StakingTokenProvider_init.selector,
            uniswapV2Factory,
            defaultPairedToken,
            defaultPrefix
        );

        stakingTokenProvider = address(new AdminUpgradeabilityProxy(_logic, msg.sender, _initializationCalldata));
        IOwnable(stakingTokenProvider).transferOwnership(msg.sender);

        proxyController.deployerUpdateProxy(STAKING_TOKEN_PROVIDER, stakingTokenProvider);

        emit ProxyDeployed(STAKING_TOKEN_PROVIDER, stakingTokenProvider, msg.sender);
    }
}
