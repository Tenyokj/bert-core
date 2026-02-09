**Upgrade Guide**

**Contents**
1. When To Upgrade
2. Storage Layout Rules
3. Pre-Upgrade Checklist
4. Upgrade Steps
5. Example Upgrade (V1 -> V2)
6. Post-Upgrade Checks
7. Common Pitfalls
8. Rollback Strategy
9. Recommended Workflow
10. Upgrade Flow Diagram (ASCII)
11. Upgrade Flow Diagram (PDF)

**When To Upgrade**
1. Fix critical bugs
2. Add new features without breaking storage
3. Adjust protocol parameters via new logic

**Storage Layout Rules**
1. Do not reorder state variables
2. Only append new variables at the end
3. Preserve storage gaps in upgradeable contracts
4. Keep inheritance order unchanged

**Pre-Upgrade Checklist**
1. Verify storage layout compatibility
2. Run tests and upgrade simulations
3. Deploy new implementation on localhost
4. Verify admin ownership of the proxy
5. Confirm correct proxy and ProxyAdmin addresses
6. Confirm initializer is not re-used incorrectly

**Upgrade Steps**
1. Deploy new implementation using `upgrade-proxy.ts`
2. Verify the proxy implementation address changed
3. Run post-upgrade checks

**Example Upgrade (V1 -> V2)**
1. Deploy `MockVotingSystemV2` as new implementation
2. Upgrade proxy via ProxyAdmin
3. Validate `version()` and new storage field

**Post-Upgrade Checks**
1. Read EIP-1967 implementation slot
2. Validate key parameters and role wiring
3. Smoke test critical flows
4. Run `verify-deploy.ts` with updated addresses

**Common Pitfalls**
1. Using file name instead of contract name for `IMPL`
2. Supplying ProxyAdmin address as proxy address
3. Upgrading with an admin that is not the ProxyAdmin owner
4. Restarting local node between deploy and upgrade
5. Accidentally calling initializer twice

**Rollback Strategy**
1. Keep the previous implementation address
2. Re-upgrade to the previous implementation if needed
3. Document rollback triggers
4. Verify state consistency after rollback

**Recommended Workflow**
1. Localhost upgrade rehearsal
2. Sepolia upgrade rehearsal
3. Production upgrade with audit and review

**Upgrade Flow Diagram (ASCII)**
```text
New Impl Deploy
   |
   v
ProxyAdmin.upgradeAndCall
   |
   v
Proxy Implementation Updated
   |
   v
Post-Upgrade Checks
```
