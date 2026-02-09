**Security Overview**

**Contents**
1. Roles And Permissions
2. Role Assignment Principles
3. Admin Key Practices
4. Pausability
5. Upgrade Safety
6. Threat Model Notes
7. Operational Controls
8. External Calls
9. Emergency Checklist
10. Threat Model Diagram (ASCII)
11. Threat Model Diagram (PDF)

**Roles And Permissions**
1. `DEFAULT_ADMIN_ROLE` controls critical parameters and role grants
2. `VOTING_ROLE` restricts voting system operations
3. `GRANT_ROLE` and `DISTRIBUTOR_ROLE` protect grant distribution
4. `IREGISTRY_ROLE` controls cross-contract registry actions
5. `REPUTATION_MANAGER_ROLE` controls reputation updates
6. `AUTO_GRANT_ROLE` allows voter progression to grant user roles

**Role Assignment Principles**
1. System roles should only be granted to contracts, not EOAs
2. Admin role should be held by a multisig for production use
3. Use the smallest permission set required for each module

**Admin Key Practices**
1. Use a dedicated admin address for deployments
2. Rotate admin keys after deployment if needed
3. Never use admin keys for day-to-day interactions
4. Store admin keys in a hardware wallet or secure signer

**Pausability**
1. `FundingPoolUpgradeable`, `VotingSystemUpgradeable`, and `GrantManagerUpgradeable` are pausable
2. Keep pause privileges limited to trusted admins
3. Document pause and unpause procedures
4. Use pause in emergencies only, then perform a post-mortem

**Upgrade Safety**
1. Review storage layout before any upgrade
2. Use upgrade rehearsals on localhost and Sepolia
3. Store deployment and upgrade artifacts for auditability
4. Prefer multi-step reviews for production upgrades
5. Validate new implementation bytecode before upgrade

**Threat Model Notes**
1. Admin key compromise is the highest-risk scenario
2. Misconfigured roles can cause unintended permissions
3. Incorrect proxy admin use can block upgrades
4. Incorrect parameters can halt voting or cause unfair outcomes

**Operational Controls**
1. Keep a record of ProxyAdmin owners per proxy
2. Verify admin and impl slots after upgrades
3. Monitor pause status and critical parameters
4. Review events for unexpected role changes

**External Calls**
1. Cross-contract calls are protected by role checks
2. Integrations must respect access restrictions
3. Untrusted external calls should be wrapped with try/catch where possible

**Emergency Checklist**
1. Pause FundingPool, VotingSystem, GrantManager
2. Identify the root cause and scope
3. Patch or upgrade the affected module
4. Verify state consistency before unpausing

**Threat Model Diagram (ASCII)**
```text
Admin Key Compromise
  -> Unauthorized upgrades
  -> Role abuse
  -> Fund misdirection

Misconfigured Roles
  -> Unauthorized status changes
  -> Reputation manipulation

Operational Errors
  -> Wrong proxy/admin
  -> Broken upgrades
```
