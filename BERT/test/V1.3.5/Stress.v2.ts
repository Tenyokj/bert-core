/**
 * @file Stress.v2.ts
 * @notice Stress testing with max voters/ideas and gas bounds.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "../setup.js";
import { deploySystem, createIdeas } from "./helpers.js";
import { HDNodeWallet } from "ethers";

/** @notice describe: DAO Grant System stress */
describe("DAO Grant System stress", function () {
  /** @notice it: handles max voters and ideas under gas limits */
  it("handles max voters and ideas under gas limits", async function () {
    const {
      admin,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
      ethers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();

    const voters: HDNodeWallet[] = [];
    for (let i = 0; i < 30; i += 1) {
      const wallet = HDNodeWallet.createRandom().connect(ethers.provider);
      voters.push(wallet);
      await admin.sendTransaction({
        to: wallet.address,
        value: 10n ** 18n,
      });
      await governanceToken.mint(wallet.address, minStake);
      await governanceToken
        .connect(wallet)
        .approve(await fundingPool.getAddress(), minStake);
      await votingSystem.connect(wallet).vote(1, i + 1, minStake);
    }

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    const tx = await votingSystem.endVotingRound(1);
    const receipt = await tx.wait();
    expect(receipt?.gasUsed).to.be.lt(12_000_000n);
  });
});
