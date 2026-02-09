// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../BERT/DAO/VotingSystemUpgradeable.sol";

/**
 * @title MockVotingSystemV2
 * @notice V2 mock for upgradeability tests
 */
contract MockVotingSystemV2 is VotingSystemUpgradeable {
    uint256 public v2Value;

    function setV2Value(uint256 value) external onlyAdmin {
        v2Value = value;
    }

    function version() external pure returns (uint256) {
        return 2;
    }
}
