**Mocks Overview**

Mocks are simplified or purpose-built contracts used only for testing. They simulate edge cases, failure modes, and upgrade scenarios that are hard to reproduce with production contracts.

**Purpose**
1. Isolate behavior for a single feature
2. Force failure paths for revert coverage
3. Validate upgradeability and storage safety
4. Speed up testing by reducing dependencies

**Scope**
1. Mocks are not deployed in production
2. Mocks are only used in test suites
3. Mocks may intentionally break assumptions to validate error handling

**Examples**
1. Mock contracts that revert on token transfers
2. Mock versions that add new storage for upgrade tests
3. Mock registry/roles contracts to expose internal state
