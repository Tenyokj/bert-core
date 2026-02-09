// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IGrantManager } from "../interfaces/IGrantManager.sol";
import { IFundingPool } from "../interfaces/IFundingPool.sol";
import { IIdeaRegistry } from "../interfaces/IIdeaRegistry.sol";
import { IVotingSystem } from "../interfaces/IVotingSystem.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import "../utils/IdeaStatus.sol";
import "../utils/Errors.sol";

/**
 * @title GrantManager
 * @notice Central coordinator for grant rounds, voting, and fund distribution
 * @dev Orchestrates the complete DAO grant lifecycle from creation to funding
 * @dev Pausable, Upgradeable
 * 
 * @custom:version 1.0.0
 */
contract GrantManagerUpgradeable is 
    Initializable, 
    ReentrancyGuardUpgradeable, 
    PausableUpgradeable, 
    RolesAwareUpgradeable, 
    IGrantManager 
{
    /* ========== CONTRACTS ========== */

    /// @notice VotingSystem contract interface
    IVotingSystem public votingSystem;
    
    /// @notice FundingPool contract interface
    IFundingPool public fundingPool;
    
    /// @notice IdeaRegistry contract interface
    IIdeaRegistry public ideaRegistry;

    /* ========== STATE VARIABLES ========== */
    
    /** @notice The author's share of their grant in basis points 
     *@dev Default is 95% 
     */
    uint256 public authorSharePercent; // 95%

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the GrantManager contract
     * @dev Sets up the initial contract addresses for the DAO ecosystem
     * @param _votingSystem Address of the VotingSystem contract
     * @param _fundingPool Address of the FundingPool contract
     * @param _ideaRegistry Address of the IdeaRegistry contract
     * @param _rolesRegistry Address of the RolesRegistry contract
     * @custom:emits GrantManagerInitialized
     * @custom:requires All addresses must be non-zero
     */
   function initialize(
        address _votingSystem,
        address _fundingPool,
        address _ideaRegistry,
        address _rolesRegistry
    ) public initializer  {
        __ReentrancyGuard_init();
        __Pausable_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");

        __RolesAware_init(_rolesRegistry);

        if (_votingSystem == address(0)) revert ZeroAddress("votingSystem");
        if (_fundingPool == address(0)) revert ZeroAddress("fundingPool");
        if (_ideaRegistry == address(0)) revert ZeroAddress("ideaRegistry");

        votingSystem = IVotingSystem(_votingSystem);
        fundingPool = IFundingPool(_fundingPool);
        ideaRegistry = IIdeaRegistry(_ideaRegistry);
        authorSharePercent = 95; // 95%
        
        _pause();
        
        emit GrantManagerInitialized(msg.sender);
    }

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Claims author grant for a winning idea
     * @dev Distributes funds to the author of the winning idea and updates idea status to Funded
     * @param roundId The ID of the funding round
     * @custom:emits RoundFunded
     * @custom:requires Round must not already have funds distributed
     * @custom:requires Round must be ended
     * @custom:requires Round must have a valid winner (winningIdeaId > 0)
     * @custom:requires Winning idea must be in WonVoting status
     * @custom:requires Winning idea author must be valid (non-zero address)
     * @custom:requires Caller must be the author of the winning idea
     */
    function claimGrant(uint256 roundId) external nonReentrant whenNotPaused {
        // Check if funds have already been distributed for this round
        if (fundingPool.isDistributed(roundId)) {
            revert AlreadyDistributed(roundId);
        }

        // Get the information about this round
        (, , , , , bool ended , , , ) = votingSystem.getRoundInfo(roundId);
        if (!ended) {
            revert RoundNotEnded(roundId);
        }

        // Get the winning idea for this round
        (uint256 winningIdeaId, ) = votingSystem.getRoundWinner(roundId);
        if (winningIdeaId == 0) {
            revert NoWinner(roundId);
        }

        // Verify the idea is in the correct status
        IdeaStatus currentStatus = ideaRegistry.getStatus(winningIdeaId);
        if (currentStatus != IdeaStatus.WonVoting) {
            revert IdeaNotEligible(
                winningIdeaId,
                uint8(IdeaStatus.WonVoting),
                uint8(currentStatus)
            );
        }

        // Get and verify the author
        address author = ideaRegistry.getIdeaAuthor(winningIdeaId);
        if (author == address(0)) {
            revert InvalidAuthor();
        }
        if (msg.sender != author) {
            revert NotAuthor(msg.sender, author);
        }

        // Calculate distribution amounts
        uint256 totalIdeaStake = fundingPool.poolByRoundAndIdea(roundId, winningIdeaId);
        if (totalIdeaStake == 0) {
            revert NoFundsAllocated(roundId, winningIdeaId);
        }
        uint256 authorAmount = (totalIdeaStake * authorSharePercent) / 100;
        
        // Update idea status to Funded (status 3)
        ideaRegistry.updateStatus(winningIdeaId, IdeaStatus.Funded);

        try fundingPool.distributeFunds(roundId, winningIdeaId, authorAmount) {
            // Success - emit event
            emit RoundFunded(roundId, winningIdeaId, authorAmount);
        } catch {
            revert ExternalCallFailed("FundingPool", "distributeFunds");
        }
    }

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Calculates the distribution amounts for a given round and idea
     * @dev Helper function to preview distribution without executing it
     * @param roundId The ID of the funding round
     * @param ideaId The ID of the idea (should be the winning idea)
     * @return authorAmount Amount that would go to the author
     * @return protocolAmount Amount that would be kept by the protocol
     * @return totalAmount Total amount available for the idea in this round
     */
    function calculateDistribution(uint256 roundId, uint256 ideaId) 
        external 
        view 
        returns (
            uint256 authorAmount,
            uint256 protocolAmount,
            uint256 totalAmount
        ) 
    {
        totalAmount = fundingPool.poolByRoundAndIdea(roundId, ideaId);
        authorAmount = (totalAmount * authorSharePercent) / 100;
        protocolAmount = totalAmount - authorAmount;
    }

    /**
     * @notice Checks if a grant can be claimed for a specific round
     * @dev Validates all conditions required for grant claiming
     * @param roundId The ID of the funding round
     * @return canClaim True if grant can be claimed
     * @return reason Human-readable reason if cannot claim
     */
    function canClaimGrant(uint256 roundId) 
        external 
        view 
        returns (
            bool canClaim, 
            string memory reason
        ) 
    {
        if (fundingPool.isDistributed(roundId)) {
            return (false, "Grant already distributed");
        }

        (, , , , , bool ended , , , ) = votingSystem.getRoundInfo(roundId);
        if (!ended) {
            return (false, "Round not ended");
        }

        (uint256 winningIdeaId, ) = votingSystem.getRoundWinner(roundId);
        if (winningIdeaId == 0) {
            return (false, "No winner for this round");
        }

        if (ideaRegistry.getStatus(winningIdeaId) != IdeaStatus.WonVoting) {
            return (false, "Idea not in WonVoting status");
        }

        address author = ideaRegistry.getIdeaAuthor(winningIdeaId);
        if (author == address(0)) {
            return (false, "Invalid author address");
        }

        uint256 totalStake = fundingPool.poolByRoundAndIdea(roundId, winningIdeaId);
        if (totalStake == 0) {
            return (false, "No funds allocated to this idea");
        }

        return (true, "Grant can be claimed");
    }

    /**
     * @notice Gets the winning idea and author for a specific round
     * @param roundId The ID of the funding round
     * @return winningIdeaId The ID of the winning idea
     * @return author The address of the winning idea's author
     * @return ideaStatus The current status of the winning idea
     */
    function getRoundInfo(uint256 roundId) 
        external 
        view 
        returns (
            uint256 winningIdeaId,
            address author,
            IdeaStatus ideaStatus
        ) 
    {
        (winningIdeaId, ) = votingSystem.getRoundWinner(roundId);
        if (winningIdeaId != 0) {
            author = ideaRegistry.getIdeaAuthor(winningIdeaId);
            ideaStatus = ideaRegistry.getStatus(winningIdeaId);
        }
    }

    /**
     * @notice Gets the current protocol fee share
     * @dev Protocol share is calculated as 100% - authorSharePercent
     * @return uint256 Protocol share in basis points
     */
    function getProtocolShare() external view returns (uint256) {
        return 100 - authorSharePercent;
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
     * @notice Updates the voting system contract address
     * @dev Can only be called by the contract admin
     * @param _newVoting New VotingSystem contract address
     * @custom:emits VotingSystemUpdated
     * @custom:requires Only admin can call
     * @custom:requires _newVoting cannot be zero address
     */
    function setVotingSystem(address _newVoting) external onlyAdmin {
        if (_newVoting == address(0)) {
            revert ZeroAddress("newVoting");
        }
        votingSystem = IVotingSystem(_newVoting);
        emit VotingSystemUpdated(_newVoting);
    }

    /**
     * @notice Updates the author's share percentage
     * @dev Can only be called by the contract admin. Share is in basis points (95 = 95%)
     * @param newSharePercent New author share in basis points (must be ≤ 100)
     * @custom:emits FeeUpdated
     * @custom:requires Only admin can call
     * @custom:requires newShareBps must be ≤ 100
     */
    function setAuthorShare(uint256 newSharePercent) external onlyAdmin {
        if (newSharePercent > 100) {
            revert InvalidShare(newSharePercent, 100);
        }
        authorSharePercent = newSharePercent;
        emit FeeUpdated(authorSharePercent, 100 - authorSharePercent);
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
