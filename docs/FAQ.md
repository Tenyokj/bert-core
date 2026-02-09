**FAQ**

**Why do I see multiple ProxyAdmins?**
Each Transparent proxy creates its own ProxyAdmin in OZ v5. This is expected.

**Why does the admin slot show 0x0?**
The proxy address is wrong or the node was restarted. Redeploy and use fresh addresses.

**Why does upgrade fail with owner errors?**
Only the ProxyAdmin owner can upgrade. Use the deployer or transfer ownership.

**Do I need to run `hardhat node` for tests?**
No. `hardhat test` uses in-process network by default.

**Why does `IMPL` not resolve?**
`IMPL` must be the contract name, not the file name.

**Can I use `tsx` to run scripts?**
No. Use `npx hardhat run` to ensure correct network context.

**Why does ProxyAdmin ownership differ from my deployer?**
You likely used a ProxyAdmin address as initial owner or mixed addresses from different deploys.

**How do I confirm role wiring?**
Use `scripts/verify-deploy.ts` or query `RolesRegistryUpgradeable.hasRole` manually.

**What if I lose ProxyAdmin ownership?**
Upgrades will be blocked. You must recover ownership or redeploy proxies.

**Where are the proxy and implementation addresses stored?**
They are printed during deployment. Record them and keep a deployment log.

**Is there a single ProxyAdmin for all contracts?**
No. Each proxy creates its own ProxyAdmin in the current architecture.

**Can I reduce the number of admins?**
Yes, by changing the deployment pattern, but it requires a different proxy setup.
