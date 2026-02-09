# FundingPoolUpgradeable

**Summary**
Treasury-like pool that holds governance tokens, tracks deposits, and distributes funds to winning ideas.

**Role In System**
Receives deposits and stakes from voters, records pool balances per round/idea, and pays out grants through the grant manager.

**Key Features**
- Accepts token deposits and records donor balances
- Tracks pool balances per round and per idea
- Distributes funds to winning idea authors
- Maintains protocol reserve for leftover funds
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
