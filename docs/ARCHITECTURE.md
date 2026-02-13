**Architecture Overview**

**Contents**
1. System Flow
2. Data Flow (At a Glance)
3. Core Modules
4. Core Responsibilities
5. Access Control
6. Role Matrix (High Level)
7. Supporting Systems
8. State Model
9. Upgradeability
10. Storage Boundaries
11. Trust Boundaries
12. Data Dependencies
13. User Journey (At A Glance)
14. Diagram (ASCII)

**System Flow**
1. Users submit ideas in `IdeaRegistryUpgradeable`
2. Voting rounds are started in `VotingSystemUpgradeable`
3. Votes stake governance tokens through `FundingPoolUpgradeable`
4. Winners are determined, reputation and progression are updated
5. `GrantManagerUpgradeable` finalizes payouts and updates idea status

**Data Flow (At a Glance)**
1. Idea metadata is stored only in `IdeaRegistryUpgradeable`
2. Voting rounds and vote accounting are stored in `VotingSystemUpgradeable`
3. Deposits and pool balances are stored in `FundingPoolUpgradeable`
4. Grant payouts are executed by `GrantManagerUpgradeable`

**Core Modules**
1. `IdeaRegistryUpgradeable`
2. `VotingSystemUpgradeable`
3. `FundingPoolUpgradeable`
4. `GrantManagerUpgradeable`
5. `GovernanceTokenUpgradeable`

**Core Responsibilities**
1. `IdeaRegistryUpgradeable` is the single source of truth for ideas and status transitions
2. `VotingSystemUpgradeable` manages round lifecycle, staking rules, and winners
3. `FundingPoolUpgradeable` collects stake and distributes grant funds
4. `GrantManagerUpgradeable` validates eligibility and triggers distribution
5. `GovernanceTokenUpgradeable` is the staking asset and reward token

**Access Control**
1. `RolesRegistryUpgradeable` is the central role authority
2. `RolesAwareUpgradeable` enforces role checks in all core modules

**Role Matrix (High Level)**
1. `VOTING_ROLE` = voting system contract
2. `GRANT_ROLE` + `DISTRIBUTOR_ROLE` = grant manager
3. `IREGISTRY_ROLE` = idea registry
4. `REPUTATION_MANAGER_ROLE` = voting system + idea registry
5. `AUTO_GRANT_ROLE` = voter progression

**Supporting Systems**
1. `ReputationSystemUpgradeable` tracks author reputation
2. `VoterProgressionUpgradeable` grants CURATOR/REVIEWER roles

**State Model**
1. Idea status transitions defined in `IdeaStatus`
2. Errors defined in `Errors` for consistent reverts

**Upgradeability**
1. All core modules are deployed behind Transparent proxies
2. Each proxy has its own `ProxyAdmin` (OZ v5 pattern)
3. Upgrade operations are managed per proxy

**Storage Boundaries**
1. No contract holds another contract's state directly
2. Cross-contract reads are done via interfaces
3. Role checks prevent unauthorized state changes

**Trust Boundaries**
1. Admin roles can pause and change parameters
2. System roles are granted only to contracts, not EOAs
3. User roles are granted by progression logic

**Data Dependencies**
1. Voting depends on IdeaRegistry and FundingPool
2. GrantManager depends on VotingSystem and FundingPool
3. IdeaRegistry depends on ReputationSystem and VoterProgression

**User Journey (At A Glance)**
1. Create idea
2. Enter voting round
3. Vote with stake
4. Winner selected
5. Grant claimed and distributed

**Diagram (ASCII)**
```text
User
  |
  v
IdeaRegistryUpgradeable
  |  (status updates)
  v
VotingSystemUpgradeable <---- ReputationSystemUpgradeable
  |   (stake/votes)            VoterProgressionUpgradeable
  v
FundingPoolUpgradeable
  |
  v
GrantManagerUpgradeable -----> IdeaRegistryUpgradeable (funded status)
```

