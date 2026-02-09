// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title IdeaStatus
 * @notice Enumeration representing the lifecycle stages of an idea in the DAO
 * @dev Used across multiple contracts to track idea progression
 */
enum IdeaStatus {
    /**
     * @notice Idea has been created but is not yet in a voting round
     * @dev Initial state after idea creation
     */
    Pending,
    
    /**
     * @notice Idea is currently participating in a voting round
     * @dev Active voting phase
     */
    Voting,
    
    /**
     * @notice Idea has won a voting round but has not yet received funding
     * @dev Transition state between winning votes and receiving funds
     */
    WonVoting,
    
    /**
     * @notice Idea has received funding from the grant pool
     * @dev Funds have been distributed to the idea author
     */
    Funded,
    
    /**
     * @notice Idea was rejected (lost voting or disqualified)
     * @dev Terminal state - idea will not proceed further
     */
    Rejected,
    
    /**
     * @notice Idea has completed its funded project
     * @dev Final terminal state - project delivered
     */
    Completed
}
