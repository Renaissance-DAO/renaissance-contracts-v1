// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ds-test/test.sol";
import {SetupEnvironment} from "./utils/utils.sol";
import {LPStakingZap} from "../contracts/LPStakingZap.sol";
import {ILPStakingZap} from "../contracts/interfaces/ILPStakingZap.sol";
import {VaultManager} from "../contracts/VaultManager.sol";
import {LPStaking} from "../contracts/LPStaking.sol";
import {FeeDistributor} from "../contracts/FeeDistributor.sol";
import {IUniswapV2Router} from "../contracts/interfaces/IUniswapV2Router.sol";
import {FNFTCollectionFactory} from "../contracts/FNFTCollectionFactory.sol";
import {FNFTCollection} from "../contracts/FNFTCollection.sol";
import {LPStakingXTokenUpgradeable} from "../contracts/token/LPStakingXTokenUpgradeable.sol";
import {SimpleMockNFT} from "../contracts/mocks/NFT.sol";
import {IUniswapV2Factory} from "./utils/uniswap-v2/IUniswapV2Factory.sol";
import {IUniswapV2Pair} from "./utils/uniswap-v2/IUniswapV2Pair.sol";
import {MockERC20Upgradeable} from "../contracts/mocks/ERC20.sol";

contract LPStakingZapTest is DSTest, SetupEnvironment {
    IUniswapV2Factory private v2Factory;
    IUniswapV2Router private router;
    FeeDistributor private feeDistributor;
    VaultManager private vaultManager;
    LPStakingZap private lpStakingZap;
    LPStaking private lpStaking;
    FNFTCollectionFactory private fnftCollectionFactory;
    FNFTCollection private vault;
    SimpleMockNFT private token;

    function setUp() public {
        setupForkedEnvironment(10 ether);
        (
            ,
            vaultManager,
            ,
            lpStaking,
            ,
            feeDistributor,
            fnftCollectionFactory
        ) = setupContracts();

        router = setupRouter();
        v2Factory = setupPairFactory();

        lpStakingZap = new LPStakingZap(address(vaultManager), address(router));

        token = new SimpleMockNFT();
        fnftCollectionFactory.createVault(address(token), false, true, "Doodles", "DOODLE");
        vault = FNFTCollection(vaultManager.vault(uint256(0)));
    }

    function testBasicVariables() public {
        assertEq(address(lpStakingZap.router()), address(router));
        assertEq(address(lpStakingZap.vaultManager()), address(vaultManager));
        assertEq(address(lpStakingZap.WETH()), address(weth));
        assertEq(weth.allowance(address(lpStakingZap), address(router)), type(uint256).max);
    }

    function testAssignLPStakingContract() public {
        assertEq(address(lpStakingZap.lpStaking()), address(0));
        lpStakingZap.assignLPStakingContract();
        assertEq(address(lpStakingZap.lpStaking()), address(lpStaking));
    }

    function testAssignLPStakingContractNotZeroAddress() public {
        lpStakingZap.assignLPStakingContract();

        vm.expectRevert(ILPStakingZap.NotZeroAddress.selector);
        lpStakingZap.assignLPStakingContract();
    }

    event LPLockTimeUpdated(uint256 oldLockTime, uint256 newLockTime);

    function testSetLPLockTime() public {
        vm.expectEmit(true, false, false, true);
        emit LPLockTimeUpdated(48 hours, 7 days);
        lpStakingZap.setLPLockTime(7 days);
    }

    function testSetLPLockTimeLockTooLong() public {
        vm.expectRevert(ILPStakingZap.LockTooLong.selector);
        lpStakingZap.setLPLockTime(7 days + 1 seconds);
    }

    function testSetLPLockTimeNotOwner() public {
        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        lpStakingZap.setLPLockTime(7 days);
    }

    event UserStaked(uint256 indexed vaultId, address indexed sender, uint256 count, uint256 lpBalance, uint256 timelockUntil);

    // stake liquidity with ETH
    function testStakeLiquidityETHSuccess() public {
        _stakeLiquiditySetup();

        uint256 ethBalanceBefore = address(this).balance;
        uint256 vaultBalanceBefore = vault.balanceOf(address(this));
        address to = address(this);

        uint256 expectedXTokenBalance = 999999999999999000;
        uint256 expectedTimelockUntil = block.timestamp + 48 hours;
        vm.expectEmit(true, true, false, true);
        emit UserStaked(0, to, 1 ether, expectedXTokenBalance, expectedTimelockUntil);

        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);

        uint256 ethBalanceAfter = address(this).balance;
        uint256 vaultBalanceAfter = vault.balanceOf(address(this));
        assertEq(ethBalanceBefore - ethBalanceAfter, 1 ether);
        assertEq(vaultBalanceBefore - vaultBalanceAfter, 1 ether);

        address pair = v2Factory.getPair(address(weth), address(vault));
        assertEq(IUniswapV2Pair(pair).balanceOf(to), 0);

        LPStakingXTokenUpgradeable xToken = lpStaking.xToken(0);
        assertEq(xToken.balanceOf(to), expectedXTokenBalance);
        assertEq(xToken.timelockUntil(to), expectedTimelockUntil);
    }

    function testStakeLiquidityETHToZeroAddress() public {
        _stakeLiquiditySetup();
        address to = address(0);
        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);
    }

    function testStakeLiquidityETHToCurrentAddress() public {
        _stakeLiquiditySetup();
        address to = address(lpStakingZap);
        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);
    }

    function testStakeLiquidityETHLPStakingZapNotExcludedFromFees() public {
        _stakeLiquiditySetup();
        vaultManager.setFeeExclusion(address(lpStakingZap), false);
        address to = address(this);
        vm.expectRevert(ILPStakingZap.NotExcluded.selector);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);
    }

    // unlock and remove liquidity to ETH
    function testUnstakeLiquidityETHSuccess() public {
        _stakeLiquiditySetup();
        address to = address(this);
        uint256 currentTimestamp = block.timestamp;
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);

        uint256 ethBalanceBefore = address(this).balance;
        uint256 vaultBalanceBefore = vault.balanceOf(address(this));

        LPStakingXTokenUpgradeable xToken = lpStaking.xToken(0);
        // Test claim reward
        address tokenRewardDistributor = xToken.owner();
        _mintTokens(tokenRewardDistributor, 3);
        vm.startPrank(tokenRewardDistributor);
        vault.transfer(address(xToken), 1 ether);
        xToken.distributeRewards(1 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 48 hours + 1 seconds);
        lpStakingZap.unlockAndRemoveLiquidityETH(0, 999999999999999000, 0, 0, to);

        uint256 ethBalanceAfter = address(this).balance;
        uint256 vaultBalanceAfter = vault.balanceOf(address(this));

        assertEq(ethBalanceAfter - ethBalanceBefore, 999999999999999000);
        assertEq(vaultBalanceAfter - vaultBalanceBefore, 2199999999999998999);

        address pair = v2Factory.getPair(address(weth), address(vault));
        assertEq(IUniswapV2Pair(pair).balanceOf(to), 0);

        assertEq(xToken.balanceOf(to), 0);
        // Should it be reset to 0?
        assertEq(xToken.timelockUntil(to), currentTimestamp + 48 hours);

        uint256 withdrawnReward = xToken.withdrawnRewardOf(to);
        assertEq(withdrawnReward, 1199999999999999999);
    }

    function testUnstakeLiquidityETHUserIsLocked() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);

        vm.expectRevert(LPStakingXTokenUpgradeable.UserIsLocked.selector);
        lpStakingZap.unlockAndRemoveLiquidityETH(0, 999999999999999000, 0, 0, to);
    }

    function testUnstakeLiquidityETHToZeroAddress() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);

        vm.warp(block.timestamp + 48 hours + 1 seconds);

        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.unlockAndRemoveLiquidityETH(0, 999999999999999000, 0, 0, address(0));
    }

    function testUnstakeLiquidityETHToCurrentAddress() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);

        vm.warp(block.timestamp + 48 hours + 1 seconds);

        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.unlockAndRemoveLiquidityETH(0, 999999999999999000, 0, 0, address(lpStakingZap));
    }

    function testUnstakeLiquidityETHLPStakingZapNotExcludedFromFees() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityETH{value: 1 ether}(0, 1 ether, 1 ether, to);

        vm.warp(block.timestamp + 48 hours + 1 seconds);

        vaultManager.setFeeExclusion(address(lpStakingZap), false);
        vm.expectRevert(ILPStakingZap.NotExcluded.selector);
        lpStakingZap.unlockAndRemoveLiquidityETH(0, 999999999999999000, 0, 0, to);
    }

    // stake liquidity with WETH
    function testStakeLiquidityWETHSuccess() public {
        _stakeLiquiditySetup();

        uint256 wethBalanceBefore = weth.balanceOf(address(this));
        uint256 vaultBalanceBefore = vault.balanceOf(address(this));
        address to = address(this);

        uint256 expectedXTokenBalance = 999999999999999000;
        uint256 expectedTimelockUntil = block.timestamp + 48 hours;
        vm.expectEmit(true, true, false, true);
        emit UserStaked(0, to, 1 ether, expectedXTokenBalance, expectedTimelockUntil);

        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);

        uint256 wethBalanceAfter = weth.balanceOf(address(this));
        uint256 vaultBalanceAfter = vault.balanceOf(address(this));
        assertEq(wethBalanceBefore - wethBalanceAfter, 1 ether);
        assertEq(vaultBalanceBefore - vaultBalanceAfter, 1 ether);

        address pair = v2Factory.getPair(address(weth), address(vault));
        assertEq(IUniswapV2Pair(pair).balanceOf(to), 0);

        LPStakingXTokenUpgradeable xToken = lpStaking.xToken(0);
        assertEq(xToken.balanceOf(to), expectedXTokenBalance);
        assertEq(xToken.timelockUntil(to), expectedTimelockUntil);
    }

    function testStakeLiquidityWETHToZeroAddress() public {
        _stakeLiquiditySetup();
        address to = address(0);
        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);
    }

    function testStakeLiquidityWETHToCurrentAddress() public {
        _stakeLiquiditySetup();
        address to = address(lpStakingZap);
        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);
    }

    function testStakeLiquidityWETHLPStakingZapNotExcludedFromFees() public {
        _stakeLiquiditySetup();
        vaultManager.setFeeExclusion(address(lpStakingZap), false);
        address to = address(this);
        vm.expectRevert(ILPStakingZap.NotExcluded.selector);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);
    }

    // unlock and remove liquidity to WETH
    function testUnstakeLiquidityWETHSuccess() public {
        _stakeLiquiditySetup();
        address to = address(this);
        uint256 currentTimestamp = block.timestamp;
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);

        uint256 wethBalanceBefore = weth.balanceOf(address(this));
        uint256 vaultBalanceBefore = vault.balanceOf(address(this));

        LPStakingXTokenUpgradeable xToken = lpStaking.xToken(0);
        // Test claim reward
        address tokenRewardDistributor = xToken.owner();
        _mintTokens(tokenRewardDistributor, 3);
        vm.startPrank(tokenRewardDistributor);
        vault.transfer(address(xToken), 1 ether);
        xToken.distributeRewards(1 ether);
        vm.stopPrank();

        vm.warp(block.timestamp + 48 hours + 1 seconds);
        lpStakingZap.unlockAndRemoveLiquidityWETH(0, 999999999999999000, 0, 0, to);

        uint256 wethBalanceAfter = weth.balanceOf(address(this));
        uint256 vaultBalanceAfter = vault.balanceOf(address(this));

        assertEq(wethBalanceAfter - wethBalanceBefore, 999999999999999000);
        assertEq(vaultBalanceAfter - vaultBalanceBefore, 2199999999999998999);

        address pair = v2Factory.getPair(address(weth), address(vault));
        assertEq(IUniswapV2Pair(pair).balanceOf(to), 0);

        assertEq(xToken.balanceOf(to), 0);
        // Should it be reset to 0?
        assertEq(xToken.timelockUntil(to), currentTimestamp + 48 hours);

        uint256 withdrawnReward = xToken.withdrawnRewardOf(to);
        assertEq(withdrawnReward, 1199999999999999999);
    }

    function testUnstakeLiquidityWETHUserIsLocked() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);

        vm.expectRevert(LPStakingXTokenUpgradeable.UserIsLocked.selector);
        lpStakingZap.unlockAndRemoveLiquidityWETH(0, 999999999999999000, 0, 0, to);
    }

    function testUnstakeLiquidityWETHToZeroAddress() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);

        vm.warp(block.timestamp + 48 hours + 1 seconds);

        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.unlockAndRemoveLiquidityWETH(0, 999999999999999000, 0, 0, address(0));
    }

    function testUnstakeLiquidityWETHToCurrentAddress() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);

        vm.warp(block.timestamp + 48 hours + 1 seconds);

        vm.expectRevert(ILPStakingZap.InvalidDestination.selector);
        lpStakingZap.unlockAndRemoveLiquidityWETH(0, 999999999999999000, 0, 0, address(lpStakingZap));
    }

    function testUnstakeLiquidityWETHLPStakingZapNotExcludedFromFees() public {
        _stakeLiquiditySetup();
        address to = address(this);
        lpStakingZap.stakeLiquidityWETH(0, 1 ether, 1 ether, 1 ether, to);

        vm.warp(block.timestamp + 48 hours + 1 seconds);

        vaultManager.setFeeExclusion(address(lpStakingZap), false);
        vm.expectRevert(ILPStakingZap.NotExcluded.selector);
        lpStakingZap.unlockAndRemoveLiquidityWETH(0, 999999999999999000, 0, 0, to);
    }

    function testRescueETHSuccess() public {
        vm.deal(address(lpStakingZap), 1 ether);
        uint256 balanceBefore = address(this).balance;

        lpStakingZap.rescue(address(0));
        assertEq(address(lpStakingZap).balance, 0);
        assertEq(address(this).balance - balanceBefore, 1 ether);
    }

    function testRescueETHNotOwner() public {
        vm.deal(address(lpStakingZap), 1 ether);

        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        lpStakingZap.rescue(address(0));
    }

    function testRescueERC20() public {
        MockERC20Upgradeable erc20 = new MockERC20Upgradeable();
        erc20.mint(address(lpStakingZap), 1 ether);

        lpStakingZap.rescue(address(erc20));
        assertEq(erc20.balanceOf(address(lpStakingZap)), 0);
        assertEq(erc20.balanceOf(address(this)), 1 ether);
    }

    function testRescueERC20NotOwner() public {
        MockERC20Upgradeable erc20 = new MockERC20Upgradeable();
        erc20.mint(address(lpStakingZap), 1 ether);

        vm.prank(address(1));
        vm.expectRevert("Ownable: caller is not the owner");
        lpStakingZap.rescue(address(erc20));
    }

    function _stakeLiquiditySetup() private {
        lpStakingZap.assignLPStakingContract();
        _mintTokens(address(this), 1);
        vault.approve(address(lpStakingZap), 1 ether);
        weth.approve(address(lpStakingZap), 1 ether);
        vaultManager.setFeeExclusion(address(lpStakingZap), true);
    }

    function _mintTokens(address owner, uint256 startingTokenId) private {
        token.mint(owner, startingTokenId);
        token.mint(owner, startingTokenId + 1);

        vm.startPrank(owner);
        token.setApprovalForAll(address(vault), true);

        uint256[] memory tokenIds = new uint256[](2);
        tokenIds[0] = startingTokenId;
        tokenIds[1] = startingTokenId + 1;

        uint256[] memory amounts = new uint256[](0);

        vault.mint(tokenIds, amounts);
        vm.stopPrank();
    }

    receive() external payable {}
}