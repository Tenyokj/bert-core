/**
 * @file NonStandardERC20.fully.ts
 * @notice Non-standard ERC20 failure handling and mock token coverage.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";

/** @notice describe: Non-standard ERC20 failure paths */
describe("Non-standard ERC20 failure paths", function () {
  /** @notice it: FundingPool deposit reverts when transferFrom returns false */
  it("FundingPool deposit reverts when transferFrom returns false", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );
    const voterProgression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );
    const ideaRegistry = await deployUpgradeable(
      ethers,
      admin,
      "IdeaRegistryUpgradeable",
      [
        await reputation.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress(),
      ]
    );

    const mockToken = await ethers.deployContract("MockERC20Fail", [
      "Mock",
      "MOCK",
    ]);
    await mockToken.waitForDeployment();

    const fundingPool = await deployUpgradeable(
      ethers,
      admin,
      "FundingPoolUpgradeable",
      [await mockToken.getAddress(), await ideaRegistry.getAddress(), await roles.getAddress()]
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, await ideaRegistry.getAddress());

    await mockToken.mint(user.address, 100n);
    await mockToken.connect(user).approve(await fundingPool.getAddress(), 100n);
    await fundingPool.connect(admin).unpause();
    await mockToken.setFailTransferFrom(true, true);

    await expect(
      fundingPool.connect(user).deposit(10n)
    )
      .to.be.revertedWithCustomError(fundingPool, "SafeERC20FailedOperation")
      .withArgs(await mockToken.getAddress());
  });

  /** @notice it: FundingPool distributeFunds reverts when token transfer fails */
  it("FundingPool distributeFunds reverts when token transfer fails", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const reputation = await deployUpgradeable(
      ethers,
      admin,
      "ReputationSystemUpgradeable",
      [await roles.getAddress()]
    );
    const voterProgression = await deployUpgradeable(
      ethers,
      admin,
      "VoterProgressionUpgradeable",
      [await roles.getAddress()]
    );
    const ideaRegistry = await deployUpgradeable(
      ethers,
      admin,
      "IdeaRegistryUpgradeable",
      [
        await reputation.getAddress(),
        await voterProgression.getAddress(),
        await roles.getAddress(),
      ]
    );

    const mockToken = await ethers.deployContract("MockERC20Fail", [
      "Mock",
      "MOCK",
    ]);
    await mockToken.waitForDeployment();

    const fundingPool = await deployUpgradeable(
      ethers,
      admin,
      "FundingPoolUpgradeable",
      [await mockToken.getAddress(), await ideaRegistry.getAddress(), await roles.getAddress()]
    );

    const REPUTATION_MANAGER_ROLE = await roles.REPUTATION_MANAGER_ROLE();
    await roles.grantSystemRole(REPUTATION_MANAGER_ROLE, await ideaRegistry.getAddress());

    await ideaRegistry.connect(user).createIdea("Idea", "Desc", "");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const DISTRIBUTOR_ROLE = await roles.DISTRIBUTOR_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await roles.grantSystemRole(DISTRIBUTOR_ROLE, admin.address);

    await mockToken.mint(user.address, 200n);
    await mockToken.connect(user).approve(await fundingPool.getAddress(), 200n);

    await fundingPool.connect(admin).unpause();
    await fundingPool.connect(admin).depositForIdeaFrom(user.address, 1, 1, 200n);

    await mockToken.setFailTransfer(true, true);

    await expect(
      fundingPool.connect(admin).distributeFunds(1, 1, 100n)
    )
      .to.be.revertedWithCustomError(fundingPool, "SafeERC20FailedOperation")
      .withArgs(await mockToken.getAddress());
  });
});

/** @notice describe: MockERC20Fail coverage */
describe("MockERC20Fail coverage", function () {
  /** @notice it: covers transfer success and failure branches */
  it("covers transfer success and failure branches", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const token = await ethers.deployContract("MockERC20Fail", ["Mock", "MOCK"]);
    await token.waitForDeployment();

    await token.mint(admin.address, 10n);
    await token.transfer(user.address, 5n);
    expect(await token.balanceOf(user.address)).to.equal(5n);

    await token.setFailTransfer(true, false);
    await expect(token.transfer(user.address, 1n)).to.be.revertedWith(
      "MockERC20Fail: transfer failed"
    );
  });

  /** @notice it: covers transferFrom failure branch */
  it("covers transferFrom failure branch", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const token = await ethers.deployContract("MockERC20Fail", ["Mock", "MOCK"]);
    await token.waitForDeployment();

    await token.mint(admin.address, 10n);
    await token.approve(user.address, 5n);

    await token.setFailTransferFrom(true, false);
    await expect(
      token.connect(user).transferFrom(admin.address, user.address, 1n)
    ).to.be.revertedWith("MockERC20Fail: transferFrom failed");
  });
});
