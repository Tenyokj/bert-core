/**
 * @file BTKFaucet.ts
 * @notice Faucet claims, cooldown, admin controls, and pause checks.
 */
import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";

describe("BTKFaucet", function () {
  it("validates constructor params", async function () {
    const { ethers } = await getConnection();
    const [admin] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100000000"),
      admin.address,
      await roles.getAddress(),
    ]);

    await expect(
      ethers.deployContract("BTKFaucet", [
        ethers.ZeroAddress,
        await roles.getAddress(),
        ethers.parseEther("10000"),
        86400,
      ])
    ).to.be.revertedWith("Token cannot be zero address");

    await expect(
      ethers.deployContract("BTKFaucet", [
        await token.getAddress(),
        ethers.ZeroAddress,
        ethers.parseEther("10000"),
        86400,
      ])
    ).to.be.revertedWith("RolesRegistry cannot be zero address");

    await expect(
      ethers.deployContract("BTKFaucet", [
        await token.getAddress(),
        await roles.getAddress(),
        0,
        86400,
      ])
    ).to.be.revertedWith("Claim amount must be > 0");

    await expect(
      ethers.deployContract("BTKFaucet", [
        await token.getAddress(),
        await roles.getAddress(),
        ethers.parseEther("10000"),
        0,
      ])
    ).to.be.revertedWith("Cooldown must be > 0");
  });

  it("claims once, blocks during cooldown, allows after cooldown", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100000000"),
      admin.address,
      await roles.getAddress(),
    ]);

    const faucet = await ethers.deployContract("BTKFaucet", [
      await token.getAddress(),
      await roles.getAddress(),
      ethers.parseEther("10000"),
      86400,
    ]);

    await token.setMinter(await faucet.getAddress(), true);

    await expect(faucet.connect(user).claim())
      .to.emit(faucet, "Claimed")
      .withArgs(user.address, ethers.parseEther("10000"), (await ethers.provider.getBlock("latest"))!.timestamp + 86400 + 1);

    await expect(faucet.connect(user).claim()).to.be.revertedWith("Cooldown not elapsed!")

    await ethers.provider.send("evm_increaseTime", [86401]);
    await ethers.provider.send("evm_mine", []);

    await faucet.connect(user).claim();
    expect(await token.balanceOf(user.address)).to.equal(ethers.parseEther("20000"));
  });

  it("admin controls (setters, pause/unpause), non-admin blocked", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const token = await deployUpgradeable(ethers, admin, "GovernanceTokenUpgradeable", [
      "GovToken",
      "GOV",
      ethers.parseEther("100000000"),
      admin.address,
      await roles.getAddress(),
    ]);

    const faucet = await ethers.deployContract("BTKFaucet", [
      await token.getAddress(),
      await roles.getAddress(),
      ethers.parseEther("10000"),
      86400,
    ]);

    await token.setMinter(await faucet.getAddress(), true);

    await expect(faucet.connect(user).setClaimAmount(1)).to.be.revertedWithCustomError(faucet, "NotAdmin");
    await expect(faucet.connect(user).setCooldown(1)).to.be.revertedWithCustomError(faucet, "NotAdmin");
    await expect(faucet.connect(user).pause()).to.be.revertedWithCustomError(faucet, "NotAdmin");

    await faucet.connect(admin).setClaimAmount(ethers.parseEther("5000"));
    expect(await faucet.claimAmount()).to.equal(ethers.parseEther("5000"));

    await faucet.connect(admin).setCooldown(3600);
    expect(await faucet.cooldown()).to.equal(3600);

    await faucet.connect(admin).pause();
    expect(await faucet.isPaused()).to.equal(true);

    await expect(faucet.connect(user).claim()).to.be.revertedWithCustomError(faucet, "EnforcedPause");

    await faucet.connect(admin).unpause();
    expect(await faucet.isPaused()).to.equal(false);
  });
});
