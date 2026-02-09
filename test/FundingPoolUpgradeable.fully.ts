/**
 * @file FundingPoolUpgradeable.fully.ts
 * @notice Deposits, distributions, reserves, and admin controls.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deploySystem } from "./helpers.js";

/** @notice describe: FundingPoolUpgradeable */
describe("FundingPoolUpgradeable", function () {
  /** @notice it: handles deposits and pause logic */
  it("handles deposits and pause logic", async function () {
    const { admin, user1, fundingPool, governanceToken } = await deploySystem();

    await governanceToken.mint(user1.address, 1000n);
    await governanceToken.connect(user1).approve(await fundingPool.getAddress(), 1000n);

    await expect(fundingPool.connect(user1).deposit(100n))
      .to.be.revertedWithCustomError(fundingPool, "EnforcedPause");

    await fundingPool.connect(admin).unpause();

    await expect(fundingPool.connect(user1).deposit(0))
      .to.be.revertedWithCustomError(fundingPool, "ZeroAmount");

    await expect(fundingPool.connect(user1).deposit(100n))
      .to.emit(fundingPool, "FundsDeposited")
      .withArgs(user1.address, 100n);

    expect(await fundingPool.totalPoolBalance()).to.equal(100n);
  });

  /** @notice it: allows voting system deposits for ideas */
  it("allows voting system deposits for ideas", async function () {
    const { admin, user1, roles, fundingPool, governanceToken } =
      await deploySystem();

    await governanceToken.mint(user1.address, 500n);
    await governanceToken.connect(user1).approve(await fundingPool.getAddress(), 500n);
    await fundingPool.connect(admin).unpause();

    await expect(
      fundingPool.depositForIdeaFrom(user1.address, 1, 1, 100n)
    ).to.be.revertedWithCustomError(fundingPool, "NotVotingSystem");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await fundingPool
      .connect(admin)
      .depositForIdeaFrom(user1.address, 1, 1, 100n);

    expect(await fundingPool.totalPoolBalance()).to.equal(100n);
  });

  /** @notice it: distributes funds with reserve accounting */
  it("distributes funds with reserve accounting", async function () {
    const {
      admin,
      user1,
      roles,
      fundingPool,
      governanceToken,
      ideaRegistry,
    } = await deploySystem();

    await governanceToken.mint(user1.address, 1000n);
    await governanceToken.connect(user1).approve(await fundingPool.getAddress(), 1000n);

    await fundingPool.connect(admin).unpause();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 200n);

    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 150n)
    )
      .to.emit(fundingPool, "FundsDistributed")
      .withArgs(1n, 1n, 150n);

    expect(await fundingPool.protocolReserve()).to.equal(50n);
    expect(await fundingPool.totalPoolBalance()).to.equal(50n);

    await fundingPool.connect(admin).syncBalance();
    expect(await fundingPool.totalPoolBalance()).to.equal(0n);
  });

  /** @notice it: validates pool queries and admin functions */
  it("validates pool queries and admin functions", async function () {
    const { admin, ethers, fundingPool, governanceToken, ideaRegistry } =
      await deploySystem();

    await expect(fundingPool.isDistributed(0))
      .to.be.revertedWithCustomError(fundingPool, "InvalidId")
      .withArgs("roundId");

    await expect(fundingPool.poolByRoundAndIdea(0, 1))
      .to.be.revertedWithCustomError(fundingPool, "InvalidId")
      .withArgs("roundId");

    await expect(fundingPool.poolByRoundAndIdea(1, 0))
      .to.be.revertedWithCustomError(fundingPool, "InvalidId")
      .withArgs("ideaId");

    await expect(
      fundingPool.setGovernanceToken(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(fundingPool, "ZeroAddress");

    await expect(
      fundingPool.setIdeaRegistry(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(fundingPool, "ZeroAddress");

    await expect(
      fundingPool.allocateReserveToIdea(1, 1, 10)
    ).to.be.revertedWithCustomError(fundingPool, "InsufficientPoolBalance");

    await fundingPool.setGovernanceToken(await governanceToken.getAddress());
    await fundingPool.setIdeaRegistry(await ideaRegistry.getAddress());

    await fundingPool.connect(admin).unpause();
    await fundingPool.connect(admin).pause();
    expect(await fundingPool.isPaused()).to.equal(true);
  });
});

/** @notice describe: FundingPoolUpgradeable edge cases */
describe("FundingPoolUpgradeable edge cases", function () {
  /** @notice it: validates depositForIdeaFrom inputs */
  it("validates depositForIdeaFrom inputs", async function () {
    const { ethers, admin, roles, fundingPool, governanceToken, user1 } =
      await deploySystem();

    await fundingPool.connect(admin).unpause();
    await governanceToken.mint(user1.address, 1000n);
    await governanceToken.connect(user1).approve(await fundingPool.getAddress(), 1000n);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await expect(
      fundingPool.connect(admin).depositForIdeaFrom(ethers.ZeroAddress, 1, 1, 1)
    ).to.be.revertedWithCustomError(fundingPool, "ZeroAddress");

    await expect(
      fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 0, 1)
    ).to.be.revertedWithCustomError(fundingPool, "InvalidId");

    await expect(
      fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 0)
    ).to.be.revertedWithCustomError(fundingPool, "ZeroAmount");
  });

  /** @notice it: rejects double distribution and insufficient idea balance */
  it("rejects double distribution and insufficient idea balance", async function () {
    const {
      admin,
      user1,
      roles,
      fundingPool,
      governanceToken,
      ideaRegistry,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    await governanceToken.mint(user1.address, 500n);
    await governanceToken.connect(user1).approve(await fundingPool.getAddress(), 500n);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 200n);

    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 300n)
    ).to.be.revertedWithCustomError(fundingPool, "InsufficientIdeaBalance");

    await fundingPool.connect(admin).distributeFunds(1, 1, 150n);

    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 10n)
    ).to.be.revertedWithCustomError(fundingPool, "AlreadyDistributed");
  });

  /** @notice it: validates reserve allocation inputs */
  it("validates reserve allocation inputs", async function () {
    const { admin, fundingPool } = await deploySystem();

    await expect(
      fundingPool.allocateReserveToIdea(0, 1, 1)
    ).to.be.revertedWithCustomError(fundingPool, "InvalidId");

    await expect(
      fundingPool.allocateReserveToIdea(1, 0, 1)
    ).to.be.revertedWithCustomError(fundingPool, "InvalidId");

    await expect(
      fundingPool.allocateReserveToIdea(1, 1, 0)
    ).to.be.revertedWithCustomError(fundingPool, "ZeroAmount");
  });
});

/** @notice describe: FundingPoolUpgradeable extra coverage */
describe("FundingPoolUpgradeable extra coverage", function () {
  /** @notice it: rejects distributeFunds when paused or non-distributor */
  it("rejects distributeFunds when paused or non-distributor", async function () {
    const {
      admin,
      user1,
      roles,
      fundingPool,
      governanceToken,
      ideaRegistry,
    } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");
    await governanceToken.mint(user1.address, 200n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), 200n);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await fundingPool.connect(admin).unpause();
    await fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 200n);

    await expect(
      fundingPool.connect(user1).distributeFunds(1, 1, 100n)
    ).to.be.revertedWithCustomError(fundingPool, "NotDistributor");

    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await fundingPool.connect(admin).pause();
    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 100n)
    ).to.be.revertedWithCustomError(fundingPool, "EnforcedPause");
  });

  /** @notice it: validates distributeFunds zero amount and records distributions */
  it("validates distributeFunds zero amount and records distributions", async function () {
    const {
      admin,
      user1,
      roles,
      fundingPool,
      governanceToken,
      ideaRegistry,
    } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");
    await governanceToken.mint(user1.address, 200n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), 200n);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await fundingPool.connect(admin).unpause();
    await fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 200n);

    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 0)
    ).to.be.revertedWithCustomError(fundingPool, "ZeroAmount");

    await fundingPool.connect(admin).distributeFunds(1, 1, 150n);

    expect(await fundingPool.getDistributionCount()).to.equal(1n);
    const dist = await fundingPool.getDistribution(0);
    expect(dist[0]).to.equal(1n);
    expect(dist[1]).to.equal(1n);
    expect(dist[2]).to.equal(150n);

    await expect(fundingPool.getDistribution(1))
      .to.be.revertedWithCustomError(fundingPool, "IndexOutOfBounds");
  });

  /** @notice it: allocates protocol reserve to idea */
  it("allocates protocol reserve to idea", async function () {
    const {
      admin,
      user1,
      roles,
      fundingPool,
      governanceToken,
      ideaRegistry,
    } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");
    await governanceToken.mint(user1.address, 200n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), 200n);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await fundingPool.connect(admin).unpause();
    await fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 200n);
    await fundingPool.connect(admin).distributeFunds(1, 1, 150n);

    expect(await fundingPool.protocolReserve()).to.equal(50n);

    await fundingPool.allocateReserveToIdea(2, 2, 50n);
    expect(await fundingPool.poolByRoundAndIdea(2, 2)).to.equal(50n);
  });

  /** @notice it: enforces admin-only functions */
  it("enforces admin-only functions", async function () {
    const { user1, fundingPool, governanceToken, ideaRegistry } =
      await deploySystem();

    await expect(
      fundingPool.connect(user1).setGovernanceToken(await governanceToken.getAddress())
    ).to.be.revertedWithCustomError(fundingPool, "NotAdmin");

    await expect(
      fundingPool.connect(user1).setIdeaRegistry(await ideaRegistry.getAddress())
    ).to.be.revertedWithCustomError(fundingPool, "NotAdmin");

    await expect(
      fundingPool.connect(user1).syncBalance()
    ).to.be.revertedWithCustomError(fundingPool, "NotAdmin");

    await expect(
      fundingPool.connect(user1).pause()
    ).to.be.revertedWithCustomError(fundingPool, "NotAdmin");

    await expect(
      fundingPool.connect(user1).unpause()
    ).to.be.revertedWithCustomError(fundingPool, "NotAdmin");
  });

  /** @notice it: rejects depositForIdeaFrom when paused */
  it("rejects depositForIdeaFrom when paused", async function () {
    const { admin, user1, roles, fundingPool, governanceToken } =
      await deploySystem();

    await governanceToken.mint(user1.address, 100n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), 100n);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await expect(
      fundingPool.connect(admin).depositForIdeaFrom(user1.address, 1, 1, 10n)
    ).to.be.revertedWithCustomError(fundingPool, "EnforcedPause");
  });

  /** @notice it: reverts on invalid author during distribution */
  it("reverts on invalid author during distribution", async function () {
    const { admin, roles, fundingPool, governanceToken, ethers } =
      await deploySystem();

    const mockIdeaRegistry = await ethers.deployContract(
      "MockIdeaRegistryAuthorZero",
      []
    );
    await mockIdeaRegistry.waitForDeployment();

    await fundingPool.setIdeaRegistry(await mockIdeaRegistry.getAddress());

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await fundingPool.connect(admin).unpause();

    await governanceToken.mint(admin.address, 200n);
    await governanceToken
      .connect(admin)
      .approve(await fundingPool.getAddress(), 200n);

    await fundingPool
      .connect(admin)
      .depositForIdeaFrom(admin.address, 1, 1, 200n);

    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 100n)
    ).to.be.revertedWithCustomError(fundingPool, "InvalidAuthor");
  });
});
