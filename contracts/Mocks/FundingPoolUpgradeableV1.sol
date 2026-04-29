// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { RolesAwareUpgradeable } from "../BERT/extensions/Roles/RolesAwareUpgradeable.sol";
import { IIdeaRegistry } from "../BERT/interfaces/IIdeaRegistry.sol";
import "../BERT/utils/Errors.sol";

/**
 * @title FundingPoolUpgradeableV1
 * @notice Test-only legacy implementation used to validate upgrade storage compatibility.
 * @dev Mirrors the pre-v1.1 storage layout before `authorStakeByIdea` was introduced.
 */
contract FundingPoolUpgradeableV1 is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    RolesAwareUpgradeable
{
    using SafeERC20 for IERC20;

    IERC20 public governanceToken;
    IIdeaRegistry public ideaRegistry;
    uint256 public totalPoolBalance;
    uint256 public protocolReserve;

    struct Distribution {
        uint256 roundId;
        uint256 ideaId;
        uint256 amount;
        uint256 distributedAt;
    }

    mapping(address => uint256) public donorBalances;
    mapping(uint256 => mapping(uint256 => uint256)) public _poolByRoundAndIdea;
    Distribution[] public distributionHistory;
    mapping(uint256 => bool) public distributed;

    constructor() {
        _disableInitializers();
    }

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
    }

    function deposit(uint256 amount) external nonReentrant whenNotPaused {
        if (amount == 0) revert ZeroAmount();

        governanceToken.safeTransferFrom(msg.sender, address(this), amount);
        donorBalances[msg.sender] += amount;
        totalPoolBalance += amount;
    }

    function depositForIdeaFrom(
        address from,
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external onlyVotingSystem nonReentrant whenNotPaused {
        if (from == address(0)) revert ZeroAddress("from");
        if (amount == 0) revert ZeroAmount();
        if (ideaId == 0) revert InvalidId("ideaId");

        governanceToken.safeTransferFrom(from, address(this), amount);
        totalPoolBalance += amount;
        _poolByRoundAndIdea[roundId][ideaId] += amount;
    }

    function distributeFunds(
        uint256 roundId,
        uint256 ideaId,
        uint256 amount
    ) external onlyDistributor nonReentrant whenNotPaused {
        if (distributed[roundId]) revert AlreadyDistributed(roundId);
        if (amount == 0) revert ZeroAmount();

        address author = ideaRegistry.getIdeaAuthor(ideaId);
        if (author == address(0)) revert InvalidAuthor();

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
    }

    function getDistributionCount() external view returns (uint256) {
        return distributionHistory.length;
    }

    function getDistribution(uint256 index) external view returns (
        uint256 roundId,
        uint256 ideaId,
        uint256 amount,
        uint256 distributedAt
    ) {
        if (index >= distributionHistory.length) revert IndexOutOfBounds();
        Distribution memory d = distributionHistory[index];
        return (d.roundId, d.ideaId, d.amount, d.distributedAt);
    }

    function isDistributed(uint256 roundId) external view returns (bool) {
        if (roundId == 0) revert InvalidId("roundId");
        return distributed[roundId];
    }

    function poolByRoundAndIdea(uint256 roundId, uint256 ideaId) external view returns (uint256) {
        if (roundId == 0) revert InvalidId("roundId");
        if (ideaId == 0) revert InvalidId("ideaId");
        return _poolByRoundAndIdea[roundId][ideaId];
    }

    function setGovernanceToken(address _newToken) external onlyAdmin {
        if (_newToken == address(0)) revert ZeroAddress("newToken");
        governanceToken = IERC20(_newToken);
    }

    function setIdeaRegistry(address _newRegistry) external onlyAdmin {
        if (_newRegistry == address(0)) revert ZeroAddress("newRegistry");
        ideaRegistry = IIdeaRegistry(_newRegistry);
    }

    function syncBalance() external onlyAdmin {
        uint256 real = governanceToken.balanceOf(address(this));
        totalPoolBalance = real - protocolReserve;
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    uint256[50] private __gap;
}
