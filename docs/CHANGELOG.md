# Changelog

## v1.1.0

**Summary**
1. Added author stake requirements for idea creation
2. Added staged grant payouts with reviewer-approved milestones
3. Added milestone rejection cooldown and resubmission flow

**Protocol Changes**
1. `IdeaRegistryUpgradeable`
2. `FundingPoolUpgradeable`
3. `GrantManagerUpgradeable`
4. `IdeaStatus`

**What Changed**
1. Authors must stake at least `authorMinStake` when creating an idea
2. Losing ideas have their locked author stake moved to `protocolReserve`
3. Winning ideas now release grant funds in tranches: `30%` initial, `40%` in-process, `30%` completion
4. Milestone proof submissions are reviewed by addresses with `REVIEWER_ROLE`
5. In-process payout needs `3` approvals out of at most `5` reviewer votes
6. Completion payout needs `2` approvals out of at most `3` reviewer votes
7. Rejected milestone requests can be resubmitted after `48 hours`

**Status Flow**
1. `Pending -> Voting -> WonVoting -> Funded -> InProcess -> Completed`
2. `Voting -> Rejected` remains the losing path

## v1.0.0

**Summary**
1. Initial core DAO release

**What Included**
1. Idea creation and voting rounds
2. Vote staking through the funding pool
3. Winner selection and one-step grant claim flow
4. Reputation and voter progression systems
5. Upgradeable core modules
