// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

/**
 * @title IVotingSystem
 * @notice Interface for VotingSystem contract that manages voting rounds for idea selection
 * @dev Handles token-staked voting, round management, and winner determination
 */
interface IVotingSystem {
    /* ========== EVENTS ========== */

    /**
     * @notice Emmited when contract was initialized
     * @param sender Address who initialized the contract
     */
    event VotingSystemInitialized(address sender);
    /**
     * @notice Emitted when a new voting round starts
     * @param roundId Unique identifier of the voting round
     * @param ideaIds Array of idea IDs included in the round
     * @param startTime Round start timestamp
     * @param endTime Round end timestamp
     */
    event VotingRoundStarted(
        uint256 indexed roundId,
        uint256[] ideaIds,
        uint256 startTime,
        uint256 endTime
    );

    /**
     * @notice Emitted when a user casts votes
     * @param voter Address of the voting user
     * @param roundId Voting round identifier
     * @param ideaId Idea receiving votes
     * @param amount Amount of tokens staked as votes
     */
    event VoteCast(
        address indexed voter,
        uint256 indexed roundId,
        uint256 indexed ideaId,
        uint256 amount
    );

    /**
     * @notice Emitted when a voting round ends
     * @param roundId Unique identifier of the ended round
     * @param winningIdeaId ID of the winning idea (0 if no votes)
     * @param winningVotes Total votes received by the winner
     */
    event VotingRoundEnded(
        uint256 indexed roundId,
        uint256 winningIdeaId,
        uint256 winningVotes
    );

    /**
     * @notice Emitted when FundingPool address is updated
     * @param newFundingPool New FundingPool contract address
     */
    event FundingPoolUpdated(address newFundingPool);
    
    /**
     * @notice Emitted when IdeaRegistry address is updated
     * @param newIdeaRegistry New IdeaRegistry contract address
     */
    event IdeaRegistryUpdated(address newIdeaRegistry);
    
    /**
     * @notice Emitted when IdeaRegistry address is updated
     * @param newReputationSystem New ReputationSystem contract address
     */
    event ReputationSystemUpdated(address newReputationSystem);

    /**
     * @notice Emitted when IdeaRegistry address is updated
     * @param newVoterProgression New ReputationSystem contract address
     */
    event VoterProgressionUpdated(address newVoterProgression);

    /**
     * @notice Emitted when voting duration is updated
     * @param newDuration New voting duration in seconds
     */
    event VotingDurationUpdated(uint256 newDuration);

    /**
     * @notice Emitted when minimum stake is updated
     * @param newMinStake New minimum stake amount
     */
    event MinStakeUpdated(uint256 newMinStake);

    /**
     * @notice Emitted when ideas per round is updated
     * @param newQuantity New number of ideas per round
     */
    event IdeasPerRoundUpdated(uint256 newQuantity);


    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Starts a new voting round (anyone can call)
     * @dev Sets up round parameters, validates included ideas, and updates their status
     */
    function startVotingRound() external;

    /**
     * @notice Casts votes for an idea in a specific round
     * @dev Transfers tokens from voter to funding pool as stake
     * @param roundId Voting round identifier
     * @param ideaId Idea to vote for
     * @param amount Amount of tokens to stake as votes
     */
    function vote(
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external;

    /**
     * @notice Ends a voting round and determines winner (callable by anyone)
     * @dev Identifies idea with highest votes, updates statuses, and handles rewards
     * @param roundId Voting round to end
     * @return winningIdeaId ID of the winning idea (0 if no votes)
     */
    function endVotingRound(uint256 roundId) external returns (uint256 winningIdeaId);

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Retrieves voting results for a completed round
     * @param roundId Voting round to query
     * @return winningIdeaId ID of the winning idea
     * @return totalVotes Total votes cast in the round
     */
    function getRoundResults(uint256 roundId) external view returns (uint256 winningIdeaId, uint256 totalVotes);

    /**
     * @notice Gets the winner and winning votes for a completed round
     * @param roundId Voting round to query
     * @return winningIdeaId ID of the winning idea
     * @return winningVotes Votes received by the winning idea
     */
    function getRoundWinner(uint256 roundId) external view returns(uint256 winningIdeaId, uint256 winningVotes);

    /**
     * @notice Returns votes received by a specific idea in a round
     * @param roundId Voting round identifier
     * @param ideaId Idea to query votes for
     * @return votes Amount of votes received
     * @custom:requires Round must exist
     */
    function getVotesForIdea(uint256 roundId, uint256 ideaId) external view returns (uint256 votes);

    /**
     * @notice Returns comprehensive round information
     * @param roundId Voting round to query
     * @return id Round identifier
     * @return ideaIds Array of included idea IDs
     * @return startTime Round start timestamp
     * @return endTime Round end timestamp
     * @return active Whether round is currently active
     * @return ended Whether round has ended
     * @return totalVotes Total votes cast
     * @return winningIdeaId ID of winning idea (if ended)
     * @return winningVotes Votes received by winner (if ended)
     * @custom:requires Round must exist
     */
    function getRoundInfo(uint256 roundId) external view returns (
        uint256 id,
        uint256[] memory ideaIds,
        uint256 startTime,
        uint256 endTime,
        bool active,
        bool ended,
        uint256 totalVotes,
        uint256 winningIdeaId,
        uint256 winningVotes
    );

    /**
     * @notice Checks if an address has voted in a specific round
     * @param roundId Voting round identifier
     * @param voter Address to check
     * @return bool True if the address has voted in the round
     */
    function hasVoted(uint256 roundId, address voter) external view returns (bool);

    /**
     * @notice Gets all voters for a specific idea in a round
     * @param roundId Voting round identifier
     * @param ideaId Idea to query
     * @return voters Array of voter addresses
     */
    function getVotersForIdea(uint256 roundId, uint256 ideaId) external view returns (address[] memory voters);

    /**
     * @notice Checks if a round can be started (cooldown passed and enough ideas)
     * @return canStart True if a new round can be started
     * @return reason Human-readable reason if cannot start
     */
    function canStartNewRound() external view returns (bool canStart, string memory reason);

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates the funding pool contract address
     * @dev Can only be called by the contract owner
     * @param _newPool New FundingPool contract address
     */
    function setFundingPool(address _newPool) external;

    /**
     * @notice Updates the idea registry contract address
     * @dev Can only be called by the contract owner
     * @param _newRegistry New IdeaRegistry contract address
     */
    function setIdeaRegistry(address _newRegistry) external;

    /**
     * @notice Updates the reputation system contract address
     * @dev Can only be called by the contract owner
     * @param _newReputationSystem New ReputationSystem contract address
     */
    function setReputationSystem(address _newReputationSystem) external;

    /**
     * @notice Updates the voter progression contract address
     * @dev Can only be called by the contract owner
     * @param _newVoterProgression New VoterProgression contract address
     */
    function setVoterProgression(address _newVoterProgression) external;

    /**
     * @notice Updates the default voting duration
     * @dev Can only be called by the contract owner
     * @param _duration New voting duration in seconds
     */
    function setVotingDuration(uint256 _duration) external;

    /**
     * @notice Updates the minimum stake required to vote
     * @dev Can only be called by the contract owner
     * @param _minStake New minimum stake amount (in token units)
     */
    function setMinStake(uint256 _minStake) external;
    
    /**
     * @notice Updates the minimum ideas per round required to start a voting round
     * @dev Can only be called by the contract owner
     * @param quantity New number of ideas per round
     */
    function setIdeaPerRound(uint256 quantity) external;
}
