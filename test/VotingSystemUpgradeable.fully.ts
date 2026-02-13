/**
 * @file VotingSystemUpgradeable.fully.ts
 * @notice Voting rounds, vote constraints, results, and admin parameters.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deploySystem, createIdeas } from "./helpers.js";
import { HDNodeWallet } from "ethers";


/** @notice describe: VotingSystemUpgradeable */
describe("VotingSystemUpgradeable", function () {
  /** @notice it: starts rounds when enough ideas */
  it("starts rounds when enough ideas", async function () {
    const {
      admin,
      ideaRegistry,
      votingSystem,
      fundingPool,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    await expect(votingSystem.startVotingRound())
      .to.emit(votingSystem, "VotingRoundStarted");

    const roundInfo = await votingSystem.getRoundInfo(1);
    expect(roundInfo[0]).to.equal(1n);
    expect(roundInfo[4]).to.equal(true);
  });

  /** @notice it: rejects voting when conditions are not met */
  it("rejects voting when conditions are not met", async function () {
    const { admin, user1, ideaRegistry, votingSystem } = await deploySystem();

    await createIdeas(ideaRegistry, admin, 30);
    await votingSystem.connect(admin).unpause();

    await expect(votingSystem.vote(0, 1, 1))
      .to.be.revertedWithCustomError(votingSystem, "InvalidId")
      .withArgs("roundId");

    await votingSystem.startVotingRound();

    await expect(votingSystem.vote(1, 0, 1))
      .to.be.revertedWithCustomError(votingSystem, "InvalidId")
      .withArgs("ideaId");

    await expect(
      votingSystem.connect(user1).vote(1, 1, 1)
    ).to.be.revertedWithCustomError(votingSystem, "InsufficientStake");

    const minStake = await votingSystem.minStake();

    await expect(
      votingSystem.connect(admin).vote(1, 1, minStake)
    )
      .to.be.revertedWithCustomError(votingSystem, "CannotVoteForOwnIdea")
      .withArgs(admin.address, 1n);
  });


  /** @notice it: "casts votes */
  it("casts votes, tracks voters, and ends rounds with winner", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);

    await votingSystem.startVotingRound();

    await governanceToken.mint(user1.address, 5000n * 10n ** 18n);
    await governanceToken.mint(user2.address, 5000n * 10n ** 18n);

    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), 5000n * 10n ** 18n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), 5000n * 10n ** 18n);

    const minStake = await votingSystem.minStake();

    await expect(
      votingSystem.connect(user1).vote(1, 1, minStake)
    )
      .to.emit(votingSystem, "VoteCast")
      .withArgs(user1.address, 1n, 1n, minStake);

    await votingSystem.connect(user2).vote(1, 1, minStake + 1n);

    expect(await votingSystem.hasVoted(1, user1.address)).to.equal(true);
    const voters = await votingSystem.getVotersForIdea(1, 1);
    expect(voters.length).to.equal(2);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    await expect(votingSystem.endVotingRound(1))
      .to.emit(votingSystem, "VotingRoundEnded")
      .withArgs(1n, 1n, minStake + (minStake + 1n));

    const winner = await votingSystem.getRoundWinner(1);
    expect(winner[0]).to.equal(1n);
  });

  /** @notice it: handles no-vote rounds */
  it("handles no-vote rounds", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers } =
      await deploySystem();

    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);

    await votingSystem.startVotingRound();

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    await expect(votingSystem.endVotingRound(1))
      .to.emit(votingSystem, "VotingRoundEnded")
      .withArgs(1n, 0n, 0n);
  });
});

/** @notice describe: VotingSystemUpgradeable edge cases */
describe("VotingSystemUpgradeable edge cases", function () {
  /** @notice it: enforces pause */
  it("enforces pause", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers } =
      await deploySystem();

    await createIdeas(ideaRegistry, admin, 60);

    await expect(votingSystem.startVotingRound())
      .to.be.revertedWithCustomError(votingSystem, "EnforcedPause");

    await votingSystem.connect(admin).unpause();

   await expect(votingSystem.startVotingRound())
      .to.emit(votingSystem, "VotingRoundStarted");

  });

  /** @notice it: rejects start when not enough ideas */
  it("rejects start when not enough ideas", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers } =
      await deploySystem();

    await votingSystem.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 5);
    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);

    await expect(votingSystem.startVotingRound())
      .to.be.revertedWithCustomError(votingSystem, "NotEnoughIdeas");
  });

  /** @notice it: rejects start when idea not pending */
  it("rejects start when idea not pending", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers, roles } =
      await deploySystem();

    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await ideaRegistry.connect(admin).updateStatus(1, 1);

    await expect(votingSystem.startVotingRound())
      .to.be.revertedWithCustomError(votingSystem, "IdeaNotPending");
  });

  /** @notice it: rejects voting outside time window and duplicate votes */
  it("rejects voting outside time window and duplicate votes", async function () {
    const {
      admin,
      user1,
      user2,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
    } = await deploySystem();

    await votingSystem.connect(admin).unpause();
    await fundingPool.connect(admin).unpause();

    await createIdeas(ideaRegistry, admin, 30);

    const now_ = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now_ + 700);

    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user1.address, minStake * 2n);
    await governanceToken.mint(user2.address, minStake * 2n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await governanceToken
      .connect(user2)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    const roundInfo = await votingSystem.getRoundInfo(1);
    const nowStart = await networkHelpers.time.latest();
    const startTarget = Number(roundInfo[2]) + 1;
    if (startTarget <= nowStart) {
      await networkHelpers.time.increase(2);
    } else {
      await networkHelpers.time.increaseTo(startTarget);
    }

    await votingSystem.connect(user1).vote(1, 1, minStake);

    await expect(
      votingSystem.connect(user1).vote(1, 1, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "AlreadyVoted");

    // move past end time using relative increase to avoid backward timestamps
    const now = await networkHelpers.time.latest();
    if (Number(roundInfo[3]) + 1 <= now) {
      await networkHelpers.time.increase(2);
    } else {
      await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    }

    await expect(
      votingSystem.connect(user2).vote(1, 1, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "NotInVotingWindow");
  });

  /** @notice it: rejects voting for idea not in round and after round ended */
  it("rejects voting for idea not in round and after round ended", async function () {
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

    await expect(
      votingSystem.connect(user1).vote(1, 999, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "IdeaNotInRound");

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    await expect(
      votingSystem.connect(user1).vote(1, 1, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "RoundNotActive");
  });

  /** @notice it: rejects double end and results before end */
  it("rejects double end and results before end", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers } =
      await deploySystem();

    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);

    await votingSystem.startVotingRound();

    await expect(votingSystem.getRoundResults(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundNotEnded");

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    await votingSystem.endVotingRound(1);

    await expect(votingSystem.endVotingRound(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundAlreadyEnded");
  });
});

/** @notice describe: VotingSystemUpgradeable max voters */
describe("VotingSystemUpgradeable max voters", function () {
  /** @notice it: reverts when max voters reached for an idea */
  it("reverts when max voters reached for an idea", async function () {
    const {
      admin,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
      ethers,
    } = await deploySystem();

    await votingSystem.connect(admin).unpause();
    await fundingPool.connect(admin).unpause();

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
      await votingSystem.connect(wallet).vote(1, 1, minStake);
    }

    const extra = HDNodeWallet.createRandom().connect(ethers.provider);
    await admin.sendTransaction({
      to: extra.address,
      value: 10n ** 18n,
    });
    await governanceToken.mint(extra.address, minStake);
    await governanceToken
      .connect(extra)
      .approve(await fundingPool.getAddress(), minStake);

    await expect(
      votingSystem.connect(extra).vote(1, 1, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "MaxVotersReached");
  });
});

/** @notice describe: VotingSystemUpgradeable extra coverage */
describe("VotingSystemUpgradeable extra coverage", function () {
  /** @notice it: reverts on non-existent round access */
  it("reverts on non-existent round access", async function () {
    const { votingSystem } = await deploySystem();

    await expect(votingSystem.getRoundInfo(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundDoesNotExist")
      .withArgs(1n);

    await expect(votingSystem.getRoundResults(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundDoesNotExist")
      .withArgs(1n);

    await expect(votingSystem.hasVoted(1, "0x0000000000000000000000000000000000000001"))
      .to.be.revertedWithCustomError(votingSystem, "RoundDoesNotExist")
      .withArgs(1n);
  });

  /** @notice it: rejects endVotingRound before end time */
  it("rejects endVotingRound before end time", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers } =
      await deploySystem();

    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    await expect(votingSystem.endVotingRound(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundNotEnded")
      .withArgs(1n);
  });

  /** @notice it: rejects vote when paused */
  it("rejects vote when paused", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    await votingSystem.connect(admin).pause();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user1.address, minStake * 2n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), minStake * 2n);

    await expect(
      votingSystem.connect(user1).vote(1, 1, minStake)
    ).to.be.revertedWithCustomError(votingSystem, "EnforcedPause");
  });

  /** @notice it: reports canStartNewRound reasons and success */
  it("reports canStartNewRound reasons and success", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers } =
      await deploySystem();

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);

    const before = await votingSystem.canStartNewRound();
    expect(before[0]).to.equal(false);
    expect(before[1]).to.equal("Not enough new ideas");

    await createIdeas(ideaRegistry, admin, 30);
    const after = await votingSystem.canStartNewRound();
    expect(after[0]).to.equal(true);
    expect(after[1]).to.equal("Can start new round");
  });

  /** @notice it: returns votes for idea */
  it("returns votes for idea", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
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

    await votingSystem.connect(user1).vote(1, 1, minStake);

    expect(await votingSystem.getVotesForIdea(1, 1)).to.equal(minStake);
  });

  /** @notice it: returns round results and winner after end */
  it("returns round results and winner after end", async function () {
    const {
      admin,
      user1,
      ideaRegistry,
      votingSystem,
      fundingPool,
      governanceToken,
      networkHelpers,
    } = await deploySystem();

    await fundingPool.connect(admin).unpause();
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
    await votingSystem.connect(user1).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);
    await votingSystem.endVotingRound(1);

    const results = await votingSystem.getRoundResults(1);
    expect(results[0]).to.equal(1n);
    expect(results[1]).to.equal(minStake);

    const winner = await votingSystem.getRoundWinner(1);
    expect(winner[0]).to.equal(1n);
    expect(winner[1]).to.equal(minStake);
  });

  /** @notice it: reverts when reputation decrease fails */
  it("reverts when reputation decrease fails", async function () {
    const {
      admin,
      user1,
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

    const mockReputation = await ethers.deployContract(
      "MockReputationSystemDecreaseFail",
      []
    );
    await mockReputation.waitForDeployment();
    await votingSystem.setReputationSystem(await mockReputation.getAddress());

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const minStake = await votingSystem.minStake();
    await governanceToken.mint(user1.address, minStake * 2n);
    await governanceToken
      .connect(user1)
      .approve(await fundingPool.getAddress(), minStake * 2n);
    await votingSystem.connect(user1).vote(1, 1, minStake);

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    await expect(votingSystem.endVotingRound(1))
      .to.be.revertedWithCustomError(votingSystem, "ExternalCallFailed")
      .withArgs("ReputationSystem", "decreaseReputation");
  });

  /** @notice it: reverts endVotingRound when round not active */
  it("reverts endVotingRound when round not active", async function () {
    const { admin, ideaRegistry, votingSystem, networkHelpers, ethers } =
      await deploySystem();

    await votingSystem.connect(admin).unpause();
    await createIdeas(ideaRegistry, admin, 30);

    const now = await networkHelpers.time.latest();
    await networkHelpers.time.increaseTo(now + 700);
    await votingSystem.startVotingRound();

    const roundInfo = await votingSystem.getRoundInfo(1);
    await networkHelpers.time.increaseTo(Number(roundInfo[3]) + 1);

    const startTime = BigInt(roundInfo[2]);
    let base: bigint | undefined;
    for (let s = 0; s < 500; s += 1) {
      const slot = BigInt(
        ethers.keccak256(
          ethers.AbiCoder.defaultAbiCoder().encode(
            ["uint256", "uint256"],
            [1n, BigInt(s)]
          )
        )
      );
      const idVal = await ethers.provider.getStorage(
        await votingSystem.getAddress(),
        ethers.toBeHex(slot, 32)
      );
      if (BigInt(idVal) !== 1n) {
        continue;
      }
      const startVal = await ethers.provider.getStorage(
        await votingSystem.getAddress(),
        ethers.toBeHex(slot + 2n, 32)
      );
      if (BigInt(startVal) === startTime) {
        base = slot;
        break;
      }
    }
    if (base === undefined) {
      throw new Error("Missing votingRounds base slot");
    }
    const activeSlot = base + 4n;
    await ethers.provider.send("hardhat_setStorageAt", [
      await votingSystem.getAddress(),
      ethers.toBeHex(activeSlot, 32),
      ethers.toBeHex(0, 32),
    ]);

    await expect(votingSystem.endVotingRound(1))
      .to.be.revertedWithCustomError(votingSystem, "RoundNotActive")
      .withArgs(1n);
  });

  /** @notice it: updates admin parameters successfully */
  it("updates admin parameters successfully", async function () {
    const { admin, votingSystem, fundingPool, ideaRegistry, reputationSystem, voterProgression } =
      await deploySystem();

    await votingSystem.connect(admin).setFundingPool(await fundingPool.getAddress());
    await votingSystem.connect(admin).setIdeaRegistry(await ideaRegistry.getAddress());
    await votingSystem.connect(admin).setReputationSystem(
      await reputationSystem.getAddress()
    );
    await votingSystem.connect(admin).setVoterProgression(
      await voterProgression.getAddress()
    );
    await votingSystem.connect(admin).setVotingDuration(1000);
    await votingSystem.connect(admin).setMinStake(1n);
    await votingSystem.connect(admin).setIdeaPerRound(10);

    expect(await votingSystem.VOTING_DURATION()).to.equal(1000n);
    expect(await votingSystem.minStake()).to.equal(1n);
    expect(await votingSystem.IDEAS_PER_ROUND()).to.equal(10n);
  });

  /** @notice it: enforces admin-only setters and validates zero addresses */
  it("enforces admin-only setters and validates zero addresses", async function () {
    const { admin, user1, ethers, votingSystem, fundingPool, ideaRegistry, reputationSystem, voterProgression } =
      await deploySystem();

    await expect(
      votingSystem.connect(user1).setFundingPool(await fundingPool.getAddress())
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.setFundingPool(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(votingSystem, "ZeroAddress");

    await expect(
      votingSystem.connect(user1).setIdeaRegistry(await ideaRegistry.getAddress())
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.setIdeaRegistry(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(votingSystem, "ZeroAddress");

    await expect(
      votingSystem.connect(user1).setReputationSystem(await reputationSystem.getAddress())
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.setReputationSystem(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(votingSystem, "ZeroAddress");

    await expect(
      votingSystem.connect(user1).setVoterProgression(await voterProgression.getAddress())
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.setVoterProgression(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(votingSystem, "ZeroAddress");

    await expect(
      votingSystem.connect(user1).setVotingDuration(1)
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.connect(user1).setMinStake(1)
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.connect(user1).setIdeaPerRound(1)
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.connect(user1).pause()
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");

    await expect(
      votingSystem.connect(user1).unpause()
    ).to.be.revertedWithCustomError(votingSystem, "NotAdmin");
  });
});

function makePrng(seed: number) {
  let state = seed >>> 0;
  return () => {
    state = (state * 1103515245 + 12345) >>> 0;
    return state;
  };
}

/** @notice describe: VotingSystemUpgradeable invariants */
describe("VotingSystemUpgradeable invariants", function () {
  /** @notice it: totalVotes equals sum of idea votes */
  it("totalVotes equals sum of idea votes", async function () {
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

    const prng = makePrng(123);
    const voters: HDNodeWallet[] = [];
    const counts = new Array<number>(30).fill(0);

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

      const ideaId = (prng() % 30) + 1;
      counts[ideaId - 1] += 1;
      await votingSystem.connect(wallet).vote(1, ideaId, minStake);
    }

    let sum = 0n;
    for (let i = 0; i < 30; i += 1) {
      const ideaId = i + 1;
      const votes = await votingSystem.getVotesForIdea(1, ideaId);
      expect(votes).to.equal(minStake * BigInt(counts[i]));
      sum += votes;

      const votersForIdea = await votingSystem.getVotersForIdea(1, ideaId);
      expect(votersForIdea.length).to.equal(counts[i]);
    }

    const roundInfo = await votingSystem.getRoundInfo(1);
    expect(roundInfo[6]).to.equal(sum);
  });
});
