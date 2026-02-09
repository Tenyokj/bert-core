/**
 * @file IdeaRegistryUpgradeable.fully.ts
 * @notice Idea lifecycle, status transitions, reviews, and role-gated actions.
 * @dev NatSpec-style comment for test documentation.
 */

import { expect } from "../setup.js";

import { deploySystem } from "./helpers.js";

/** @notice describe: IdeaRegistry */
describe("IdeaRegistry", function () {
  /** @notice describe: Creation */
  describe("Creation", function () {
    /** @notice it: should create idea and initialize author reputation */
    it("should create idea and initialize author reputation", async function () {
      const { ideaRegistry, reputationSystem, user1 } = await deploySystem();
      
      await expect(
        ideaRegistry.connect(user1).createIdea("Test Idea", "Detailed description", "https://example.com")
      )
        .to.emit(ideaRegistry, "IdeaCreated")
        .withArgs(1n, user1.address, "Test Idea");
      
      // Проверка данных идеи
      const idea = await ideaRegistry.getIdea(1);
      expect(idea.id).to.equal(1n);
      expect(idea.author).to.equal(user1.address);
      expect(idea.title).to.equal("Test Idea");
      expect(idea.description).to.equal("Detailed description");
      expect(idea.link).to.equal("https://example.com");
      expect(idea.totalVotes).to.equal(0n);
      expect(idea.status).to.equal(0); // Pending
      
      // Репутация должна быть инициализирована
      expect(await reputationSystem.isInitialized(user1.address)).to.be.true;
    });
    
    /** @notice it: should validate input parameters */
    it("should validate input parameters", async function () {
      const { ideaRegistry, user1 } = await deploySystem();
      
      await expect(
        ideaRegistry.connect(user1).createIdea("", "Description", "")
      ).to.be.revertedWithCustomError(ideaRegistry, "ZeroLength")
        .withArgs("title");
      
      await expect(
        ideaRegistry.connect(user1).createIdea("Title", "", "")
      ).to.be.revertedWithCustomError(ideaRegistry, "ZeroLength")
        .withArgs("description");
    });
    
    /** @notice it: should increment idea counter */
    it("should increment idea counter", async function () {
      const { ideaRegistry, user1 } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Idea 1", "Desc 1", "");
      await ideaRegistry.connect(user1).createIdea("Idea 2", "Desc 2", "");
      await ideaRegistry.connect(user1).createIdea("Idea 3", "Desc 3", "");
      
      expect(await ideaRegistry.totalIdeas()).to.equal(3n);
    });
  });
  
  /** @notice describe: Status Management */
  describe("Status Management", function () {
    /** @notice it: should update status with valid transitions */
    it("should update status with valid transitions", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      // Создаем идею
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      // Даем админу роли
      const VOTING_ROLE = await roles.VOTING_ROLE();
      const GRANT_ROLE = await roles.GRANT_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await roles.grantSystemRole(GRANT_ROLE, admin.address);
      
      // Pending → Voting
      await expect(ideaRegistry.connect(admin).updateStatus(1, 1))
        .to.emit(ideaRegistry, "IdeaStatusUpdated")
        .withArgs(1n, 1);
      
      expect(await ideaRegistry.getStatus(1)).to.equal(1); // Voting
      
      // Voting → WonVoting
      await expect(ideaRegistry.connect(admin).updateStatus(1, 2))
        .to.emit(ideaRegistry, "IdeaStatusUpdated")
        .withArgs(1n, 2);
      
      // WonVoting → Funded
      await expect(ideaRegistry.connect(admin).updateStatus(1, 3))
        .to.emit(ideaRegistry, "IdeaStatusUpdated")
        .withArgs(1n, 3);
      
      // Funded → Completed
      await expect(ideaRegistry.connect(admin).updateStatus(1, 5))
        .to.emit(ideaRegistry, "IdeaStatusUpdated")
        .withArgs(1n, 5);
    });
    
    /** @notice it: should reject invalid status transitions */
    it("should reject invalid status transitions", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      
      // Прямой переход Pending → WonVoting (невалидный)
      await expect(
        ideaRegistry.connect(admin).updateStatus(1, 2)
      ).to.be.revertedWithCustomError(ideaRegistry, "InvalidTransition");
      
      // Pending → Voting (валидный)
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      // Voting → Funded (невалидный, нужно через WonVoting)
      await expect(
        ideaRegistry.connect(admin).updateStatus(1, 3)
      ).to.be.revertedWithCustomError(ideaRegistry, "InvalidTransition");
    });
    
    /** @notice it: should reject status update to same status */
    it("should reject status update to same status", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      await expect(
        ideaRegistry.connect(admin).updateStatus(1, 1)
      ).to.be.revertedWithCustomError(ideaRegistry, "StatusUnchanged");
    });
    
    /** @notice it: should require VOTING_ROLE or GRANT_ROLE to update status */
    it("should require VOTING_ROLE or GRANT_ROLE to update status", async function () {
      const { ideaRegistry, user1, user2 } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      await expect(
        ideaRegistry.connect(user2).updateStatus(1, 1)
      ).to.be.revertedWithCustomError(ideaRegistry, "NotVotingOrGrant");
    });
  });
  
  /** @notice describe: Voting */
  describe("Voting", function () {
    /** @notice it: should add votes only in voting status */
    it("should add votes only in voting status", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      
      // Нельзя добавить голоса в статусе Pending
      await expect(
        ideaRegistry.connect(admin).addVote(1, 100)
      ).to.be.revertedWithCustomError(ideaRegistry, "NotInVotingStatus");
      
      // Переводим в Voting
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      // Теперь можно добавить голоса
      await expect(ideaRegistry.connect(admin).addVote(1, 100))
        .to.emit(ideaRegistry, "IdeaVoted")
        .withArgs(1n, admin.address, 100n);
      
      expect((await ideaRegistry.getIdea(1)).totalVotes).to.equal(100n);
    });
    
    /** @notice it: should not add zero votes */
    it("should not add zero votes", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      await expect(
        ideaRegistry.connect(admin).addVote(1, 0)
      ).to.be.revertedWithCustomError(ideaRegistry, "ZeroVoteAmount");
    });
    
    /** @notice it: should require VOTING_ROLE to add votes */
    it("should require VOTING_ROLE to add votes", async function () {
      const { ideaRegistry, user1, user2 } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      await expect(
        ideaRegistry.connect(user2).addVote(1, 100)
      ).to.be.revertedWithCustomError(ideaRegistry, "NotVotingSystem");
    });
  });
  
  /** @notice describe: Reviews and Quality */
  describe("Reviews and Quality", function () {
    /** @notice it: should allow curators to mark ideas as low quality */
    it("should allow curators to mark ideas as low quality", async function () {
      const { ideaRegistry, user1, user2, admin, roles, voterProgression } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      // Даем user2 роль CURATOR_ROLE
      await voterProgression.grantCuratorRole(user2.address);
      
      await expect(ideaRegistry.connect(user2).markLowQuality(1))
        .to.emit(ideaRegistry, "IdeaMarkedLowQuality")
        .withArgs(1n, user2.address);
      
      expect((await ideaRegistry.getIdeaStruct(1)).isLowQuality).to.be.true;
    });
    
    /** @notice it: should not allow self-marking as low quality */
    it("should not allow self-marking as low quality", async function () {
      const { ideaRegistry, user1, admin, roles, voterProgression } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      // Даем автору роль куратора (не должно работать)
      await voterProgression.grantCuratorRole(user1.address);
      
      await expect(
        ideaRegistry.connect(user1).markLowQuality(1)
      ).to.be.revertedWithCustomError(ideaRegistry, "CannotReviewOwnIdea");
    });
    
    /** @notice it: should require CURATOR_ROLE to mark low quality */
    it("should require CURATOR_ROLE to mark low quality", async function () {
      const { ideaRegistry, user1, user2, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      await expect(
        ideaRegistry.connect(user2).markLowQuality(1)
      ).to.be.revertedWithCustomError(ideaRegistry, "NotCurator");
    });
    
    /** @notice it: should allow reviewers to add reviews */
    it("should allow reviewers to add reviews", async function () {
      const { ideaRegistry, user1, user2, admin, roles, voterProgression } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      // Даем user2 роль REVIEWER_ROLE
      await voterProgression.grantReviewerRole(user2.address);
      
      await expect(ideaRegistry.connect(user2).addReview(1, "Great idea!"))
        .to.emit(ideaRegistry, "ReviewAdded")
        .withArgs(1n, user2.address);
      
      const reviews = await ideaRegistry.getIdeaReviews(1);
      expect(reviews).to.have.lengthOf(1);
      expect(reviews[0].reviewer).to.equal(user2.address);
      expect(reviews[0].comment).to.equal("Great idea!");
    });
    
    /** @notice it: should require REVIEWER_ROLE to add reviews */
    it("should require REVIEWER_ROLE to add reviews", async function () {
      const { ideaRegistry, user1, user2, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      
      await expect(
        ideaRegistry.connect(user2).addReview(1, "Comment")
      ).to.be.revertedWithCustomError(ideaRegistry, "NotReviewer");
    });
  });
  
  /** @notice describe: Completion */
  describe("Completion", function () {
    /** @notice it: should allow author to mark funded idea as completed */
    it("should allow author to mark funded idea as completed", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      const GRANT_ROLE = await roles.GRANT_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await roles.grantSystemRole(GRANT_ROLE, admin.address);
      
      // Проходим весь путь
      await ideaRegistry.connect(admin).updateStatus(1, 1); // Voting
      await ideaRegistry.connect(admin).updateStatus(1, 2); // WonVoting
      await ideaRegistry.connect(admin).updateStatus(1, 3); // Funded
      
      // Автор может отметить как завершенную
      await expect(ideaRegistry.connect(user1).markAsCompleted(1))
        .to.emit(ideaRegistry, "IdeaStatusUpdated")
        .withArgs(1n, 5); // Completed
      
      expect(await ideaRegistry.getStatus(1)).to.equal(5);
    });
    
    /** @notice it: should not allow non-author to mark as completed */
    it("should not allow non-author to mark as completed", async function () {
      const { ideaRegistry, user1, user2, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      const GRANT_ROLE = await roles.GRANT_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      await roles.grantSystemRole(GRANT_ROLE, admin.address);
      
      await ideaRegistry.connect(admin).updateStatus(1, 1);
      await ideaRegistry.connect(admin).updateStatus(1, 2);
      await ideaRegistry.connect(admin).updateStatus(1, 3);
      
      await expect(
        ideaRegistry.connect(user2).markAsCompleted(1)
      ).to.be.revertedWithCustomError(ideaRegistry, "NotAuthor");
    });
    
    /** @notice it: should require funded status to mark as completed */
    it("should require funded status to mark as completed", async function () {
      const { ideaRegistry, user1, admin, roles } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      const VOTING_ROLE = await roles.VOTING_ROLE();
      await roles.grantSystemRole(VOTING_ROLE, admin.address);
      
      await ideaRegistry.connect(admin).updateStatus(1, 1); // Voting
      
      await expect(
        ideaRegistry.connect(user1).markAsCompleted(1)
      ).to.be.revertedWithCustomError(ideaRegistry, "NotInCorrectStatus");
    });
  });
  
  /** @notice describe: View Functions */
  describe("View Functions", function () {
    /** @notice it: should return ideas by author */
    it("should return ideas by author", async function () {
      const { ideaRegistry, user1, user2 } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Idea 1", "Desc 1", "");
      await ideaRegistry.connect(user1).createIdea("Idea 2", "Desc 2", "");
      await ideaRegistry.connect(user2).createIdea("Idea 3", "Desc 3", "");
      
      const user1Ideas = await ideaRegistry.getIdeasByAuthor(user1.address);
      const user2Ideas = await ideaRegistry.getIdeasByAuthor(user2.address);
      
      expect(user1Ideas).to.have.lengthOf(2);
      expect(user1Ideas[0]).to.equal(1n);
      expect(user1Ideas[1]).to.equal(2n);
      
      expect(user2Ideas).to.have.lengthOf(1);
      expect(user2Ideas[0]).to.equal(3n);
    });
    
    /** @notice it: should return author of idea */
    it("should return author of idea", async function () {
      const { ideaRegistry, user1 } = await deploySystem();
      
      await ideaRegistry.connect(user1).createIdea("Test", "Desc", "");
      
      expect(await ideaRegistry.getIdeaAuthor(1)).to.equal(user1.address);
    });
    
    /** @notice it: should revert for non-existent idea */
    it("should revert for non-existent idea", async function () {
      const { ideaRegistry } = await deploySystem();
      
      await expect(ideaRegistry.getIdea(999))
        .to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist")
        .withArgs(999n);
      
      await expect(ideaRegistry.getIdeaAuthor(999))
        .to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist")
        .withArgs(999n);
      
      await expect(ideaRegistry.getStatus(999))
        .to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist")
        .withArgs(999n);
    });
  });
});

/** @notice describe: IdeaRegistryUpgradeable edge cases */
describe("IdeaRegistryUpgradeable edge cases", function () {
  /** @notice it: rejects updateStatus from unauthorized caller */
  it("rejects updateStatus from unauthorized caller", async function () {
    const { user1, user2, ideaRegistry } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    await expect(
      ideaRegistry.connect(user2).updateStatus(1, 1)
    ).to.be.revertedWithCustomError(ideaRegistry, "NotVotingOrGrant");
  });

  /** @notice it: rejects markAsCompleted when not funded */
  it("rejects markAsCompleted when not funded", async function () {
    const { user1, ideaRegistry } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    await expect(
      ideaRegistry.connect(user1).markAsCompleted(1)
    ).to.be.revertedWithCustomError(ideaRegistry, "NotInCorrectStatus");
  });

  /** @notice it: rejects addReview and markLowQuality when not voting */
  it("rejects addReview and markLowQuality when not voting", async function () {
    const { admin, user1, user2, ideaRegistry, voterProgression, roles } =
      await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    await voterProgression.grantCuratorRole(user2.address);
    await voterProgression.grantReviewerRole(user2.address);

    await expect(
      ideaRegistry.connect(user2).markLowQuality(1)
    ).to.be.revertedWithCustomError(ideaRegistry, "NotInVotingStatus");

    await expect(
      ideaRegistry.connect(user2).addReview(1, "Nice")
    ).to.be.revertedWithCustomError(ideaRegistry, "NotInVotingStatus");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await ideaRegistry.connect(admin).updateStatus(1, 1);

    await expect(ideaRegistry.connect(user2).addReview(1, "Nice"))
      .to.emit(ideaRegistry, "ReviewAdded")
      .withArgs(1n, user2.address);
  });
});

/** @notice describe: IdeaRegistryUpgradeable extra coverage */
describe("IdeaRegistryUpgradeable extra coverage", function () {
  /** @notice it: handles invalid IDs and GRANT_ROLE access on updateStatus */
  it("handles invalid IDs and GRANT_ROLE access on updateStatus", async function () {
    const { admin, user1, ideaRegistry, roles } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    const GRANT_ROLE = await roles.GRANT_ROLE();
    await roles.grantSystemRole(GRANT_ROLE, admin.address);

    await expect(
      ideaRegistry.connect(admin).updateStatus(0, 1)
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");

    await expect(
      ideaRegistry.connect(admin).updateStatus(2, 1)
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");

    await expect(
      ideaRegistry.connect(admin).updateStatus(1, 1)
    ).to.emit(ideaRegistry, "IdeaStatusUpdated");
  });

  /** @notice it: allows Voting -> Rejected transition */
  it("allows Voting -> Rejected transition", async function () {
    const { admin, user1, ideaRegistry, roles } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await ideaRegistry.connect(admin).updateStatus(1, 1);

    await expect(
      ideaRegistry.connect(admin).updateStatus(1, 4)
    ).to.emit(ideaRegistry, "IdeaStatusUpdated");
  });

  /** @notice it: rejects addVote for invalid IDs and non-voting caller */
  it("rejects addVote for invalid IDs and non-voting caller", async function () {
    const { admin, user1, ideaRegistry, roles } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    await expect(
      ideaRegistry.connect(user1).addVote(1, 1)
    ).to.be.revertedWithCustomError(ideaRegistry, "NotVotingSystem");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);

    await expect(
      ideaRegistry.connect(admin).addVote(0, 1)
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");

    await expect(
      ideaRegistry.connect(admin).addVote(2, 1)
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");
  });

  /** @notice it: rejects reviews and low-quality for invalid IDs and self-review */
  it("rejects reviews and low-quality for invalid IDs and self-review", async function () {
    const { admin, user1, ideaRegistry, voterProgression, roles } =
      await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    await voterProgression.grantCuratorRole(user1.address);
    await voterProgression.grantReviewerRole(user1.address);

    const VOTING_ROLE = await roles.VOTING_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await ideaRegistry.connect(admin).updateStatus(1, 1);

    await expect(
      ideaRegistry.connect(user1).addReview(1, "Self")
    ).to.be.revertedWithCustomError(ideaRegistry, "CannotReviewOwnIdea");

    await expect(
      ideaRegistry.connect(user1).markLowQuality(2)
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");

    await expect(
      ideaRegistry.connect(user1).addReview(2, "Bad id")
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");
  });

  /** @notice it: rejects markAsCompleted for invalid ID */
  it("rejects markAsCompleted for invalid ID", async function () {
    const { user1, ideaRegistry } = await deploySystem();

    await expect(
      ideaRegistry.connect(user1).markAsCompleted(0)
    ).to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist");
  });

  /** @notice it: returns view data for author and idea structs */
  it("returns view data for author and idea structs", async function () {
    const { user1, ideaRegistry } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    const ideas = await ideaRegistry.getIdeasByAuthor(user1.address);
    expect(ideas.length).to.equal(1);
    expect(ideas[0]).to.equal(1n);

    const status = await ideaRegistry.getStatus(1);
    expect(status).to.equal(0n);

    const idea = await ideaRegistry.getIdeaStruct(1);
    expect(idea.author).to.equal(user1.address);
    expect(await ideaRegistry.getReviewCount(1)).to.equal(0n);
  });

  /** @notice it: rejects invalid transitions for each stage */
  it("rejects invalid transitions for each stage", async function () {
    const { admin, user1, ideaRegistry, roles } = await deploySystem();

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");

    const VOTING_ROLE = await roles.VOTING_ROLE();
    const GRANT_ROLE = await roles.GRANT_ROLE();
    await roles.grantSystemRole(VOTING_ROLE, admin.address);
    await roles.grantSystemRole(GRANT_ROLE, admin.address);

    await expect(
      ideaRegistry.connect(admin).updateStatus(1, 2)
    ).to.be.revertedWithCustomError(ideaRegistry, "InvalidTransition");

    await ideaRegistry.connect(admin).updateStatus(1, 1);

    await expect(
      ideaRegistry.connect(admin).updateStatus(1, 3)
    ).to.be.revertedWithCustomError(ideaRegistry, "InvalidTransition");

    await ideaRegistry.connect(admin).updateStatus(1, 2);

    await expect(
      ideaRegistry.connect(admin).updateStatus(1, 5)
    ).to.be.revertedWithCustomError(ideaRegistry, "InvalidTransition");

    await ideaRegistry.connect(admin).updateStatus(1, 3);

    await expect(
      ideaRegistry.connect(admin).updateStatus(1, 4)
    ).to.be.revertedWithCustomError(ideaRegistry, "InvalidTransition");
  });

  /** @notice it: rejects invalid IDs for getIdeaStruct/getStatus and returns reviews */
  it("rejects invalid IDs for getIdeaStruct/getStatus and returns reviews", async function () {
    const { user1, ideaRegistry } = await deploySystem();

    await expect(ideaRegistry.getIdeaStruct(1))
      .to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist")
      .withArgs(1n);

    await expect(ideaRegistry.getStatus(1))
      .to.be.revertedWithCustomError(ideaRegistry, "IdeaDoesNotExist")
      .withArgs(1n);

    await ideaRegistry.connect(user1).createIdea("Idea", "Desc", "");
    const reviews = await ideaRegistry.getIdeaReviews(1);
    expect(reviews.length).to.equal(0);
  });

  /** @notice it: sets reputation system and voter progression successfully */
  it("sets reputation system and voter progression successfully", async function () {
    const { admin, ideaRegistry, reputationSystem, voterProgression } =
      await deploySystem();

    await ideaRegistry.connect(admin).setReputationSystem(
      await reputationSystem.getAddress()
    );
    await ideaRegistry.connect(admin).setVoterProgression(
      await voterProgression.getAddress()
    );
  });

  /** @notice it: enforces admin-only setters and zero address checks */
  it("enforces admin-only setters and zero address checks", async function () {
    const { admin, user1, ethers, ideaRegistry, reputationSystem, voterProgression } =
      await deploySystem();

    await expect(
      ideaRegistry.connect(user1).setReputationSystem(await reputationSystem.getAddress())
    ).to.be.revertedWithCustomError(ideaRegistry, "NotAdmin");

    await expect(
      ideaRegistry.setReputationSystem(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(ideaRegistry, "ZeroAddress");

    await expect(
      ideaRegistry.connect(user1).setVoterProgression(await voterProgression.getAddress())
    ).to.be.revertedWithCustomError(ideaRegistry, "NotAdmin");

    await expect(
      ideaRegistry.setVoterProgression(ethers.ZeroAddress)
    ).to.be.revertedWithCustomError(ideaRegistry, "ZeroAddress");
  });
});
