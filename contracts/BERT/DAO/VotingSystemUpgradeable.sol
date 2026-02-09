// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IVotingSystem } from "../interfaces/IVotingSystem.sol";
import { IFundingPool } from "../interfaces/IFundingPool.sol";
import { IIdeaRegistry } from "../interfaces/IIdeaRegistry.sol";
import { IReputationSystem } from "../interfaces/IReputationSystem.sol";
import { IVoterProgression } from "../interfaces/IVoterProgression.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import "../utils/IdeaStatus.sol";
import "../utils/Errors.sol";

/**
 * @title VotingSystem
 * @notice Manages voting rounds for idea selection within the DAO
 * @dev Handles token-staked voting, round management, and winner determination
 * @dev Pausable, Upgradeable
 * 
 * @custom:version 1.0.0
 */
contract VotingSystemUpgradeable is 
    Initializable, 
    ReentrancyGuardUpgradeable, 
    PausableUpgradeable, 
    RolesAwareUpgradeable, 
    IVotingSystem 
{
    /* ========== CONTRACTS ========== */

    /// @notice FundingPool contract interface
    IFundingPool public fundingPool;

    /// @notice IdeaRegistry contract interface
    IIdeaRegistry public ideaRegistry;

    /// @notice ReputationSystem contract interface
    IReputationSystem public reputationSystem;

    /// @notice VoterProgression contract interface
    IVoterProgression public voterProgression;

    /* ========== CONSTANTS ========== */

    /// @notice Cooldown period between rounds in seconds (10 minutes)
    uint256 public constant ROUND_COOLDOWN = 10 minutes;
    
    /// @notice Maximum voters allowed per idea in a round (protects endVotingRound gas usage)
    uint256 public constant MAX_VOTERS_PER_IDEA = 30;

    /* ========== STATE VARIABLES ========== */

    /// @notice Minimum quantity of ideas required to start a Voting Round
    uint256 public IDEAS_PER_ROUND;

    /// @notice Default voting duration in seconds (1 day)
    uint256 public VOTING_DURATION;

    /// @notice Timestamp when the last round ended
    uint256 public lastRoundEnd;
    
    /// @notice Last used idea ID in voting rounds
    uint256 public lastUsedIdeaId;

    /// @notice Current round ID counter
    uint256 public currentRoundId;

    /// @notice Minimum token stake required to vote (in token units with 18 decimals)
    uint256 public minStake;

    /* ========== STRUCTS ========== */
    
    /**
     * @notice Voting round data structure
     * @dev Uses nested mappings for efficient vote tracking
     * @param id Round identifier
     * @param ideaIds Array of idea IDs included in the round
     * @param startTime Round start timestamp
     * @param endTime Round end timestamp
     * @param active Whether the round is currently active
     * @param ended Whether the round has ended
     * @param totalVotes Total votes cast in the round
     * @param winningIdeaId ID of the winning idea
     * @param winningVotes Total votes received by the winning idea
     * @param ideaVotes Mapping of votes per idea: ideaId → vote amount
     * @param hasVoted Mapping tracking which addresses have voted: voter → voted status
     * @param isIdeaInRound Mapping tracking which ideas are in the round: ideaId → inclusion status
     * @param votersForIdea Mapping of voters per idea: ideaId → array of voter addresses
     */
    struct VotingRound {
        uint256 id;
        uint256[] ideaIds;
        uint256 startTime;
        uint256 endTime;
        bool active;
        bool ended;
        uint256 totalVotes;
        uint256 winningIdeaId;
        uint256 winningVotes;
        mapping(uint256 => uint256) ideaVotes;         
        mapping(address => bool) hasVoted;            
        mapping(uint256 => bool) isIdeaInRound;
        mapping(uint256 => address[]) votersForIdea;        
    }

    /* ========== STORAGE ========== */ 

    /// @dev Mapping from round ID to VotingRound struct
    mapping(uint256 => VotingRound) private votingRounds;

    /* ========== MODIFIERS ========== */

    /**
     * @notice Verifies a voting round exists
     * @param roundId ID to check for existence
     * @custom:requires Voting round with given ID must exist
     */
    modifier roundExists(uint256 roundId) {
        if (votingRounds[roundId].id != roundId) {
            revert RoundDoesNotExist(roundId);
        }
        _;
    }

    /**
     * @notice Verifies that a round can be ended (time has expired)
     * @param roundId ID of the round to check
     * @custom:requires Current time must be past round end time
     */
    modifier canEndRound(uint256 roundId) {
        VotingRound storage r = votingRounds[roundId];
        if (block.timestamp <= r.endTime) {
            revert RoundNotEnded(roundId);
        }
        _;
    }

    /**
     * @notice Verifies that cooldown period has passed since last round
     * @custom:requires Cooldown period must have passed since last round ended
     */
    modifier cooldownPassed() {
        uint256 cooldownEnd = lastRoundEnd + ROUND_COOLDOWN;
        if (block.timestamp < cooldownEnd) {
            revert CooldownNotPassed(lastRoundEnd, cooldownEnd); 
        }
        _;
    }

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the VotingSystem contract
     * @dev Sets up all external contract dependencies
     * @param _fundingPool Address of the FundingPool contract
     * @param _ideaRegistry Address of the IdeaRegistry contract
     * @param _reputationSystem Address of the ReputationSystem contract
     * @param _voterProgression Address of the VoterProgression contract
     * @param _rolesRegistry Address of the RolesRegistry contract
     * @custom:emits VotingSystemInitialized
     * @custom:requires All addresses must be non-zero
     */
    function initialize(
        address _fundingPool, 
        address _ideaRegistry, 
        address _reputationSystem,
        address _voterProgression,
        address _rolesRegistry
    ) public initializer {
        __ReentrancyGuard_init();
        __Pausable_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");

        __RolesAware_init(_rolesRegistry);
        
        // Проверки
        if (_fundingPool == address(0)) revert ZeroAddress("fundingPool");
        if (_ideaRegistry == address(0)) revert ZeroAddress("ideaRegistry");
        if (_reputationSystem == address(0)) revert ZeroAddress("reputationSystem");
        if (_voterProgression == address(0)) revert ZeroAddress("voterProgression");

        // Инициализация переменных
        fundingPool = IFundingPool(_fundingPool);
        ideaRegistry = IIdeaRegistry(_ideaRegistry);
        reputationSystem = IReputationSystem(_reputationSystem);
        voterProgression = IVoterProgression(_voterProgression);
        
        // Инициализация значений
        IDEAS_PER_ROUND = 30;
        VOTING_DURATION = 1 days;
        currentRoundId = 1;
        minStake = 3000 * 10**18;
        
        _pause();
        
        emit VotingSystemInitialized(msg.sender);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Starts a new voting round (anyone can call)
     * @dev Sets up round parameters, validates included ideas, and updates their status
     * @custom:emits VotingRoundStarted
     * @custom:requires Cooldown period must have passed since last round
     * @custom:requires Enough new ideas must be available (≥ IDEAS_PER_ROUND)
     * @custom:reentrancy protected
     */
    function startVotingRound() 
        external 
        nonReentrant 
        cooldownPassed 
        whenNotPaused 
    {
        uint256 totalIdeas = ideaRegistry.totalIdeas();
        uint256 availableIdeas = totalIdeas - lastUsedIdeaId;
        
        if (availableIdeas < IDEAS_PER_ROUND) {
            revert NotEnoughIdeas(availableIdeas, IDEAS_PER_ROUND);
        }

        // Create array of new idea IDs
        uint256[] memory ideaIds = new uint256[](IDEAS_PER_ROUND);
        for (uint256 i = 0; i < IDEAS_PER_ROUND; i++) {
            ideaIds[i] = lastUsedIdeaId + 1 + i;
        }

        uint256 newId = currentRoundId;

        // Initialize new voting round
        VotingRound storage r = votingRounds[newId];
        r.id = newId;
        r.startTime = block.timestamp;
        r.endTime = block.timestamp + VOTING_DURATION;
        r.active = true;

        // Add ideas to round
        for (uint256 i = 0; i < ideaIds.length; i++) {
            uint256 ideaId = ideaIds[i];
            if (ideaId == 0) {
                revert InvalidId("ideaId");
            }
            
            IdeaStatus status = ideaRegistry.getStatus(ideaId);
            if (status != IdeaStatus.Pending) {
                revert IdeaNotPending(ideaId, uint8(status));
            }
            
            if (r.isIdeaInRound[ideaId]) {
                revert DuplicateIdea(newId, ideaId);
            }

            r.ideaIds.push(ideaId);
            r.isIdeaInRound[ideaId] = true;
        }

        // Update counters
        lastUsedIdeaId += IDEAS_PER_ROUND;

        // Update idea statuses to Voting (status 1)
        for (uint256 j = 0; j < r.ideaIds.length; j++) {
            ideaRegistry.updateStatus(r.ideaIds[j], IdeaStatus.Voting); // Status.Voting
        }

        currentRoundId++;

        emit VotingRoundStarted(newId, ideaIds, r.startTime, r.endTime);
    }

    /**
     * @notice Casts votes for an idea in a specific round
     * @dev Transfers tokens from voter to funding pool as stake
     * @param roundId Voting round identifier
     * @param ideaId Idea to vote for
     * @param amount Amount of tokens to stake as votes
     * @custom:emits VoteCast
     * @custom:requires Round id must be > 0 
     * @custom:requires Idea must exists
     * @custom:requires Round must exist and be active
     * @custom:requires Voting must be within round time window
     * @custom:requires Voter hasn't voted in this round
     * @custom:requires Amount must be ≥ minStake
     * @custom:requires Idea must be included in the round
     * @custom:reentrancy protected
     */
    function vote(
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external 
      nonReentrant 
      roundExists(roundId) 
      whenNotPaused 
    {
        if (roundId == 0) {
            revert InvalidId("roundId");
        }
        if (ideaId == 0) {
            revert InvalidId("ideaId");
        }

        VotingRound storage r = votingRounds[roundId];
        
        if (!r.active) {
            revert RoundNotActive(roundId);
        }
        
        if (block.timestamp < r.startTime || block.timestamp > r.endTime) {
            revert NotInVotingWindow(r.startTime, r.endTime, block.timestamp);
        }
        
        if (r.hasVoted[msg.sender]) {
            revert AlreadyVoted(msg.sender, roundId);
        }
        
        if (amount < minStake) {
            revert InsufficientStake(amount, minStake);
        }
        
        if (!r.isIdeaInRound[ideaId]) {
            revert IdeaNotInRound(roundId, ideaId);
        }
        
        if (r.votersForIdea[ideaId].length >= MAX_VOTERS_PER_IDEA) {
            revert MaxVotersReached(roundId, ideaId, MAX_VOTERS_PER_IDEA);
        }

        // Deposit tokens through funding pool
        try fundingPool.depositForIdeaFrom(msg.sender, roundId, ideaId, amount) {
            // Success - continue
        } catch {
            revert ExternalCallFailed("FundingPool", "depositForIdeaFrom");
        }

        // Update voting records
        r.ideaVotes[ideaId] += amount;
        r.totalVotes += amount;
        r.hasVoted[msg.sender] = true;
        r.votersForIdea[ideaId].push(msg.sender);

        // Register vote in idea registry
        ideaRegistry.addVote(ideaId, amount);

        emit VoteCast(msg.sender, roundId, ideaId, amount);
    }

    /**
     * @notice Ends a voting round and determines winner (callable by anyone)
     * @dev Identifies idea with highest votes, updates statuses, and handles rewards
     * @param roundId Voting round to end
     * @return winningIdeaId ID of the winning idea (0 if no votes)
     * @custom:emits VotingRoundEnded
     * @custom:requires Round must exist and be active
     * @custom:requires Round must not already be ended
     * @custom:requires Current time must be past round end time
     */
    function endVotingRound(uint256 roundId)
        external
        roundExists(roundId)
        canEndRound(roundId)
        returns (uint256 winningIdeaId)
    {
        VotingRound storage r = votingRounds[roundId];
        
        if (r.ended) {
            revert RoundAlreadyEnded(roundId);
        }
        
        if (!r.active) {
            revert RoundNotActive(roundId);
        }

        // Find idea with highest votes
        uint256 highestVotes = 0;
        winningIdeaId = 0;

        for (uint256 i = 0; i < r.ideaIds.length; i++) {
            uint256 id = r.ideaIds[i];
            uint256 votes = r.ideaVotes[id];
            if (votes > highestVotes) {
                highestVotes = votes;
                winningIdeaId = id;
            }
        }

        // Handle case with no votes
        if (highestVotes == 0) {
            for (uint256 i = 0; i < r.ideaIds.length; i++) {
                uint256 id = r.ideaIds[i];
                ideaRegistry.updateStatus(id, IdeaStatus.Rejected); // Status.Rejected
            }
            r.ended = true;
            r.active = false;
            // Update last round end timestamp
            lastRoundEnd = block.timestamp;
            emit VotingRoundEnded(roundId, 0, 0);
            return 0;
        }

        // Update round state
        r.active = false;
        r.ended = true;
        r.winningIdeaId = winningIdeaId;
        r.winningVotes = highestVotes;

        // Update idea statuses and reputation
        for (uint256 i = 0; i < r.ideaIds.length; i++) {
            uint256 id = r.ideaIds[i];
            address author = ideaRegistry.getIdeaAuthor(id);

            if (id == winningIdeaId) {
                ideaRegistry.updateStatus(id, IdeaStatus.WonVoting);
                try reputationSystem.increaseReputation(author) {
                    // Success
                } catch {
                    revert ExternalCallFailed("ReputationSystem", "increaseReputation");
                }
            } else {
                ideaRegistry.updateStatus(id, IdeaStatus.Rejected);
                try reputationSystem.decreaseReputation(author) {
                    // Success
                } catch {
                    revert ExternalCallFailed("ReputationSystem", "decreaseReputation");
                }
            }
        }

        // Register winning votes for voter progression
        address[] memory voters = r.votersForIdea[winningIdeaId];
        if (voters.length > 0) {
            for (uint256 i = 0; i < voters.length; i++) {
                try voterProgression.registerWinningVote(voters[i]) {
                    // Success
                } catch {
                    revert ExternalCallFailed("VoterProgression", "registerWinningVote");
                }
            }
        }

        // Update last round end timestamp
        lastRoundEnd = block.timestamp; 

        emit VotingRoundEnded(roundId, winningIdeaId, highestVotes);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Retrieves voting results for a completed round
     * @param roundId Voting round to query
     * @return winningIdeaId ID of the winning idea
     * @return totalVotes Total votes cast in the round
     * @custom:requires Round must exist
     * @custom:requires Round must be ended
     */
    function getRoundResults(uint256 roundId)
        external
        view
        roundExists(roundId)
        returns (uint256 winningIdeaId, uint256 totalVotes)
    {
        VotingRound storage r = votingRounds[roundId];
        if (!r.ended) {
            revert RoundNotEnded(roundId);
        }
        return (r.winningIdeaId, r.totalVotes);
    }

    /**
     * @notice Gets the winner and winning votes for a completed round
     * @param roundId Voting round to query
     * @return winningIdeaId ID of the winning idea
     * @return winningVotes Votes received by the winning idea
     * @custom:requires Round must exist
     * @custom:requires Round must be ended
     */
    function getRoundWinner(uint256 roundId)
        external
        view 
        roundExists(roundId)
        returns(uint256 winningIdeaId, uint256 winningVotes)
    {
        VotingRound storage r = votingRounds[roundId];
        if (!r.ended) {
            revert RoundNotEnded(roundId);
        }
        return (r.winningIdeaId, r.winningVotes);
    }

    /**
     * @notice Returns votes received by a specific idea in a round
     * @param roundId Voting round identifier
     * @param ideaId Idea to query votes for
     * @return votes Amount of votes received
     * @custom:requires Round must exist
     */
    function getVotesForIdea(uint256 roundId, uint256 ideaId)
        external
        view
        roundExists(roundId)
        returns (uint256)
    {
        return votingRounds[roundId].ideaVotes[ideaId];
    }

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
    function getRoundInfo(uint256 roundId)
        external
        view
        roundExists(roundId)
        returns (
            uint256 id,
            uint256[] memory ideaIds,
            uint256 startTime,
            uint256 endTime,
            bool active,
            bool ended,
            uint256 totalVotes,
            uint256 winningIdeaId,
            uint256 winningVotes
        )
    {
        VotingRound storage r = votingRounds[roundId];
        return (
            r.id,
            r.ideaIds,
            r.startTime,
            r.endTime,
            r.active,
            r.ended,
            r.totalVotes,
            r.winningIdeaId,
            r.winningVotes
        );
    }

    /**
     * @notice Checks if an address has voted in a specific round
     * @param roundId Voting round identifier
     * @param voter Address to check
     * @return bool True if the address has voted in the round
     * @custom:requires Round must exist
     */
    function hasVoted(uint256 roundId, address voter) 
        external 
        view 
        roundExists(roundId) 
        returns (bool) 
    {
        return votingRounds[roundId].hasVoted[voter];
    }

    /**
     * @notice Gets all voters for a specific idea in a round
     * @param roundId Voting round identifier
     * @param ideaId Idea to query
     * @return voters Array of voter addresses
     * @custom:requires Round must exist
     */
    function getVotersForIdea(uint256 roundId, uint256 ideaId)
        external
        view
        roundExists(roundId)
        returns (address[] memory)
    {
        return votingRounds[roundId].votersForIdea[ideaId];
    }

    /**
     * @notice Checks if a round can be started (cooldown passed and enough ideas)
     * @return canStart True if a new round can be started
     * @return reason Human-readable reason if cannot start
     */
    function canStartNewRound() 
        external 
        view 
        returns (
            bool canStart, 
            string memory reason
        ) 
    {
        uint256 cooldownEnd = lastRoundEnd + ROUND_COOLDOWN;
        if (block.timestamp < cooldownEnd) {
            return (false, "Cooldown period not passed");
        }
        
        uint256 totalIdeas = ideaRegistry.totalIdeas();
        uint256 availableIdeas = totalIdeas - lastUsedIdeaId;
        if (availableIdeas < IDEAS_PER_ROUND) {
            return (false, "Not enough new ideas");
        }
        
        return (true, "Can start new round");
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates the funding pool contract address
     * @dev Can only be called by the contract admin
     * @param _newPool New FundingPool contract address
     * @custom:emits FundingPoolUpdated
     * @custom:requires Only admin can call
     * @custom:requires _newPool cannot be zero address
     */
    function setFundingPool(address _newPool) external onlyAdmin {
        if (_newPool == address(0)) {
            revert ZeroAddress("newPool");
        }
        fundingPool = IFundingPool(_newPool);
        emit FundingPoolUpdated(_newPool);
    }

    /**
     * @notice Updates the idea registry contract address
     * @dev Can only be called by the contract admin
     * @param _newRegistry New IdeaRegistry contract address
     * @custom:emits IdeaRegistryUpdated
     * @custom:requires Only admin can call
     * @custom:requires _newRegistry cannot be zero address
     */
    function setIdeaRegistry(address _newRegistry) external onlyAdmin {
        if (_newRegistry == address(0)) {
            revert ZeroAddress("newRegistry");
        }
        ideaRegistry = IIdeaRegistry(_newRegistry);
        emit IdeaRegistryUpdated(_newRegistry);
    }

    /**
     * @notice Updates the reputation system contract address
     * @dev Can only be called by the contract admin
     * @param _newReputationSystem New ReputationSystem contract address
     * @custom:requires Only admin can call
     * @custom:requires _newReputationSystem cannot be zero address
     */
    function setReputationSystem(address _newReputationSystem) external onlyAdmin {
        if (_newReputationSystem == address(0)) {
            revert ZeroAddress("newReputationSystem");
        }
        reputationSystem = IReputationSystem(_newReputationSystem);
        emit ReputationSystemUpdated(_newReputationSystem);
    }

    /**
     * @notice Updates the voter progression contract address
     * @dev Can only be called by the contract admin
     * @param _newVoterProgression New VoterProgression contract address
     * @custom:requires Only admin can call
     * @custom:requires _newVoterProgression cannot be zero address
     */
    function setVoterProgression(address _newVoterProgression) external onlyAdmin {
        if (_newVoterProgression == address(0)) {
            revert ZeroAddress("newVoterProgression");
        }
        voterProgression = IVoterProgression(_newVoterProgression);
        emit VoterProgressionUpdated(_newVoterProgression);
    }

    /**
     * @notice Updates the default voting duration
     * @dev Can only be called by the contract admin
     * @param _duration New voting duration in seconds
     * @custom:emits VotingDurationUpdated
     * @custom:requires Only admin can call
     */
    function setVotingDuration(uint256 _duration) external onlyAdmin {
        VOTING_DURATION = _duration;
        emit VotingDurationUpdated(_duration);
    }

    /**
     * @notice Updates the minimum stake required to vote
     * @dev Can only be called by the contract admin
     * @param _minStake New minimum stake amount (in token units)
     * @custom:emits MinStakeUpdated
     * @custom:requires Only admin can call
     */
    function setMinStake(uint256 _minStake) external onlyAdmin {
        minStake = _minStake;
        emit MinStakeUpdated(_minStake);
    }
    
    /**
     * @notice Updates the minimum ideas per round required to start a voting round
     * @dev Can only be called by the contract admin
     * @param quantity New number of ideas per round
     * @custom:emits IdeasPerRoundUpdated
     * @custom:requires Only admin can call
     */
    function setIdeaPerRound(uint256 quantity) external onlyAdmin {
        IDEAS_PER_ROUND = quantity;
        emit IdeasPerRoundUpdated(quantity);
    }

    /* ========== PAUSE FUNCTIONS ========== */

    /**
     * @notice Emergency pause the voting system
     * @dev Only admin can pause. Stops all critical operations.
     * @custom:requires Only admin can call
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @notice Unpause the voting system
     * @dev Only admin can unpause. Resumes normal operations.
     * @custom:requires Only admin can call
     */
    function unpause() external onlyAdmin {
        _unpause();
    }

    /**
     * @notice Check if contract is paused
     * @return bool True if contract is paused
     */
    function isPaused() external view returns (bool) {
        return paused();
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
