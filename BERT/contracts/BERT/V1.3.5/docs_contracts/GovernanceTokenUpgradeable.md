# GovernanceTokenUpgradeable

**Summary**
ERC20 governance token with minting control, burnability, and pausable transfers.

**Role In System**
Token used for staking and funding. Can be minted by authorized minters.

**Key Features**
- ERC20 with burnable extension
- Pausable transfers
- Max supply enforcement
- Admin-controlled minter list

**Access Control**
- Minters controlled by admin
- Pausing controlled by admin
- Uses `RolesAwareUpgradeable` for admin role checks

**Dependencies**
- `RolesRegistryUpgradeable` for access control

**Upgradeability**
Upgradeable and pausable. Storage gap is included.
