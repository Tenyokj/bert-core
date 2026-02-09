# IdeaRegistryUpgradeable

**Summary**
Central registry for ideas. Stores idea metadata, tracks lifecycle status, and integrates with reputation and voter progression.

**Role In System**
Source of truth for ideas and their status. It gates status transitions and enforces role-based actions for voting and grants.

**Key Features**
- Creates ideas with titles, descriptions, and optional links
- Tracks per-idea status (`Pending` -> `Voting` -> `WonVoting/Funded/Rejected/Completed`)
- Stores reviews and low-quality flags
- Integrates with `ReputationSystemUpgradeable` for reputation initialization
- Integrates with `VoterProgressionUpgradeable` for voter progression

**Access Control**
- Uses `RolesAwareUpgradeable` modifiers
- Status updates restricted to voting system or grant manager
- Low-quality and review actions limited to curator/reviewer roles

**Dependencies**
- `ReputationSystemUpgradeable` for reputation checks
- `VoterProgressionUpgradeable` for progression hooks
- `RolesRegistryUpgradeable` for access control

**Upgradeability**
Upgradeable (UUPS-like pattern via Transparent proxy). Storage gap is included for future upgrades.
