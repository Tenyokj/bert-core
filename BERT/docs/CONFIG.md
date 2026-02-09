**Protocol Configuration**

**Voting System Parameters**
1. `IDEAS_PER_ROUND`
2. `VOTING_DURATION`
3. `minStake`

**Grant Distribution**
1. `authorSharePercent` in `GrantManagerUpgradeable`

**Token Parameters**
1. `maxSupply` in `GovernanceTokenUpgradeable`
2. Initial minters and minting permissions

**Role Assignments**
1. All system roles are set in `deploy-proxies.ts`
2. User roles are granted via `VoterProgressionUpgradeable`

**Where To Change Parameters**
1. Admin-only setters in upgradeable contracts
2. Upgrades for new parameters or constraints

**Parameter Change Guidance**
1. Prefer changes on Sepolia before any production environment
2. Document changes and expected impact
3. Re-run post-deploy checks after updates
