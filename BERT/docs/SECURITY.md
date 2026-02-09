**Security Overview**

**Roles And Permissions**
1. `DEFAULT_ADMIN_ROLE` controls critical parameters and role grants
2. `VOTING_ROLE` restricts voting system operations
3. `GRANT_ROLE` and `DISTRIBUTOR_ROLE` protect grant distribution
4. `IREGISTRY_ROLE` controls cross-contract registry actions
5. `REPUTATION_MANAGER_ROLE` controls reputation updates
6. `AUTO_GRANT_ROLE` allows voter progression to grant user roles

**Admin Key Practices**
1. Use a dedicated admin address for deployments
2. Rotate admin keys after deployment if needed
3. Never use admin keys for day-to-day interactions

**Pausability**
1. `FundingPoolUpgradeable`, `VotingSystemUpgradeable`, and `GrantManagerUpgradeable` are pausable
2. Keep pause privileges limited to trusted admins
3. Document pause and unpause procedures

**Upgrade Safety**
1. Review storage layout before any upgrade
2. Use upgrade rehearsals on localhost and Sepolia
3. Store deployment and upgrade artifacts for auditability
4. Prefer multi-step reviews for production upgrades

**Threat Model Notes**
1. Admin key compromise is the highest-risk scenario
2. Misconfigured roles can cause unintended permissions
3. Incorrect proxy admin use can block upgrades

**Operational Controls**
1. Keep a record of ProxyAdmin owners per proxy
2. Verify admin and impl slots after upgrades
3. Monitor pause status and critical parameters

**External Calls**
1. Cross-contract calls are protected by role checks
2. Integrations must respect access restrictions
