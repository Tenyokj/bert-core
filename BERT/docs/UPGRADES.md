**Upgrade Guide**

**When To Upgrade**
1. Fix critical bugs
2. Add new features without breaking storage
3. Adjust protocol parameters via new logic

**Pre-Upgrade Checklist**
1. Verify storage layout compatibility
2. Run tests and upgrade simulations
3. Deploy new implementation on localhost
4. Verify admin ownership of the proxy
5. Confirm correct proxy and ProxyAdmin addresses

**Upgrade Steps**
1. Deploy new implementation using `upgrade-proxy.ts`
2. Verify the proxy implementation address changed
3. Run post-upgrade checks

**Post-Upgrade Checks**
1. Read EIP-1967 implementation slot
2. Validate key parameters and role wiring
3. Smoke test critical flows

**Common Pitfalls**
1. Using file name instead of contract name for `IMPL`
2. Supplying ProxyAdmin address as proxy address
3. Upgrading with an admin that is not the ProxyAdmin owner
4. Restarting local node between deploy and upgrade

**Rollback Strategy**
1. Keep the previous implementation address
2. Re-upgrade to the previous implementation if needed
3. Document rollback triggers

**Recommended Workflow**
1. Localhost upgrade rehearsal
2. Sepolia upgrade rehearsal
3. Production upgrade with audit and review
