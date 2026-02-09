# RolesAwareUpgradeable

**Summary**
Abstract base that provides role-based access modifiers for all DAO contracts.

**Role In System**
Shared access-control layer that enforces permissions via `RolesRegistryUpgradeable`.

**Key Features**
- Centralizes role checks
- Provides modifiers for voting, grants, registry, reputation, curator, reviewer, admin

**Access Control**
- All modifiers read roles from `RolesRegistryUpgradeable`

**Dependencies**
- `RolesRegistryUpgradeable`

**Upgradeability**
Upgradeable. Storage gap is included.
