# GrantManagerUpgradeable

**Summary**
Orchestrates the grant lifecycle and coordinates staged distribution after voting.

**Role In System**
Reads voting results, validates idea eligibility, and triggers distribution from the funding pool.

**Key Features**
- Validates round completion and winning idea
- Releases initial author share on claim
- Handles milestone proof submission and reviewer approvals
- Releases staged payouts in a `30/40/30` flow
- Updates idea status through `Funded`, `InProcess`, and `Completed`
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
