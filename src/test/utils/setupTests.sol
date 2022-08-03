// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../../lib/ds-test/src/test.sol";
import {Deployer} from "../../contracts/proxy/Deployer.sol";
import {MultiProxyController} from "../../contracts/proxy/MultiProxyController.sol";
import {CheatCodes} from "./cheatcodes.sol";
import {console} from "./console.sol";
import {WETH} from "../../contracts/mocks/WETH.sol";
import {StakingTokenProvider} from "../../contracts/StakingTokenProvider.sol";
import {FNFTCollectionFactory} from "../../contracts/FNFTCollectionFactory.sol";
import {FNFTCollection} from "../../contracts/FNFTCollection.sol";
import {LPStaking} from "../../contracts/LPStaking.sol";
import {FNFTStaking} from "../../contracts/FNFTStaking.sol";
import {FeeDistributor} from "../../contracts/FeeDistributor.sol";
import {IUniswapV2Factory} from "./uniswap-v2/IUniswapV2Factory.sol";
import {IUniswapV2Router} from "../../contracts/interfaces/IUniswapV2Router.sol";
import {VaultManager} from "../../contracts/VaultManager.sol";
import {SimpleMockNFT} from "../../contracts/mocks/NFT.sol";

contract SetupEnvironment {
    Deployer public deployer;
    CheatCodes public vm;
    MultiProxyController public proxyController;
    WETH public weth;
    address constant internal UNISWAP_V2_FACTORY_ADDRESS = 0xc66F594268041dB60507F00703b152492fb176E7;
    address constant internal UNISWAP_V2_ROUTER_ADDRESS = 0x2CB45Edb4517d5947aFdE3BEAbF95A582506858B;
    address constant internal TREASURY_ADDRESS = 0x511fEFE374e9Cb50baF1E3f2E076c94b3eF8B03b;
    address constant internal WETH_ADDRESS = 0xC9BdeEd33CD01541e1eeD10f90519d2C06Fe3feB;

    function setupDeployerAndProxyController() public {
        deployer = new Deployer();
        bytes32[] memory keys;
        address[] memory proxies;
        proxyController = new MultiProxyController(keys, proxies, address(deployer));
        deployer.setProxyController(address(proxyController));
    }

    function setupWETH(uint256 _amountToMint) public {
        weth = new WETH(_amountToMint);
    }

    function setupPairFactory() public pure returns (IUniswapV2Factory v2Factory) {
        v2Factory = IUniswapV2Factory(UNISWAP_V2_FACTORY_ADDRESS);
    }

    function setupRouter() public pure returns (IUniswapV2Router router) {
        router = IUniswapV2Router(UNISWAP_V2_ROUTER_ADDRESS);
    }

    function setupVaultManager() public returns (VaultManager vaultManager) {
        vaultManager = VaultManager(
            deployer.deployVaultManager(
                address(new VaultManager()), address(weth)
            )
        );
    }

    function setupFNFTCollectionFactory(address _vaultManager) public returns (FNFTCollectionFactory fnftCollectionFactory) {
        fnftCollectionFactory = FNFTCollectionFactory(
            deployer.deployFNFTCollectionFactory(
                address(new FNFTCollectionFactory()),
                _vaultManager,
                address(new FNFTCollection())
            )
        );
    }

    function setupFNFTCollection(address _fnftCollectionFactory, uint256 _amountToMint) public returns (FNFTCollection fnftCollection) {
        FNFTCollectionFactory factory = FNFTCollectionFactory(_fnftCollectionFactory);

        SimpleMockNFT token = new SimpleMockNFT();
        fnftCollection = FNFTCollection(factory.createVault(address(token), false, true, "Doodles", "DOODLE"));
        uint256[] memory tokenIds = new uint256[](_amountToMint);

        for (uint i; i < _amountToMint; i++) {
            token.mint(address(this), i + 1);
            tokenIds[i] = i + 1;
        }
        token.setApprovalForAll(address(fnftCollection), true);
        uint256[] memory amounts = new uint256[](0);

        fnftCollection.mint(tokenIds, amounts);
    }

    function setupStakingTokenProvider() public returns (StakingTokenProvider stakingTokenProvider) {
        stakingTokenProvider = StakingTokenProvider(
            deployer.deployStakingTokenProvider(
                address(new StakingTokenProvider()),
                UNISWAP_V2_FACTORY_ADDRESS,
                WETH_ADDRESS,
                string("x")
            )
        );
    }

    function setupLPStaking(address vaultManager, address stakingTokenProvider) public returns (LPStaking lpStaking) {
        lpStaking = LPStaking(
            deployer.deployLPStaking(
                address(new LPStaking()),
                vaultManager,
                stakingTokenProvider
            )
        );
    }

    function setupFeeDistributor(address vaultManager, address lpStaking) public returns (FeeDistributor feeDistributor) {
        feeDistributor = FeeDistributor(
            deployer.deployFeeDistributor(
                address(new FeeDistributor()),
                vaultManager,
                lpStaking,
                TREASURY_ADDRESS
            )
        );
    }

    function setupFNFTStaking(address vaultManager) public returns (FNFTStaking fnftStaking) {
        fnftStaking = FNFTStaking(
            deployer.deployFNFTStaking(
                address(new FNFTStaking()),
                vaultManager
            )
        );
    }

    function setupEnvironment(uint256 _wethAmount) public {
        vm = CheatCodes(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
        setupDeployerAndProxyController();
        setupWETH(_wethAmount);
    }

    function setupContracts()
        public
        returns (
            IUniswapV2Factory pairFactory,

            VaultManager vaultManager,

            StakingTokenProvider stakingTokenProvider,
            LPStaking lpStaking,
            FNFTStaking fnftStaking,
            FeeDistributor feeDistributor,

            FNFTCollectionFactory fnftCollectionFactory
        )
    {
        pairFactory = setupPairFactory();

        vaultManager = setupVaultManager();
        stakingTokenProvider = setupStakingTokenProvider();

        lpStaking = setupLPStaking(address(vaultManager), address(stakingTokenProvider));
        fnftStaking = setupFNFTStaking(address(vaultManager));

        feeDistributor = setupFeeDistributor(address(vaultManager), address(lpStaking));
        fnftCollectionFactory = setupFNFTCollectionFactory(address(vaultManager));

        vaultManager.setFNFTCollectionFactory(address(fnftCollectionFactory));
        vaultManager.setFeeDistributor(address(feeDistributor));
    }
}