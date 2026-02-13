**Deploy BERT Protocol**

**TL;DR**
```bash
# 1) Start a local node
npx hardhat node

# 2) Deploy the system
npx hardhat run scripts/deploy-proxies.ts --network localhost

# 3) Upgrade a proxy (example)
PROXY=<proxy_address> \
IMPL=MockVotingSystemV2 \
GAS_LIMIT=5000000 \
npx hardhat run scripts/upgrade-proxy.ts --network localhost
```

**Requirements**
1. `node >= 22.10`
2. Install deps: `npm i`
3. Copy `.env.example` to `.env` and fill in values as needed

**General Information**
The deployment uses OpenZeppelin v5 TransparentUpgradeableProxy. Each proxy auto-creates its own ProxyAdmin contract. The deployer (or `PROXY_ADMIN_OWNER`) becomes the owner of these ProxyAdmin contracts.

The deployment script:
1. Deploys all upgradeable contracts behind proxies
2. Grants system roles in `RolesRegistryUpgradeable`
3. Unpauses core contracts
4. Prints proxy addresses, implementation addresses, and per-proxy ProxyAdmin addresses

**Deployment Config**
Optional env vars for the governance token:
1. `GOV_TOKEN_NAME` (default `BertToken`)
2. `GOV_TOKEN_SYMBOL` (default `BRT`)
3. `GOV_MAX_SUPPLY` (default `80000000`, parsed with `ethers.parseEther`)

Optional env var for ProxyAdmin ownership:
1. `PROXY_ADMIN_OWNER` (default deployer)

Optional RPC and key env vars:
1. `LOCAL_RPC_URL` (default `http://127.0.0.1:8545`)
2. `SEPOLIA_RPC_URL`
3. `DEPLOYER_KEY`

**Localhost Deployment**
1. Start the node and keep it running:
```bash
npx hardhat node
```
2. Deploy:
```bash
npx hardhat run scripts/deploy-proxies.ts --network localhost
```
3. Save the output. You will need:
1. The **proxy address** from `Deployment summary`
2. The **ProxyAdmin address** from `ProxyAdmin per proxy`

Notes:
1. If you restart `hardhat node`, all addresses reset.
2. Use `npx hardhat run` only. Do not run scripts via `tsx`.

**Sepolia Deployment**
This repo does not deploy to mainnet. Use Sepolia for public test deployments.

1. Add a Sepolia network entry to `hardhat.config.ts`.
2. Create a `.env` with your RPC and private key.
3. Run the [deploy script](scripts/deploy/deploy-proxies.ts) on Sepolia.

Example network config:
```ts
sepolia: {
  type: "http",
  url: process.env.SEPOLIA_RPC_URL,
  chainId: 11155111,
  accounts: [process.env.DEPLOYER_KEY],
}
```

Example env:
```bash
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/<id>
DEPLOYER_KEY=0x<private_key>
GOV_TOKEN_NAME=BertToken
GOV_TOKEN_SYMBOL=BRT
GOV_MAX_SUPPLY=80000000
```

Deploy on Sepolia:
```bash
npx hardhat run scripts/deploy-proxies.ts --network sepolia
```

**Roles And Wiring**
`deploy-proxies.ts` automatically:
1. Grants VOTING_ROLE to `VotingSystemUpgradeable`
2. Grants GRANT_ROLE and DISTRIBUTOR_ROLE to `GrantManagerUpgradeable`
3. Grants IREGISTRY_ROLE to `IdeaRegistryUpgradeable`
4. Grants REPUTATION_MANAGER_ROLE to `VotingSystemUpgradeable` and `IdeaRegistryUpgradeable`
5. Grants AUTO_GRANT_ROLE to `VoterProgressionUpgradeable`
6. Unpauses `FundingPoolUpgradeable`, `VotingSystemUpgradeable`, `GrantManagerUpgradeable`

**Deploy Faucet**
The [faucet deploy script](../deploy-faucet.ts) deploys `BRTFaucet` and grants it minter permission in `GovernanceTokenUpgradeable`.

Required env vars:
1. `GOV_TOKEN_PROXY` (governance token proxy address)
2. `ROLES_REGISTRY_PROXY` (roles registry proxy address)

Optional env vars:
1. `FAUCET_CLAIM_AMOUNT` (default `10000`, parsed with `ethers.parseEther`)
2. `FAUCET_COOLDOWN_SEC` (default `86400`)

Run:
```bash
GOV_TOKEN_PROXY=<gov_token_proxy> \
ROLES_REGISTRY_PROXY=<roles_registry_proxy> \
FAUCET_CLAIM_AMOUNT=10000 \
FAUCET_COOLDOWN_SEC=86400 \
npx hardhat run scripts/deploy/deploy-faucet.ts --network localhost
```

**Upgrade A Proxy**
The [upgrade script](scripts/upgrade-proxy.ts) deploys a new implementation and upgrades a single proxy via its ProxyAdmin.

Important:
1. Use the **proxy address** from `Deployment summary`
2. Use the **ProxyAdmin address** from `ProxyAdmin per proxy`
3. `IMPL` must be the **contract name**, not the file name

Example upgrade:
```bash
PROXY=0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82 \
PROXY_ADMIN=0x32467b43BFa67273FC7dDda0999Ee9A12F2AaA08 \
IMPL=MockVotingSystemV2 \
GAS_LIMIT=5000000 \
npx hardhat run scripts/deploy/upgrade-proxy.ts --network localhost
```

Example with `upgradeAndCall`:
```bash
PROXY=0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82 \
PROXY_ADMIN=0x32467b43BFa67273FC7dDda0999Ee9A12F2AaA08 \
IMPL=MockVotingSystemV2 \
CALL='initializeV2(uint256)' \
ARGS='[123]' \
GAS_LIMIT=5000000 \
npx hardhat run scripts/deploy/upgrade-proxy.ts --network localhost
```

If you omit `PROXY_ADMIN`, the script reads it from the proxy admin slot:
```bash
PROXY=0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82 \
IMPL=MockVotingSystemV2 \
GAS_LIMIT=5000000 \
npx hardhat run scripts/deploy/upgrade-proxy.ts --network localhost
```

**Troubleshooting**
1. `admin slot = 0x0` and `impl slot = 0x0` means the proxy address is wrong or the node was restarted.
2. `ProxyAdmin owner` must be your deployer; otherwise upgrade will fail.
3. If the proxy admin does not match, you likely used a ProxyAdmin address instead of the proxy address.

**Post-Deploy Checks**
Run these quick checks to validate the deployment:

1. Confirm proxy code exists:
```bash
npx hardhat console --network localhost
```
```js
const { ethers } = await hre.network.connect();
await ethers.provider.getCode("<proxy_address>");
```
If this returns `"0x"`, the address is wrong or the node was restarted.

2. Confirm proxy admin and implementation:
```js
const adminSlot = ethers.toBeHex(BigInt(ethers.keccak256(ethers.toUtf8Bytes("eip1967.proxy.admin"))) - 1n, 32);
const implSlot = ethers.toBeHex(BigInt(ethers.keccak256(ethers.toUtf8Bytes("eip1967.proxy.implementation"))) - 1n, 32);
const admin = await ethers.provider.getStorage("<proxy_address>", adminSlot);
const impl = await ethers.provider.getStorage("<proxy_address>", implSlot);
ethers.getAddress(ethers.dataSlice(admin, 12));
ethers.getAddress(ethers.dataSlice(impl, 12));
```

3. Confirm roles are wired:
```js
const roles = await ethers.getContractAt("RolesRegistryUpgradeable", "<roles_proxy>");
await roles.hasRole(await roles.VOTING_ROLE(), "<voting_system_proxy>");
await roles.hasRole(await roles.GRANT_ROLE(), "<grant_manager_proxy>");
await roles.hasRole(await roles.DISTRIBUTOR_ROLE(), "<grant_manager_proxy>");
await roles.hasRole(await roles.IREGISTRY_ROLE(), "<idea_registry_proxy>");
await roles.hasRole(await roles.REPUTATION_MANAGER_ROLE(), "<voting_system_proxy>");
await roles.hasRole(await roles.REPUTATION_MANAGER_ROLE(), "<idea_registry_proxy>");
await roles.hasRole(await roles.AUTO_GRANT_ROLE(), "<voter_progression_proxy>");
```

4. One-command [verification script](scripts/verify-deploy.ts):
```bash
ROLES=<roles_proxy> \
IDEA=<idea_registry_proxy> \
FUNDING=<funding_pool_proxy> \
VOTING=<voting_system_proxy> \
GRANT=<grant_manager_proxy> \
REPUTATION=<reputation_system_proxy> \
VOTER=<voter_progression_proxy> \
npx hardhat run scripts/deploy/verify-deploy.ts --network localhost
```
This script checks:
1. Role wiring for all core contracts
2. Pause status for Funding/Voting/Grant
3. Voting parameters (IDEAS_PER_ROUND, VOTING_DURATION, minStake)
