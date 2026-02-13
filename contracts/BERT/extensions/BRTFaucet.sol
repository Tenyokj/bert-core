// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.24;

import "../DAO/GovernanceTokenUpgradeable.sol";
import "./Roles/RolesRegistryUpgradeable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title BRTFaucet
 * @notice Provides a recurring token distribution mechanism with cooldown periods and admin controls
 * @dev Users can claim a fixed amount of GovernanceToken every `cooldown` seconds. Admin can pause,
 *      adjust claim amount, and modify cooldown duration. Requires minting permissions on token.
 */
contract BRTFaucet is Pausable {
    /// @notice Governance token distributed by the faucet
    GovernanceTokenUpgradeable public immutable token;

    /// @notice Registry for role-based access control
    RolesRegistryUpgradeable public roles;

    /// @notice Amount of tokens each user receives per claim
    uint256 public claimAmount;

    /// @notice Time in seconds that must pass between claims for a given user
    uint256 public cooldown;

    /// @notice Timestamp of the last claim made by each user
    mapping(address => uint256) public lastClaimAt;

    /// @notice Emitted when a user successfully claims tokens
    event Claimed(address indexed user, uint256 amount, uint256 nextClaimAt);

    /// @notice Emitted when admin updates the claim amount
    event ClaimAmountUpdated(uint256 oldAmount, uint256 newAmount);

    /// @notice Emitted when admin updates the cooldown period
    event CooldownUpdated(uint256 oldCooldown, uint256 newCooldown);

    /**
     * @notice Constructor sets the token, roles registry, initial claim amount and cooldown
     * @param _token Address of the GovernanceToken contract (must allow minting by this contract)
     * @param _rolesRegistry Address of the RolesRegistry contract
     * @param _claimAmount Initial amount of tokens per claim (must be > 0)
     * @param _cooldown Initial cooldown period in seconds (must be > 0)
     */
    constructor(
        address _token,
        address _rolesRegistry,
        uint256 _claimAmount,
        uint256 _cooldown
    ) {
        require(_token != address(0), "Token cannot be zero address");
        require(_rolesRegistry != address(0), "RolesRegistry cannot be zero address");
        require(_claimAmount > 0, "Claim amount must be > 0");
        require(_cooldown > 0, "Cooldown must be > 0");

        token = GovernanceTokenUpgradeable(_token);
        roles = RolesRegistryUpgradeable(_rolesRegistry);
        claimAmount = _claimAmount;
        cooldown = _cooldown;
    }

    /// @dev Ensures caller has DEFAULT_ADMIN_ROLE in RolesRegistry
    modifier onlyAdmin() {
        if (!roles.hasRole(roles.DEFAULT_ADMIN_ROLE(), msg.sender)) revert NotAdmin();
        _;
    }

    /**
     * @notice Claim tokens from the faucet
     * @dev Can only be called when contract is not paused. Respects cooldown per user.
     *      First claim has no cooldown. Mints tokens directly to caller.
     */
    function claim() external whenNotPaused {
        uint256 last = lastClaimAt[msg.sender];
        uint256 next = last + cooldown;
        if(last != 0 && block.timestamp < next) revert ("Cooldown not elapsed!");

        lastClaimAt[msg.sender] = block.timestamp;
        token.mint(msg.sender, claimAmount);

        emit Claimed(msg.sender, claimAmount, block.timestamp + cooldown);
    }

    /**
     * @notice Update the amount of tokens distributed per claim
     * @param newAmount New claim amount (must be > 0)
     * @dev Only callable by admin
     */
    function setClaimAmount(uint256 newAmount) external onlyAdmin {
        require(newAmount > 0, "new Claim amount must be > 0");
        uint256 old = claimAmount;
        claimAmount = newAmount;
        emit ClaimAmountUpdated(old, newAmount);
    }

    /**
     * @notice Update the cooldown period between claims
     * @param newCooldown New cooldown in seconds (must be > 0)
     * @dev Only callable by admin
     */
    function setCooldown(uint256 newCooldown) external onlyAdmin {
        require(newCooldown > 0, "new Cooldown must be > 0");
        uint256 old = cooldown;
        cooldown = newCooldown;
        emit CooldownUpdated(old, newCooldown);
    }

    /**
     * @notice Pause the faucet, preventing claims
     * @dev Only callable by admin
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @notice Unpause the faucet, allowing claims
     * @dev Only callable by admin
     */
    function unpause() external onlyAdmin {
        _unpause();
    }

    /**
     * @notice Check if the faucet is currently paused
     * @return bool True if paused, false otherwise
     */
    function isPaused() external view returns (bool) {
        return paused();
    }

    /**
     * @notice Check if a user is eligible to claim and when they can next claim
     * @param user Address to check
     * @return ok True if user can claim now
     * @return nextClaimAt Timestamp when user can next claim (0 if never claimed or faucet paused)
     * @dev Returns (false, 0) if faucet is paused
     */
    function canClaim(address user) external view returns (bool ok, uint256 nextClaimAt) {
        if (paused()) return (false, 0);
        uint256 last = lastClaimAt[user];
        if (last == 0) return (true, 0);

        nextClaimAt = last + cooldown;
        ok = block.timestamp >= nextClaimAt;
    }
}
