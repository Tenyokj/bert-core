// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { RolesAwareUpgradeable } from "../BERT/extensions/Roles/RolesAwareUpgradeable.sol";
import { IReputationSystem } from "../BERT/interfaces/IReputationSystem.sol";
import { IVoterProgression } from "../BERT/interfaces/IVoterProgression.sol";
import "../BERT/utils/IdeaStatus.sol";
import "../BERT/utils/Errors.sol";

/**
 * @title IdeaRegistryUpgradeableV1
 * @notice Test-only legacy implementation used to validate upgrade storage compatibility.
 * @dev Mirrors the pre-v1.1 storage layout where `_ideaIdCounter` and the idea mappings
 *      were declared before any funding-pool or author-stake fields existed.
 */
contract IdeaRegistryUpgradeableV1 is
    Initializable,
    ReentrancyGuardUpgradeable,
    RolesAwareUpgradeable
{
    IReputationSystem public reputationSystem;
    IVoterProgression public voterProgression;
    uint256 private _ideaIdCounter;

    struct Idea {
        uint256 id;
        address author;
        string title;
        string description;
        string link;
        uint256 createdAt;
        uint256 totalVotes;
        bool isLowQuality;
        IdeaStatus status;
    }

    struct Review {
        address reviewer;
        string comment;
    }

    mapping(uint256 => Idea) public ideas;
    mapping(uint256 => Review[]) public ideaReviews;
    mapping(address => uint256[]) public authorIdeas;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        address _reputationSystem,
        address _voterProgression,
        address _rolesRegistry
    ) public initializer {
        __ReentrancyGuard_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");
        __RolesAware_init(_rolesRegistry);

        if (_reputationSystem == address(0)) revert ZeroAddress("reputationSystem");
        if (_voterProgression == address(0)) revert ZeroAddress("voterProgression");

        reputationSystem = IReputationSystem(_reputationSystem);
        voterProgression = IVoterProgression(_voterProgression);
        _ideaIdCounter = 1;
    }

    function createIdea(
        string memory _title,
        string memory _description,
        string memory _link
    ) external nonReentrant {
        if (bytes(_title).length == 0) revert ZeroLength("title");
        if (bytes(_description).length == 0) revert ZeroLength("description");

        if (!reputationSystem.isInitialized(msg.sender)) {
            reputationSystem.initializeReputation(msg.sender);
        }

        uint256 newId = _ideaIdCounter;

        ideas[newId] = Idea({
            id: newId,
            author: msg.sender,
            title: _title,
            description: _description,
            link: _link,
            createdAt: block.timestamp,
            totalVotes: 0,
            isLowQuality: false,
            status: IdeaStatus.Pending
        });

        authorIdeas[msg.sender].push(newId);
        _ideaIdCounter++;
    }

    function totalIdeas() external view returns (uint256) {
        return _ideaIdCounter - 1;
    }

    function getIdeaAuthor(uint256 ideaId) external view returns (address) {
        if (ideaId == 0 || ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(ideaId);
        }
        return ideas[ideaId].author;
    }

    function getIdea(uint256 _ideaId) external view returns (Idea memory) {
        if (_ideaId == 0 || _ideaId >= _ideaIdCounter) {
            revert IdeaDoesNotExist(_ideaId);
        }
        return ideas[_ideaId];
    }

    uint256[50] private __gap;
}
