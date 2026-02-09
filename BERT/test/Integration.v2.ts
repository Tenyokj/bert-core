/**
 * @file Integration.v2.ts
 * @notice End-to-end DAO grant lifecycle integration test.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deploySystem, createIdeas } from "./helpers.js";

/** @notice describe: DAO Grant System Integration (v2) */
describe("DAO Grant System Integration (v2)", function () {
  /** @notice it: runs full idea -> vote -> fund lifecycle */
  it("runs full idea -> vote -> fund lifecycle", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      grantManager,
      governanceToken,
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

    const authorBalanceBefore = await governanceToken.balanceOf(user1.address);

    await grantManager.connect(user1).claimGrant(1);

    const authorBalanceAfter = await governanceToken.balanceOf(user1.address);
    expect(authorBalanceAfter).to.be.gt(authorBalanceBefore);

    const idea = await ideaRegistry.getIdea(1);
    expect(idea[7]).to.equal(3n);
  });
});
