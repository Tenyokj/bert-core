# VotingSystemUpgradeable

**Summary**
Core voting engine that manages rounds, staking, and winner selection.

**Role In System**
Coordinates voting rounds, updates idea status, and triggers reputation and progression updates based on outcomes.

**Key Features**
- Starts and ends voting rounds with cooldowns
- Tracks votes and idea participation
- Applies staking rules and minimum stake
- Updates idea statuses via `IdeaRegistryUpgradeable`
- Integrates with reputation and voter progression systems
- Pausable for safety

**Access Control**
- Uses `RolesAwareUpgradeable` modifiers
- Key admin functions restricted to DEFAULT_ADMIN_ROLE

**Dependencies**
- `FundingPoolUpgradeable` for staking
- `IdeaRegistryUpgradeable` for idea data and status updates
- `ReputationSystemUpgradeable` for reputation changes
- `VoterProgressionUpgradeable` for progression updates
- `RolesRegistryUpgradeable` for access control

**Upgradeability**
Upgradeable and pausable. Storage gap is included.
