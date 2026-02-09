// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "../BERT/extensions/Roles/RolesRegistryUpgradeable.sol";

/**
 * @title MockRolesRegistryExpose
 * @notice Exposes internal role validation for coverage
 */
contract MockRolesRegistryExpose is RolesRegistryUpgradeable {
    function isValidRole(bytes32 role) external pure returns (bool) {
        return _isValidRole(role);
    }
}
