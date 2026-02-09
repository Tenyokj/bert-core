// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "../utils/IdeaStatus.sol";

/**
 * @title IIdeaRegistry
 * @notice Interface for IdeaRegistry contract - central registry for storing and managing ideas
 * @dev Provides external function declarations and event definitions for idea lifecycle management
 */
interface IIdeaRegistry {
    /* ========== EVENTS ========== */

    /**
     * @notice Emmited when contract was initialized
     * @param sender Address who initialized the contract
     */
    event IdeaRegistryInitialized(address sender);

    /**
     * @notice Emitted when a new idea is created
     * @param ideaId Unique identifier of the created idea
     * @param author Address of the idea creator
     * @param title Title of the idea
     */
    event IdeaCreated(uint256 indexed ideaId, address indexed author, string title);

    /**
     * @notice Emitted when an idea's status is updated
     * @param ideaId Unique identifier of the idea
     * @param newStatus New status of the idea
     */
    event IdeaStatusUpdated(uint256 indexed ideaId, IdeaStatus newStatus);

    /**
     * @notice Emitted when votes are added to an idea
     * @param ideaId Unique identifier of the idea
     * @param voter Address that added the votes
     * @param amount Number of votes added
     */
    event IdeaVoted(uint256 indexed ideaId, address indexed voter, uint256 amount);

    /**
     * @notice Emitted when an idea is marked as low quality
     * @param ideaId Unique identifier of the idea
     * @param curator Address of the curator who marked the idea
     */
    event IdeaMarkedLowQuality(uint256 indexed ideaId, address indexed curator);

    /**
     * @notice Emitted when a review is added to an idea
     * @param ideaId Unique identifier of the idea
     * @param reviewer Address of the reviewer
     */
    event ReviewAdded(uint256 indexed ideaId, address indexed reviewer);

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

    /* ========== IDEA MANAGEMENT FUNCTIONS ========== */

    /**
     * @notice Creates a new idea entry
     * @dev Idea starts with Pending status and zero votes. Initializes author's reputation if needed.
     * @param _title Title of the idea
     * @param _description Detailed description of the idea
     * @param _link Optional external link (can be empty string)
     */
    function createIdea(
        string memory _title,
        string memory _description,
        string memory _link
    ) external;

    /**
     * @notice Updates the status of an existing idea
     * @dev Only callable by authorized roles (Voting System or Grant Manager)
     * @param ideaId ID of the idea to update
     * @param newStatus New status for the idea
     */
    function updateStatus(
        uint256 ideaId,
        IdeaStatus newStatus
    ) external;

    /**
     * @notice Manually adds votes to an idea
     * @dev Primarily for administrative adjustments and testing. Only callable by VOTING_ROLE.
     * @param ideaId ID of the idea receiving votes
     * @param amount Number of votes to add
     */
    function addVote(uint256 ideaId, uint256 amount) external;

    /**
     * @notice Marks an idea as low quality
     * @dev Only callable by CURATOR_ROLE. Idea must be in Voting status.
     * @param ideaId ID of the idea to mark as low quality
     */
    function markLowQuality(uint256 ideaId) external;

    /**
     * @notice Adds a review to an idea
     * @dev Only callable by REVIEWER_ROLE. Idea must be in Voting status.
     * @param ideaId ID of the idea to review
     * @param comment Review comment text
     */
    function addReview(uint256 ideaId, string memory comment) external;

    /**
     * @notice Marks idea status as completed (when the author implements his idea)
     * @param ideaId ID of the idea to mark
     */
    function markAsCompleted(uint256 ideaId) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Retrieves all idea IDs created by a specific author
     * @param _author Address to query
     * @return Array of idea IDs created by the author
     */
    function getIdeasByAuthor(address _author) external view returns (uint256[] memory);

    /**
     * @notice Retrieves the author address for a specific idea
     * @dev Optimized for external contracts needing only author information
     * @param ideaId ID of the idea to query
     * @return author Address of the idea creator
     */
    function getIdeaAuthor(uint256 ideaId) external view returns (address);

    /**
     * @notice Retrieves comprehensive idea data as separate return values
     * @param _ideaId ID of the idea to retrieve
     * @return id Unique identifier
     * @return author Creator address
     * @return title Idea title
     * @return description Detailed description
     * @return link External reference
     * @return createdAt Creation timestamp
     * @return totalVotes Cumulative votes received
     * @return status Current lifecycle status as uint8
     */
    function getIdea(uint256 _ideaId) external view returns (
        uint256 id,
        address author,
        string memory title,
        string memory description,
        string memory link,
        uint256 createdAt,
        uint256 totalVotes,
        uint8 status
    );

    /**
     * @notice Retrieves the status of an idea
     * @param _ideaId ID of the idea to query
     * @return Current status of the idea
     */
    function getStatus(uint256 _ideaId) external view returns (IdeaStatus);

    /**
     * @notice Returns the total number of created ideas
     * @return Count of all ideas
     */
    function totalIdeas() external view returns (uint256);

    /**
     * @notice Retrieves the number of reviews for a specific idea
     * @param ideaId ID of the idea
     * @return Number of reviews for the idea
     */
    function getReviewCount(uint256 ideaId) external view returns (uint256);

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates the ReputationSystem contract address
     * @dev Only callable by contract owner
     * @param _newReputationSystem New ReputationSystem contract address
     */
    function setReputationSystem(address _newReputationSystem) external;

    /**
     * @notice Updates the VoterProgression contract address
     * @dev Only callable by contract owner
     * @param _newVoterProgression New VoterProgression contract address
     */
    function setVoterProgression(address _newVoterProgression) external;
}
