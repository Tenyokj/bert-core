/**
 * @file verify-deploy.ts
 * @notice Quick post-deploy checks for core proxies and role wiring.
 * @dev Uses env vars to locate deployed proxies.
 * @dev Run with: npx hardhat run scripts/verify-deploy.ts --network localhost
 */
import { hre } from "../../test/setup.js";

type AddrMap = {
  ROLES: string;
  IDEA: string;
  FUNDING: string;
  VOTING: string;
  GRANT: string;
  REPUTATION: string;
  VOTER: string;
};

function getEnv(name: keyof AddrMap): string {
  const v = process.env[name];
  if (!v) {
    throw new Error(`Missing env var ${name}`);
  }
  return v;
}

function normalizeAddress(ethers: any, v: string): string {
  // Accept lowercase or any-case; normalize to checksummed.
  return ethers.getAddress(v.toLowerCase());
}

async function main() {
  const connection = await hre.network.connect();
  const { ethers } = connection;
  const { network } = hre;

  const addrs: AddrMap = {
    ROLES: normalizeAddress(ethers, getEnv("ROLES")),
    IDEA: normalizeAddress(ethers, getEnv("IDEA")),
    FUNDING: normalizeAddress(ethers, getEnv("FUNDING")),
    VOTING: normalizeAddress(ethers, getEnv("VOTING")),
    GRANT: normalizeAddress(ethers, getEnv("GRANT")),
    REPUTATION: normalizeAddress(ethers, getEnv("REPUTATION")),
    VOTER: normalizeAddress(ethers, getEnv("VOTER")),
  };

    let networkName = "unknown";

  try {
    const network = await ethers.provider.getNetwork();
    networkName = network.name;
    if (networkName === "unknown" && network.chainId) {
      networkName = `chain-${network.chainId}`;
    }
  } catch (e2) {
    const networkArgIndex = process.argv.indexOf("--network");
    if (networkArgIndex !== -1 && process.argv[networkArgIndex + 1]) {
      networkName = process.argv[networkArgIndex + 1];
    }
  }

  console.log("🔍 Verify Deployment");
  console.log("Network:", networkName);
  console.log("Addresses:", addrs);

  const roles = await ethers.getContractAt(
    "RolesRegistryUpgradeable",
    addrs.ROLES
  );

  const VOTING_ROLE = await roles.VOTING_ROLE();
  const GRANT_ROLE = await roles.GRANT_ROLE();
  const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
  const IREGISTRY_ROLE = await roles.IREGISTRY_ROLE();
  const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
  const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();

  console.log("\n✅ Role wiring");
  console.log(
    "VOTING_ROLE -> VotingSystem:",
    await roles.hasRole(VOTING_ROLE, addrs.VOTING)
  );
  console.log(
    "GRANT_ROLE -> GrantManager:",
    await roles.hasRole(GRANT_ROLE, addrs.GRANT)
  );
  console.log(
    "DISTRIBUTOR_ROLE -> GrantManager:",
    await roles.hasRole(DISTRIBUTOR_ROLE, addrs.GRANT)
  );
  console.log(
    "IREGISTRY_ROLE -> IdeaRegistry:",
    await roles.hasRole(IREGISTRY_ROLE, addrs.IDEA)
  );
  console.log(
    "REPUTATION_MANAGER_ROLE -> VotingSystem:",
    await roles.hasRole(REPUTATION_MANAGER_ROLE, addrs.VOTING)
  );
  console.log(
    "REPUTATION_MANAGER_ROLE -> IdeaRegistry:",
    await roles.hasRole(REPUTATION_MANAGER_ROLE, addrs.IDEA)
  );
  console.log(
    "AUTO_GRANT_ROLE -> VoterProgression:",
    await roles.hasRole(AUTO_GRANT_ROLE, addrs.VOTER)
  );

  console.log("\n✅ Pause status");
  const funding = await ethers.getContractAt(
    "FundingPoolUpgradeable",
    addrs.FUNDING
  );
  const voting = await ethers.getContractAt(
    "VotingSystemUpgradeable",
    addrs.VOTING
  );
  const grant = await ethers.getContractAt(
    "GrantManagerUpgradeable",
    addrs.GRANT
  );

  console.log("FundingPool paused:", await funding.paused());
  console.log("VotingSystem paused:", await voting.paused());
  console.log("GrantManager paused:", await grant.paused());

  console.log("\n✅ Voting params");
  console.log("IDEAS_PER_ROUND:", await voting.IDEAS_PER_ROUND());
  console.log("VOTING_DURATION:", await voting.VOTING_DURATION());
  console.log("minStake:", await voting.minStake());
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
