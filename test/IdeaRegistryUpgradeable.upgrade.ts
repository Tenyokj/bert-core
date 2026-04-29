/**
 * @file IdeaRegistryUpgradeable.upgrade.ts
 * @notice Contract Upgrade
 * @dev NatSpec-style comment for test documentation.
 */
import { createRequire } from "module";
import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";

const require = createRequire(import.meta.url);
const proxyAdminArtifact = require(
  "@openzeppelin/contracts/build/contracts/ProxyAdmin.json"
);
const transparentProxyArtifact = require(
  "@openzeppelin/contracts/build/contracts/TransparentUpgradeableProxy.json"
);

function getAdminSlot(ethers: any) {
  const adminSlot =
    BigInt(ethers.keccak256(ethers.toUtf8Bytes("eip1967.proxy.admin"))) - 1n;
  return ethers.toBeHex(adminSlot, 32);
}

describe("IdeaRegistryUpgradeable upgrade safety", function () {
  it("preserves legacy ideas when upgrading from the pre-stake layout", async function () {
    const { ethers } = await getConnection();
    const [admin, user1] = await ethers.getSigners();

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

    const legacyFactory = await ethers.getContractFactory(
      "IdeaRegistryUpgradeableV1",
      admin
    );
    const legacyImpl = await legacyFactory.deploy();
    await legacyImpl.waitForDeployment();

    const initData = legacyFactory.interface.encodeFunctionData("initialize", [
      await reputationSystem.getAddress(),
      await voterProgression.getAddress(),
      await roles.getAddress(),
    ]);

    const proxyFactory = new ethers.ContractFactory(
      transparentProxyArtifact.abi,
      transparentProxyArtifact.bytecode,
      admin
    );
    const proxy = await proxyFactory.deploy(
      await legacyImpl.getAddress(),
      admin.address,
      initData
    );
    await proxy.waitForDeployment();
    const proxyAddress = await proxy.getAddress();

    const legacyRegistry = await ethers.getContractAt(
      "IdeaRegistryUpgradeableV1",
      proxyAddress,
      admin
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    const IREGISTRY_ROLE = await roles.IREGISTRY_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, proxyAddress);
    await roles.grantSystemRole(IREGISTRY_ROLE, proxyAddress);

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
        proxyAddress,
        await roles.getAddress(),
      ]
    );

    await fundingPool.connect(admin).unpause();
    await governanceToken.mint(user1.address, 100000n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), ethers.MaxUint256);

    await legacyRegistry
      .connect(user1)
      .createIdea("Legacy idea", "Stored before upgrade", "https://legacy.example");

    expect(await legacyRegistry.totalIdeas()).to.equal(1n);
    const legacyIdea = await legacyRegistry.getIdea(1n);
    expect(legacyIdea.title).to.equal("Legacy idea");
    expect(legacyIdea.author).to.equal(user1.address);

    const adminStorage = await ethers.provider.getStorage(
      proxyAddress,
      getAdminSlot(ethers)
    );
    const proxyAdminAddress = ethers.getAddress(ethers.dataSlice(adminStorage, 12));
    const proxyAdmin = new ethers.Contract(
      proxyAdminAddress,
      proxyAdminArtifact.abi,
      admin
    );

    const currentFactory = await ethers.getContractFactory(
      "IdeaRegistryUpgradeable",
      admin
    );
    const currentImpl = await currentFactory.deploy();
    await currentImpl.waitForDeployment();

    const upgradeCall = currentFactory.interface.encodeFunctionData(
      "initializeV2",
      [await fundingPool.getAddress(), 1n]
    );

    await proxyAdmin.upgradeAndCall(
      proxyAddress,
      await currentImpl.getAddress(),
      upgradeCall
    );

    const upgradedRegistry = await ethers.getContractAt(
      "IdeaRegistryUpgradeable",
      proxyAddress,
      admin
    );

    expect(await upgradedRegistry.totalIdeas()).to.equal(1n);
    expect(await upgradedRegistry.fundingPool()).to.equal(
      await fundingPool.getAddress()
    );
    expect(await upgradedRegistry.authorMinStake()).to.equal(1n);

    const upgradedIdea = await upgradedRegistry.getIdea(1n);
    expect(upgradedIdea.title).to.equal("Legacy idea");
    expect(upgradedIdea.author).to.equal(user1.address);

    await expect(
      upgradedRegistry
        .connect(user1)
        .createIdea("Post-upgrade idea", "Uses the new stake flow", "", 1n)
    )
      .to.emit(upgradedRegistry, "IdeaCreated")
      .withArgs(2n, user1.address, "Post-upgrade idea");

    expect(await upgradedRegistry.totalIdeas()).to.equal(2n);
    const secondIdea = await upgradedRegistry.getIdea(2n);
    expect(secondIdea.title).to.equal("Post-upgrade idea");
  });
});
