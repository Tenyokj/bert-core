/**
 * @file Upgradeability.edge.ts
 * @notice ERC1967 proxy upgrade and storage preservation.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect, toBeHex } from "../setup.js";
import { deploySystem } from "./helpers.js";

/** @notice describe: Upgradeability edge cases */
describe("Upgradeability edge cases", function () {
  /** @notice it: upgrades ERC1967 proxy to V2 and preserves storage */
  it("upgrades ERC1967 proxy to V2 and preserves storage", async function () {
    const { ethers, admin, votingSystem } = await deploySystem();

    await votingSystem.connect(admin).setMinStake(123n);
    await votingSystem.connect(admin).setIdeaPerRound(15);

    const proxyAddress = await votingSystem.getAddress();

    const implV2 = await (await ethers.getContractFactory("MockVotingSystemV2", admin)).deploy();
    await implV2.waitForDeployment();

    const implSlot =
      BigInt(
        ethers.keccak256(ethers.toUtf8Bytes("eip1967.proxy.implementation"))
      ) - 1n;
    const slotHex = toBeHex(implSlot, 32);

    const implBefore = await ethers.provider.getStorage(proxyAddress, slotHex);

    await ethers.provider.send("hardhat_setStorageAt", [
      proxyAddress,
      slotHex,
      ethers.zeroPadValue(await implV2.getAddress(), 32),
    ]);

    const implAfter = await ethers.provider.getStorage(proxyAddress, slotHex);
    expect(implAfter).to.not.equal(implBefore);

    const votingV2 = await ethers.getContractAt(
      "MockVotingSystemV2",
      proxyAddress,
      admin
    );

    expect(await votingV2.minStake()).to.equal(123n);
    expect(await votingV2.IDEAS_PER_ROUND()).to.equal(15n);
    expect(await votingV2.v2Value()).to.equal(0n);

    await votingV2.setV2Value(999n);
    expect(await votingV2.v2Value()).to.equal(999n);
    expect(await votingV2.version()).to.equal(2n);
  });
});
