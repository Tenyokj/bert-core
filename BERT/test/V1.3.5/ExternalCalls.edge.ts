/**
 * @file ExternalCalls.edge.ts
 * @notice ExternalCallFailed paths across contracts.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "../setup.js";
import { deploySystem, createIdeas } from "./helpers.js";

/** @notice describe: External call failure paths */
describe("External call failure paths", function () {
  /** @notice it: IdeaRegistry reverts ExternalCallFailed when reputation init fails */
  it("IdeaRegistry reverts ExternalCallFailed when reputation init fails", async function () {
    const { admin, user1, ideaRegistry, roles } = await deploySystem();

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.revokeSystemRole(REPUTATION_MANAGER_ROLE, await ideaRegistry.getAddress());

    await expect(
      ideaRegistry.connect(user1).createIdea("Idea", "Desc", "")
    ).to.be.revertedWithCustomError(ideaRegistry, "ExternalCallFailed")
      .withArgs("ReputationSystem", "initializeReputation");
  });

  /** @notice it: VotingSystem vote reverts ExternalCallFailed when funding pool paused */
  it("VotingSystem vote reverts ExternalCallFailed when funding pool paused", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
    } = await deploySystem();

    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user1.address, minStake * 2n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await expect(
      votingSystem.connect(user1).vote(1, 1, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "ExternalCallFailed")
      .withArgs("FundingPool", "depositForIdeaFrom");
  });

  /** @notice it: VotingSystem endVotingRound reverts ExternalCallFailed when reputation role revoked */
  it("VotingSystem endVotingRound reverts ExternalCallFailed when reputation role revoked", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      roles,
      networkHelpers,
    } = await deploySystem();

    await votingSystem.connect(admin).unpause();
    await fundingPool.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user1.address, minStake * 2n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user1).vote(1, 1, minStake);

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.revokeSystemRole(REPUTATION_MANAGER_ROLE, await votingSystem.getAddress());

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    await expect(votingSystem.endVotingRound(1))
      .to.be.revertedWithCustomError(votingSystem, "ExternalCallFailed")
      .withArgs("ReputationSystem", "increaseReputation");
  });

  /** @notice it: VotingSystem endVotingRound reverts ExternalCallFailed when voter progression role revoked */
  it("VotingSystem endVotingRound reverts ExternalCallFailed when voter progression role revoked", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      roles,
      networkHelpers,
    } = await deploySystem();

    await votingSystem.connect(admin).unpause();
    await fundingPool.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user1.address, minStake * 2n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user1).vote(1, 1, minStake);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const GRANT_ROLE = await roles.GRANT_ROLE();
    // keep updateStatus working via GRANT_ROLE, but make registerWinningVote fail
    await roles.grantSystemRole(GRANT_ROLE, await votingSystem.getAddress());
    await roles.revokeSystemRole(VOTING_ROLE, await votingSystem.getAddress());

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    await expect(votingSystem.endVotingRound(1))
      .to.be.revertedWithCustomError(votingSystem, "ExternalCallFailed")
      .withArgs("VoterProgression", "registerWinningVote");
  });

  /** @notice it: GrantManager reverts ExternalCallFailed when funding pool paused */
  it("GrantManager reverts ExternalCallFailed when funding pool paused", async function () {
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

    await fundingPool.connect(admin).pause();

    await expect(grantManager.connect(user1).claimGrant(1))
      .to.be.revertedWithCustomError(grantManager, "ExternalCallFailed")
      .withArgs("FundingPool", "distributeFunds");
  });
});
