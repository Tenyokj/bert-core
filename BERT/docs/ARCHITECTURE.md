**Architecture Overview**

**System Flow**
1. Users submit ideas in `IdeaRegistryUpgradeable`
2. Voting rounds are started in `VotingSystemUpgradeable`
3. Votes stake governance tokens through `FundingPoolUpgradeable`
4. Winners are determined, reputation and progression are updated
5. `GrantManagerUpgradeable` finalizes payouts and updates idea status

**Core Modules**
1. `IdeaRegistryUpgradeable`
2. `VotingSystemUpgradeable`
3. `FundingPoolUpgradeable`
4. `GrantManagerUpgradeable`
5. `GovernanceTokenUpgradeable`

**Access Control**
1. `RolesRegistryUpgradeable` is the central role authority
2. `RolesAwareUpgradeable` enforces role checks in all core modules

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
