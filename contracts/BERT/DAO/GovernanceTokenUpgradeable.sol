// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { RolesAwareUpgradeable } from "../extensions/Roles/RolesAwareUpgradeable.sol";
import "../utils/Errors.sol";

/**
 * @title GovernanceToken
 * @notice ERC20 token for DAO governance, mintable, burnable, and pausable
 * @dev Upgradeable version, compatible with OpenZeppelin ERC20 v5
 * 
 * @custom:version 1.0.0
 */
contract GovernanceTokenUpgradeable is 
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    PausableUpgradeable,
    RolesAwareUpgradeable
{
    /* ========== STATE VARIABLES ========== */

    /// @notice Maximum number of tokens that can ever exist
    uint256 public maxSupply;

    /// @notice Mapping of authorized minters: address => permission
    mapping(address => bool) public authorizedMinters;

    /* ========== EVENTS ========== */

    /// @notice Event emitted when a minter is added or removed
    /// @param minter Address of the minter
    /// @param status True if minter is authorized, false if removed
    event MinterUpdated(address indexed minter, bool status);

    /// @notice Event emitted when new tokens are minted
    /// @param to Recipient address
    /// @param amount Amount of tokens minted
    event TokensMinted(address indexed to, uint256 amount);

    /* ========== INITIALIZE ========== */

    constructor() {
        _disableInitializers();
    }

    /**
     * @notice Initializes the GovernanceToken contract
     * @param name Token name
     * @param symbol Token symbol
     * @param _maxSupply Maximum number of tokens allowed
     * @param _initialMinter Optional initial minter address
     * @param _rolesRegistry Address of the RolesRegistry contract
     * @custom:requirements _maxSupply must be greater than zero
     */
    function initialize(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        address _initialMinter,
        address _rolesRegistry
    ) public initializer {
        __ERC20_init(name, symbol);
        __ERC20Burnable_init();
        __Pausable_init();

        if (_rolesRegistry == address(0)) revert ZeroAddress("rolesRegistry");

        __RolesAware_init(_rolesRegistry);

        require(_maxSupply > 0, "Max supply cannot be zero");
        maxSupply = _maxSupply;

        // Set initial minters
        authorizedMinters[msg.sender] = true;
        if (_initialMinter != address(0)) {
            authorizedMinters[_initialMinter] = true;
        }

        emit MinterUpdated(msg.sender, true);
        if (_initialMinter != address(0)) {
            emit MinterUpdated(_initialMinter, true);
        }
    }

    /* ========== MODIFIERS ========== */

    /// @notice Modifier restricting functions to authorized minters only
    modifier onlyMinter() {
        require(authorizedMinters[msg.sender], "Not authorized minter");
        _;
    }

    /* ========== MINT FUNCTIONS ========== */

    /**
     * @notice Mints new tokens to a specified address
     * @param to Recipient address
     * @param amount Number of tokens to mint
     * @dev Only minters can call this function
     * @dev Function will fail if the contract is paused
     * @custom:emits TokensMinted
     * @custom:requires to != 0
     * @custom:requires amount > 0
     * @custom:requires totalSupply + amount <= maxSupply
     */
    function mint(address to, uint256 amount) external onlyMinter whenNotPaused {
        require(to != address(0), "Cannot mint to zero address");
        require(amount > 0, "Cannot mint zero tokens");
        require(totalSupply() + amount <= maxSupply, "Max supply exceeded");

        _mint(to, amount);
        emit TokensMinted(to, amount);
    }

    /* ========== MINTER MANAGEMENT ========== */

    /**
     * @notice Adds or removes a minter
     * @param minter Address to add/remove
     * @param status True to allow minting, false to revoke
     * @dev Only the contract admin can call
     * @custom:emits MinterUpdated
     * @custom:requires minter != 0
     */
    function setMinter(address minter, bool status) external onlyAdmin {
        require(minter != address(0), "Minter cannot be zero address");
        authorizedMinters[minter] = status;
        emit MinterUpdated(minter, status);
    }

    /**
     * @notice Checks if an address is an authorized minter
     * @param account Address to check
     * @return bool True if address is authorized minter
     */
    function isMinter(address account) external view returns (bool) {
        return authorizedMinters[account];
    }

    /* ========== SUPPLY MANAGEMENT ========== */

    /**
     * @notice Updates the maximum supply (only admin, for upgrades)
     * @param newMaxSupply New maximum supply
     * @dev Can only increase supply, not decrease
     * @custom:requires newMaxSupply >= current maxSupply
     * @custom:requires newMaxSupply >= current totalSupply
     */
    function updateMaxSupply(uint256 newMaxSupply) external onlyAdmin {
        require(newMaxSupply >= maxSupply, "Max supply can only increase");
        require(newMaxSupply >= totalSupply(), "Cannot set max supply below current total");
        maxSupply = newMaxSupply;
    }

    /**
     * @notice Gets the remaining mintable tokens
     * @return uint256 Number of tokens that can still be minted
     */
    function remainingMintable() external view returns (uint256) {
        return maxSupply - totalSupply();
    }

    /* ========== PAUSE FUNCTIONS ========== */

    /**
     * @notice Pauses all token transfers and minting
     * @dev Only the contract admin can call
     */
    function pause() external onlyAdmin {
        _pause();
    }

    /**
     * @notice Unpauses all token transfers and minting
     * @dev Only the contract admin can call
     */
    function unpause() external onlyAdmin {
        _unpause();
    }

    /* ========== OVERRIDE FUNCTIONS ========== */

    /**
     * @notice Overrides the standard ERC20 transfer with a pause check
     * @param from Sender address
     * @param to Recipient address
     * @param value Amount of tokens to transfer
     * @dev Transfer will fail if the contract is paused
     */
    function _update(
        address from,
        address to,
        uint256 value
    ) internal override whenNotPaused {
        super._update(from, to, value);
    }

    /**
     * @notice Returns the number of decimals used by the token
     * @return uint8 Always 18
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }

    /* ========== UPGRADE SAFETY ========== */

    /**
     * @notice Storage gap for future upgrades
     * @dev Reserved storage space to allow for new variables in upgrades
     * @dev Prevents storage collisions when adding new state variables
     * 
     * @custom:upgrade-safety Always include 50 slots gap in upgradeable contracts
     * @custom:warning Do not remove or reduce this gap in future versions
     */
    uint256[50] private __gap;
}
