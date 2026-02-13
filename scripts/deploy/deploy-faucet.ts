/**
 * @file deploy-faucet.ts
 * @notice Deploys BTKFaucet and grants minter permission in GovernanceToken.
 * @dev Run: npx hardhat run scripts/deploy/deploy-faucet.ts --network localhost
 */
import { hre } from "../../test/setup.js";

async function main() {
  const connection = await hre.network.connect();
  const { ethers } = connection;
  const [deployer] = await ethers.getSigners();

  const tokenAddress = process.env.GOV_TOKEN_PROXY;
  const rolesAddress = process.env.ROLES_REGISTRY_PROXY;
  const claimAmount = process.env.FAUCET_CLAIM_AMOUNT ?? "10000";
  const cooldownSec = Number(process.env.FAUCET_COOLDOWN_SEC ?? "86400");

  if (!tokenAddress) throw new Error("Missing GOV_TOKEN_PROXY");
  if (!rolesAddress) throw new Error("Missing ROLES_REGISTRY_PROXY");

  const faucet = await ethers.deployContract("BTKFaucet", [
    tokenAddress,
    rolesAddress,
    ethers.parseEther(claimAmount),
    cooldownSec,
  ]);
  await faucet.waitForDeployment();

  const faucetAddress = await faucet.getAddress();

  const token = await ethers.getContractAt(
    "GovernanceTokenUpgradeable",
    tokenAddress,
    deployer
  );
  await token.setMinter(faucetAddress, true);

  console.log("BTKFaucet:", faucetAddress);
  console.log("Minter granted to faucet in GovernanceToken");
}

main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
