// SPDX-License-Identifier: MIT

pragma solidity 0.8.13;

import "@openzeppelin/contracts/access/Ownable.sol";

import "../interfaces/IAdminUpgradeabilityProxy.sol";

contract MultiProxyController is Ownable {
    struct Proxy {
        bytes32 name;
        IAdminUpgradeabilityProxy proxy;
        uint index;
        bool isValue;
    }

    mapping(bytes32 => Proxy) public proxyMap;
    bytes32[] public proxyKeys;

    address public deployer;

    event ProxyUpdated(bytes32 key, address proxy);
    event ProxyRemoved(bytes32 key);
    event ProxyAdminChanged(bytes32 key, address newAdmin);

    constructor(bytes32[] memory _keys, address[] memory _proxies, address _deployer) Ownable() {
        deployer = _deployer;
        uint256 length = _proxies.length;
        require(_keys.length == length, "Not equal length");
        for (uint256 i; i < length;) {
            addProxy(_keys[i], _proxies[i]);
            unchecked {
                ++i;
            }
        }
    }

    // Proxy Gov

    function upgradeProxyTo(bytes32 key, address newImpl) public onlyOwner {
        require(proxyMap[key].isValue, "Doesn't exist");
        proxyMap[key].proxy.upgradeTo(newImpl);
    }

    function changeProxyAdmin(bytes32 key, address newAdmin) public onlyOwner {
        require(proxyMap[key].isValue, "Doesn't exist");
        proxyMap[key].proxy.changeAdmin(newAdmin);
        emit ProxyAdminChanged(key, newAdmin);
    }

    // MultiProxyController Gov

    function changeDeployer(address _deployer) external onlyOwner {
        deployer = _deployer;
    }

    function deployerUpdateProxy(bytes32 key, address proxy) public {
        require(msg.sender == deployer, "Not deployer");
        if (proxyMap[key].isValue) {
            _changeProxy(key, proxy);
        } else {
            _addProxy(key, proxy);
        }
    }

    function _changeProxy(bytes32 key, address proxyAddress) private {
        require(proxyMap[key].isValue, "Doesn't exist");

        proxyMap[key].proxy = IAdminUpgradeabilityProxy(proxyAddress);
    }

    function changeProxy(bytes32 key, address proxyAddress) public onlyOwner {
        _changeProxy(key, proxyAddress);
    }

    function changeProxyKey(bytes32 oldKey, bytes32 newKey) public onlyOwner {
        require(proxyMap[oldKey].isValue, "Doesn't exist");

        Proxy memory proxy = proxyMap[oldKey];

        proxyMap[newKey] = proxy;
        proxyKeys[proxy.index] = newKey;
        delete proxyMap[oldKey];
    }

    function _addProxy(bytes32 key, address proxyAddress) private {
        require(!proxyMap[key].isValue, "Exists");

        IAdminUpgradeabilityProxy proxyContract = IAdminUpgradeabilityProxy(proxyAddress);
        proxyKeys.push(key);
        Proxy memory newProxy = Proxy(key, proxyContract, proxyKeys.length - 1, true);
        proxyMap[key] = newProxy;
        emit ProxyUpdated(key, proxyAddress);
    }

    function addProxy(bytes32 key, address proxyAddress) public onlyOwner {
        _addProxy(key, proxyAddress);
    }

    function removeProxy(bytes32 key) public onlyOwner {
        require(proxyMap[key].isValue, "Doesn't exist");
        bytes32[] storage keys = proxyKeys;
        Proxy memory proxy = proxyMap[key];

        proxyMap[keys[keys.length - 1]].index = proxy.index;

        keys[proxy.index] = keys[keys.length - 1];
        keys.pop();

        delete proxyMap[key];

        emit ProxyRemoved(key);
    }

    function getName(bytes32 key) public view returns (bytes32) {
        return proxyMap[key].name;
    }

    function getAdmin(bytes32 key) public view returns (address) {
        return proxyMap[key].proxy.admin();
    }

    function getImpl(bytes32 key) public view returns(address) {
        return proxyMap[key].proxy.implementation();
    }

    // Bulk

    function changeAllAdmins(address newAdmin) external onlyOwner {
        uint256 length = proxyKeys.length;
        for (uint256 i; i < length;) {
            changeProxyAdmin(proxyKeys[i], newAdmin);
            unchecked {
                ++i;
            }
        }
    }

    function getAllProxiesInfo() public view returns (bytes32[] memory) {
        uint256 length = proxyKeys.length;
        bytes32[] memory proxyInfos = new bytes32[](length);
        for (uint256 i; i < length;) {
            proxyInfos[i] = proxyKeys[i];
            unchecked {
                ++i;
            }
        }
        return proxyInfos;
    }

    function getAllProxies() external view returns (address[] memory) {
        uint256 length = proxyKeys.length;
        address[] memory proxyInfos = new address[](length);
        for (uint256 i; i < length;) {
            proxyInfos[i] = address(proxyMap[proxyKeys[i]].proxy);
            unchecked {
                ++i;
            }
        }
        return proxyInfos;
    }

    function getAllImpls() external view returns (address[] memory) {
        uint256 length = proxyKeys.length;
        address[] memory proxyInfos = new address[](length);
        for (uint256 i; i < length;) {
            proxyInfos[i] = address(proxyMap[proxyKeys[i]].proxy.implementation());
            unchecked {
                ++i;
            }
        }
        return proxyInfos;
    }
}
