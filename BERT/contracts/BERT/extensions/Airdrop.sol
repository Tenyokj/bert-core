// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../DAO/GovernanceTokenUpgradeable.sol";

/**
 * @title Airdrop
 * @notice Distributes a fixed amount of GovernanceToken to the first N users
 * @dev Only allows minting to the first `maxUsers`. Tracks claimed addresses to prevent double claiming.
 */
contract Airdrop {
    /// @notice Governance token to be airdropped
    GovernanceTokenUpgradeable public immutable token;

    /// @notice Amount of tokens each eligible user receives
    uint256 public immutable amountPerUser;

    /// @notice Maximum number of users eligible for the airdrop
    uint256 public immutable maxUsers;

    /// @notice Counter for how many users have claimed
    uint256 public claimedCount;

    /// @notice Tracks which addresses have already claimed the airdrop
    mapping(address => bool) public hasClaimed;

    /// @notice Emitted when a user successfully claims airdrop
    event TokensAirdropped(address indexed user, uint256 amount);

    /**
     * @notice Constructor sets the token, amount per user, and maximum eligible users
     * @param _token Address of the GovernanceToken contract
     * @param _amountPerUser Amount of tokens to mint per user
     * @param _maxUsers Maximum number of users that can claim
     */
    constructor(
        address _token,
        uint256 _amountPerUser,
        uint256 _maxUsers
    ) {
        require(_token != address(0), "Token cannot be zero address");
        require(_amountPerUser > 0, "Amount per user must be > 0");
        require(_maxUsers > 0, "Max users must be > 0");

        token = GovernanceTokenUpgradeable(_token);
        amountPerUser = _amountPerUser;
        maxUsers = _maxUsers;
    }

    /**
     * @notice Claim airdrop tokens if user is among the first `maxUsers`
     * @dev Mints tokens directly to the caller. Can only be claimed once per address.
     */
    function claim() external {
        require(!hasClaimed[msg.sender], "Already claimed");
        require(claimedCount < maxUsers, "Airdrop limit reached");

        hasClaimed[msg.sender] = true;
        claimedCount++;

        // Mint tokens to the user
        token.mint(msg.sender, amountPerUser);

        emit TokensAirdropped(msg.sender, amountPerUser);
    }

    /**
     * @notice Returns whether a given address is eligible to claim the airdrop
     * @param user Address to check
     * @return eligible True if the address can claim
     */
    function canClaim(address user) external view returns (bool eligible) {
        if (hasClaimed[user]) return false;
        if (claimedCount >= maxUsers) return false;
        return true;
    }
}
