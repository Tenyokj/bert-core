// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import "../utils/IdeaStatus.sol";

/**
 * @title IGrantManager
 * @notice Interface for GrantManager contract - central coordinator for grant rounds, voting, and fund distribution
 * @dev Orchestrates the complete DAO grant lifecycle from creation to funding
 */
interface IGrantManager {
    /* ========== EVENTS ========== */

    /**
     * @notice Emmited when contract was initialized
     * @param sender Address who initialized the contract
     */
    event GrantManagerInitialized(address sender);
    
    /**
     * @notice Emitted when funds are distributed for a round
     * @param roundId Round identifier
     * @param ideaId Winning idea ID
     * @param amount Amount distributed to the author
     */
    event RoundFunded(uint256 indexed roundId, uint256 indexed ideaId, uint256 amount);
    
    /**
     * @notice Emitted when VotingSystem address is updated
     * @param newVotingSystem New VotingSystem contract address
     */
    event VotingSystemUpdated(address newVotingSystem);
    
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
     * @notice Emitted when author share percentage is updated
     * @param authorSharePercent New author share in basis points
     * @param protocolSharePercent New protocol share in basis points (100 - authorSharePercent)
     */
    event FeeUpdated(uint256 authorSharePercent, uint256 protocolSharePercent);

    /* ========== EXTERNAL FUNCTIONS ========== */

    /**
     * @notice Claims author grant for a winning idea
     * @dev Distributes funds to the author of the winning idea and updates idea status to Funded
     * @param roundId The ID of the funding round
     */
    function claimGrant(uint256 roundId) external;

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
        );

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
        );

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
        );

    /**
     * @notice Gets the current protocol fee share
     * @dev Protocol share is calculated as 100% - authorSharePercent
     * @return uint256 Protocol share in basis points
     */
    function getProtocolShare() external view returns (uint256);

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
     * @notice Updates the voting system contract address
     * @dev Can only be called by the contract owner
     * @param _newVoting New VotingSystem contract address
     */
    function setVotingSystem(address _newVoting) external;

    /**
     * @notice Updates the author's share percentage
     * @dev Can only be called by the contract owner. Share is in basis points (95 = 95%)
     * @param newShareBps New author share in basis points (must be ≤ 100)
     */
    function setAuthorShare(uint256 newShareBps) external;
}
