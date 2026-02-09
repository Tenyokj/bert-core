// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./RolesRegistryUpgradeable.sol";

/**
 * @title RolesAwareUpgradeable
 * @notice Abstract base contract providing role-based access control modifiers
 * @dev Inherited by all DAO contracts to enforce role-based permissions
 * @dev Provides modifiers that check permissions against the central RolesRegistry
 * @dev Upgradeable contract with gap storage for future upgrades
 *
 * @custom:version 1.0.0
 */
abstract contract RolesAwareUpgradeable is Initializable {
    /* ========== STATE VARIABLES ========== */
    
    /// @notice Reference to the central RolesRegistry contract
    /// @dev All role checks are delegated to this contract
    RolesRegistryUpgradeable public roles;

    /* ========== INITIALIZE ========== */

    /**
     * @notice Internal initialization function
     * @dev Sets up the RolesRegistry reference for the contract
     * @dev Should be called in derived contract's initialize() function
     * @param _rolesRegistry Address of the RolesRegistry contract
     * 
     * @custom:requirements _rolesRegistry cannot be zero address
     * @custom:emits No events
     */
    function __RolesAware_init(address _rolesRegistry) internal onlyInitializing {
        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");
        roles = RolesRegistryUpgradeable(_rolesRegistry);
    }

    /* ========== MODIFIERS ========== */

    /**
     * @notice Restricts function to addresses with DISTRIBUTOR_ROLE
     * @dev Used by FundingPool.distributeFunds()
     * 
     * @custom:reverts NotDistributor If caller doesn't have DISTRIBUTOR_ROLE
     * @custom:role DISTRIBUTOR_ROLE Token distribution rights
     */
    modifier onlyDistributor() {
        if (!roles.hasRole(roles.DISTRIBUTOR_ROLE(), msg.sender)) {
            revert NotDistributor();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with VOTING_ROLE or GRANT_ROLE
     * @dev Used by IdeaRegistry.updateStatus() for voting results and grant processing
     * 
     * @custom:reverts NotVotingOrGrant If caller doesn't have VOTING_ROLE or GRANT_ROLE
     * @custom:role VOTING_ROLE Voting system contract
     * @custom:role GRANT_ROLE Grant manager contract
     */
    modifier onlyVotingSystemOrGrantManager() {
        if (!roles.hasRole(roles.VOTING_ROLE(), msg.sender) && 
            !roles.hasRole(roles.GRANT_ROLE(), msg.sender)) {
            revert NotVotingOrGrant();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with VOTING_ROLE
     * @dev Used by VotingSystem functions and IdeaRegistry.addVote()
     * 
     * @custom:reverts NotVotingSystem If caller doesn't have VOTING_ROLE
     * @custom:role VOTING_ROLE Voting system contract
     */
    modifier onlyVotingSystem() {
        if (!roles.hasRole(roles.VOTING_ROLE(), msg.sender)) {
            revert NotVotingSystem();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with GRANT_ROLE
     * @dev Used by GrantManager functions
     * 
     * @custom:reverts NotGrantManager If caller doesn't have GRANT_ROLE
     * @custom:role GRANT_ROLE Grant manager contract
     */
    modifier onlyGrantManager() {
        if (!roles.hasRole(roles.GRANT_ROLE(), msg.sender)) {
            revert NotGrantManager();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with IREGISTRY_ROLE
     * @dev Used for cross-contract IdeaRegistry calls
     * 
     * @custom:reverts NotIdeaRegistry If caller doesn't have IREGISTRY_ROLE
     * @custom:role IREGISTRY_ROLE Idea registry contract
     */
    modifier onlyIdeaRegistry() {
        if (!roles.hasRole(roles.IREGISTRY_ROLE(), msg.sender)) {
            revert NotIdeaRegistry();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with REPUTATION_MANAGER_ROLE
     * @dev Used by ReputationSystem functions
     * 
     * @custom:reverts NotReputationManager If caller doesn't have REPUTATION_MANAGER_ROLE
     * @custom:role REPUTATION_MANAGER_ROLE Reputation system contract
     */
    modifier onlyReputationManager() {
        if (!roles.hasRole(roles.REPUTATION_MANAGER_ROLE(), msg.sender)) {
            revert NotReputationManager();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with CURATOR_ROLE
     * @dev Used by IdeaRegistry.markLowQuality() for content curation
     * 
     * @custom:reverts NotCurator If caller doesn't have CURATOR_ROLE
     * @custom:role CURATOR_ROLE Content curator (earned through voting progression)
     * @custom:progression Requires 20 winning votes to earn this role
     */
    modifier onlyCurator() {
        if (!roles.hasRole(roles.CURATOR_ROLE(), msg.sender)) {
            revert NotCurator();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with REVIEWER_ROLE
     * @dev Used by IdeaRegistry.addReview() for idea reviews
     * 
     * @custom:reverts NotReviewer If caller doesn't have REVIEWER_ROLE
     * @custom:role REVIEWER_ROLE Idea reviewer (earned through voting progression)
     * @custom:progression Requires 60 winning votes to earn this role
     */
    modifier onlyReviewer() {
        if (!roles.hasRole(roles.REVIEWER_ROLE(), msg.sender)) {
            revert NotReviewer();
        }
        _;
    }

    /**
     * @notice Restricts function to addresses with DEFAULT_ADMIN_ROLE
     * @dev Used for administrative functions across all contracts
     * 
     * @custom:reverts NotAdmin If caller doesn't have DEFAULT_ADMIN_ROLE
     * @custom:role DEFAULT_ADMIN_ROLE System administrator
     * @custom:warning Admin has full control over contract parameters
     */
    modifier onlyAdmin() {
        if (!roles.hasRole(roles.DEFAULT_ADMIN_ROLE(), msg.sender)) {
            revert NotAdmin();
        }
        _;
    }

     /* ========== UPGRADE SAFETY ========== */

    /**
     * @notice Storage gap for future upgrades
     * @dev Reserved storage space to allow for new variables in upgrades
     * @dev Prevents storage collisions when adding new state variables
     * 
     * @custom:upgrade-safety Always include 50 slots gap in upgradeable contracts
     * @custom:warning Do not remove or reduce this gap in future versions
     */
    uint256[50] private __gap;
}
