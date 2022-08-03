// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;

import "ds-test/test.sol";
import {SetupEnvironment} from "./utils/utils.sol";
import {LPStakingZap} from "../contracts/LPStakingZap.sol";
import {VaultManager} from "../contracts/VaultManager.sol";
import {LPStaking} from "../contracts/LPStaking.sol";
import {FeeDistributor} from "../contracts/FeeDistributor.sol";
import {IUniswapV2Router} from "../contracts/interfaces/IUniswapV2Router.sol";

contract LPStakingZapTest is DSTest, SetupEnvironment {
    IUniswapV2Router private router;
    FeeDistributor private feeDistributor;
    VaultManager private vaultManager;
    LPStakingZap private lpStakingZap;
    LPStaking private lpStaking;

    function setUp() public {
        setupEnvironment(10 ether);
        (   ,
            lpStaking,
            ,
            ,
            ,
            feeDistributor,
            vaultManager,
            ,
            ,
        ) = setupContracts();
        router = setupRouter();
        lpStakingZap = new LPStakingZap(address(vaultManager), address(router));
    }

    function testAssignLPStakingContract() public {
        assertEq(address(lpStakingZap.lpStaking()), address(0));

        lpStakingZap.assignLPStakingContract();

        assertEq(address(lpStakingZap.lpStaking()), address(lpStaking));
    }

    event LPLockTimeUpdated(uint256 oldLockTime, uint256 newLockTime);

    function testSetLPLockTime() public {
        vm.expectEmit(true, false, false, true);
        emit LPLockTimeUpdated(48 hours, 7 days);
        lpStakingZap.setLPLockTime(7 days);
    }
}