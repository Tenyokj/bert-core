/**
 * @file RolesAwareUpgradeable.ts
 * @notice Modifier behavior for role-gated access.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "./setup.js";
import { deployUpgradeable, getConnection } from "./helpers.js";

/** @notice describe: RolesAwareUpgradeable modifier coverage */
describe("RolesAwareUpgradeable modifier coverage", function () {
  /** @notice it: reverts for onlyGrantManager and onlyIdeaRegistry without roles */
  it("reverts for onlyGrantManager and onlyIdeaRegistry without roles", async function () {
    const { ethers } = await getConnection();
    const [admin, user] = await ethers.getSigners();

    const roles = await deployUpgradeable(ethers, admin, "RolesRegistryUpgradeable", []);
    const mock = await deployUpgradeable(ethers, admin, "MockRolesAware", [
      await roles.getAddress(),
    ]);

    await expect(
      mock.connect(user).onlyGrantManagerFn()
    ).to.be.revertedWithCustomError(mock, "NotGrantManager");

    await expect(
      mock.connect(user).onlyIdeaRegistryFn()
    ).to.be.revertedWithCustomError(mock, "NotIdeaRegistry");
  });
});
