// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.18;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IFundingPool
 * @notice Interface for FundingPool contract that manages token deposits and grant distributions
 * @dev Provides external function declarations and event definitions for the funding pool system
 */
interface IFundingPool {
    /* ========== EVENTS ========== */

    /**
     * @notice Emmited when contract was initialized
     * @param sender Address who initialized the contract
     */
    event FundingPoolInitialized(address sender);
    /**
     * @notice Emitted when funds are deposited into the pool
     * @param donor Address of the depositor
     * @param amount Amount of tokens deposited
     */
    event FundsDeposited(address indexed donor, uint256 amount);

    /**
     * @notice Emitted when funds are distributed to a winning idea
     * @param roundId Identifier of the funding round
     * @param ideaId Identifier of the winning idea
     * @param amount Amount of tokens distributed
     */
    event FundsDistributed(uint256 indexed roundId, uint256 indexed ideaId, uint256 amount);

    /**
     * @notice Emitted when the total pool balance is updated
     * @param newBalance New total balance of the pool
     */
    event PoolBalanceUpdated(uint256 newBalance);

    /**
     * @notice Emitted when the governance token address is updated
     * @param newToken Address of the new governance token contract
     */
    event GovernanceTokenUpdated(address indexed newToken);

    /**
     * @notice Emitted when the idea registry address is updated
     * @param newRegistry Address of the new idea registry contract
     */
    event IdeaRegistryUpdated(address indexed newRegistry);
    
    /**
     * @notice Emitted when protocol reserve is allocated to a round/idea
     * @param roundId Identifier of the funding round
     * @param ideaId Identifier of the idea receiving the allocation
     * @param amount Amount allocated from reserve
     */
    event ProtocolReserveAllocated(uint256 indexed roundId, uint256 indexed ideaId, uint256 amount);

    /**
     * @notice Emitted when author stake is deposited for a new idea
     * @param ideaId Identifier of the idea
     * @param author Address that supplied the stake
     * @param amount Amount staked
     */
    event AuthorStakeDeposited(uint256 indexed ideaId, address indexed author, uint256 amount);

    /**
     * @notice Emitted when an author's stake is moved into protocol reserve
     * @param ideaId Identifier of the idea
     * @param amount Amount slashed into reserve
     */
    event AuthorStakeSlashed(uint256 indexed ideaId, uint256 amount);

    /**
     * @notice Emitted when idea-specific round funds are moved into protocol reserve
     * @param roundId Identifier of the funding round
     * @param ideaId Identifier of the idea
     * @param amount Amount moved into reserve
     */
    event IdeaFundsReserved(uint256 indexed roundId, uint256 indexed ideaId, uint256 amount);

    /* ========== DEPOSIT FUNCTIONS ========== */

    /**
     * @notice Deposits governance tokens into the funding pool
     * @dev Transfers tokens from caller to contract, updates donor balance
     * @param amount Amount of tokens to deposit
     */
    function deposit(uint256 amount) external;

    /**
     * @notice Deposits author stake for an idea directly from the author
     * @dev Can only be called by the IdeaRegistry contract
     * @param from Author address that supplies the stake
     * @param ideaId ID of the idea
     * @param amount Amount of tokens to stake
     */
    function depositAuthorStakeFrom(address from, uint256 ideaId, uint256 amount) external;

    /**
     * @notice Deposits tokens from a specified address for a specific idea in a round
     * @dev Can only be called by addresses with VOTING_ROLE
     * @param from Address from which tokens are transferred
     * @param roundId ID of the funding round
     * @param ideaId ID of the idea receiving the deposit
     * @param amount Amount of tokens to deposit
     */
    function depositForIdeaFrom(
        address from,
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external;

    /* ========== DISTRIBUTION FUNCTIONS ========== */

    /**
     * @notice Distributes funds to a winning idea
     * @dev Can only be called by addresses with GRANT_ROLE
     * @param roundId Grant round identifier
     * @param ideaId Winning idea identifier
     * @param amount Amount to distribute
     */
    function distributeFunds(
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external;

    /**
     * @notice Moves part of an idea's allocated round funds into protocol reserve
     * @dev Can only be called by addresses with DISTRIBUTOR_ROLE
     * @param roundId Grant round identifier
     * @param ideaId Winning idea identifier
     * @param amount Amount to move into reserve
     */
    function moveIdeaFundsToReserve(uint256 roundId, uint256 ideaId, uint256 amount) external;

    /**
     * @notice Slashes an author's locked idea stake into protocol reserve
     * @dev Can only be called by the IdeaRegistry contract
     * @param ideaId ID of the rejected idea
     */
    function slashAuthorStakeToReserve(uint256 ideaId) external;

    /* ========== VIEW FUNCTIONS ========== */

    /**
     * @notice Returns the total number of distributions made
     * @return count Number of distribution records
     */
    function getDistributionCount() external view returns (uint256);

    /**
     * @notice Returns distribution details by index
     * @param index Position in distributionHistory array
     * @return roundId Grant round identifier
     * @return ideaId Winning idea identifier
     * @return amount Distributed amount
     * @return distributedAt Distribution timestamp
     */
    function getDistribution(uint256 index) external view returns (
        uint256 roundId,
        uint256 ideaId,
        uint256 amount,
        uint256 distributedAt
    );

    /**
     * @notice Checks if funds have been distributed for a specific round
     * @param roundId Identifier of the round to check
     * @return isDistributed True if funds have been distributed for this round
     */
    function isDistributed(uint256 roundId) external view returns (bool);

    /**
     * @notice Gets the pool balance for a specific idea in a specific round
     * @param roundId The ID of the round
     * @param ideaId The ID of the idea
     * @return uint256 The amount of tokens allocated to this idea in this round
     */
    function poolByRoundAndIdea(uint256 roundId, uint256 ideaId) external view returns (uint256);

    /**
     * @notice Gets the locked author stake for an idea
     * @param ideaId The ID of the idea
     * @return uint256 Locked author stake amount
     */
    function authorStakeByIdea(uint256 ideaId) external view returns (uint256);

    /**
     * @notice Returns the governance token used by the funding pool
     * @return token ERC20 governance token contract
     */
    function governanceToken() external view returns (IERC20 token);

    /* ========== ADMIN FUNCTIONS ========== */

    /**
     * @notice Updates the governance token contract address
     * @dev Can only be called by the contract owner
     * @param _newToken New governance token address
     */
    function setGovernanceToken(address _newToken) external;

    /**
     * @notice Updates the idea registry contract address
     * @dev Can only be called by the contract owner
     * @param _newRegistry New idea registry address
     */
    function setIdeaRegistry(address _newRegistry) external;

    /**
     * @notice Allocates protocol reserve to a specific round/idea
     * @dev Can only be called by the admin
     * @param roundId The ID of the round
     * @param ideaId The ID of the idea
     * @param amount Amount of reserve to allocate
     */
    function allocateReserveToIdea(uint256 roundId, uint256 ideaId, uint256 amount) external;
}
