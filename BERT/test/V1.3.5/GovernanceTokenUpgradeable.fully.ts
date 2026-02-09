/**
 * @file GovernanceTokenUpgradeable.fully.ts
 * @notice Token minting, max supply, and pause behavior.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "../setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";
import { deploySystem } from "./helpers.js";

/** @notice describe: GovernanceTokenUpgradeable */
describe("GovernanceTokenUpgradeable", function () {
  /** @notice it: initializes with max supply and minters */
  it("initializes with max supply and minters", async function () {
    const { ethers } = await getConnection();
    const [admin, initialMinter] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);

    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("1000"),
      initialMinter.address,
      await roles.getAddress(),
    ]);

    expect(await token.maxSupply()).to.equal(ethers.parseEther("1000"));
    expect(await token.isMinter(admin.address)).to.equal(true);
    expect(await token.isMinter(initialMinter.address)).to.equal(true);
    expect(await token.decimals()).to.equal(18);
  });

  /** @notice it: "mints */
  it("mints, pauses, and enforces max supply", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("10"),
      admin.address,
      await roles.getAddress(),
    ]);

    await expect(token.mint(user.address, ethers.parseEther("1")))
      .to.emit(token, "TokensMinted")
      .withArgs(user.address, ethers.parseEther("1"));

    await token.pause();
    await expect(token.mint(user.address, ethers.parseEther("1")))
      .to.be.revertedWithCustomError(token, "EnforcedPause");

    await token.unpause();
    await expect(token.mint(user.address, 0)).to.be.revertedWith(
      "Cannot mint zero tokens"
    );

    await expect(
      token.mint(user.address, ethers.parseEther("100"))
    ).to.be.revertedWith("Max supply exceeded");
  });

  /** @notice it: requires authorized minter */
  it("requires authorized minter", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100"),
      admin.address,
      await roles.getAddress(),
    ]);

    await expect(
      token.connect(user).mint(user.address, ethers.parseEther("1"))
    ).to.be.revertedWith("Not authorized minter");
  });

  /** @notice it: manages minters and max supply via admin */
  it("manages minters and max supply via admin", async function () {
    const { ethers } = await getConnection();
    const [admin, user, other] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100"),
      admin.address,
      await roles.getAddress(),
    ]);

    await expect(token.setMinter(user.address, true))
      .to.emit(token, "MinterUpdated")
      .withArgs(user.address, true);

    await expect(
      token.connect(other).setMinter(other.address, true)
    ).to.be.revertedWithCustomError(token, "NotAdmin");

    await expect(token.setMinter(ethers.ZeroAddress, true)).to.be.revertedWith(
      "Minter cannot be zero address"
    );

    await expect(token.updateMaxSupply(ethers.parseEther("50"))).to.be.revertedWith(
      "Max supply can only increase"
    );

    await token.updateMaxSupply(ethers.parseEther("200"));
    expect(await token.maxSupply()).to.equal(ethers.parseEther("200"));
  });

  /** @notice it: blocks transfers while paused */
  it("blocks transfers while paused", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100"),
      admin.address,
      await roles.getAddress(),
    ]);

    await token.mint(admin.address, ethers.parseEther("10"));
    await token.pause();

    await expect(
      token.transfer(user.address, ethers.parseEther("1"))
    ).to.be.revertedWithCustomError(token, "EnforcedPause");
  });
});

/** @notice describe: GovernanceTokenUpgradeable edge cases */
describe("GovernanceTokenUpgradeable edge cases", function () {
  /** @notice it: rejects mint to zero and zero amount */
  it("rejects mint to zero and zero amount", async function () {
    const { ethers, governanceToken } = await deploySystem();

    await expect(
      governanceToken.mint(ethers.ZeroAddress, 1)
    ).to.be.revertedWith("Cannot mint to zero address");

    await expect(governanceToken.mint(governanceToken.target, 0)).to.be.revertedWith(
      "Cannot mint zero tokens"
    );
  });

  /** @notice it: rejects updateMaxSupply below total supply */
  it("rejects updateMaxSupply below total supply", async function () {
    const { governanceToken, admin } = await deploySystem();

    await governanceToken.mint(admin.address, 100n);

    await expect(
      governanceToken.updateMaxSupply(50n)
    ).to.be.revertedWith("Max supply can only increase");
  });
});

/** @notice describe: GovernanceTokenUpgradeable extra coverage */
describe("GovernanceTokenUpgradeable extra coverage", function () {
  /** @notice it: revokes minter and computes remainingMintable */
  it("revokes minter and computes remainingMintable", async function () {
    const { governanceToken, admin, user1 } = await deploySystem();

    await governanceToken.setMinter(user1.address, true);
    expect(await governanceToken.isMinter(user1.address)).to.equal(true);

    await governanceToken.setMinter(user1.address, false);
    expect(await governanceToken.isMinter(user1.address)).to.equal(false);

    const remainingBefore = await governanceToken.remainingMintable();
    await governanceToken.mint(admin.address, 100n);
    const remainingAfter = await governanceToken.remainingMintable();

    expect(remainingAfter).to.equal(remainingBefore - 100n);
  });

  /** @notice it: allows updateMaxSupply equal to current max */
  it("allows updateMaxSupply equal to current max", async function () {
    const { governanceToken } = await deploySystem();
    const current = await governanceToken.maxSupply();
    await governanceToken.updateMaxSupply(current);
    expect(await governanceToken.maxSupply()).to.equal(current);
  });
});
