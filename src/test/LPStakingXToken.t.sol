// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ds-test/test.sol";
import {CheatCodes} from "./utils/cheatcodes.sol";

import {LPStakingXTokenUpgradeable} from "../contracts/token/LPStakingXTokenUpgradeable.sol";
import {MockERC20Upgradeable} from "../contracts/mocks/ERC20.sol";

contract LPStakingXTokenTest is DSTest {
  LPStakingXTokenUpgradeable distribution;
  MockERC20Upgradeable rewardToken;
  CheatCodes vm;

  function setUp() public {
    distribution = new LPStakingXTokenUpgradeable();
    rewardToken = new MockERC20Upgradeable();
    rewardToken.__MockERC20Upgradeable_init("Test", "TEST");
    distribution.__LPStakingXToken_init(rewardToken, "Test", "TEST");

    vm = CheatCodes(address(bytes20(uint160(uint256(keccak256("hevm cheat code"))))));
  }

  function testMint() public {
    distribution.mint(address(1), 1e18);
    assertEq(distribution.balanceOf(address(1)), 1e18);
  }

  function testTimelockMint() public {
    assertEq(distribution.timelockUntil(address(1)), 0);
    distribution.timelockMint(address(1), 1e18, 600);
    assertEq(distribution.timelockUntil(address(1)), block.timestamp + 600);
    assertEq(distribution.balanceOf(address(1)), 1e18);
  }

  function testBurnFrom() public {
    distribution.mint(address(1), 3e18);
    distribution.burnFrom(address(1), 1e18);
    assertEq(distribution.balanceOf(address(1)), 2e18);
  }

  function testDistributeRewards() public {
    distribution.mint(address(1), 2e18);
    distribution.distributeRewards(4e18);
    assertEq(distribution.accumulativeRewardOf(address(1)), 4e18);

    // minting new tokens does not affect existing token holders' accumulative reward
    distribution.mint(address(2), 4e18);
    assertEq(distribution.accumulativeRewardOf(address(1)), 4e18);
    assertEq(distribution.accumulativeRewardOf(address(2)), 0);

    distribution.distributeRewards(6e18);
    assertEq(distribution.accumulativeRewardOf(address(1)), 6e18);
    assertEq(distribution.accumulativeRewardOf(address(2)), 4e18);
  }

  function testDistributeRewardsZeroSupply() public {
    vm.expectRevert(LPStakingXTokenUpgradeable.ZeroSupply.selector);
    distribution.distributeRewards(1e18);
  }

  function testDistributeRewardsZeroAmount() public {
    distribution.mint(address(1), 1e18);
    vm.expectRevert(LPStakingXTokenUpgradeable.ZeroAmount.selector);
    distribution.distributeRewards(0);
  }

  function testWithdrawReward() public {
    distribution.mint(address(1), 2e18);
    distribution.distributeRewards(4e18);
    rewardToken.mint(address(distribution), 4e18);

    assertEq(distribution.dividendOf(address(1)), 4e18);
    assertEq(distribution.withdrawnRewardOf(address(1)), 0);
    assertEq(distribution.accumulativeRewardOf(address(1)), 4e18);
    assertEq(rewardToken.balanceOf(address(1)), 0);

    distribution.withdrawReward(address(1));

    assertEq(distribution.dividendOf(address(1)), 0);
    assertEq(distribution.withdrawnRewardOf(address(1)), 4e18);
    assertEq(distribution.accumulativeRewardOf(address(1)), 4e18);
    assertEq(rewardToken.balanceOf(address(1)), 4e18);

    // doing it twice will not increase user balance
    rewardToken.mint(address(distribution), 5e18);
    distribution.withdrawReward(address(1));

    assertEq(distribution.dividendOf(address(1)), 0);
    assertEq(distribution.withdrawnRewardOf(address(1)), 4e18);
    assertEq(distribution.accumulativeRewardOf(address(1)), 4e18);
    assertEq(rewardToken.balanceOf(address(1)), 4e18);

    // distribute some reward again, this time there should be an increase in withdrawable reward
    distribution.distributeRewards(5e18);

    distribution.withdrawReward(address(1));

    assertEq(distribution.dividendOf(address(1)), 0);
    assertEq(distribution.withdrawnRewardOf(address(1)), 9e18);
    assertEq(distribution.accumulativeRewardOf(address(1)), 9e18);
    assertEq(rewardToken.balanceOf(address(1)), 9e18);
  }
}