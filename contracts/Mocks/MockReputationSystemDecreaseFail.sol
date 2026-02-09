// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

/**
 * @title MockReputationSystemDecreaseFail
 * @notice increaseReputation succeeds, decreaseReputation reverts
 */
contract MockReputationSystemDecreaseFail {
    function increaseReputation(address) external {
        // no-op
    }

    function decreaseReputation(address) external pure {
        revert("MockReputationSystemDecreaseFail: decrease failed");
    }
}
