/**
 * @file Airdrop.ts
 * @notice Airdrop claims, limits, and eligibility checks.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";

/** @notice describe: Airdrop */
describe("Airdrop", function () {
  /** @notice it: validates constructor parameters */
  it("validates constructor parameters", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100"),
      admin.address,
      await roles.getAddress(),
    ]);

    await expect(
      ethers.deployContract("Airdrop", [ethers.ZeroAddress, 1, 1])
    ).to.be.revertedWith("Token cannot be zero address");

    await expect(
      ethers.deployContract("Airdrop", [await token.getAddress(), 0, 1])
    ).to.be.revertedWith("Amount per user must be > 0");

    await expect(
      ethers.deployContract("Airdrop", [await token.getAddress(), 1, 0])
    ).to.be.revertedWith("Max users must be > 0");
  });

  /** @notice it: allows claim for first N users and blocks repeat/overflow */
  it("allows claim for first N users and blocks repeat/overflow", async function () {
    const { ethers } = await getConnection();
    const [admin, user1, user2, user3] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100"),
      admin.address,
      await roles.getAddress(),
    ]);

    const airdrop = await ethers.deployContract("Airdrop", [
      await token.getAddress(),
      ethers.parseEther("1"),
      2,
    ]);

    await token.setMinter(await airdrop.getAddress(), true);

    await expect(airdrop.connect(user1).claim())
      .to.emit(airdrop, "TokensAirdropped")
      .withArgs(user1.address, ethers.parseEther("1"));

    expect(await airdrop.canClaim(user1.address)).to.equal(false);

    await expect(airdrop.connect(user1).claim()).to.be.revertedWith(
      "Already claimed"
    );

    await airdrop.connect(user2).claim();

    await expect(airdrop.connect(user3).claim()).to.be.revertedWith(
      "Airdrop limit reached"
    );

    expect(await airdrop.canClaim(user3.address)).to.equal(false);
  });
});
