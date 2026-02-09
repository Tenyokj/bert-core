# RolesRegistryUpgradeable

**Summary**
Central role registry for all system and user roles.

**Role In System**
Single source of truth for permissions across the DAO contracts.

**Key Features**
- Defines system roles (Voting, Grant, Distributor, IdeaRegistry, Reputation)
- Defines user roles (Curator, Reviewer)
- Grants system roles to contracts
- Grants user roles via AUTO_GRANT_ROLE

**Access Control**
- System role grants by DEFAULT_ADMIN_ROLE
- User role grants by AUTO_GRANT_ROLE

**Dependencies**
- AccessControlUpgradeable, OwnableUpgradeable (OZ)

**Upgradeability**
Upgradeable. Storage gap is included.
