/**
 * @file VoterProgressionUpgradeable.fully.ts
 * @notice Progression thresholds, role grants, and admin overrides.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "../setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";
import { deploySystem } from "./helpers.js";

/** @notice describe: VoterProgressionUpgradeable */
describe("VoterProgressionUpgradeable", function () {
  /** @notice it: registers winning votes and grants roles at thresholds */
  it("registers winning votes and grants roles at thresholds", async function () {
    const { ethers } = await getConnection();
    const [admin, votingSystem, voter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();

    await roles.grantSystemRole(VOTING_ROLE, votingSystem.address);
    await roles.grantRole(AUTO_GRANT_ROLE, await progression.getAddress());

    for (let i = 0; i < 19; i += 1) {
      await progression.connect(votingSystem).registerWinningVote(voter.address);
    }

    expect(await progression.qualifiesForCurator(voter.address)).to.equal(false);

    await expect(
      progression.connect(votingSystem).registerWinningVote(voter.address)
    )
      .to.emit(progression, "RoleGranted")
      .withArgs(voter.address, await roles.CURATOR_ROLE());

    expect(await progression.hasRoleCurator(voter.address)).to.equal(true);

    for (let i = 0; i < 40; i += 1) {
      await progression.connect(votingSystem).registerWinningVote(voter.address);
    }

    expect(await progression.hasRoleReviewer(voter.address)).to.equal(true);
  });

  /** @notice it: validates inputs and role protections */
  it("validates inputs and role protections", async function () {
    const { ethers } = await getConnection();
    const [admin, voter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    await expect(
      progression.registerWinningVote(voter.address)
    ).to.be.revertedWithCustomError(progression, "NotVotingSystem");

    await expect(
      progression.qualifiesForCurator(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(progression, "ZeroAddress");
  });

  /** @notice it: reports progression status and allows admin overrides */
  it("reports progression status and allows admin overrides", async function () {
    const { ethers } = await getConnection();
    const [admin, votingSystem, voter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();

    await roles.grantSystemRole(VOTING_ROLE, votingSystem.address);
    await roles.grantRole(AUTO_GRANT_ROLE, await progression.getAddress());

    const statusBefore = await progression.getProgressionStatus(voter.address);
    expect(statusBefore[0]).to.equal(0n);
    expect(statusBefore[3]).to.equal(20n);
    expect(statusBefore[4]).to.equal(60n);

    await expect(progression.grantCuratorRole(voter.address))
      .to.emit(progression, "RoleGranted")
      .withArgs(voter.address, await roles.CURATOR_ROLE());

    await expect(progression.grantCuratorRole(voter.address))
      .to.be.revertedWithCustomError(progression, "AlreadyCurator")
      .withArgs(voter.address);

    await expect(progression.grantReviewerRole(voter.address))
      .to.emit(progression, "RoleGranted")
      .withArgs(voter.address, await roles.REVIEWER_ROLE());

    await roles.grantRole(
      await roles.DEFAULT_ADMIN_ROLE(),
      await progression.getAddress()
    );

    await expect(progression.resetProgression(voter.address))
      .to.emit(progression, "ProgressionReset")
      .withArgs(voter.address);

    await expect(progression.resetProgression(voter.address))
      .to.be.revertedWithCustomError(progression, "NoProgressionToReset")
      .withArgs(voter.address);
  });
});

/** @notice describe: VoterProgressionUpgradeable edge cases */
describe("VoterProgressionUpgradeable edge cases", function () {
  /** @notice it: rejects registerWinningVote for zero address */
  it("rejects registerWinningVote for zero address", async function () {
    const { ethers, admin, roles, voterProgression } = await deploySystem();

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await expect(
      voterProgression.connect(admin).registerWinningVote(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(voterProgression, "ZeroAddress");
  });

  /** @notice it: qualifiesForReviewer toggles after grant */
  it("qualifiesForReviewer toggles after grant", async function () {
    const { admin, roles, voterProgression, user1 } = await deploySystem();

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();

    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await roles.grantRole(AUTO_GRANT_ROLE, await voterProgression.getAddress());

    for (let i = 0; i < 59; i += 1) {
      await voterProgression.connect(admin).registerWinningVote(user1.address);
    }

    expect(await voterProgression.qualifiesForReviewer(user1.address)).to.equal(false);

    await voterProgression.connect(admin).registerWinningVote(user1.address);

    expect(await voterProgression.hasRoleReviewer(user1.address)).to.equal(true);
    expect(await voterProgression.qualifiesForReviewer(user1.address)).to.equal(false);
  });
});

/** @notice describe: VoterProgressionUpgradeable extra coverage */
describe("VoterProgressionUpgradeable extra coverage", function () {
  /** @notice it: enforces admin-only functions and zero address checks */
  it("enforces admin-only functions and zero address checks", async function () {
    const { ethers } = await getConnection();
    const [admin, other, voter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    await expect(
      progression.connect(other).grantCuratorRole(voter.address)
    ).to.be.revertedWithCustomError(progression, "NotAdmin");

    await expect(
      progression.connect(other).grantReviewerRole(voter.address)
    ).to.be.revertedWithCustomError(progression, "NotAdmin");

    await expect(
      progression.connect(other).resetProgression(voter.address)
    ).to.be.revertedWithCustomError(progression, "NotAdmin");

    await expect(
      progression.grantCuratorRole(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(progression, "ZeroAddress");

    await expect(
      progression.grantReviewerRole(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(progression, "ZeroAddress");

    await expect(
      progression.resetProgression(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(progression, "ZeroAddress");
  });

  /** @notice it: rejects view functions for zero address */
  it("rejects view functions for zero address", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    await expect(
      progression.getProgressionStatus(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(progression, "ZeroAddress");

    await expect(
      progression.qualifiesForReviewer(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(progression, "ZeroAddress");
  });

  /** @notice it: tracks winning votes and reset revokes roles */
  it("tracks winning votes and reset revokes roles", async function () {
    const { ethers } = await getConnection();
    const [admin, votingSystem, voter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    await roles.grantRole(await roles.DEFAULT_ADMIN_ROLE(), await progression.getAddress());
    await roles.grantRole(await roles.AUTO_GRANT_ROLE(), await progression.getAddress());
    await roles.grantSystemRole(await roles.VOTING_ROLE(), votingSystem.address);

    for (let i = 0; i < 60; i += 1) {
      await progression.connect(votingSystem).registerWinningVote(voter.address);
    }

    expect(await roles.hasRole(await roles.CURATOR_ROLE(), voter.address)).to.equal(true);
    expect(await roles.hasRole(await roles.REVIEWER_ROLE(), voter.address)).to.equal(true);
    expect(await progression.getWinningVotes(voter.address)).to.equal(60n);

    await progression.resetProgression(voter.address);

    expect(await roles.hasRole(await roles.CURATOR_ROLE(), voter.address)).to.equal(false);
    expect(await roles.hasRole(await roles.REVIEWER_ROLE(), voter.address)).to.equal(false);
    expect(await progression.getWinningVotes(voter.address)).to.equal(0n);
  });

  /** @notice it: reverts when granting reviewer twice */
  it("reverts when granting reviewer twice", async function () {
    const { ethers } = await getConnection();
    const [admin, voter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const progression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );

    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();
    await roles.grantRole(AUTO_GRANT_ROLE, await progression.getAddress());

    await progression.grantReviewerRole(voter.address);

    await expect(
      progression.grantReviewerRole(voter.address)
    )
      .to.be.revertedWithCustomError(progression, "AlreadyReviewer")
      .withArgs(voter.address);
  });
});
