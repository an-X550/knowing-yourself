# Manual Review Readiness Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing manual review-readiness detector reachable through Codex semantic natural-language intent and no-argument `/review`, returning only one recommendation and never writing data.

**Architecture:** Keep `review-readiness-checker` as the single decision authority. Make `/review` explicitly dispatch to it only for a no-argument request, and add a Codex routing contract block that maps natural-language readiness requests to that same command and agent. Tests verify the route and non-writing boundary as text contracts.

**Tech Stack:** Markdown runtime contracts, PowerShell contract tests, existing user-package export script.

## Global Constraints

- Do not add a scheduler, hook, state file, report type, or automatic write.
- Keep explicit date/period review routing unchanged.
- A readiness check returns at most one recommendation and may return an empty string.
- Natural-language examples are illustrative, not a fixed keyword list. Route only the semantic intent "what should I update/review next?".
- Explicit requests for a dated/periodic/project/life-design review bypass the readiness check; ordinary conversation and a single emotion do not route to it.
- Mirror product behavior into `packaging/zhiji-user-overlay/` and regenerate `zhiji-user/`.

---

### Task 1: Define the unified routing contract

**Files:**
- Modify: `.claude/commands/review.md`
- Modify: `.claude/agents/review-readiness-checker.md`
- Modify: `.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `packaging/zhiji-user-overlay/.claude/commands/review.md`
- Modify: `packaging/zhiji-user-overlay/.claude/agents/review-readiness-checker.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/codex-natural-language-routing.md`
- Test: `tests/review-readiness-routing.tests.ps1`

**Interfaces:**
- Consumes: a no-argument `/review` request or a natural-language request to check the next needed update or review.
- Produces: one <=80-character recommendation or an empty string; no file writes and no report generation.

- [ ] **Step 1: Write the failing test**

Create a PowerShell test that requires the actual Codex routing body (not only YAML metadata) to define positive semantic examples, negative boundaries, the `/review` fallback, the checker route, one-result output, and no write/report behavior.

- [ ] **Step 2: Run test to verify it fails**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure because no current Codex routing body declares semantic readiness intent boundaries.

- [ ] **Step 3: Write minimal implementation**

Add one `## 手动复盘前检查` block to the Codex routing contract. Change no-argument `/review` to explicitly invoke `review-readiness-checker`, and make the agent output boundary explicit. Copy the resulting three runtime files to the overlay.

- [ ] **Step 4: Run test to verify it passes**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: `PASS: review readiness routing contract checks`.

### Task 2: Regenerate the package and verify integration

**Files:**
- Modify: `zhiji-user/` generated controlled files
- Test: `tests/codex-routing-contract.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`
- Test: `tests/distribution-boundary.tests.ps1`

**Interfaces:**
- Consumes: synchronized overlay definitions.
- Produces: user package files matching manifest and boundary declarations.

- [ ] **Step 1: Export the user package**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1`

- [ ] **Step 2: Run focused and integration checks**

Run the new readiness test plus `tests/codex-routing-contract.tests.ps1`, `tests/project-integrity.tests.ps1`, and `tests/distribution-boundary.tests.ps1`.

Expected: every script exits 0 and reports PASS.

- [ ] **Step 3: Audit the exact requirements**

Confirm the final diff shows both entry forms pointing to the same command/agent, exactly one recommendation output, and no scheduler/write/report behavior.
