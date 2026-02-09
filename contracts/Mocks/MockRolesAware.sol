// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../BERT/extensions/Roles/RolesAwareUpgradeable.sol";

/**
 * @title MockRolesAware
 * @notice Exposes modifiers for coverage
 */
contract MockRolesAware is RolesAwareUpgradeable {
    constructor() {
        _disableInitializers();
    }

    function initialize(address rolesRegistry) external initializer {
        __RolesAware_init(rolesRegistry);
    }

    function onlyGrantManagerFn() external onlyGrantManager {
        // no-op
    }

    function onlyIdeaRegistryFn() external onlyIdeaRegistry {
        // no-op
    }
}
