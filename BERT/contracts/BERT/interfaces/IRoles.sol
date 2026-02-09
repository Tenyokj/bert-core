// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title IRoles
 * @notice Interface for Roles contract - central role registry for protocol contracts
 * @dev Manages role-based access control across the DAO ecosystem
 * @dev Owner is responsible ONLY for assigning system roles to contracts
 * @dev User roles are granted through progression systems (VoterProgression)
 */
interface IRoles {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function VOTING_ROLE() external view returns (bytes32);
    function GRANT_ROLE() external view returns (bytes32);
    function DISTRIBUTOR_ROLE() external view returns (bytes32);
    function IREGISTRY_ROLE() external view returns (bytes32);
    function REPUTATION_MANAGER_ROLE() external view returns (bytes32);
    function CURATOR_ROLE() external view returns (bytes32);
    function REVIEWER_ROLE() external view returns (bytes32);


    /* ========== EVENTS ========== */

    /**
     * @notice Emmited when contract was initialized
     * @param sender Address who initialized the contract
     */
    event RolesInitialized(address sender);

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
    function grantSystemRole(bytes32 role, address account) external;

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
    function revokeSystemRole(bytes32 role, address account) external;

    /**
     * @notice Grant a user role (CURATOR_ROLE or REVIEWER_ROLE) to an address
     * @dev Typically called by VoterProgression contract based on vote thresholds
     * @param role User role to grant (CURATOR_ROLE or REVIEWER_ROLE)
     * @param account User address to grant the role to
     * @custom:emits RoleGranted
     * @custom:requires Caller must have AUTO_GRANT_ROLE
     * @custom:requires role must be a valid user role
     * @custom:requires account cannot be zero address
     */
    function grantUserRole(bytes32 role, address account) external;

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
    function revokeUserRole(bytes32 role, address account) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Check if a bytes32 value represents a valid system role
     * @param role Role identifier to check
     * @return bool True if role is a system role
     */
    function isSystemRole(bytes32 role) external pure returns (bool);

    /**
     * @notice Check if a bytes32 value represents a valid user role
     * @param role Role identifier to check
     * @return bool True if role is a user role
     */
    function isUserRole(bytes32 role) external pure returns (bool);
    
    /**
     * @notice Get all roles assigned to an address
     * @param account Address to query
     * @return roles Array of role identifiers the address has
     */
    function getRoles(address account) external view returns (bytes32[] memory roles);

    /**
     * @notice Check if an address has any role in the system
     * @param account Address to check
     * @return bool True if address has any role (including DEFAULT_ADMIN_ROLE)
     */
    function hasAnyRole(address account) external view returns (bool);
}