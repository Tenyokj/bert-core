# BRTFaucet

**Summary**
Recurring token faucet with configurable claim amounts and cooldown periods. Users can claim a fixed amount of governance tokens repeatedly, with a mandatory waiting time between claims.

**Role In System**
Primary mechanism for distributing testnet/mainnet tokens to users. Provides controlled, sustainable token distribution while preventing rapid draining.

**Key Features**
- Recurring claims with cooldown timer per address
- Admin-adjustable claim amount and cooldown duration
- Pausable for emergency situations
- First claim is immediate (no cooldown)
- Emits detailed claim events with next claim timestamp

**Access Control**
- **Admin** (DEFAULT_ADMIN_ROLE): Can adjust claim amount, modify cooldown, pause/unpause
- **Users**: Can claim tokens if cooldown has elapsed

**Dependencies**
- `GovernanceTokenUpgradeable`: Contract must grant `MINTER_ROLE` to faucet
- `RolesRegistryUpgradeable`: Provides admin role verification

**Upgradeability**
Not upgradeable (regular contract).