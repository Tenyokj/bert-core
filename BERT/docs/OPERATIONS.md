**Operations Guide**

**Day-2 Tasks**
1. Monitor pause status of core modules
2. Track voting round health and outcomes
3. Review grant distribution events

**Monitoring Suggestions**
1. Track `Paused` status for FundingPool, VotingSystem, GrantManager
2. Watch for unexpected role changes in RolesRegistry
3. Record upgrade transactions and implementation addresses

**Upgrade Operations**
1. Maintain a log of upgrades and tx hashes
2. Rehearse upgrades on localhost and Sepolia
3. Verify new implementation addresses after upgrade

**Emergency Procedure**
1. Pause FundingPool, VotingSystem, and GrantManager
2. Investigate and patch issue
3. Resume after post-incident checks

**Admin Rotation**
1. Transfer ProxyAdmin ownership if needed
2. Update operational playbooks accordingly
3. Validate access after rotation
