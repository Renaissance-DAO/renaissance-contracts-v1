// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "./IBeacon.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

/**
 * @dev This contract is used in conjunction with one or more instances of {BeaconProxy} to determine their
 * implementation contract, which is where they will delegate all function calls.
 *
 * An owner is able to change the implementation the beacon points to, thus upgrading the proxies that use this beacon.
 */
contract BeaconUpgradeable is OwnableUpgradeable, IBeacon {
    address private _childImplementation;

    /**
     * @dev Emitted when the child implementation returned by the beacon is changed.
     */
    event Upgraded(address indexed childImplementation);

    function __BeaconUpgradeable__init(address childImplementation_) public initializer {
        _setChildImplementation(childImplementation_);
    }

    /**
     * @dev Returns the current child implementation address.
     */
    function childImplementation() public view virtual override returns (address) {
        return _childImplementation;
    }

    /**
     * @dev Upgrades the beacon to a new implementation.
     *
     * Emits an {Upgraded} event.
     *
     * Requirements:
     *
     * - msg.sender must be the owner of the contract.
     * - `newChildImplementation` must be a contract.
     */
    function upgradeChildTo(address newChildImplementation) external virtual override onlyOwner {
        _setChildImplementation(newChildImplementation);
    }

    /**
     * @dev Sets the implementation contract address for this beacon
     *
     * Requirements:
     *
     * - `newChildImplementation` must be a contract.
     */
    function _setChildImplementation(address newChildImplementation) private {
        require(Address.isContract(newChildImplementation), "UpgradeableBeacon: child implementation is not a contract");
        _childImplementation = newChildImplementation;
        emit Upgraded(newChildImplementation);
    }
}