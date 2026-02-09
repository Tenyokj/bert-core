/**
 * @file ReputationSystemUpgradeable.fully.ts
 * @notice Reputation initialization, updates, and admin operations.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";
import { deploySystem } from "./helpers.js";

/** @notice describe: ReputationSystemUpgradeable */
describe("ReputationSystemUpgradeable", function () {
  /** @notice it: initializes and enforces reputation manager role */
  it("initializes and enforces reputation manager role", async function () {
    const { ethers } = await getConnection();
    const [admin, manager, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, manager.address);

    await expect(reputation.connect(manager).initializeReputation(user.address))
      .to.emit(reputation, "ReputationInitialized")
      .withArgs(user.address);

    await expect(
      reputation.connect(manager).initializeReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "AlreadyInitialized");

    await expect(
      reputation.initializeReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "NotReputationManager");
  });

  /** @notice it: increases and decreases with caps and floors */
  it("increases and decreases with caps and floors", async function () {
    const { ethers } = await getConnection();
    const [admin, manager, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, manager.address);

    await reputation.connect(manager).initializeReputation(user.address);

    await expect(reputation.connect(manager).increaseReputation(user.address))
      .to.emit(reputation, "ReputationIncreased")
      .withArgs(user.address, 10500n);

    for (let i = 0; i < 50; i += 1) {
      await reputation.connect(manager).increaseReputation(user.address);
    }

    expect(await reputation.getReputation(user.address)).to.equal(20000n);

    await expect(reputation.connect(manager).decreaseReputation(user.address))
      .to.emit(reputation, "ReputationDecreased")
      .withArgs(user.address, 19500n, 500n);

    for (let i = 0; i < 100; i += 1) {
      await reputation.connect(manager).decreaseReputation(user.address);
    }

    expect(await reputation.getReputation(user.address)).to.equal(0n);
  });

  /** @notice it: returns default reputation for uninitialized users and validates inputs */
  it("returns default reputation for uninitialized users and validates inputs", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    expect(await reputation.getReputation(user.address)).to.equal(10000n);

    await expect(
      reputation.isInitialized(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(reputation, "ZeroAddress");

    const [values, initialized] = await reputation.getBatchReputation([
      user.address,
    ]);
    expect(values[0]).to.equal(10000n);
    expect(initialized[0]).to.equal(false);
  });

  /** @notice it: handles batch limits and zero addresses */
  it("handles batch limits and zero addresses", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    const tooMany = Array.from({ length: 101 }, () => admin.address);

    await expect(
      reputation.getBatchReputation(tooMany)
    ).to.be.revertedWithCustomError(reputation, "BatchSizeExceeded");

    await expect(
      reputation.getBatchReputation([ethers.ZeroAddress])
    ).to.be.revertedWithCustomError(reputation, "BatchContainsZeroAddress")
      .withArgs(0);
  });

  /** @notice it: admin controls batch initialize and emergency setters */
  it("admin controls batch initialize and emergency setters", async function () {
    const { ethers } = await getConnection();
    const [admin, user, other] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    await expect(
      reputation.connect(other).batchInitializeReputation([user.address])
    ).to.be.revertedWithCustomError(reputation, "NotAdmin");

    await reputation.batchInitializeReputation([user.address]);
    expect(await reputation.isInitialized(user.address)).to.equal(true);

    await expect(
      reputation.setReputation(ethers.ZeroAddress, 1)
    ).to.be.revertedWithCustomError(reputation, "ZeroAddress");

    await expect(
      reputation.setReputation(user.address, 30000)
    ).to.be.revertedWithCustomError(reputation, "ReputationOverflow");

    await expect(reputation.setReputation(user.address, 500))
      .to.emit(reputation, "ReputationSet")
      .withArgs(user.address, 10000n, 500n);

    await expect(reputation.deinitializeReputation(user.address))
      .to.emit(reputation, "ReputationDeinitialized")
      .withArgs(user.address);
  });
});

/** @notice describe: ReputationSystemUpgradeable edge cases */
describe("ReputationSystemUpgradeable edge cases", function () {
  /** @notice it: rejects increase/decrease when not initialized */
  it("rejects increase/decrease when not initialized", async function () {
    const { reputationSystem, user1, roles, admin } = await deploySystem();

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, admin.address);

    await expect(
      reputationSystem.connect(admin).increaseReputation(user1.address)
    ).to.be.revertedWithCustomError(reputationSystem, "NotInitialized");

    await expect(
      reputationSystem.connect(admin).decreaseReputation(user1.address)
    ).to.be.revertedWithCustomError(reputationSystem, "NotInitialized");
  });

  /** @notice it: rejects batch initialize with zero address */
  it("rejects batch initialize with zero address", async function () {
    const { ethers, reputationSystem } = await deploySystem();

    await expect(
      reputationSystem.batchInitializeReputation([ethers.ZeroAddress])
    ).to.be.revertedWithCustomError(reputationSystem, "BatchContainsZeroAddress")
      .withArgs(0n);
  });
});

/** @notice describe: ReputationSystemUpgradeable extra coverage */
describe("ReputationSystemUpgradeable extra coverage", function () {
  /** @notice it: reports availability and canReceiveReputation at max */
  it("reports availability and canReceiveReputation at max", async function () {
    const { reputationSystem, roles, admin, user1 } = await deploySystem();

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, admin.address);

    await reputationSystem.connect(admin).initializeReputation(user1.address);

    for (let i = 0; i < 50; i += 1) {
      await reputationSystem.connect(admin).increaseReputation(user1.address);
    }

    expect(await reputationSystem.getAvailableReputationIncrease(user1.address)).to.equal(0n);
    expect(await reputationSystem.canReceiveReputation(user1.address)).to.equal(false);
  });

  /** @notice it: batchInitializeReputation skips already initialized */
  it("batchInitializeReputation skips already initialized", async function () {
    const { reputationSystem, roles, admin, user1 } = await deploySystem();

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, admin.address);

    await reputationSystem.connect(admin).initializeReputation(user1.address);

    await reputationSystem.batchInitializeReputation([user1.address]);
    expect(await reputationSystem.isInitialized(user1.address)).to.equal(true);
  });
});

/** @notice describe: ReputationSystemUpgradeable extra coverage 2 */
describe("ReputationSystemUpgradeable extra coverage 2", function () {
  /** @notice it: validates access control for manager-only functions */
  it("validates access control for manager-only functions", async function () {
    const { ethers } = await getConnection();
    const [admin, other, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    await expect(
      reputation.connect(other).initializeReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "NotReputationManager");

    await expect(
      reputation.connect(other).increaseReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "NotReputationManager");

    await expect(
      reputation.connect(other).decreaseReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "NotReputationManager");
  });

  /** @notice it: validates zero address and batch size errors */
  it("validates zero address and batch size errors", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, admin.address);

    await expect(
      reputation.initializeReputation(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(reputation, "ZeroAddress");

    const tooMany = Array.from({ length: 101 }, () => admin.address);
    await expect(
      reputation.batchInitializeReputation(tooMany)
    ).to.be.revertedWithCustomError(reputation, "BatchSizeExceeded");
  });

  /** @notice it: validates admin-only emergency functions */
  it("validates admin-only emergency functions", async function () {
    const { ethers } = await getConnection();
    const [admin, other, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    await expect(
      reputation.connect(other).setReputation(user.address, 1)
    ).to.be.revertedWithCustomError(reputation, "NotAdmin");

    await expect(
      reputation.connect(other).deinitializeReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "NotAdmin");

    await expect(
      reputation.deinitializeReputation(user.address)
    ).to.be.revertedWithCustomError(reputation, "NotInitialized");
  });

  /** @notice it: reports availability for uninitialized users */
  it("reports availability for uninitialized users", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    expect(await reputation.getAvailableReputationIncrease(user.address)).to.equal(10000n);
    expect(await reputation.canReceiveReputation(user.address)).to.equal(true);
  });

  /** @notice it: reports availability for initialized users below max */
  it("reports availability for initialized users below max", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, admin.address);

    await reputation.connect(admin).initializeReputation(user.address);
    await reputation.connect(admin).increaseReputation(user.address);

    const available = await reputation.getAvailableReputationIncrease(user.address);
    expect(available).to.equal(9500n);
  });

  /** @notice it: setReputation initializes when not initialized and deinitialize checks zero */
  it("setReputation initializes when not initialized and deinitialize checks zero", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );

    await reputation.setReputation(user.address, 123n);
    expect(await reputation.isInitialized(user.address)).to.equal(true);

    await expect(
      reputation.deinitializeReputation(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(reputation, "ZeroAddress");
  });
});
