/**
 * @file RolesRegistryUpgradeable.fully.ts
 * @notice System/user role management and access controls.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";

/** @notice describe: RolesRegistryUpgradeable */
describe("RolesRegistryUpgradeable", function () {
  /** @notice it: initializes and assigns default admin role */
  it("initializes and assigns default admin role", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    const hasAdmin = await roles.hasRole(
      await roles.DEFAULT_ADMIN_ROLE(),
      admin.address
    );

    expect(hasAdmin).to.equal(true);
  });

  /** @notice it: grants and revokes system roles with validation */
  it("grants and revokes system roles with validation", async function () {
    const { ethers } = await getConnection();
    const [admin, other] = await ethers.getSigners();
    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    const VOTING_ROLE = await roles.VOTING_ROLE();

    await expect(roles.grantSystemRole(VOTING_ROLE, other.address))
      .to.emit(roles, "RoleGranted")
      .withArgs(VOTING_ROLE, other.address, admin.address);

    await expect(roles.grantSystemRole(VOTING_ROLE, other.address))
      .to.be.revertedWithCustomError(roles, "AlreadyHasRole")
      .withArgs(VOTING_ROLE, other.address);

    await expect(roles.revokeSystemRole(VOTING_ROLE, other.address))
      .to.emit(roles, "RoleRevoked")
      .withArgs(VOTING_ROLE, other.address, admin.address);

    await expect(roles.revokeSystemRole(VOTING_ROLE, other.address))
      .to.be.revertedWithCustomError(roles, "RoleNotFound")
      .withArgs(VOTING_ROLE, other.address);
  });

  /** @notice it: rejects invalid system role and zero address */
  it("rejects invalid system role and zero address", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();
    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    const invalidRole = await roles.CURATOR_ROLE();

    await expect(roles.grantSystemRole(invalidRole, admin.address))
      .to.be.revertedWithCustomError(roles, "InvalidSystemRole")
      .withArgs(invalidRole);

    await expect(roles.grantSystemRole(await roles.VOTING_ROLE(), ethers.ZeroAddress))
      .to.be.revertedWithCustomError(roles, "ZeroAddress")
      .withArgs("account");
  });

  /** @notice it: grants and revokes user roles only via auto grant role */
  it("grants and revokes user roles only via auto grant role", async function () {
    const { ethers } = await getConnection();
    const [admin, autoGranter, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();
    const CURATOR_ROLE = await roles.CURATOR_ROLE();

    await roles.grantRole(AUTO_GRANT_ROLE, autoGranter.address);

    await expect(
      roles.connect(autoGranter).grantUserRole(CURATOR_ROLE, user.address)
    )
      .to.emit(roles, "RoleGranted")
      .withArgs(CURATOR_ROLE, user.address, autoGranter.address);

    await expect(
      roles.connect(autoGranter).grantUserRole(CURATOR_ROLE, user.address)
    )
      .to.be.revertedWithCustomError(roles, "AlreadyHasRole")
      .withArgs(CURATOR_ROLE, user.address);

    await expect(roles.revokeUserRole(CURATOR_ROLE, user.address))
      .to.emit(roles, "RoleRevoked")
      .withArgs(CURATOR_ROLE, user.address, admin.address);
  });

  /** @notice it: rejects invalid user role and zero address */
  it("rejects invalid user role and zero address", async function () {
    const { ethers } = await getConnection();
    const [admin, autoGranter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();
    await roles.grantRole(AUTO_GRANT_ROLE, autoGranter.address);

    const invalidRole = await roles.VOTING_ROLE();

    await expect(
      roles.connect(autoGranter).grantUserRole(invalidRole, admin.address)
    )
      .to.be.revertedWithCustomError(roles, "InvalidUserRole")
      .withArgs(invalidRole);

    await expect(
      roles.connect(autoGranter).grantUserRole(await roles.CURATOR_ROLE(), ethers.ZeroAddress)
    )
      .to.be.revertedWithCustomError(roles, "ZeroAddress")
      .withArgs("account");
  });

  /** @notice it: returns role lists and hasAnyRole correctly */
  it("returns role lists and hasAnyRole correctly", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const VOTING_ROLE = await roles.VOTING_ROLE();

    expect(await roles.hasAnyRole(user.address)).to.equal(false);

    await roles.grantSystemRole(VOTING_ROLE, user.address);

    const userRoles = await roles.getRoles(user.address);
    expect(userRoles).to.include(VOTING_ROLE);
    expect(await roles.hasAnyRole(user.address)).to.equal(true);
  });
});

/** @notice describe: RolesRegistryUpgradeable extra coverage */
describe("RolesRegistryUpgradeable extra coverage", function () {
  /** @notice it: enforces access control on system role management */
  it("enforces access control on system role management", async function () {
    const { ethers } = await getConnection();
    const [admin, other] = await ethers.getSigners();
    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const DEFAULT_ADMIN_ROLE = await roles.DEFAULT_ADMIN_ROLE();

    await expect(
      roles.connect(other).grantSystemRole(VOTING_ROLE, other.address)
    )
      .to.be.revertedWithCustomError(roles, "AccessControlUnauthorizedAccount")
      .withArgs(other.address, DEFAULT_ADMIN_ROLE);

    await roles.grantSystemRole(VOTING_ROLE, other.address);

    await expect(
      roles.connect(other).revokeSystemRole(VOTING_ROLE, other.address)
    )
      .to.be.revertedWithCustomError(roles, "AccessControlUnauthorizedAccount")
      .withArgs(other.address, DEFAULT_ADMIN_ROLE);
  });

  /** @notice it: enforces access control on user role management */
  it("enforces access control on user role management", async function () {
    const { ethers } = await getConnection();
    const [admin, other, user] = await ethers.getSigners();
    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    const CURATOR_ROLE = await roles.CURATOR_ROLE();
    const AUTO_GRANT_ROLE = await roles.AUTO_GRANT_ROLE();

    await expect(
      roles.connect(other).grantUserRole(CURATOR_ROLE, user.address)
    )
      .to.be.revertedWithCustomError(roles, "AccessControlUnauthorizedAccount")
      .withArgs(other.address, AUTO_GRANT_ROLE);

    await roles.grantRole(AUTO_GRANT_ROLE, other.address);
    await roles.connect(other).grantUserRole(CURATOR_ROLE, user.address);

    const DEFAULT_ADMIN_ROLE = await roles.DEFAULT_ADMIN_ROLE();
    await expect(
      roles.connect(other).revokeUserRole(CURATOR_ROLE, user.address)
    )
      .to.be.revertedWithCustomError(roles, "AccessControlUnauthorizedAccount")
      .withArgs(other.address, DEFAULT_ADMIN_ROLE);
  });

  /** @notice it: validates revokeUserRole errors and role checks */
  it("validates revokeUserRole errors and role checks", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();
    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    await expect(
      roles.revokeUserRole(await roles.VOTING_ROLE(), user.address)
    )
      .to.be.revertedWithCustomError(roles, "InvalidUserRole")
      .withArgs(await roles.VOTING_ROLE());

    await expect(
      roles.revokeUserRole(await roles.CURATOR_ROLE(), user.address)
    )
      .to.be.revertedWithCustomError(roles, "RoleNotFound")
      .withArgs(await roles.CURATOR_ROLE(), user.address);

    expect(await roles.isSystemRole(await roles.VOTING_ROLE())).to.equal(true);
    expect(await roles.isSystemRole(await roles.CURATOR_ROLE())).to.equal(false);
    expect(await roles.isUserRole(await roles.CURATOR_ROLE())).to.equal(true);
    expect(await roles.isUserRole(await roles.VOTING_ROLE())).to.equal(false);
  });

  /** @notice it: rejects revokeSystemRole with invalid role */
  it("rejects revokeSystemRole with invalid role", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();
    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    await expect(
      roles.revokeSystemRole(await roles.CURATOR_ROLE(), admin.address)
    )
      .to.be.revertedWithCustomError(roles, "InvalidSystemRole")
      .withArgs(await roles.CURATOR_ROLE());
  });
});

/** @notice describe: RolesRegistryUpgradeable internal exposure */
describe("RolesRegistryUpgradeable internal exposure", function () {
  /** @notice it: exposes isValidRole for coverage */
  it("exposes isValidRole for coverage", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(
      ethers,
      admin,
      "MockRolesRegistryExpose",
      []
    );

    expect(await roles.isValidRole(await roles.DEFAULT_ADMIN_ROLE())).to.equal(true);
    expect(await roles.isValidRole(await roles.VOTING_ROLE())).to.equal(true);
    expect(await roles.isValidRole(await roles.CURATOR_ROLE())).to.equal(true);
    expect(
      await roles.isValidRole(ethers.keccak256(ethers.toUtf8Bytes("RANDOM")))
    ).to.equal(false);
  });
});
