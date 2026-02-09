// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../BERT/V1.3.5/extensions/Roles/RolesRegistryUpgradeable.sol";

/**
 * @title MockRolesRegistryExpose
 * @notice Exposes internal role validation for coverage
 */
contract MockRolesRegistryExpose is RolesRegistryUpgradeable {
    function isValidRole(bytes32 role) external pure returns (bool) {
        return _isValidRole(role);
    }
}
