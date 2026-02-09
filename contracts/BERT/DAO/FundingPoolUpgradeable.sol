// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import { IFundingPool } from "../interfaces/IFundingPool.sol";
import { IIdeaRegistry } from "../interfaces/IIdeaRegistry.sol";
import "../utils/Errors.sol";

/**
 * @title FundingPool
 * @notice Manages token deposits and distributes grants to winning ideas
 * @dev Handles donor balances, fund safekeeping, and controlled distribution
 * @dev Pausable, Upgradeable
 * 
 * @custom:version 1.0.0
 */
contract FundingPoolUpgradeable is 
    Initializable, 
    ReentrancyGuardUpgradeable, 
    PausableUpgradeable, 
    RolesAwareUpgradeable, 
    IFundingPool 
{
    using SafeERC20 for IERC20;

    /* ========== CONTRACTS ========== */ 

    /// @notice Governance token contract
    IERC20 public governanceToken;
    
    /// @notice IdeaRegistry contract address for author verification
    IIdeaRegistry public ideaRegistry;

    /* ========== STATE VARIABLES ========== */

    /// @notice Total tokens held in the pool
    uint256 public totalPoolBalance;
    
    /// @notice Protocol reserve retained after distributions
    uint256 public protocolReserve;

    /* ========== STRUCTS ========== */

    /**
     * @notice Structure representing a fund distribution record
     * @param roundId Identifier of the funding round
     * @param ideaId Identifier of the winning idea
     * @param amount Amount of tokens distributed
     * @param distributedAt Timestamp when distribution occurred
     */
    struct Distribution {
        uint256 roundId;
        uint256 ideaId;
        uint256 amount;
        uint256 distributedAt;
    }

    /* ========== STORAGE ========== */

    /// @notice Mapping from donor address to their deposited amount
    mapping(address => uint256) public donorBalances;

    /// @notice Mapping of pool history for Round & ideas: roundId => ideaId => amount
    mapping(uint256 => mapping(uint256 => uint256)) public _poolByRoundAndIdea;

    /// @dev Array of all historical distributions
    Distribution[] public distributionHistory;
    
    /// @dev Mapping from round ID to distribution status
    mapping(uint256 => bool) public distributed;

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the FundingPool contract
     * @param _governanceToken Governance token contract address
     * @param _ideaRegistry IdeaRegistry contract address
     * @custom:emits FundingPoolInitialized
     * @custom:requires All addresses must be non-zero
     */
    function initialize(
        address _governanceToken,
        address _ideaRegistry,
        address _rolesRegistry
    ) public initializer {
        __ReentrancyGuard_init();
        __Pausable_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");

        __RolesAware_init(_rolesRegistry);
        
        if (_governanceToken == address(0)) revert ZeroAddress("governanceToken");
        if (_ideaRegistry == address(0)) revert ZeroAddress("ideaRegistry");

        governanceToken = IERC20(_governanceToken);
        ideaRegistry = IIdeaRegistry(_ideaRegistry);
        
        _pause();
        
        emit FundingPoolInitialized(msg.sender);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Deposits governance tokens into the funding pool
     * @dev Transfers tokens from caller to contract, updates donor balance
     * @param amount Amount of tokens to deposit
     * @custom:emits FundsDeposited
     * @custom:emits PoolBalanceUpdated
     * @custom:requires amount > 0
     * @custom:reentrancy protected
     */
    function deposit(uint256 amount) external nonReentrant whenNotPaused {
        if (amount == 0) {
            revert ZeroAmount();
        }
        
        governanceToken.safeTransferFrom(msg.sender, address(this), amount);

        donorBalances[msg.sender] += amount;
        totalPoolBalance += amount;

        emit FundsDeposited(msg.sender, amount);
        emit PoolBalanceUpdated(totalPoolBalance);
    }

    /**
     * @notice Deposits tokens from a specified address for a specific idea in a round
     * @dev Can only be called by addresses with VOTING_ROLE, transfers tokens on behalf of another address
     * @param from Address from which tokens are transferred
     * @param roundId ID of the funding round
     * @param ideaId ID of the idea receiving the deposit
     * @param amount Amount of tokens to deposit
     * @custom:emits FundsDeposited
     * @custom:emits PoolBalanceUpdated
     * @custom:requires from != address(0)
     * @custom:requires amount > 0
     * @custom:requires ideaId > 0
     * @custom:reentrancy protected
     */
    function depositForIdeaFrom(address from, uint256 roundId, uint256 ideaId, uint256 amount) 
        external 
        onlyVotingSystem 
        nonReentrant
        whenNotPaused 
    {
        if (from == address(0)) {
            revert ZeroAddress("from");
        }
        if (amount == 0) {
            revert ZeroAmount();
        }
        if (ideaId == 0) {
            revert InvalidId("ideaId");
        }
        
        governanceToken.safeTransferFrom(from, address(this), amount);
        
        totalPoolBalance += amount;
        _poolByRoundAndIdea[roundId][ideaId] += amount;

        emit FundsDeposited(from, amount);
        emit PoolBalanceUpdated(totalPoolBalance);
    }

    /**
     * @notice Distributes funds to a winning idea (only distributor role can call)
     * @dev Transfers tokens to idea author, records distribution
     * @param roundId Grant round identifier
     * @param ideaId Winning idea identifier
     * @param amount Amount to distribute
     * @custom:emits FundsDistributed
     * @custom:emits PoolBalanceUpdated
     * @custom:requires Only addresses with GRANT_ROLE can call
     * @custom:requires round not previously distributed
     * @custom:requires amount > 0 and ≤ pool balance for that idea in the round
     * @custom:reentrancy protected
     */
    function distributeFunds(
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external 
      onlyDistributor
      nonReentrant 
      whenNotPaused 
    {
        if (distributed[roundId]) {
            revert AlreadyDistributed(roundId);
        }
        if (amount == 0) {
            revert ZeroAmount();
        }
        
        address author = ideaRegistry.getIdeaAuthor(ideaId);
        if (author == address(0)) {
            revert InvalidAuthor();
        }

        uint256 available = _poolByRoundAndIdea[roundId][ideaId];
        if (amount > available) {
            revert InsufficientIdeaBalance(roundId, ideaId, available, amount);
        }

        uint256 remaining = available - amount;
        _poolByRoundAndIdea[roundId][ideaId] = 0;
        if (remaining > 0) {
            protocolReserve += remaining;
        }
        totalPoolBalance -= amount;
        distributed[roundId] = true;
        
        distributionHistory.push(Distribution({
            roundId: roundId,
            ideaId: ideaId,
            amount: amount,
            distributedAt: block.timestamp
        }));

        governanceToken.safeTransfer(author, amount);

        emit FundsDistributed(roundId, ideaId, amount);
        emit PoolBalanceUpdated(totalPoolBalance);
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Returns the total number of distributions made
     * @return count Number of distribution records
     */
    function getDistributionCount() external view returns (uint256) {
        return distributionHistory.length;
    }

    /**
     * @notice Returns distribution details by index
     * @param index Position in distributionHistory array
     * @return roundId Grant round identifier
     * @return ideaId Winning idea identifier
     * @return amount Distributed amount
     * @return distributedAt Distribution timestamp
     * @custom:requires index must be within bounds
     */
    function getDistribution(uint256 index) external view returns (
        uint256 roundId,
        uint256 ideaId,
        uint256 amount,
        uint256 distributedAt
    ) {
        if (index >= distributionHistory.length) {
            revert IndexOutOfBounds();
        }
        Distribution memory d = distributionHistory[index];
        return (d.roundId, d.ideaId, d.amount, d.distributedAt);
    }

    /**
     * @notice Checks if funds have been distributed for a specific round
     * @param roundId The ID of the round to check
     * @return bool True if funds have been distributed for this round, false otherwise
     * @custom:requires roundId > 0
     */
    function isDistributed(uint256 roundId) external view returns (bool) {
        if (roundId == 0) {
            revert InvalidId("roundId");
        }
        return distributed[roundId];
    }

    /**
     * @notice Gets the pool balance for a specific idea in a specific round
     * @param roundId The ID of the round
     * @param ideaId The ID of the idea
     * @return uint256 The amount of tokens allocated to this idea in this round
     * @custom:requires roundId > 0
     * @custom:requires ideaId > 0
     */
    function poolByRoundAndIdea(uint256 roundId, uint256 ideaId) external view returns (uint256) {
        if (roundId == 0) {
            revert InvalidId("roundId");
        }
        if (ideaId == 0) {
            revert InvalidId("ideaId");
        }
        return _poolByRoundAndIdea[roundId][ideaId];
    }

    /* =========== ADMIN FUNCTIONS =========== */
    
    /**
     * @notice Allocates protocol reserve to a specific round/idea
     * @dev Only callable by the admin
     * @param roundId The ID of the round
     * @param ideaId The ID of the idea
     * @param amount Amount of reserve to allocate
     */
    function allocateReserveToIdea(uint256 roundId, uint256 ideaId, uint256 amount) external onlyAdmin {
        if (roundId == 0) {
            revert InvalidId("roundId");
        }
        if (ideaId == 0) {
            revert InvalidId("ideaId");
        }
        if (amount == 0) {
            revert ZeroAmount();
        }
        if (amount > protocolReserve) {
            revert InsufficientPoolBalance(protocolReserve, amount);
        }

        protocolReserve -= amount;
        _poolByRoundAndIdea[roundId][ideaId] += amount;
        emit ProtocolReserveAllocated(roundId, ideaId, amount);
    }
    
    /**
     * @notice Updates the governance token contract address
     * @dev Can only be called by the contract admin
     * @param _newToken New governance token address
     * @custom:emits GovernanceTokenUpdated
     * @custom:requires _newToken cannot be zero address
     */
    function setGovernanceToken(address _newToken) external onlyAdmin {
        if (_newToken == address(0)) {
            revert ZeroAddress("newToken");
        }
        governanceToken = IERC20(_newToken);
        emit GovernanceTokenUpdated(_newToken);
    }

    /**
     * @notice Updates the idea registry contract address
     * @dev Can only be called by the contract admin
     * @param _newRegistry New idea registry address
     * @custom:emits IdeaRegistryUpdated
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
     * @notice Checks real pool balance
     * @dev Can only be called by the contract admin
     */
    function syncBalance() external onlyAdmin {
        uint256 real = governanceToken.balanceOf(address(this));
        totalPoolBalance = real - protocolReserve;
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
