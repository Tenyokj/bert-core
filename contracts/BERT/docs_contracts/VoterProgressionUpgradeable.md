# VoterProgressionUpgradeable

**Summary**
Tracks winning votes and grants curator/reviewer roles when thresholds are met.

**Role In System**
Progression layer that rewards active voters with higher privileges.

**Key Features**
- Tracks per-user winning votes
- Grants CURATOR_ROLE and REVIEWER_ROLE at thresholds
- Exposes progression status helpers

**Access Control**
- Only VotingSystem can register winning votes
- Uses `RolesAwareUpgradeable` modifiers

**Dependencies**
- `RolesRegistryUpgradeable` for role grants

**Upgradeability**
Upgradeable. Storage gap is included.
