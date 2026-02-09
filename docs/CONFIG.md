**Protocol Configuration**

**Voting System Parameters**
1. `IDEAS_PER_ROUND`
2. `VOTING_DURATION`
3. `minStake`

**Parameter Effects**
1. Higher `IDEAS_PER_ROUND` increases round size but raises gas usage
2. Longer `VOTING_DURATION` reduces spam but slows funding cadence
3. Higher `minStake` reduces spam but increases voter cost

**Grant Distribution**
1. `authorSharePercent` in `GrantManagerUpgradeable`

**Grant Tradeoffs**
1. Higher author share increases builder incentives
2. Lower author share increases protocol reserve

**Token Parameters**
1. `maxSupply` in `GovernanceTokenUpgradeable`
2. Initial minters and minting permissions

**Token Tradeoffs**
1. Lower `maxSupply` constrains long-term emissions
2. Minters should be limited and monitored

**Role Assignments**
1. All system roles are set in `deploy-proxies.ts`
2. User roles are granted via `VoterProgressionUpgradeable`

**Where To Change Parameters**
1. Admin-only setters in upgradeable contracts
2. Upgrades for new parameters or constraints

**Recommended Defaults (Local/Sepolia)**
1. `IDEAS_PER_ROUND = 30`
2. `VOTING_DURATION = 1 day`
3. `minStake = 3000 * 10**18`
4. `authorSharePercent = 95`

**Parameter Change Guidance**
1. Prefer changes on Sepolia before any production environment
2. Document changes and expected impact
3. Re-run post-deploy checks after updates
