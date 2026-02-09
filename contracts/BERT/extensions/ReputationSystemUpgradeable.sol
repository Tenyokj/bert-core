// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IReputationSystem } from "../interfaces/IReputationSystem.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import "../utils/Errors.sol";

/**
 * @title ReputationSystem
 * @notice Manages user reputation scores within the DAO ecosystem
 * @dev Handles reputation initialization, increases for wins, and decreases for losses
 * @dev Upgradeable
 * 
 * @custom:version 1.0.0
 */
contract ReputationSystemUpgradeable is RolesAwareUpgradeable, IReputationSystem {

    /* ========== CONSTANTS ========== */

    /// @notice Maximum reputation score a user can achieve
    uint256 public constant MAX_REPUTATION = 20_000;

    /// @notice Starting reputation score for new users
    uint256 public constant START_REPUTATION = 10_000;

    /// @notice Reputation points awarded per winning vote
    uint256 public constant REPUTATION_UPDATING_VALUE = 500;

    /// @notice Maximum number of addresses for batch operations
    uint256 private constant MAX_BATCH_SIZE = 100;

    /* ========== STORAGE ========== */

    /// @dev Mapping from user address to their current reputation score
    mapping(address => uint256) private _reputation;

    /// @dev Mapping from user address to initialization status
    mapping(address => bool) private _initialized;

    /* ========== INITIALIZE =========== */
    
    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the ReputationSystem contract
     * @param _rolesRegistry Address of the RolesRegistry contract
     */
    function initialize(address _rolesRegistry) public initializer {
        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");
        __RolesAware_init(_rolesRegistry);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Initialize reputation for a new author
     * @dev Called once when a user first participates in the system
     * @param author Address of the author to initialize reputation for
     * @custom:emits ReputationInitialized
     * @custom:requires Caller must have REPUTATION_MANAGER_ROLE
     * @custom:requires author cannot be zero address
     * @custom:requires author must not already be initialized
     */
    function initializeReputation(address author)
        external
        onlyReputationManager
    {
        if (author == address(0)) {
            revert ZeroAddress("author");
        }

        if (_initialized[author]) {
            revert AlreadyInitialized();
        }

        _initialized[author] = true;
        _reputation[author] = START_REPUTATION;

        emit ReputationInitialized(author);
    }

    /**
     * @notice Increase reputation after winning a voting round
     * @dev Caps reputation at MAX_REPUTATION
     * @param author Address of the author whose reputation should increase
     * @custom:emits ReputationIncreased
     * @custom:requires Caller must have REPUTATION_MANAGER_ROLE
     * @custom:requires author must be initialized
     */
    function increaseReputation(address author)
        external
        onlyReputationManager
    {
        if (!_initialized[author]) {
            revert NotInitialized(author);
        }

        uint256 currentReputation = _reputation[author];
        uint256 newReputation = currentReputation + REPUTATION_UPDATING_VALUE;

        if (newReputation > MAX_REPUTATION) {
            newReputation = MAX_REPUTATION;
        }

        _reputation[author] = newReputation;
        emit ReputationIncreased(author, newReputation);
    }

    /**
     * @notice Decrease reputation (e.g., for losing a voting round)
     * @dev Prevents reputation from going below zero
     * @param author Address of the author whose reputation should decrease
     * @custom:emits ReputationDecreased
     * @custom:requires Caller must have VOTING_ROLE
     * @custom:requires author must be initialized
     */
    function decreaseReputation(address author) 
        external 
        onlyReputationManager
    {
        if (!_initialized[author]) {
            revert NotInitialized(author);
        }

        uint256 currentReputation = _reputation[author];
        uint256 newReputation;

        if (currentReputation <= REPUTATION_UPDATING_VALUE) {
            newReputation = 0;
            _reputation[author] = 0;
            emit ReputationDecreased(author, 0, currentReputation);
            return;
        }

        newReputation = currentReputation - REPUTATION_UPDATING_VALUE;
        _reputation[author] = newReputation;
        emit ReputationDecreased(author, newReputation, REPUTATION_UPDATING_VALUE);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Get the current reputation score for an address
     * @dev Returns START_REPUTATION for uninitialized users
     * @param author Address to query reputation for
     * @return uint256 Current reputation score
     */
    function getReputation(address author)
        external
        view
        returns (uint256)
    {
        if (!_initialized[author]) {
            return START_REPUTATION;
        }
        return _reputation[author];
    }

    /**
     * @notice Check if a user's reputation has been initialized
     * @param author Address to check
     * @return bool True if reputation has been initialized
     * @custom:requires author cannot be zero address
     */
    function isInitialized(address author) 
        external
        view 
        returns (bool)
    {
        if (author == address(0)) {
            revert ZeroAddress("author");
        }
        return _initialized[author];
    }

    /**
     * @notice Get the maximum allowed reputation increase for a user
     * @dev Calculates how much reputation can be added before hitting MAX_REPUTATION
     * @param author Address to check
     * @return uint256 Available reputation increase capacity (0 if at max)
     */
    function getAvailableReputationIncrease(address author) 
        external 
        view 
        returns (uint256) 
    {
        if (!_initialized[author]) {
            return MAX_REPUTATION - START_REPUTATION;
        }

        uint256 currentReputation = _reputation[author];
        if (currentReputation >= MAX_REPUTATION) {
            return 0;
        }

        return MAX_REPUTATION - currentReputation;
    }

    /**
     * @notice Check if a user can receive more reputation (not at max)
     * @param author Address to check
     * @return bool True if user can receive more reputation
     */
    function canReceiveReputation(address author) 
        external 
        view 
        returns (bool) 
    {
        if (!_initialized[author]) {
            return true;
        }
        return _reputation[author] < MAX_REPUTATION;
    }

    /**
     * @notice Get reputation statistics for multiple addresses
     * @param authors Array of addresses to query
     * @return reputations Array of reputation scores
     * @return initializedStatus Array of initialization statuses
     */
    function getBatchReputation(address[] calldata authors)
        external
        view
        returns (uint256[] memory reputations, bool[] memory initializedStatus)
    {
        if (authors.length > MAX_BATCH_SIZE) {
            revert BatchSizeExceeded(authors.length, MAX_BATCH_SIZE);
        }

        reputations = new uint256[](authors.length);
        initializedStatus = new bool[](authors.length);

        for (uint256 i = 0; i < authors.length; i++) {
            address author = authors[i];
            if (author == address(0)) {
                revert BatchContainsZeroAddress(i);
            }
            initializedStatus[i] = _initialized[author];
            reputations[i] = _initialized[author] ? _reputation[author] : START_REPUTATION;
        }
    }

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Force initialize reputation for multiple users (admin only)
     * @param authors Array of addresses to initialize
     * @custom:emits ReputationInitialized for each new initialization
     * @custom:requires Caller must have DEFAULT_ADMIN_ROLE
     */
    function batchInitializeReputation(address[] calldata authors) 
        external 
        onlyAdmin
    {
        if (authors.length > MAX_BATCH_SIZE) {
            revert BatchSizeExceeded(authors.length, MAX_BATCH_SIZE);
        }

        for (uint256 i = 0; i < authors.length; i++) {
            address author = authors[i];
            if (author == address(0)) {
                revert BatchContainsZeroAddress(i);
            }

            if (!_initialized[author]) {
                _initialized[author] = true;
                _reputation[author] = START_REPUTATION;
                emit ReputationInitialized(author);
            }
        }
    }

    /* ========== EMERGENCY FUNCTIONS ========== */

    /**
     * @notice Emergency function to set reputation directly (admin only)
     * @dev Only for extreme cases like recovery from bugs
     * @param author Address to update
     * @param newReputation New reputation value (0 to MAX_REPUTATION)
     */
    function setReputation(address author, uint256 newReputation) 
        external 
        onlyAdmin
    {
        if (author == address(0)) {
            revert ZeroAddress("author");
        }

        if (newReputation > MAX_REPUTATION) {
            revert ReputationOverflow(
                author, 
                _initialized[author] ? _reputation[author] : START_REPUTATION, 
                newReputation, 
                MAX_REPUTATION
            );
        }

        if (!_initialized[author]) {
            _initialized[author] = true;
        }

        uint256 oldReputation = _reputation[author];
        _reputation[author] = newReputation;

        emit ReputationSet(author, oldReputation, newReputation);
    }

    /**
     * @notice Emergency function to deinitialize reputation (admin only)
     * @dev Only for extreme cases like account recovery
     * @param author Address to deinitialize
     */
    function deinitializeReputation(address author) 
        external 
        onlyAdmin
    {
        if (author == address(0)) {
            revert ZeroAddress("author");
        }

        if (!_initialized[author]) {
            revert NotInitialized(author);
        }

        _initialized[author] = false;
        delete _reputation[author];

        emit ReputationDeinitialized(author);
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
