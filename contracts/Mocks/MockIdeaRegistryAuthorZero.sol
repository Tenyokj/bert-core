// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../BERT/utils/IdeaStatus.sol";

/**
 * @title MockIdeaRegistryAuthorZero
 * @notice Mock that can return a configurable author (including zero)
 */
contract MockIdeaRegistryAuthorZero {
    address public author;
    IdeaStatus public status = IdeaStatus.WonVoting;

    function setAuthor(address newAuthor) external {
        author = newAuthor;
    }

    function setStatus(IdeaStatus newStatus) external {
        status = newStatus;
    }

    function getIdeaAuthor(uint256) external view returns (address) {
        return author;
    }

    function getStatus(uint256) external view returns (IdeaStatus) {
        return status;
    }

    function updateStatus(uint256, IdeaStatus) external {
        // no-op
    }
}
