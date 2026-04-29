/**
 * @file GrantManagerUpgradeable.fully.ts
 * @notice GrantManager grant-claim lifecycle, access control, and edge cases.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deploySystem, createIdeas, deployUpgradeable } from "./helpers.js";

/** @notice describe: GrantManagerUpgradeable */
describe("GrantManagerUpgradeable", function () {
  /** @notice it: calculates distributions and validates share updates */
  it("calculates distributions and validates share updates", async function () {
    const { admin, grantManager } = await deploySystem();

    const protocolShare = await grantManager.getProtocolShare();
    expect(protocolShare).to.equal(5n);

    await expect(grantManager.setAuthorShare(101))
      .to.be.revertedWithCustomError(grantManager, "InvalidShare")
      .withArgs(101n, 100n);

    await expect(grantManager.setAuthorShare(90))
      .to.emit(grantManager, "FeeUpdated")
      .withArgs(90n, 10n);

    expect(await grantManager.authorSharePercent()).to.equal(90n);
  });

  /** @notice it: claims grant for winning idea and updates state */
  it("claims grant for winning idea and updates state", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const totalAllocated = await fundingPool.poolByRoundAndIdea(1, 1);
    const expectedAuthor = (totalAllocated * 95n) / 100n;
    const expectedInitialPayout = (expectedAuthor * 30n) / 100n;

    await expect(grantManager.connect(user1).claimGrant(1))
      .to.emit(grantManager, "RoundFunded")
      .withArgs(1n, 1n, expectedInitialPayout);

    const idea = await ideaRegistry.getIdea(1);
    expect(idea[7]).to.equal(3n);
  });

  /** @notice it: rejects claim when conditions are unmet */
  it("rejects claim when conditions are unmet", async function () {
    const { admin, grantManager, votingSystem } = await deploySystem();

    await grantManager.connect(admin).unpause();

    await expect(grantManager.claimGrant(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundDoesNotExist");
  });
});

/** @notice describe: GrantManagerUpgradeable edge cases */
describe("GrantManagerUpgradeable edge cases", function () {
  /** @notice it: rejects claim when paused */
  it("rejects claim when paused", async function () {
    const { grantManager } = await deploySystem();

    await expect(grantManager.claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "EnforcedPause");
  });

  /** @notice it: rejects claim when round not ended */
  it("rejects claim when round not ended", async function () {
    const {
      admin,
      ideaRegistry,
      votingSystem,
      fundingPool,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    await expect(grantManager.claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "RoundNotEnded");
  });

  /** @notice it: rejects claim when no winner */
  it("rejects claim when no winner", async function () {
    const {
      admin,
      ideaRegistry,
      votingSystem,
      fundingPool,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await expect(grantManager.claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "NoWinner");
  });

  /** @notice it: rejects claim when not author */
  it("rejects claim when not author", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await expect(grantManager.connect(user2).claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "NotAuthor");
  });
});

/** @notice describe: GrantManagerUpgradeable extra coverage */
describe("GrantManagerUpgradeable extra coverage", function () {
  /** @notice it: rejects claim when already distributed */
  it("rejects claim when already distributed", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await grantManager.connect(user1).claimGrant(1);

    await expect(grantManager.connect(user1).claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "AlreadyDistributed")
      .withArgs(1n);
  });

  /** @notice it: rejects claim when idea not in WonVoting status */
  it("rejects claim when idea not in WonVoting status", async function () {
    const {
      admin,
      user1,
      user2,
      roles,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const GRANT_ROLE = await roles.GRANT_ROLE();
    await roles.grantSystemRole(GRANT_ROLE, admin.address);
    await ideaRegistry.connect(admin).updateStatus(1, 3);

    await expect(grantManager.connect(user1).claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "IdeaNotEligible");
  });

  /** @notice it: rejects claim when no funds allocated */
  it("rejects claim when no funds allocated", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
      ethers,
      roles,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const newPool = await deployUpgradeable(ethers, admin, "FundingPoolUpgradeable", [
      await governanceToken.getAddress(),
      await ideaRegistry.getAddress(),
      await roles.getAddress(),
    ]);

    await grantManager.setFundingPool(await newPool.getAddress());

    await expect(grantManager.connect(user1).claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "NoFundsAllocated");
  });

  /** @notice it: reports canClaimGrant and calculateDistribution */
  it("reports canClaimGrant and calculateDistribution", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const canClaim = await grantManager.canClaimGrant(1);
    expect(canClaim[0]).to.equal(true);

    const calc = await grantManager.calculateDistribution(1, 1);
    expect(calc[2]).to.equal(await fundingPool.poolByRoundAndIdea(1, 1));
  });

  /** @notice it: covers canClaimGrant failure reasons */
  it("covers canClaimGrant failure reasons", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    let res = await grantManager.canClaimGrant(1);
    expect(res[0]).to.equal(false);
    expect(res[1]).to.equal("Round not ended");

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    res = await grantManager.canClaimGrant(1);
    expect(res[0]).to.equal(false);
    expect(res[1]).to.equal("No winner for this round");
  });

  /** @notice it: covers canClaimGrant invalid author address via mock registry */
  it("covers canClaimGrant invalid author address via mock registry", async function () {
    const {
      admin,
      user1,
      user2,
      votingSystem,
      fundingPool,
      grantManager,
      governanceToken,
      ethers,
      networkHelpers,
      ideaRegistry,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const mockRegistry = await ethers.deployContract(
      "MockIdeaRegistryAuthorZero",
      []
    );
    await mockRegistry.waitForDeployment();
    await mockRegistry.setStatus(2);
    await mockRegistry.setAuthor(ethers.ZeroAddress);

    await grantManager.setIdeaRegistry(await mockRegistry.getAddress());

    const res = await grantManager.canClaimGrant(1);
    expect(res[0]).to.equal(false);
    expect(res[1]).to.equal("Invalid author address");
  });

  /** @notice it: covers canClaimGrant idea not in WonVoting status */
  it("covers canClaimGrant idea not in WonVoting status", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
      ethers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const mockRegistry = await ethers.deployContract(
      "MockIdeaRegistryAuthorZero",
      []
    );
    await mockRegistry.waitForDeployment();
    await mockRegistry.setStatus(4);
    await mockRegistry.setAuthor(user1.address);

    await grantManager.setIdeaRegistry(await mockRegistry.getAddress());

    const res = await grantManager.canClaimGrant(1);
    expect(res[0]).to.equal(false);
    expect(res[1]).to.equal("Idea not in WonVoting status");
  });

  /** @notice it: covers canClaimGrant no funds allocated */
  it("covers canClaimGrant no funds allocated", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
      ethers,
      roles,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const mockRegistry = await ethers.deployContract(
      "MockIdeaRegistryAuthorZero",
      []
    );
    await mockRegistry.waitForDeployment();
    await mockRegistry.setStatus(2);
    await mockRegistry.setAuthor(user1.address);

    const newPool = await deployUpgradeable(ethers, admin, "FundingPoolUpgradeable", [
      await governanceToken.getAddress(),
      await mockRegistry.getAddress(),
      await roles.getAddress(),
    ]);

    await grantManager.setIdeaRegistry(await mockRegistry.getAddress());
    await grantManager.setFundingPool(await newPool.getAddress());

    const res = await grantManager.canClaimGrant(1);
    expect(res[0]).to.equal(false);
    expect(res[1]).to.equal("No funds allocated to this idea");
  });

  /** @notice it: rejects claim when author address is zero */
  it("rejects claim when author address is zero", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
      ethers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const mockRegistry = await ethers.deployContract(
      "MockIdeaRegistryAuthorZero",
      []
    );
    await mockRegistry.waitForDeployment();
    await mockRegistry.setStatus(2);
    await mockRegistry.setAuthor(ethers.ZeroAddress);
    await grantManager.setIdeaRegistry(await mockRegistry.getAddress());

    await expect(grantManager.connect(user1).claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "InvalidAuthor");
  });

  /** @notice it: enforces admin-only setters and zero address checks */
  it("enforces admin-only setters and zero address checks", async function () {
    const { user1, ethers, grantManager, fundingPool, ideaRegistry, votingSystem } =
      await deploySystem();

    await expect(
      grantManager.connect(user1).setFundingPool(await fundingPool.getAddress())
    ).to.be.revertedWithCustomError(grantManager, "NotAdmin");

    await expect(
      grantManager.setFundingPool(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(grantManager, "ZeroAddress");

    await expect(
      grantManager.connect(user1).setIdeaRegistry(await ideaRegistry.getAddress())
    ).to.be.revertedWithCustomError(grantManager, "NotAdmin");

    await expect(
      grantManager.setIdeaRegistry(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(grantManager, "ZeroAddress");

    await expect(
      grantManager.connect(user1).setVotingSystem(await votingSystem.getAddress())
    ).to.be.revertedWithCustomError(grantManager, "NotAdmin");

    await expect(
      grantManager.setVotingSystem(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(grantManager, "ZeroAddress");

    await expect(
      grantManager.connect(user1).pause()
    ).to.be.revertedWithCustomError(grantManager, "NotAdmin");

    await expect(
      grantManager.connect(user1).unpause()
    ).to.be.revertedWithCustomError(grantManager, "NotAdmin");
  });

  /** @notice it: updates voting system and pause state through admin functions */
  it("updates voting system and pause state through admin functions", async function () {
    const { grantManager, votingSystem } = await deploySystem();

    await expect(grantManager.setVotingSystem(await votingSystem.getAddress()))
      .to.emit(grantManager, "VotingSystemUpdated")
      .withArgs(await votingSystem.getAddress());

    await grantManager.unpause();
    expect(await grantManager.isPaused()).to.equal(false);

    await grantManager.pause();
    expect(await grantManager.isPaused()).to.equal(true);

    await grantManager.unpause();
    expect(await grantManager.isPaused()).to.equal(false);
  });

  /** @notice it: returns round info when winner exists */
  it("returns round info when winner exists", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const info = await grantManager.getRoundInfo(1);
    expect(info[0]).to.equal(1n);
    expect(info[1]).to.equal(user1.address);
    expect(info[2]).to.equal(2);
  });

  /** @notice it: canClaimGrant reports already distributed */
  it("canClaimGrant reports already distributed", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await grantManager.connect(user1).claimGrant(1);

    const res = await grantManager.canClaimGrant(1);
    expect(res[0]).to.equal(false);
    expect(res[1]).to.equal("Grant already distributed");
  });
});

/** @notice describe: GrantManagerUpgradeable milestone payouts */
describe("GrantManagerUpgradeable milestone payouts", function () {
  async function setupMilestoneRound() {
    const context = await deploySystem();
    const {
      admin,
      user1,
      user2,
      user3,
      user4,
      user5,
      voterProgression,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = context;

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await voterProgression.grantReviewerRole(user3.address);
    await voterProgression.grantReviewerRole(user4.address);
    await voterProgression.grantReviewerRole(user5.address);

    return context;
  }

  it("releases 30/40/30 payouts across milestone approvals", async function () {
    const {
      user1,
      user3,
      user4,
      user5,
      fundingPool,
      ideaRegistry,
      grantManager,
    } = await setupMilestoneRound();

    const totalAllocated = await fundingPool.poolByRoundAndIdea(1, 1);
    const totalGrant = (totalAllocated * 95n) / 100n;
    const initialPayout = (totalGrant * 30n) / 100n;
    const inProcessPayout = (totalGrant * 40n) / 100n;
    const finalPayout = totalGrant - initialPayout - inProcessPayout;

    await grantManager.connect(user1).claimGrant(1);

    let payout = await grantManager.getGrantPayout(1);
    expect(payout[2]).to.equal(totalGrant);
    expect(payout[3]).to.equal(initialPayout);
    expect(payout[4]).to.equal(true);

    await expect(
      grantManager
        .connect(user1)
        .submitMilestoneProof(1, 1, "ipfs://demo-proof", "demo ready")
    )
      .to.emit(grantManager, "MilestoneProofSubmitted")
      .withArgs(1n, 1n, 1n, 1n);

    await grantManager.connect(user3).reviewMilestoneProof(1, 1, true);
    await grantManager.connect(user4).reviewMilestoneProof(1, 1, true);

    await expect(grantManager.connect(user5).reviewMilestoneProof(1, 1, true))
      .to.emit(grantManager, "MilestoneApproved")
      .withArgs(1n, 1n, 1n, inProcessPayout);

    expect(await ideaRegistry.getStatus(1)).to.equal(6);

    payout = await grantManager.getGrantPayout(1);
    expect(payout[3]).to.equal(initialPayout + inProcessPayout);
    expect(payout[5]).to.equal(true);

    await grantManager
      .connect(user1)
      .submitMilestoneProof(1, 2, "ipfs://final-proof", "project shipped");

    await grantManager.connect(user3).reviewMilestoneProof(1, 2, true);
    await expect(grantManager.connect(user4).reviewMilestoneProof(1, 2, true))
      .to.emit(grantManager, "MilestoneApproved")
      .withArgs(1n, 1n, 2n, finalPayout);

    expect(await ideaRegistry.getStatus(1)).to.equal(5);

    payout = await grantManager.getGrantPayout(1);
    expect(payout[3]).to.equal(totalGrant);
    expect(payout[6]).to.equal(true);
    expect(await fundingPool.isDistributed(1)).to.equal(true);
  });

  it("enforces milestone rejection cooldown before resubmission", async function () {
    const {
      user1,
      user3,
      user4,
      user5,
      grantManager,
      networkHelpers,
    } = await setupMilestoneRound();

    await grantManager.connect(user1).claimGrant(1);
    await grantManager
      .connect(user1)
      .submitMilestoneProof(1, 1, "ipfs://demo-proof", "demo ready");

    await grantManager.connect(user3).reviewMilestoneProof(1, 1, false);
    await grantManager.connect(user4).reviewMilestoneProof(1, 1, false);

    await expect(grantManager.connect(user5).reviewMilestoneProof(1, 1, false))
      .to.emit(grantManager, "MilestoneRejected")
      .withArgs(1n, 1n, 1n, 1n);

    const request = await grantManager.getMilestoneRequest(1, 1);
    expect(request[9]).to.equal(false);

    await expect(
      grantManager
        .connect(user1)
        .submitMilestoneProof(1, 1, "ipfs://retry", "retry now")
    ).to.be.revertedWithCustomError(grantManager, "MilestoneCooldownActive");

    await networkHelpers.time.increase(48 * 60 * 60 + 1);

    await expect(
      grantManager
        .connect(user1)
        .submitMilestoneProof(1, 1, "ipfs://retry", "retry later")
    )
      .to.emit(grantManager, "MilestoneProofSubmitted")
      .withArgs(1n, 1n, 1n, 2n);
  });

  it("validates milestone submission and review edge cases", async function () {
    const {
      user1,
      user2,
      user3,
      user4,
      user5,
      voterProgression,
      grantManager,
    } = await setupMilestoneRound();

    await expect(
      grantManager.connect(user1).submitMilestoneProof(1, 1, "", "demo ready")
    ).to.be.revertedWithCustomError(grantManager, "ZeroLength")
      .withArgs("metadataURI");

    await expect(
      grantManager.connect(user1).submitMilestoneProof(1, 9, "ipfs://bad", "demo ready")
    ).to.be.revertedWithCustomError(grantManager, "MilestoneNotEligible")
      .withArgs(1n, 9n);

    await grantManager.connect(user1).claimGrant(1);

    await expect(
      grantManager.connect(user2).submitMilestoneProof(1, 1, "ipfs://demo-proof", "demo ready")
    ).to.be.revertedWithCustomError(grantManager, "NotAuthor");

    await grantManager
      .connect(user1)
      .submitMilestoneProof(1, 1, "ipfs://demo-proof", "demo ready");

    await expect(
      grantManager.connect(user1).submitMilestoneProof(1, 1, "ipfs://duplicate", "duplicate")
    ).to.be.revertedWithCustomError(grantManager, "MilestoneRequestActive")
      .withArgs(1n, 1n);

    await expect(
      grantManager.connect(user1).reviewMilestoneProof(1, 1, true)
    ).to.be.revertedWithCustomError(grantManager, "NotReviewer");

    await expect(
      grantManager.connect(user3).reviewMilestoneProof(1, 2, true)
    ).to.be.revertedWithCustomError(grantManager, "NoActiveMilestoneRequest")
      .withArgs(1n, 2n);

    await voterProgression.grantReviewerRole(user1.address);
    await expect(
      grantManager.connect(user1).reviewMilestoneProof(1, 1, true)
    ).to.be.revertedWithCustomError(grantManager, "CannotReviewOwnIdea")
      .withArgs(user1.address);

    await grantManager.connect(user3).reviewMilestoneProof(1, 1, false);
    await expect(
      grantManager.connect(user3).reviewMilestoneProof(1, 1, true)
    ).to.be.revertedWithCustomError(grantManager, "MilestoneAlreadyReviewed")
      .withArgs(1n, 1n, user3.address);

    await grantManager.connect(user4).reviewMilestoneProof(1, 1, false);
    await grantManager.connect(user5).reviewMilestoneProof(1, 1, false);
  });

  it("exposes milestone getters for active and settled requests", async function () {
    const context = await deploySystem();
    const {
      admin,
      user1,
      user2,
      user3,
      user4,
      user5,
      voterProgression,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      grantManager,
      networkHelpers,
    } = context;

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await grantManager.connect(admin).unpause();

    await createIdeas(ideaRegistry, user1, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user2).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await voterProgression.grantReviewerRole(user3.address);
    await voterProgression.grantReviewerRole(user4.address);
    await voterProgression.grantReviewerRole(user5.address);

    await grantManager.connect(user1).claimGrant(1);
    await grantManager
      .connect(user1)
      .submitMilestoneProof(1, 1, "ipfs://demo-proof", "demo ready");

    const request = await grantManager.getMilestoneRequest(1, 1);
    expect(request[0]).to.equal(1n);
    expect(request[1]).to.equal("ipfs://demo-proof");
    expect(request[2]).to.equal("demo ready");
    expect(request[7]).to.equal(5n);
    expect(request[8]).to.equal(3n);
    expect(request[9]).to.equal(true);

    await grantManager.connect(user3).reviewMilestoneProof(1, 1, false);
    await grantManager.connect(user4).reviewMilestoneProof(1, 1, false);
    await grantManager.connect(user5).reviewMilestoneProof(1, 1, false);

    const payout = await grantManager.getGrantPayout(1);
    expect(payout[0]).to.equal(1n);
    expect(payout[1]).to.equal(user1.address);
    expect(payout[4]).to.equal(true);
    expect(payout[5]).to.equal(false);

    const settledRequest = await grantManager.getMilestoneRequest(1, 1);
    expect(settledRequest[5]).to.equal(0n);
    expect(settledRequest[6]).to.equal(3n);
    expect(settledRequest[9]).to.equal(false);

    const emptyStage = await grantManager.getMilestoneRequest(1, 2);
    expect(emptyStage[0]).to.equal(0n);
    expect(emptyStage[9]).to.equal(false);
  });
});
