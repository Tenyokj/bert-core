# FundingPoolUpgradeable

**Summary**
Treasury-like pool that holds governance tokens, tracks deposits, locks author stake, and distributes milestone-based grants.

**Role In System**
Receives deposits and stakes from voters, records pool balances per round/idea, and pays out grants through the grant manager.

**Key Features**
- Accepts token deposits and records donor balances
- Locks author stake for newly created ideas
- Tracks pool balances per round and per idea
- Distributes funds to winning idea authors in multiple payout steps
- Maintains protocol reserve for leftover funds
- Can move rejected author stake and reserved round funds into protocol reserve
- Pausable for safety

**Access Control**
- Only voting system can deposit on behalf of voters
- Only distributor role can distribute funds
- Uses `RolesAwareUpgradeable` for role checks

**Dependencies**
- `GovernanceTokenUpgradeable` (ERC20)
- `IdeaRegistryUpgradeable` for idea author lookups
- `RolesRegistryUpgradeable` for access control

**Upgradeability**
Upgradeable and pausable. Storage gap is included.
