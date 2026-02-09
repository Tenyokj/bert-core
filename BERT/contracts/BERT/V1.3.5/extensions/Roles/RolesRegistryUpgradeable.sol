// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import { IRoles } from"../../interfaces/IRoles.sol";
import "../../utils/Errors.sol";

/**
 * @title Roles
 * @notice Central role registry for protocol contracts
 * @dev Manages role-based access control across the DAO ecosystem
 * @dev Owner is responsible ONLY for assigning system roles to contracts
 * @dev User roles are granted through progression systems (VoterProgression)
 * @dev Upgradeable
 * 
 * @custom:version 1.0.0
 */
contract RolesRegistryUpgradeable is 
    AccessControlUpgradeable, 
    OwnableUpgradeable, 
    IRoles 
{
    /* ========== SYSTEM ROLES ========== */

    /// @notice Role for voting system contracts that manage voting rounds
    bytes32 public constant VOTING_ROLE = keccak256("VOTING_ROLE");

    /// @notice Role for grant manager contracts that handle fund distribution
    bytes32 public constant GRANT_ROLE = keccak256("GRANT_ROLE");

    /// @notice Role for distributor contracts that distribute tokens
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    /// @notice Role for idea registry contracts that manage idea lifecycle
    bytes32 public constant IREGISTRY_ROLE = keccak256("IREGISTRY_ROLE");

    /// @notice Role for reputation system contracts that manage user reputation
    bytes32 public constant REPUTATION_MANAGER_ROLE = keccak256("REPUTATION_MANAGER_ROLE");

    /// @notice Role for voter progression contracts that handle grant user role
    bytes32 public constant AUTO_GRANT_ROLE = keccak256("AUTO_GRANT_ROLE");

    /* ========== USER ROLES ========== */

    /// @notice Role for curators who can mark ideas as low quality
    bytes32 public constant CURATOR_ROLE = keccak256("CURATOR_ROLE");

    /// @notice Role for reviewers who can add reviews to ideas
    bytes32 public constant REVIEWER_ROLE = keccak256("REVIEWER_ROLE");

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __AccessControl_init();
        __Ownable_init(msg.sender);

        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Assign a system role to a contract address
     * @dev ONLY for protocol setup and upgrades. Owner should only grant roles to contracts, not EOA.
     * @param role System role to grant (VOTING_ROLE, GRANT_ROLE, etc.)
     * @param account Contract address to grant the role to
     * @custom:emits RoleGranted
     * @custom:requires Caller must be contract owner
     * @custom:requires role must be a valid system role
     * @custom:requires account cannot be zero address
     */
    function grantSystemRole(bytes32 role, address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (account == address(0)) {
            revert ZeroAddress("account");
        }
        if (!_isSystemRole(role)) {
            revert InvalidSystemRole(role);
        }
        if (hasRole(role, account)) {
            revert AlreadyHasRole(role, account);
        }
        
        _grantRole(role, account);
    }

    /**
     * @notice Revoke a system role from a contract address
     * @dev Used during protocol upgrades or contract replacements
     * @param role System role to revoke
     * @param account Contract address to revoke the role from
     * @custom:emits RoleRevoked
     * @custom:requires Caller must be contract owner
     * @custom:requires role must be a valid system role
     * @custom:requires account must currently have the role
     */
    function revokeSystemRole(bytes32 role, address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (!_isSystemRole(role)) {
            revert InvalidSystemRole(role);
        }
        if (!hasRole(role, account)) {
            revert RoleNotFound(role, account);
        }
        
        _revokeRole(role, account);
    }

    /**
     * @notice Grant a user role (CURATOR_ROLE or REVIEWER_ROLE) to an address
     * @dev Typically called by VoterProgression contract based on vote thresholds
     * @param role User role to grant (CURATOR_ROLE or REVIEWER_ROLE)
     * @param account User address to grant the role to
     * @custom:emits RoleGranted
     * @custom:requires Caller must have DEFAULT_ADMIN_ROLE
     * @custom:requires role must be a valid user role
     * @custom:requires account cannot be zero address
     */
    function grantUserRole(bytes32 role, address account)
        external
        onlyRole(AUTO_GRANT_ROLE)
    {
        if (account == address(0)) {
            revert ZeroAddress("account");
        }
        if (!_isUserRole(role)) {
            revert InvalidUserRole(role);
        }
        if (hasRole(role, account)) {
            revert AlreadyHasRole(role, account);
        }
        
        _grantRole(role, account);
    }

    /**
     * @notice Revoke a user role from an address
     * @dev Can be used for disciplinary actions or corrections
     * @param role User role to revoke
     * @param account User address to revoke the role from
     * @custom:emits RoleRevoked
     * @custom:requires Caller must have DEFAULT_ADMIN_ROLE
     * @custom:requires role must be a valid user role
     * @custom:requires account must currently have the role
     */
    function revokeUserRole(bytes32 role, address account)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {
        if (!_isUserRole(role)) {
            revert InvalidUserRole(role);
        }
        if (!hasRole(role, account)) {
            revert RoleNotFound(role, account);
        }
        
        _revokeRole(role, account);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Check if a bytes32 value represents a valid system role
     * @param role Role identifier to check
     * @return bool True if role is a system role
     */
    function isSystemRole(bytes32 role) external pure returns (bool) {
        return _isSystemRole(role);
    }

    /**
     * @notice Check if a bytes32 value represents a valid user role
     * @param role Role identifier to check
     * @return bool True if role is a user role
     */
    function isUserRole(bytes32 role) external pure returns (bool) {
        return _isUserRole(role);
    }

    /**
     * @notice Get all roles assigned to an address
     * @param account Address to query
     * @return roles Array of role identifiers the address has
     */
    function getRoles(address account) 
        external 
        view 
        returns (bytes32[] memory roles) 
    {
        // Define all possible roles
        bytes32[] memory allRoles = new bytes32[](8);
        allRoles[0] = DEFAULT_ADMIN_ROLE;
        allRoles[1] = VOTING_ROLE;
        allRoles[2] = GRANT_ROLE;
        allRoles[3] = DISTRIBUTOR_ROLE;
        allRoles[4] = IREGISTRY_ROLE;
        allRoles[5] = REPUTATION_MANAGER_ROLE;
        allRoles[6] = CURATOR_ROLE;
        allRoles[7] = REVIEWER_ROLE;

        // Count how many roles the account has
        uint256 count = 0;
        for (uint256 i = 0; i < allRoles.length; i++) {
            if (hasRole(allRoles[i], account)) {
                count++;
            }
        }

        // Create array with exact size
        roles = new bytes32[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < allRoles.length; i++) {
            if (hasRole(allRoles[i], account)) {
                roles[index] = allRoles[i];
                index++;
            }
        }
    }

    /**
     * @notice Check if an address has any role in the system
     * @param account Address to check
     * @return bool True if address has any role (including DEFAULT_ADMIN_ROLE)
     */
    function hasAnyRole(address account) external view returns (bool) {
        bytes32[] memory allRoles = new bytes32[](8);
        allRoles[0] = DEFAULT_ADMIN_ROLE;
        allRoles[1] = VOTING_ROLE;
        allRoles[2] = GRANT_ROLE;
        allRoles[3] = DISTRIBUTOR_ROLE;
        allRoles[4] = IREGISTRY_ROLE;
        allRoles[5] = REPUTATION_MANAGER_ROLE;
        allRoles[6] = CURATOR_ROLE;
        allRoles[7] = REVIEWER_ROLE;

        for (uint256 i = 0; i < allRoles.length; i++) {
            if (hasRole(allRoles[i], account)) {
                return true;
            }
        }
        return false;
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice Internal function to check if a role is a system role
     * @param role Role identifier to check
     * @return bool True if role is a system role
     */
    function _isSystemRole(bytes32 role) internal pure returns (bool) {
        return role == VOTING_ROLE || 
               role == GRANT_ROLE || 
               role == DISTRIBUTOR_ROLE || 
               role == IREGISTRY_ROLE || 
               role == REPUTATION_MANAGER_ROLE;
    }

    /**
     * @notice Internal function to check if a role is a user role
     * @param role Role identifier to check
     * @return bool True if role is a user role
     */
    function _isUserRole(bytes32 role) internal pure returns (bool) {
        return role == CURATOR_ROLE || 
               role == REVIEWER_ROLE;
    }

    /**
     * @notice Internal function to check if a role is a valid role in the system
     * @param role Role identifier to check
     * @return bool True if role is valid (system or user role)
     */
    function _isValidRole(bytes32 role) internal pure returns (bool) {
        return _isSystemRole(role) || _isUserRole(role) || role == DEFAULT_ADMIN_ROLE;
    }

    function hasRole(bytes32 role, address account) 
    public 
    view 
    override(AccessControlUpgradeable, IRoles) 
    returns (bool) 
    {
        return super.hasRole(role, account);
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
