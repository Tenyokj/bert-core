// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "../extensions/Roles/RolesRegistryUpgradeable.sol";

/**
 * @title IVoterProgression
 * @notice Interface for VoterProgression contract that tracks voter progression and grants roles
 * @dev Manages role progression system where voters earn CURATOR_ROLE and REVIEWER_ROLE based on successful votes
 */
interface IVoterProgression {

    /* ========== EVENTS ========== */

    /// @notice Emitted when a voter's progression is reset by admin
    event ProgressionReset(address indexed voter);

    /**
     * @notice Emitted when a winning vote is registered for a voter
     * @param voter Address of the voter
     * @param totalWinningVotes New total count of winning votes for the voter
     */
    event WinningVoteRegistered(address indexed voter, uint256 totalWinningVotes);

    /**
     * @notice Emitted when a role is granted to a voter
     * @param voter Address of the voter receiving the role
     * @param role Role that was granted (CURATOR_ROLE or REVIEWER_ROLE)
     */
    event RoleGranted(address indexed voter, bytes32 role);

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Register a winning vote for a voter
     * @dev Can only be called by contracts with VOTING_ROLE (typically VotingSystem)
     * @param voter Address of the voter to register the winning vote for
     */
    function registerWinningVote(address voter) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Gets the total number of winning votes for a specific voter
     * @param voter Address of the voter to query
     * @return uint256 Total number of winning votes for the voter
     */
    function getWinningVotes(address voter) external view returns (uint256);

    /**
     * @notice Checks if a voter has been granted CURATOR_ROLE through progression
     * @param voter Address of the voter to check
     * @return bool True if voter has been granted CURATOR_ROLE via progression system
     */
    function hasRoleCurator(address voter) external view returns (bool);

    /**
     * @notice Checks if a voter has been granted REVIEWER_ROLE through progression
     * @param voter Address of the voter to check
     * @return bool True if voter has been granted REVIEWER_ROLE via progression system
     */
    function hasRoleReviewer(address voter) external view returns (bool);

    /**
     * @notice Gets the current progression status for a voter
     * @param voter Address of the voter to query
     * @return winningVotes Current number of winning votes
     * @return isCurator True if voter has CURATOR_ROLE from progression
     * @return isReviewer True if voter has REVIEWER_ROLE from progression
     * @return votesToCurator Votes needed to reach CURATOR_THRESHOLD (0 if already curator)
     * @return votesToReviewer Votes needed to reach REVIEWER_THRESHOLD (0 if already reviewer)
     */
    function getProgressionStatus(address voter) 
        external 
        view 
        returns (
            uint256 winningVotes,
            bool isCurator,
            bool isReviewer,
            uint256 votesToCurator,
            uint256 votesToReviewer
        );

    /**
     * @notice Checks if a voter qualifies for CURATOR_ROLE based on current vote count
     * @param voter Address of the voter to check
     * @return bool True if voter qualifies for CURATOR_ROLE (has enough votes and not already granted)
     */
    function qualifiesForCurator(address voter) external view returns (bool);

    /**
     * @notice Checks if a voter qualifies for REVIEWER_ROLE based on current vote count
     * @param voter Address of the voter to check
     * @return bool True if voter qualifies for REVIEWER_ROLE (has enough votes and not already granted)
     */
    function qualifiesForReviewer(address voter) external view returns (bool);

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Force grant CURATOR_ROLE to an address (admin override)
     * @dev Can only be called by contract owner or admin with appropriate role
     * @param voter Address to grant CURATOR_ROLE to
     */
    function grantCuratorRole(address voter) external;

    /**
     * @notice Force grant REVIEWER_ROLE to an address (admin override)
     * @dev Can only be called by contract owner or admin with appropriate role
     * @param voter Address to grant REVIEWER_ROLE to
     */
    function grantReviewerRole(address voter) external;

    /**
     * @notice Reset a voter's progression (emergency/admin function)
     * @dev Removes all progression data and revokes granted roles
     * @param voter Address of the voter to reset
     */
    function resetProgression(address voter) external;
}
