**Compiler Versions**

This repository uses a single Solidity compiler version for all contracts:

1. `solc 0.8.28`

This is configured in `hardhat.config.ts` and applies to every contract in `contracts/`.

**Why This Document Exists**
1. Makes audits and reviews easier by stating the exact compiler version
2. Helps avoid accidental version drift across environments
3. Clarifies compatibility with OpenZeppelin v5 upgradeable contracts

**Compilation**
```bash
npx hardhat compile
```
