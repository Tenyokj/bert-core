# GrantManagerUpgradeable

**Summary**
Orchestrates the grant lifecycle and coordinates distribution after voting.

**Role In System**
Reads voting results, validates idea eligibility, and triggers distribution from the funding pool.

**Key Features**
- Validates round completion and winning idea
- Calculates and distributes author share
- Updates idea status to Funded
- Exposes helper view functions for claimability
- Pausable for safety

**Access Control**
- Uses `RolesAwareUpgradeable` modifiers
- Critical actions restricted by roles

**Dependencies**
- `VotingSystemUpgradeable` for round results
- `FundingPoolUpgradeable` for distributions
- `IdeaRegistryUpgradeable` for idea status and author
- `RolesRegistryUpgradeable` for access control

**Upgradeability**
Upgradeable and pausable. Storage gap is included.
