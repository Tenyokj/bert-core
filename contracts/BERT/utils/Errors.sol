// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "./IdeaStatus.sol";

/**
 * @title DAOErrors
 * @notice Comprehensive error library for the DAO ecosystem
 * @dev All errors include descriptive names and parameters for debugging
 */

// ========== Generic Errors ==========

/**
 * @notice Emitted when a zero address is provided where a valid address is required
 * @param paramName Name of the parameter that was zero address
 * @dev Used across all contracts for address validation
 */
error ZeroAddress(string paramName);

/**
 * @notice Emitted when a zero amount is provided where a positive amount is required
 * @dev Typically used for token transfers, deposits, and votes
 */
error ZeroAmount();

/**
 * @notice Emitted when an invalid ID is provided
 * @param idType Type of ID that was invalid (e.g., "ideaId", "roundId")
 * @dev IDs must be positive integers and typically start from 1
 */
error InvalidId(string idType);

/**
 * @notice Emitted when an array index is out of bounds
 * @dev Used when accessing arrays with invalid indices
 */
error IndexOutOfBounds();

/**
 * @notice Emitted when a parameter has an invalid value
 * @param paramName Name of the invalid parameter
 * @param reason Explanation of why the parameter is invalid
 * @dev Used for parameter validation across all contracts
 */
error InvalidParameter(string paramName, string reason);

/**
 * @notice Emitted when a string field has zero length
 * @param field Name of the field that is empty
 * @dev Used for title, description, and other required text fields
 */
error ZeroLength(string field);


// ========== Transfer Errors ==========

/**
 * @notice Emitted when an ERC20 transferFrom operation fails
 * @dev Typically indicates insufficient allowance or balance
 */
error TransferFromFailed();

/**
 * @notice Emitted when transferring tokens to an author fails
 * @dev Used during grant distribution when payment to author fails
 */
error TransferToAuthorFailed();


// ========== State/Logic Errors ==========

/**
 * @notice Emitted when funds have already been distributed for a round
 * @param roundId ID of the round that already had distribution
 * @dev Prevents double-spending of round funds
 */
error AlreadyDistributed(uint256 roundId);

/**
 * @notice Emitted when there are insufficient funds allocated to an idea in a round
 * @param roundId ID of the funding round
 * @param ideaId ID of the idea with insufficient balance
 * @param available Amount currently available for the idea
 * @param requested Amount requested for distribution
 * @dev Used during grant claiming to ensure sufficient funding
 */
error InsufficientIdeaBalance(uint256 roundId, uint256 ideaId, uint256 available, uint256 requested);

/**
 * @notice Emitted when the pool has insufficient total balance
 * @param available Current pool balance
 * @param requested Amount requested for withdrawal or distribution
 * @dev Used for pool-wide balance checks
 */
error InsufficientPoolBalance(uint256 available, uint256 requested);

/**
 * @notice Emitted when a contract has already been initialized
 * @dev Prevents re-initialization attacks
 */
error AlreadyInitialized();

/**
 * @notice Emitted when something has already been granted/assigned
 * @param paramName Name of what was already granted (e.g., "role", "permission")
 * @dev Prevents duplicate grants
 */
error AlreadyGranted(string paramName);


// ========== Role/Access Errors ==========

/**
 * @notice Emitted when caller lacks required authorization
 * @param role Human-readable name of the required role
 * @dev Generic authorization error with role name
 */
error Unauthorized(string role);

/**
 * @notice Emitted when an invalid role bytes32 identifier is provided
 * @param role The invalid role identifier
 * @dev Used when role doesn't match any defined role constant
 */
error InvalidRole(bytes32 role);

/**
 * @notice Emitted when trying to operate on a role that account doesn't have
 * @param role Role identifier being checked
 * @param account Address being checked for the role
 * @dev Used when revoking non-existent roles
 */
error RoleNotFound(bytes32 role, address account);

/**
 * @notice Emitted when caller is not the voting system contract
 * @dev Specific to functions requiring VOTING_ROLE
 */
error NotVotingSystem();

/**
 * @notice Emitted when caller is not the grant manager contract
 * @dev Specific to functions requiring GRANT_ROLE
 */
error NotGrantManager();

/**
 * @notice Emitted when caller is not the idea registry contract
 * @dev Specific to functions requiring IREGISTRY_ROLE
 */
error NotIdeaRegistry();

/**
 * @notice Emitted when caller is not the reputation manager contract
 * @dev Specific to functions requiring REPUTATION_MANAGER_ROLE
 */
error NotReputationManager();

/**
 * @notice Emitted when caller is not a curator
 * @dev Specific to CURATOR_ROLE required functions
 */
error NotCurator();

/**
 * @notice Emitted when caller is not a reviewer
 * @dev Specific to REVIEWER_ROLE required functions
 */
error NotReviewer();

/**
 * @notice Emitted when caller has neither VOTING_ROLE nor GRANT_ROLE
 * @dev Used for functions that accept either voting system or grant manager
 */
error NotVotingOrGrant();

/**
 * @notice Emitted when caller is not a distributor
 * @dev Specific to functions requiring DEISTRIBUTOR_ROLE
 */
error NotDistributor();


/**
 * @notice Emitted when caller is not a admin
 * @dev Specific to functions requiring DEFAULT_ADMIN
 */
error NotAdmin();

// ========== Validation Errors ==========

/**
 * @notice Emitted when an author address is invalid (zero or not found)
 * @dev Used when author lookup fails or returns address(0)
 */
error InvalidAuthor();

/**
 * @notice Emitted when an invalid address is provided
 * @param param Name of the parameter containing invalid address
 * @dev More specific than ZeroAddress for other invalid address conditions
 */
error InvalidAddress(string param);


// ========== Grant Manager Errors ==========

/**
 * @notice Emitted when trying to claim grant for a round that hasn't ended
 * @param roundId ID of the round that is still active
 * @dev Round must have endTime < block.timestamp
 */
error RoundNotEnded(uint256 roundId);

/**
 * @notice Emitted when a round has no winner
 * @param roundId ID of the round without winner
 * @dev Round must have a winning idea with votes > 0
 */
error NoWinner(uint256 roundId);

/**
 * @notice Emitted when an idea is not in the correct status for grant claiming
 * @param ideaId ID of the idea with wrong status
 * @param expectedStatus Expected status (typically WonVoting)
 * @param currentStatus Current actual status of the idea
 * @dev Idea must be in WonVoting status to claim grant
 */
error IdeaNotEligible(uint256 ideaId, uint8 expectedStatus, uint8 currentStatus);

/**
 * @notice Emitted when caller is not the author of an idea
 * @param caller Address attempting the operation
 * @param expectedAuthor Actual author address of the idea
 * @dev Used to enforce author-only operations
 */
error NotAuthor(address caller, address expectedAuthor);

/**
 * @notice Emitted when no funds are allocated to an idea in a round
 * @param roundId ID of the funding round
 * @param ideaId ID of the idea without allocated funds
 * @dev Idea must have positive pool balance to claim grant
 */
error NoFundsAllocated(uint256 roundId, uint256 ideaId);

/**
 * @notice Emitted when share percentage is invalid
 * @param shareBps Share value in basis points provided
 * @param maxAllowed Maximum allowed share value
 * @dev Typically share must be ≤ 100% (≤ 10000 bps)
 */
error InvalidShare(uint256 shareBps, uint256 maxAllowed);


// ========== Voting System Errors ==========

/**
 * @notice Emitted when referencing a non-existent voting round
 * @param roundId ID of the round that doesn't exist
 * @dev Round ID must be between 1 and currentRoundId-1
 */
error RoundDoesNotExist(uint256 roundId);

/**
 * @notice Emitted when trying to interact with an inactive round
 * @param roundId ID of the inactive round
 * @dev Round must have active == true
 */
error RoundNotActive(uint256 roundId);

/**
 * @notice Emitted when trying to end a round that has already ended
 * @param roundId ID of the already ended round
 * @dev Round must have ended == false
 */
error RoundAlreadyEnded(uint256 roundId);

/**
 * @notice Emitted when voting outside the allowed time window
 * @param startTime Round start timestamp
 * @param endTime Round end timestamp
 * @param currentTime Current block timestamp
 * @dev Current time must be between startTime and endTime
 */
error NotInVotingWindow(uint256 startTime, uint256 endTime, uint256 currentTime);

/**
 * @notice Emitted when a voter tries to vote twice in the same round
 * @param voter Address that already voted
 * @param roundId ID of the round where voting occurred
 * @dev Each address can vote only once per round
 */
error AlreadyVoted(address voter, uint256 roundId);

/**
 * @notice Emitted when stake amount is below minimum requirement
 * @param amount Amount attempted to stake
 * @param minStake Minimum required stake amount
 * @dev Used for token-staked voting validation
 */
error InsufficientStake(uint256 amount, uint256 minStake);

/**
 * @notice Emitted when an idea is not included in the specified round
 * @param roundId ID of the voting round
 * @param ideaId ID of the idea not in round
 * @dev Idea must be in round.ideaIds array
 */
error IdeaNotInRound(uint256 roundId, uint256 ideaId);

/**
 * @notice Emitted when an idea is not in Pending status for round inclusion
 * @param ideaId ID of the idea with wrong status
 * @param actualStatus Current status of the idea (should be Pending)
 * @dev Ideas added to rounds must be in Pending status
 */
error IdeaNotPending(uint256 ideaId, uint8 actualStatus);

/**
 * @notice Emitted when trying to add duplicate idea to a round
 * @param roundId ID of the round
 * @param ideaId ID of the duplicate idea
 * @dev Each idea can appear only once per round
 */
error DuplicateIdea(uint256 roundId, uint256 ideaId);

/**
 * @notice Emitted when the max voters limit for an idea in a round is reached
 * @param roundId ID of the voting round
 * @param ideaId ID of the idea
 * @param maxVoters Maximum allowed voters for this idea in the round
 * @dev Used to bound voter loops in endVotingRound
 */
error MaxVotersReached(uint256 roundId, uint256 ideaId, uint256 maxVoters);

/**
 * @notice Emitted when trying to start a new round before cooldown period
 * @param lastRoundEnd Timestamp when last round ended
 * @param cooldownEnd Timestamp when cooldown period ends
 * @dev Must wait ROUND_COOLDOWN seconds between rounds
 */
error CooldownNotPassed(uint256 lastRoundEnd, uint256 cooldownEnd);

/**
 * @notice Emitted when not enough new ideas are available to start a round
 * @param available Number of new ideas available
 * @param required Minimum ideas required per round
 * @dev Need IDEAS_PER_ROUND new ideas since lastUsedIdeaId
 */
error NotEnoughIdeas(uint256 available, uint256 required);

/**
 * @notice Emitted when an idea has incorrect status for an operation
 * @param ideaId ID of the idea
 * @param expectedStatus Expected status for the operation
 * @param actualStatus Actual current status
 * @dev Used for status validation in various operations
 */
error InvalidIdeaStatus(uint256 ideaId, uint8 expectedStatus, uint8 actualStatus);


// ========== Idea Registry Errors ==========

/**
 * @notice Emitted when referencing a non-existent idea
 * @param ideaId ID of the idea that doesn't exist
 * @dev Idea ID must be between 1 and _ideaIdCounter-1
 */
error IdeaDoesNotExist(uint256 ideaId);

/**
 * @notice Emitted when trying to create an idea that already exists
 * @param ideaId ID of the existing idea
 * @dev Idea IDs are auto-incremented, so this indicates a logic error
 */
error IdeaAlreadyExists(uint256 ideaId);

/**
 * @notice Emitted when an author tries to review their own idea
 * @param author Address of the author attempting self-review
 * @dev Prevents conflict of interest in reviews
 */
error CannotReviewOwnIdea(address author);

/**
 * @notice Emitted when trying to update to the same status
 * @param currentStatus Current status (same as new status)
 * @dev Status must change for update to be meaningful
 */
error StatusUnchanged(IdeaStatus currentStatus);

/**
 * @notice Emitted when attempting an invalid status transition
 * @param fromStatus Current status of the idea
 * @param toStatus Attempted new status
 * @dev Must follow valid state machine transitions
 */
error InvalidTransition(IdeaStatus fromStatus, IdeaStatus toStatus);

/**
 * @notice Emitted when trying to update a terminal status
 * @param currentStatus Current terminal status (Completed or Rejected)
 * @dev Terminal statuses cannot be changed
 */
error TerminalStatus(IdeaStatus currentStatus);

/**
 * @notice Emitted when operation requires idea to be in Voting status
 * @param ideaId ID of the idea
 * @param currentStatus Current status (not Voting)
 * @dev Used for voting-related operations
 */
error NotInVotingStatus(uint256 ideaId, IdeaStatus currentStatus);

/**
 * @notice Emitted when idea is not in the required status for an operation
 * @param requiredStatus Status required for the operation
 * @param currentStatus Current actual status
 * @dev Generic status requirement error
 */
error NotInCorrectStatus(IdeaStatus requiredStatus, IdeaStatus currentStatus);

/**
 * @notice Emitted when trying to mark an already low-quality idea
 * @param ideaId ID of the idea already marked low quality
 * @dev isLowQuality flag can only be set once
 */
error IdeaAlreadyLowQuality(uint256 ideaId);

/**
 * @notice Emitted when trying to add zero votes to an idea
 * @dev Vote amount must be > 0
 */
error ZeroVoteAmount();


// ========== Roles Contract Errors ==========

/**
 * @notice Emitted when a role is invalid for system operations
 * @param role Role identifier that is not a system role
 * @dev System roles: VOTING_ROLE, GRANT_ROLE, DISTRIBUTOR_ROLE, etc.
 */
error InvalidSystemRole(bytes32 role);

/**
 * @notice Emitted when a role is invalid for user operations
 * @param role Role identifier that is not a user role
 * @dev User roles: CURATOR_ROLE, REVIEWER_ROLE
 */
error InvalidUserRole(bytes32 role);

/**
 * @notice Emitted when expecting a system role but got something else
 * @param role Provided role identifier
 * @dev Used in role type validation
 */
error SystemRoleExpected(bytes32 role);

/**
 * @notice Emitted when expecting a user role but got something else
 * @param role Provided role identifier
 * @dev Used in role type validation
 */
error UserRoleExpected(bytes32 role);

/**
 * @notice Emitted when trying to grant a role that account already has
 * @param role Role identifier
 * @param account Address that already has the role
 * @dev Prevents duplicate role assignments
 */
error AlreadyHasRole(bytes32 role, address account);

/**
 * @notice Emitted when trying to revoke DEFAULT_ADMIN_ROLE
 * @dev DEFAULT_ADMIN_ROLE cannot be revoked for security reasons
 */
error CannotRevokeDefaultAdmin();


// ========== Voter Progression Errors ==========

/**
 * @notice Emitted when trying to grant CURATOR_ROLE to already curator
 * @param voter Address that is already a curator
 * @dev Prevents duplicate curator role grants
 */
error AlreadyCurator(address voter);

/**
 * @notice Emitted when trying to grant REVIEWER_ROLE to already reviewer
 * @param voter Address that is already a reviewer
 * @dev Prevents duplicate reviewer role grants
 */
error AlreadyReviewer(address voter);

/**
 * @notice Emitted when progression has already been reset
 * @param voter Address whose progression was already reset
 * @dev Prevents double reset operations
 */
error ProgressionAlreadyReset(address voter);

/**
 * @notice Emitted when trying to reset non-existent progression
 * @param voter Address with no progression data to reset
 * @dev Voter must have some progression data (votes or roles)
 */
error NoProgressionToReset(address voter);

/**
 * @notice Emitted when role has already been granted through progression
 * @param voter Address that received the role
 * @param role Role that was already granted
 * @dev Tracks progression-based role grants separately from admin grants
 */
error RoleAlreadyGranted(address voter, bytes32 role);

/**
 * @notice Emitted when trying to operate on non-granted role
 * @param voter Address without the role
 * @param role Role that hasn't been granted
 * @dev Used for progression-specific role operations
 */
error RoleNotGranted(address voter, bytes32 role);

/**
 * @notice Emitted when votes are below CURATOR_THRESHOLD
 * @param current Current number of winning votes
 * @param required Required votes for curator role
 * @dev Voter needs CURATOR_THRESHOLD winning votes
 */
error BelowCuratorThreshold(uint256 current, uint256 required);

/**
 * @notice Emitted when votes are below REVIEWER_THRESHOLD
 * @param current Current number of winning votes
 * @param required Required votes for reviewer role
 * @dev Voter needs REVIEWER_THRESHOLD winning votes
 */
error BelowReviewerThreshold(uint256 current, uint256 required);

/**
 * @notice Emitted when voter has reached maximum progression
 * @param voter Address that is already both curator and reviewer
 * @dev Voter cannot receive more winning votes after max progression
 */
error AlreadyAtMaxProgression(address voter);


// ========== Reputation System Errors ==========

/**
 * @notice Emitted when operation requires initialized reputation
 * @param author Address whose reputation is not initialized
 * @dev Reputation must be initialized before increases/decreases
 */
error NotInitialized(address author);

/**
 * @notice Emitted when trying to increase reputation at maximum
 * @param author Address at max reputation
 * @param current Current reputation score
 * @param max Maximum allowed reputation (MAX_REPUTATION)
 * @dev Reputation cannot exceed MAX_REPUTATION
 */
error MaxReputationReached(address author, uint256 current, uint256 max);

/**
 * @notice Emitted when trying to decrease reputation at minimum
 * @param author Address at minimum reputation
 * @param current Current reputation score (0 or very low)
 * @dev Reputation cannot go below 0
 */
error MinReputationReached(address author, uint256 current);

/**
 * @notice Emitted when decrease would cause reputation underflow
 * @param author Address whose reputation would underflow
 * @param current Current reputation score
 * @param decrease Amount attempting to decrease
 * @dev Safe arithmetic check for reputation decreases
 */
error ReputationUnderflow(address author, uint256 current, uint256 decrease);

/**
 * @notice Emitted when increase would cause reputation overflow
 * @param author Address whose reputation would overflow
 * @param current Current reputation score
 * @param increase Amount attempting to increase
 * @param max Maximum allowed reputation
 * @dev Safe arithmetic check for reputation increases
 */
error ReputationOverflow(address author, uint256 current, uint256 increase, uint256 max);

/**
 * @notice Emitted when batch operation contains zero address
 * @param index Index in the batch array where zero address was found
 * @dev All addresses in batch operations must be non-zero
 */
error BatchContainsZeroAddress(uint256 index);

/**
 * @notice Emitted when batch size exceeds maximum allowed
 * @param size Actual batch size provided
 * @param max Maximum allowed batch size
 * @dev Prevents gas limit issues and potential DoS
 */
error BatchSizeExceeded(uint256 size, uint256 max);


// ========== External Contract Errors ==========

/**
 * @notice Emitted when an external contract call fails
 * @param contractName Name of the external contract
 * @param functionName Name of the function that failed
 * @dev Used for try/catch blocks with external calls
 */
error ExternalCallFailed(string contractName, string functionName);
