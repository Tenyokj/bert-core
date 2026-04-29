/**
 * @file FundingPoolUpgradeable.upgrade.ts
 * @notice Contract upgrade
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

describe("FundingPoolUpgradeable upgrade safety", function () {
  it("preserves legacy balances and history when upgrading from the pre-author-stake layout", async function () {
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
    const ideaRegistry = await deployUpgradeable(
      ethers,
      admin,
      "IdeaRegistryUpgradeableV1",
      [
        await reputationSystem.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress(),
      ]
    );

    const legacyFactory = await ethers.getContractFactory(
      "FundingPoolUpgradeableV1",
      admin
    );
    const legacyImpl = await legacyFactory.deploy();
    await legacyImpl.waitForDeployment();

    const token = await deployUpgradeable(
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

    const actualInitData = legacyFactory.interface.encodeFunctionData("initialize", [
      await token.getAddress(),
      await ideaRegistry.getAddress(),
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
      actualInitData
    );
    await proxy.waitForDeployment();
    const proxyAddress = await proxy.getAddress();

    const legacyPool = await ethers.getContractAt(
      "FundingPoolUpgradeableV1",
      proxyAddress,
      admin
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    const VOTING_ROLE = await roles.VOTING_ROLE();
    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(
      REPUTATION_MANAGER_ROLE,
      await ideaRegistry.getAddress()
    );
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await legacyPool.connect(admin).unpause();
    await token.mint(user1.address, 100000n);
    await token.connect(user1).approve(proxyAddress, ethers.MaxUint256);
    await ideaRegistry
      .connect(user1)
      .createIdea("Legacy idea", "Stored before funding-pool upgrade", "");

    await legacyPool.connect(user1).deposit(100n);
    await legacyPool.connect(admin).depositForIdeaFrom(user1.address, 1n, 1n, 50n);

    expect(await legacyPool.poolByRoundAndIdea(1n, 1n)).to.equal(50n);
    expect(await legacyPool.totalPoolBalance()).to.equal(150n);

    await legacyPool.connect(admin).distributeFunds(1n, 1n, 40n);

    expect(await legacyPool.poolByRoundAndIdea(1n, 1n)).to.equal(0n);
    expect(await legacyPool.isDistributed(1n)).to.equal(true);
    expect(await legacyPool.protocolReserve()).to.equal(10n);
    expect(await legacyPool.totalPoolBalance()).to.equal(110n);
    expect(await legacyPool.getDistributionCount()).to.equal(1n);

    const legacyDistribution = await legacyPool.getDistribution(0n);
    expect(legacyDistribution.roundId).to.equal(1n);
    expect(legacyDistribution.ideaId).to.equal(1n);
    expect(legacyDistribution.amount).to.equal(40n);

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
      "FundingPoolUpgradeable",
      admin
    );
    const currentImpl = await currentFactory.deploy();
    await currentImpl.waitForDeployment();

    await proxyAdmin.upgradeAndCall(
      proxyAddress,
      await currentImpl.getAddress(),
      "0x"
    );

    const upgradedPool = await ethers.getContractAt(
      "FundingPoolUpgradeable",
      proxyAddress,
      admin
    );

    expect(await upgradedPool.poolByRoundAndIdea(1n, 1n)).to.equal(0n);
    expect(await upgradedPool.isDistributed(1n)).to.equal(true);
    expect(await upgradedPool.protocolReserve()).to.equal(10n);
    expect(await upgradedPool.totalPoolBalance()).to.equal(110n);
    expect(await upgradedPool.getDistributionCount()).to.equal(1n);

    const upgradedDistribution = await upgradedPool.getDistribution(0n);
    expect(upgradedDistribution.roundId).to.equal(1n);
    expect(upgradedDistribution.ideaId).to.equal(1n);
    expect(upgradedDistribution.amount).to.equal(40n);

    expect(await upgradedPool.authorStakeByIdea(1n)).to.equal(0n);
  });
});
