/**
 * @file helpers.ts
 * @notice Shared deployment and helper utilities for tests.
 * @dev NatSpec-style comment for test documentation.
 */

import { createRequire } from "module";
import {
  hre,
  type HardhatEthers,
  type NetworkHelpers,
} from "./setup.js";

const require = createRequire(import.meta.url);
const proxyArtifact = require(
  "@openzeppelin/contracts/build/contracts/ERC1967Proxy.json"
);

export type Connection = {
  ethers: HardhatEthers;
  networkHelpers: NetworkHelpers;
};

export async function getConnection(): Promise<Connection> {
  const connection = await hre.network.connect();
  const { ethers, networkHelpers } = connection;
  return { ethers, networkHelpers };
}

// Manual deployment: implementation + ERC1967Proxy without any upgrades plugin.
export async function deployUpgradeable(
  ethers: HardhatEthers,
  signer: any,
  name: string,
  initArgs: any[]
): Promise<any> {
  const implFactory = await ethers.getContractFactory(name, signer);
  const impl = await implFactory.deploy();
  await impl.waitForDeployment();

  const initData = implFactory.interface.encodeFunctionData(
    "initialize",
    initArgs
  );

  const proxyFactory = new ethers.ContractFactory(
    proxyArtifact.abi,
    proxyArtifact.bytecode,
    signer
  );
  const proxy = await proxyFactory.deploy(await impl.getAddress(), initData);
  await proxy.waitForDeployment();

  return (await ethers.getContractAt(name, await proxy.getAddress(), signer)) as any;
}

export async function deploySystem(): Promise<any> {
  const { ethers, networkHelpers } = await getConnection();
  const signers = await ethers.getSigners();
  const [admin, user1, user2, user3, user4, user5] = signers;

  const roles = await deployUpgradeable(
    ethers,
    admin,
    "RolesRegistryUpgradeable",
    []
  );

  const reputationSystem = await deployUpgradeable(
    ethers,
    admin,
    "ReputationSystemUpgradeable",
    [await roles.getAddress()]
  );

  const voterProgression = await deployUpgradeable(
    ethers,
    admin,
    "VoterProgressionUpgradeable",
    [await roles.getAddress()]
  );

  const ideaRegistry = await deployUpgradeable(
    ethers,
    admin,
    "IdeaRegistryUpgradeable",
    [
      await reputationSystem.getAddress(),
      await voterProgression.getAddress(),
      await roles.getAddress(),
    ]
  );

  const governanceToken = await deployUpgradeable(
    ethers,
    admin,
    "GovernanceTokenUpgradeable",
    [
      "GovToken",
      "GOV",
      ethers.parseEther("1000000"),
      admin.address,
      await roles.getAddress(),
    ]
  );

  const fundingPool = await deployUpgradeable(
    ethers,
    admin,
    "FundingPoolUpgradeable",
    [
      await governanceToken.getAddress(),
      await ideaRegistry.getAddress(),
      await roles.getAddress(),
    ]
  );

  const votingSystem = await deployUpgradeable(
    ethers,
    admin,
    "VotingSystemUpgradeable",
    [
      await fundingPool.getAddress(),
      await ideaRegistry.getAddress(),
      await reputationSystem.getAddress(),
      await voterProgression.getAddress(),
      await roles.getAddress(),
    ]
  );

  const grantManager = await deployUpgradeable(
    ethers,
    admin,
    "GrantManagerUpgradeable",
    [
      await votingSystem.getAddress(),
      await fundingPool.getAddress(),
      await ideaRegistry.getAddress(),
      await roles.getAddress(),
    ]
  );

  const VOTING_ROLE = await roles.VOTING_ROLE();
  const GRANT_ROLE = await roles.GRANT_ROLE();
  const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
  const IREGISTRY_ROLE = await roles.IREGISTRY_ROLE();
  const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
  const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();

  await roles.grantSystemRole(VOTING_ROLE, await votingSystem.getAddress());
  await roles.grantSystemRole(GRANT_ROLE, await grantManager.getAddress());
  await roles.grantSystemRole(
    DISTRIBUTOR_ROLE,
    await grantManager.getAddress()
  );
  await roles.grantSystemRole(IREGISTRY_ROLE, await ideaRegistry.getAddress());
  await roles.grantSystemRole(
    REPUTATION_MANAGER_ROLE,
    await votingSystem.getAddress()
  );
  await roles.grantSystemRole(
    REPUTATION_MANAGER_ROLE,
    await ideaRegistry.getAddress()
  );

  await roles.grantRole(AUTO_GRANT_ROLE, await voterProgression.getAddress());

  return {
    ethers,
    networkHelpers,
    signers,
    admin,
    user1,
    user2,
    user3,
    user4,
    user5,
    roles,
    reputationSystem,
    voterProgression,
    ideaRegistry,
    governanceToken,
    fundingPool,
    votingSystem,
    grantManager,
  };
}

export async function createIdeas(
  ideaRegistry: any,
  author: any,
  count: number
) {
  for (let i = 0; i < count; i += 1) {
    await ideaRegistry
      .connect(author)
      .createIdea(`Idea ${i + 1}`, `Description ${i + 1}`, "");
  }
}

export async function unpauseAll(
  fundingPool: any,
  votingSystem: any,
  grantManager: any,
  admin: any
) {
  await fundingPool.connect(admin).unpause();
  await votingSystem.connect(admin).unpause();
  await grantManager.connect(admin).unpause();
}
