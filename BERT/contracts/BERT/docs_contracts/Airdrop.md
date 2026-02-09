# Airdrop

**Summary**
Simple airdrop contract that mints a fixed amount of governance tokens to the first N users.

**Role In System**
Optional distribution mechanism to bootstrap user token balances.

**Key Features**
- One-time claim per address
- Hard cap on total claimants
- Emits claim events

**Access Control**
- Anyone can claim if eligible

**Dependencies**
- `GovernanceTokenUpgradeable` (must allow minting)

**Upgradeability**
Not upgradeable (regular contract).
