// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IVoterProgression } from "../interfaces/IVoterProgression.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import "../utils/Errors.sol";

/**
 * @title VoterProgression
 * @notice Tracks voter progression and grants roles based on winning vote count
 * @dev Manages role progression system where voters earn CURATOR_ROLE and REVIEWER_ROLE based on successful votes
 * @dev Upgradeable
 * 
 * @custom:version 1.0.0
 */
contract VoterProgressionUpgradeable is 
    Initializable, 
    RolesAwareUpgradeable, 
    IVoterProgression 
{
    /* ========== CONSTANTS ========== */

    /// @notice Number of winning votes required to earn CURATOR_ROLE
    uint256 public constant CURATOR_THRESHOLD = 20;

    /// @notice Number of winning votes required to earn REVIEWER_ROLE
    uint256 public constant REVIEWER_THRESHOLD = 60;

    /* ========== STORAGE ========== */

    /// @dev Mapping from voter address to their total winning vote count
    mapping(address => uint256) private _winningVotes;

    /// @dev Mapping from voter address to CURATOR_ROLE grant status
    mapping(address => bool) private _curatorGranted;

    /// @dev Mapping from voter address to REVIEWER_ROLE grant status
    mapping(address => bool) private _reviewerGranted;

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the VoterProgression contract
     * @param _rolesRegistry Address of the RolesRegistry contract
     */
    function initialize(address _rolesRegistry) public initializer {
        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");
        __RolesAware_init(_rolesRegistry);
    }
    
    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Register a winning vote for a voter
     * @dev Can only be called by contracts with VOTING_ROLE (typically VotingSystem)
     * @param voter Address of the voter to register the winning vote for
     * @custom:emits WinningVoteRegistered
     * @custom:emits RoleGranted (if thresholds reached)
     * @custom:requires Caller must have VOTING_ROLE
     * @custom:requires voter cannot be zero address
     */
    function registerWinningVote(address voter) external onlyVotingSystem {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }

        _winningVotes[voter] += 1;
        
        emit WinningVoteRegistered(voter, _winningVotes[voter]);

        _checkAndGrantRoles(voter);
    }

    /* ========== INTERNAL FUNCTIONS ========== */

    /**
     * @notice Internal function to check and grant roles based on vote thresholds
     * @dev Grants CURATOR_ROLE at 120 winning votes and REVIEWER_ROLE at 350 winning votes
     * @param voter Address of the voter to check and potentially grant roles to
     * @custom:emits RoleGranted (if roles are granted)
     */
    function _checkAndGrantRoles(address voter) internal {
        uint256 votes = _winningVotes[voter];

        if (votes >= CURATOR_THRESHOLD && !_curatorGranted[voter]) {
            roles.grantUserRole(roles.CURATOR_ROLE(), voter);
            _curatorGranted[voter] = true;
            emit RoleGranted(voter, roles.CURATOR_ROLE());
        }

        if (votes >= REVIEWER_THRESHOLD && !_reviewerGranted[voter]) {
            roles.grantUserRole(roles.REVIEWER_ROLE(), voter);
            _reviewerGranted[voter] = true;
            emit RoleGranted(voter, roles.REVIEWER_ROLE());
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Gets the total number of winning votes for a specific voter
     * @param voter Address of the voter to query
     * @return uint256 Total number of winning votes for the voter
     */
    function getWinningVotes(address voter) external view returns (uint256) {
        return _winningVotes[voter];
    }

    /**
     * @notice Checks if a voter has been granted CURATOR_ROLE through progression
     * @param voter Address of the voter to check
     * @return bool True if voter has been granted CURATOR_ROLE via progression system
     */
    function hasRoleCurator(address voter) external view returns (bool) {
        return _curatorGranted[voter];
    }

    /**
     * @notice Checks if a voter has been granted REVIEWER_ROLE through progression
     * @param voter Address of the voter to check
     * @return bool True if voter has been granted REVIEWER_ROLE via progression system
     */
    function hasRoleReviewer(address voter) external view returns (bool) {
        return _reviewerGranted[voter];
    }

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
        ) 
    {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }

        winningVotes = _winningVotes[voter];
        isCurator = _curatorGranted[voter];
        isReviewer = _reviewerGranted[voter];

        if (!isCurator) {
            votesToCurator = winningVotes >= CURATOR_THRESHOLD ? 0 : CURATOR_THRESHOLD - winningVotes;
        }

        if (!isReviewer) {
            votesToReviewer = winningVotes >= REVIEWER_THRESHOLD ? 0 : REVIEWER_THRESHOLD - winningVotes;
        }
    }

    /**
     * @notice Checks if a voter qualifies for CURATOR_ROLE based on current vote count
     * @param voter Address of the voter to check
     * @return bool True if voter qualifies for CURATOR_ROLE (has enough votes and not already granted)
     */
    function qualifiesForCurator(address voter) external view returns (bool) {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }
        return _winningVotes[voter] >= CURATOR_THRESHOLD && !_curatorGranted[voter];
    }

    /**
     * @notice Checks if a voter qualifies for REVIEWER_ROLE based on current vote count
     * @param voter Address of the voter to check
     * @return bool True if voter qualifies for REVIEWER_ROLE (has enough votes and not already granted)
     */
    function qualifiesForReviewer(address voter) external view returns (bool) {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }
        return _winningVotes[voter] >= REVIEWER_THRESHOLD && !_reviewerGranted[voter];
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Force grant CURATOR_ROLE to an address (admin override)
     * @param voter Address to grant CURATOR_ROLE to
     * @custom:emits RoleGranted
     * @custom:requires Caller must have DEFAULT_ADMIN_ROLE
     */
    function grantCuratorRole(address voter) external onlyAdmin {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }

        if (_curatorGranted[voter]) {
            revert AlreadyCurator(voter);
        }

        roles.grantUserRole(roles.CURATOR_ROLE(), voter);
        _curatorGranted[voter] = true;
        emit RoleGranted(voter, roles.CURATOR_ROLE());
    }

    /**
     * @notice Force grant REVIEWER_ROLE to an address (admin override)
     * @param voter Address to grant REVIEWER_ROLE to
     * @custom:emits RoleGranted
     * @custom:requires Caller must have DEFAULT_ADMIN_ROLE
     */
    function grantReviewerRole(address voter) external onlyAdmin {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }

        if (_reviewerGranted[voter]) {
            revert AlreadyReviewer(voter);
        }

        roles.grantUserRole(roles.REVIEWER_ROLE(), voter);
        _reviewerGranted[voter] = true;
        emit RoleGranted(voter, roles.REVIEWER_ROLE());
    }

    /**
     * @notice Reset a voter's progression (emergency/admin function)
     * @param voter Address of the voter to reset
     * @custom:emits ProgressionReset
     * @custom:requires Caller must have DEFAULT_ADMIN_ROLE
     */
    function resetProgression(address voter) external onlyAdmin {
        if (voter == address(0)) {
            revert ZeroAddress("voter");
        }

        bool isCurator = _curatorGranted[voter];
        bool isReviewer = _reviewerGranted[voter];
        bool hasVotes = _winningVotes[voter] > 0;

        if (!hasVotes && !isCurator && !isReviewer) {
            revert NoProgressionToReset(voter);
        }

        _winningVotes[voter] = 0;

        if (isCurator) {
            roles.revokeUserRole(roles.CURATOR_ROLE(), voter);
            _curatorGranted[voter] = false;
        }

        if (isReviewer) {
            roles.revokeUserRole(roles.REVIEWER_ROLE(), voter);
            _reviewerGranted[voter] = false;
        }

        emit ProgressionReset(voter);
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
