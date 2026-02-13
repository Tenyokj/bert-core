**Getting Started**

**Requirements**
1. `node >= 22.10`
2. `npm`

**Clone**
```bash
git clone <repo-url>
cd <repo-name>
```

**Install**
```bash
npm i
```

**Compile**
```bash
npx hardhat compile
```

**Run Tests**
```bash
npx hardhat test
```

**Local Node (Optional)**
```bash
npx hardhat node
```

**Deploy (Localhost)**
```bash
npx hardhat run scripts/deploy/deploy-proxies.ts --network localhost
```
```bash
npx hardhat run scripts/deploy/deploy-faucet.ts --network localhost
```

**Sepolia Setup**
1. Copy `.env.example` to `.env`
2. Set `SEPOLIA_RPC_URL` and `DEPLOYER_KEY`

**Deploy (Sepolia)**
```bash
npx hardhat run scripts/deploy/deploy-proxies.ts --network sepolia
```
```bash
npx hardhat run scripts/deploy/deploy-faucet.ts --network sepolia
```
