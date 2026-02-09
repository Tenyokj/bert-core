# ReputationSystemUpgradeable

**Summary**
Manages user reputation scores with initialization and adjustment operations.

**Role In System**
Provides reputation scores used by the ecosystem to track author performance.

**Key Features**
- Initializes reputation for new users
- Increases or decreases reputation
- Caps reputation at a maximum
- Batch and helper read functions

**Access Control**
- Only REPUTATION_MANAGER_ROLE can mutate reputation
- Uses `RolesAwareUpgradeable` modifiers

**Dependencies**
- `RolesRegistryUpgradeable` for access control

**Upgradeability**
Upgradeable. Storage gap is included.
