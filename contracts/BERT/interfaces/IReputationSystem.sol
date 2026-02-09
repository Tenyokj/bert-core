// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../extensions/Roles/RolesRegistryUpgradeable.sol";

/**
 * @title IReputationSystem
 * @notice Interface for ReputationSystem contract that manages user reputation scores
 * @dev Handles reputation initialization, increases for wins, and decreases for losses
 */
interface IReputationSystem {
    /* ========== EVENTS ========== */

    /// @notice Emitted when an admin sets a user's reputation directly
    event ReputationSet(address indexed author, uint256 oldReputation, uint256 newReputation);

    /// @notice Emitted when an admin deinitializes a user's reputation
    event ReputationDeinitialized(address indexed author);

    /**
     * @notice Emitted when reputation is initialized for a new user
     * @param user Address of the user whose reputation was initialized
     */
    event ReputationInitialized(address indexed user);

    /**
     * @notice Emitted when a user's reputation increases
     * @param author Address of the user whose reputation increased
     * @param newValue New reputation value after increase
     */
    event ReputationIncreased(address indexed author, uint256 newValue);

    /**
     * @notice Emitted when a user's reputation decreases
     * @param author Address of the user whose reputation decreased
     * @param newValue New reputation value after decrease
     * @param amount Amount of reputation points decreased
     */
    event ReputationDecreased(address indexed author, uint256 newValue, uint256 amount);

    /**
     * @notice Emitted when reputation per win value is updated (admin only)
     * @param oldValue Previous reputation per win value
     * @param newValue New reputation per win value
     */
    event ReputationPerWinUpdated(uint256 oldValue, uint256 newValue);

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Initialize reputation for a new author
     * @dev Called once when a user first participates in the system (e.g., creates first idea)
     * @param author Address of the author to initialize reputation for
     */
    function initializeReputation(address author) external;

    /**
     * @notice Increase reputation after winning a voting round
     * @dev Caps reputation at MAX_REPUTATION if increase would exceed limit
     * @param author Address of the author whose reputation should increase
     */
    function increaseReputation(address author) external;

    /**
     * @notice Decrease reputation (e.g., for losing a voting round)
     * @dev Prevents reputation from going below zero
     * @param author Address of the author whose reputation should decrease
     */
    function decreaseReputation(address author) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Get the current reputation score for an address
     * @dev Returns START_REPUTATION for uninitialized users
     * @param author Address to query reputation for
     * @return uint256 Current reputation score (START_REPUTATION if not initialized)
     */
    function getReputation(address author) external view returns (uint256);

    /**
     * @notice Check if a user's reputation has been initialized
     * @param author Address to check
     * @return bool True if reputation has been initialized
     */
    function isInitialized(address author) external view returns (bool);

    /**
     * @notice Get the maximum allowed reputation increase for a user
     * @dev Calculates how much reputation can be added before hitting MAX_REPUTATION
     * @param author Address to check
     * @return uint256 Available reputation increase capacity (0 if at max)
     */
    function getAvailableReputationIncrease(address author) external view returns (uint256);

    /**
     * @notice Check if a user can receive more reputation (not at max)
     * @param author Address to check
     * @return bool True if user can receive more reputation
     */
    function canReceiveReputation(address author) external view returns (bool);

    /**
     * @notice Get reputation statistics for multiple addresses
     * @param authors Array of addresses to query
     * @return reputations Array of reputation scores
     * @return initializedStatus Array of initialization statuses
     */
    function getBatchReputation(address[] calldata authors) 
        external 
        view 
        returns (uint256[] memory reputations, bool[] memory initializedStatus);

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Force initialize reputation for multiple users (admin only)
     * @dev Useful for bulk initialization during migrations
     * @param authors Array of addresses to initialize
     */
    function batchInitializeReputation(address[] calldata authors) external;
}