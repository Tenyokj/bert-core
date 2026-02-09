/**
 * @file Initializers.fully.ts
 * @notice Initializer protection and zero-address validation.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";
import { createRequire } from "module";

/** @notice describe: Upgradeable initializers */
describe("Upgradeable initializers", function () {
  /** @notice it: reverts on second initialize for all upgradeables */
  it("reverts on second initialize for all upgradeables", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    await expect(roles.initialize())
      .to.be.revertedWithCustomError(roles, "InvalidInitialization");

    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );
    await expect(reputation.initialize(await roles.getAddress()))
      .to.be.revertedWithCustomError(reputation, "InvalidInitialization");

    const voterProgression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );
    await expect(voterProgression.initialize(await roles.getAddress()))
      .to.be.revertedWithCustomError(voterProgression, "InvalidInitialization");

    const ideaRegistry = await deployUpgradeable(
      ethers,
      admin,
      "IdeaRegistryUpgradeable",
      [
        await reputation.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress(),
      ]
    );
    await expect(
      ideaRegistry.initialize(
        await reputation.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress()
      )
    ).to.be.revertedWithCustomError(ideaRegistry, "InvalidInitialization");

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
    await expect(
      governanceToken.initialize(
        "GovToken",
        "GOV",
        ethers.parseEther("1000000"),
        admin.address,
        await roles.getAddress()
      )
    ).to.be.revertedWithCustomError(governanceToken, "InvalidInitialization");

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
    await expect(
      fundingPool.initialize(
        await governanceToken.getAddress(),
        await ideaRegistry.getAddress(),
        await roles.getAddress()
      )
    ).to.be.revertedWithCustomError(fundingPool, "InvalidInitialization");

    const votingSystem = await deployUpgradeable(
      ethers,
      admin,
      "VotingSystemUpgradeable",
      [
        await fundingPool.getAddress(),
        await ideaRegistry.getAddress(),
        await reputation.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress(),
      ]
    );
    await expect(
      votingSystem.initialize(
        await fundingPool.getAddress(),
        await ideaRegistry.getAddress(),
        await reputation.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress()
      )
    ).to.be.revertedWithCustomError(votingSystem, "InvalidInitialization");

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
    await expect(
      grantManager.initialize(
        await votingSystem.getAddress(),
        await fundingPool.getAddress(),
        await ideaRegistry.getAddress(),
        await roles.getAddress()
      )
    ).to.be.revertedWithCustomError(grantManager, "InvalidInitialization");
  });
});

const require = createRequire(import.meta.url);
const proxyArtifact = require(
  "@openzeppelin/contracts/build/contracts/ERC1967Proxy.json"
);

async function deployProxyExpectZeroAddress(
  name: string,
  initArgs: any[],
  errorContract: any
) {
  const { ethers } = await getConnection();
  const [admin] = await ethers.getSigners();

  const implFactory = await ethers.getContractFactory(name, admin);
  const impl = await implFactory.deploy();
  await impl.waitForDeployment();

  const initData = implFactory.interface.encodeFunctionData("initialize", initArgs);
  const proxyFactory = new ethers.ContractFactory(
    proxyArtifact.abi,
    proxyArtifact.bytecode,
    admin
  );

  await expect(
    proxyFactory.deploy(await impl.getAddress(), initData)
  ).to.be.revertedWithCustomError(errorContract, "ZeroAddress");
}

/** @notice describe: Zero address initializers */
describe("Zero address initializers", function () {
  /** @notice it: rejects zero rolesRegistry across core contracts */
  it("rejects zero rolesRegistry across core contracts", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await (await ethers.getContractFactory("RolesRegistryUpgradeable", admin)).deploy();
    await roles.waitForDeployment();

    await deployProxyExpectZeroAddress(
      "FundingPoolUpgradeable",
      [ethers.ZeroAddress, ethers.ZeroAddress, ethers.ZeroAddress],
      roles
    );

    await deployProxyExpectZeroAddress(
      "IdeaRegistryUpgradeable",
      [ethers.ZeroAddress, ethers.ZeroAddress, ethers.ZeroAddress],
      roles
    );

    await deployProxyExpectZeroAddress(
      "VotingSystemUpgradeable",
      [
        ethers.ZeroAddress,
        ethers.ZeroAddress,
        ethers.ZeroAddress,
        ethers.ZeroAddress,
        ethers.ZeroAddress,
      ],
      roles
    );

    await deployProxyExpectZeroAddress(
      "GrantManagerUpgradeable",
      [ethers.ZeroAddress, ethers.ZeroAddress, ethers.ZeroAddress, ethers.ZeroAddress],
      roles
    );

    await deployProxyExpectZeroAddress(
      "GovernanceTokenUpgradeable",
      ["Gov", "GOV", 1n, admin.address, ethers.ZeroAddress],
      roles
    );

    await deployProxyExpectZeroAddress(
      "ReputationSystemUpgradeable",
      [ethers.ZeroAddress],
      roles
    );

    await deployProxyExpectZeroAddress(
      "VoterProgressionUpgradeable",
      [ethers.ZeroAddress],
      roles
    );
  });

  /** @notice it: rejects zero dependency addresses on initialize */
  it("rejects zero dependency addresses on initialize", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await (await ethers.getContractFactory("RolesRegistryUpgradeable", admin)).deploy();
    await roles.waitForDeployment();

    await deployProxyExpectZeroAddress(
      "FundingPoolUpgradeable",
      [ethers.ZeroAddress, await roles.getAddress(), await roles.getAddress()],
      roles
    );

    await deployProxyExpectZeroAddress(
      "FundingPoolUpgradeable",
      [await roles.getAddress(), ethers.ZeroAddress, await roles.getAddress()],
      roles
    );

    await deployProxyExpectZeroAddress(
      "IdeaRegistryUpgradeable",
      [ethers.ZeroAddress, await roles.getAddress(), await roles.getAddress()],
      roles
    );

    await deployProxyExpectZeroAddress(
      "IdeaRegistryUpgradeable",
      [await roles.getAddress(), ethers.ZeroAddress, await roles.getAddress()],
      roles
    );

    await deployProxyExpectZeroAddress(
      "VotingSystemUpgradeable",
      [
        ethers.ZeroAddress,
        await roles.getAddress(),
        await roles.getAddress(),
        await roles.getAddress(),
        await roles.getAddress(),
      ],
      roles
    );

    await deployProxyExpectZeroAddress(
      "VotingSystemUpgradeable",
      [
        await roles.getAddress(),
        ethers.ZeroAddress,
        await roles.getAddress(),
        await roles.getAddress(),
        await roles.getAddress(),
      ],
      roles
    );

    await deployProxyExpectZeroAddress(
      "VotingSystemUpgradeable",
      [
        await roles.getAddress(),
        await roles.getAddress(),
        ethers.ZeroAddress,
        await roles.getAddress(),
        await roles.getAddress(),
      ],
      roles
    );

    await deployProxyExpectZeroAddress(
      "VotingSystemUpgradeable",
      [
        await roles.getAddress(),
        await roles.getAddress(),
        await roles.getAddress(),
        ethers.ZeroAddress,
        await roles.getAddress(),
      ],
      roles
    );

    await deployProxyExpectZeroAddress(
      "GrantManagerUpgradeable",
      [ethers.ZeroAddress, await roles.getAddress(), await roles.getAddress(), await roles.getAddress()],
      roles
    );

    await deployProxyExpectZeroAddress(
      "GrantManagerUpgradeable",
      [await roles.getAddress(), ethers.ZeroAddress, await roles.getAddress(), await roles.getAddress()],
      roles
    );

    await deployProxyExpectZeroAddress(
      "GrantManagerUpgradeable",
      [await roles.getAddress(), await roles.getAddress(), ethers.ZeroAddress, await roles.getAddress()],
      roles
    );
  });
});
