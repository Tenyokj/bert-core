/**
 * @file deploy-proxies.ts
 * @notice Deploys the full DAO system using TransparentUpgradeableProxy (OZ v5).
 * @dev Each proxy creates its own ProxyAdmin. Owner = PROXY_ADMIN_OWNER or deployer.
 * @dev Run with: npx hardhat run scripts/deploy-proxies.ts --network localhost
 */
import { createRequire } from "module";
import { hre, type HardhatEthers } from "../../test/setup.js";

const require = createRequire(import.meta.url);
const transparentProxyArtifact = require(
  "@openzeppelin/contracts/build/contracts/TransparentUpgradeableProxy.json"
);

type DeployedProxy = {
  proxyAddress: string;
  implAddress: string;
  proxyAdminAddress: string;
};

function getProxyAdminSlot(ethers: HardhatEthers) {
  const adminSlot =
    BigInt(
      ethers.keccak256(ethers.toUtf8Bytes("eip1967.proxy.admin"))
    ) - 1n;
  return ethers.toBeHex(adminSlot, 32);
}

async function readProxyAdmin(
  ethers: HardhatEthers,
  proxyAddress: string
): Promise<string> {
  const adminSlot = getProxyAdminSlot(ethers);
  const adminStorage = await ethers.provider.getStorage(proxyAddress, adminSlot);
  return ethers.getAddress(ethers.dataSlice(adminStorage, 12));
}

async function deployProxy(
  ethers: HardhatEthers,
  name: string,
  initArgs: any[],
  initialOwner: string
): Promise<DeployedProxy> {
  /**
   * @notice Deploy implementation + TransparentUpgradeableProxy
   * @param ethers Hardhat ethers instance
   * @param name Contract name (implementation)
   * @param initArgs Args for initialize()
   * @param initialOwner EOA that will own the auto-created ProxyAdmin
   * @return proxyAddress, implAddress, proxyAdminAddress
   */
  const [deployer] = await ethers.getSigners();

  const implFactory = await ethers.getContractFactory(name, deployer);
  const impl = await implFactory.deploy();
  await impl.waitForDeployment();

  const initData = implFactory.interface.encodeFunctionData(
    "initialize",
    initArgs
  );

  const proxyFactory = new ethers.ContractFactory(
    transparentProxyArtifact.abi,
    transparentProxyArtifact.bytecode,
    deployer
  );
  const proxy = await proxyFactory.deploy(
    await impl.getAddress(),
    initialOwner,
    initData
  );
  await proxy.waitForDeployment();
  const proxyAddress = await proxy.getAddress();
  const proxyAdminAddress = await readProxyAdmin(ethers, proxyAddress);

  return {
    proxyAddress,
    implAddress: await impl.getAddress(),
    proxyAdminAddress,
  };
}

async function main() {
  /**
   * @notice Deploys all upgradeable contracts, sets roles, and unpauses system.
   * @dev Prints proxy + impl + per-proxy admin addresses.
   */
  const connection = await hre.network.connect();
  const { ethers } = connection;
  const { network } = hre;
  const [deployer] = await ethers.getSigners();

  console.log("🚀 Deploying DAO Grant System with Transparent Proxies");
  console.log("Deployer:", deployer.address);
  const initialOwner =
    process.env.PROXY_ADMIN_OWNER && process.env.PROXY_ADMIN_OWNER.trim() !== ""
      ? process.env.PROXY_ADMIN_OWNER
      : deployer.address;
  console.log("ProxyAdmin owner (initial):", initialOwner);

  const tokenName = process.env.GOV_TOKEN_NAME ?? "BertToken";
  const tokenSymbol = process.env.GOV_TOKEN_SYMBOL ?? "BRT";
  const maxSupplyStr = process.env.GOV_MAX_SUPPLY ?? "80000000";
  const maxSupply = ethers.parseEther(maxSupplyStr);

  console.log("\n1) Deploying core contracts via proxies...");

  const roles = await deployProxy(
    ethers,
    "RolesRegistryUpgradeable",
    [],
    initialOwner
  );

  const reputationSystem = await deployProxy(
    ethers,
    "ReputationSystemUpgradeable",
    [roles.proxyAddress],
    initialOwner
  );

  const voterProgression = await deployProxy(
    ethers,
    "VoterProgressionUpgradeable",
    [roles.proxyAddress],
    initialOwner
  );

  const ideaRegistry = await deployProxy(
    ethers,
    "IdeaRegistryUpgradeable",
    [reputationSystem.proxyAddress, voterProgression.proxyAddress, roles.proxyAddress],
    initialOwner
  );

  const governanceToken = await deployProxy(
    ethers,
    "GovernanceTokenUpgradeable",
    [tokenName, tokenSymbol, maxSupply, deployer.address, roles.proxyAddress],
    initialOwner
  );

  const fundingPool = await deployProxy(
    ethers,
    "FundingPoolUpgradeable",
    [governanceToken.proxyAddress, ideaRegistry.proxyAddress, roles.proxyAddress],
    initialOwner
  );

  const votingSystem = await deployProxy(
    ethers,
    "VotingSystemUpgradeable",
    [
      fundingPool.proxyAddress,
      ideaRegistry.proxyAddress,
      reputationSystem.proxyAddress,
      voterProgression.proxyAddress,
      roles.proxyAddress,
    ],
    initialOwner
  );

  const grantManager = await deployProxy(
    ethers,
    "GrantManagerUpgradeable",
    [
      votingSystem.proxyAddress,
      fundingPool.proxyAddress,
      ideaRegistry.proxyAddress,
      roles.proxyAddress,
    ],
    initialOwner
  );

  console.log("\n2) Assigning system roles...");
  const rolesContract = await ethers.getContractAt(
    "RolesRegistryUpgradeable",
    roles.proxyAddress,
    deployer
  );

  const VOTING_ROLE = await rolesContract.VOTING_ROLE();
  const GRANT_ROLE = await rolesContract.GRANT_ROLE();
  const DISTRIBUTOR_ROLE = await rolesContract.DISTRIBUTOR_ROLE();
  const IREGISTRY_ROLE = await rolesContract.IREGISTRY_ROLE();
  const REPUTATION_MANAGER_ROLE = await rolesContract.REPUTATION_MANAGER_ROLE();
  const AUTO_GRANT_ROLE = await rolesContract.AUTO_GRANT_ROLE();

  await rolesContract.grantSystemRole(VOTING_ROLE, votingSystem.proxyAddress);
  await rolesContract.grantSystemRole(GRANT_ROLE, grantManager.proxyAddress);
  await rolesContract.grantSystemRole(
    DISTRIBUTOR_ROLE,
    grantManager.proxyAddress
  );
  await rolesContract.grantSystemRole(
    IREGISTRY_ROLE,
    ideaRegistry.proxyAddress
  );
  await rolesContract.grantSystemRole(
    REPUTATION_MANAGER_ROLE,
    votingSystem.proxyAddress
  );
  await rolesContract.grantSystemRole(
    REPUTATION_MANAGER_ROLE,
    ideaRegistry.proxyAddress
  );
  await rolesContract.grantRole(AUTO_GRANT_ROLE, voterProgression.proxyAddress);

  console.log("✅ Roles configured");

  console.log("\n3) Unpausing system contracts...");
  const fundingPoolContract = await ethers.getContractAt(
    "FundingPoolUpgradeable",
    fundingPool.proxyAddress,
    deployer
  );
  const votingSystemContract = await ethers.getContractAt(
    "VotingSystemUpgradeable",
    votingSystem.proxyAddress,
    deployer
  );
  const grantManagerContract = await ethers.getContractAt(
    "GrantManagerUpgradeable",
    grantManager.proxyAddress,
    deployer
  );

  await fundingPoolContract.unpause();
  await votingSystemContract.unpause();
  await grantManagerContract.unpause();

  console.log("✅ System unpaused");

  console.log("\nDeployment summary:");
  console.log("RolesRegistryUpgradeable:", roles.proxyAddress);
  console.log("ReputationSystemUpgradeable:", reputationSystem.proxyAddress);
  console.log("VoterProgressionUpgradeable:", voterProgression.proxyAddress);
  console.log("IdeaRegistryUpgradeable:", ideaRegistry.proxyAddress);
  console.log("GovernanceTokenUpgradeable:", governanceToken.proxyAddress);
  console.log("FundingPoolUpgradeable:", fundingPool.proxyAddress);
  console.log("VotingSystemUpgradeable:", votingSystem.proxyAddress);
  console.log("GrantManagerUpgradeable:", grantManager.proxyAddress);

  console.log("\nProxyAdmin per proxy:");
  console.log("RolesRegistryUpgradeable:", roles.proxyAdminAddress);
  console.log("ReputationSystemUpgradeable:", reputationSystem.proxyAdminAddress);
  console.log("VoterProgressionUpgradeable:", voterProgression.proxyAdminAddress);
  console.log("IdeaRegistryUpgradeable:", ideaRegistry.proxyAdminAddress);
  console.log("GovernanceTokenUpgradeable:", governanceToken.proxyAdminAddress);
  console.log("FundingPoolUpgradeable:", fundingPool.proxyAdminAddress);
  console.log("VotingSystemUpgradeable:", votingSystem.proxyAdminAddress);
  console.log("GrantManagerUpgradeable:", grantManager.proxyAdminAddress);

  console.log("\nImplementations:");
  console.log("RolesRegistryUpgradeable:", roles.implAddress);
  console.log("ReputationSystemUpgradeable:", reputationSystem.implAddress);
  console.log("VoterProgressionUpgradeable:", voterProgression.implAddress);
  console.log("IdeaRegistryUpgradeable:", ideaRegistry.implAddress);
  console.log("GovernanceTokenUpgradeable:", governanceToken.implAddress);
  console.log("FundingPoolUpgradeable:", fundingPool.implAddress);
  console.log("VotingSystemUpgradeable:", votingSystem.implAddress);
  console.log("GrantManagerUpgradeable:", grantManager.implAddress);

  console.log("\n🎉 Deployment complete");
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});

// npx tsx scripts/upgrade-proxy.ts \
//   --proxyAdmin 0x5FbDB2315678afecb367f032d93F642f64180aa3 \
//   --proxy 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0 \
//   --impl VotingSystemV2 \
//   --network localhost
