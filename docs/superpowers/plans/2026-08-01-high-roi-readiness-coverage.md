# High-ROI Readiness Coverage Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. User explicitly requires inline execution; do not dispatch subagents.

**Goal:** Turn the existing review-readiness checker into the single, evidence-based source of one high-value manual next-step recommendation.

**Architecture:** Keep all eligibility and priority rules in `review-readiness-checker`. Natural-language routing and no-argument `/review` only dispatch to it. The checker inspects existing journals, daily feedback, reports, `current.md`, and coach reports; it returns zero or one recommendation and never writes. Contract tests define every threshold and distribution boundary.

**Tech Stack:** Markdown runtime contracts, PowerShell contract tests, existing user-package export script.

## Global Constraints

- Do not add a scheduler, Stop hook, keyword hook, state file, automatic report, or automatic personal-content write.
- Preserve daily-feedback writeback to `context.verified_patterns` exactly as the existing evidence contract defines it.
- A file's age alone must never trigger a suggestion; every candidate requires new relevant evidence plus a missing or stale downstream artifact.
- Use semantic natural-language routing; do not retain a fixed trigger phrase list as executable behavior.
- Output zero or one short recommendation only; no candidate list, long explanation, or auto-execution.
- Keep explicit date, period, project, and life-design requests on their existing direct routes.
- Mirror runtime behavior to `packaging/zhiji-user-overlay/`, regenerate `zhiji-user/`, and preserve user-package overrides that are unrelated to this feature.

---

### Task 1: Make the readiness checker the single decision source

**Files:**
- Modify: `.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `.claude/commands/review.md`
- Modify: `.claude/agents/review-readiness-checker.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `packaging/zhiji-user-overlay/.claude/commands/review.md`
- Modify: `packaging/zhiji-user-overlay/.claude/agents/review-readiness-checker.md`
- Test: `tests/review-readiness-routing.tests.ps1`

**Interfaces:**
- Consumes: a semantic request for the next needed update/review, or a no-argument `/review`.
- Produces: a dispatch to `review-readiness-checker`, with explicit direct-route exclusions for dated/periodic/project/life-design requests.

- [ ] **Step 1: Write the failing routing test**

Add assertions that fail while the frontmatter contains `manual_readiness_intents`, and that require the command body to delegate eligibility and priority to `review-readiness-checker` rather than list numbered readiness conditions.

- [ ] **Step 2: Run the routing test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure naming the fixed-intent metadata and/or duplicated readiness rules.

- [ ] **Step 3: Implement the minimal routing consolidation**

Remove `manual_readiness_intents` from both routing-contract frontmatters. Keep semantic examples in Markdown body with an explicit “examples are non-exhaustive” boundary. Replace the numbered readiness conditions in both `review.md` files with a single delegation statement: the checker is the only eligibility and priority authority. Retain output, non-writing, and direct-route boundaries.

- [ ] **Step 4: Run the routing test and verify GREEN**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: `PASS: review readiness routing contract checks`.

### Task 2: Add deterministic evidence thresholds to the checker

**Files:**
- Modify: `.claude/agents/review-readiness-checker.md`
- Modify: `packaging/zhiji-user-overlay/.claude/agents/review-readiness-checker.md`
- Test: `tests/review-readiness-routing.tests.ps1`

**Interfaces:**
- Consumes: journals, daily feedback, weekly/monthly/yearly reports, `current.md`, coach reports, and the current system date via `paths.md`.
- Produces: one recommendation in the first matching priority category, or an empty string.

- [ ] **Step 1: Write failing checker-contract cases**

Add exact assertions for all of the following requirements:

```text
Daily-feedback gap: last 7 days have >=3 journals and >=2 lack matching daily feedback.
Period review: retain existing material and calendar conditions.
Current-context gap: after current.md, within 14 days there are >=3 daily feedback files and >=1 contains a current-focus, pending-decision, health/relationship, or direction change.
Coach gap: since the latest coach report there are >=7 new journals and >=14 elapsed days.
Life-design: retain existing strong-signal evidence rule.
Every candidate needs evidence; last_updated alone is insufficient.
First match wins; output is zero or one recommendation.
```

- [ ] **Step 2: Run the checker-contract test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure naming each missing threshold or priority boundary.

- [ ] **Step 3: Implement the checker rules and output templates**

Update the main checker, in this exact priority order:

1. recent daily-feedback and verification gap;
2. existing monthly, weekly, and yearly review readiness;
3. current-context gap;
4. coach sampling gap;
5. existing life-design strong/weak signal rules;
6. no suggestion.

For daily feedback, name one oldest missing journal date. For current context, state the material-change category and suggest `/update-current`. For coach, suggest `/journal-coach`. Do not infer a material change merely from timestamps. Keep the existing report thresholds and strong/weak life-design definitions unchanged.

- [ ] **Step 4: Mirror the checker into the overlay**

Apply the same readiness behavior to the overlay checker, retaining only pre-existing user-package-specific differences.

- [ ] **Step 5: Run the checker-contract test and verify GREEN**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: `PASS: review readiness routing contract checks`.

### Task 3: Verify distribution and release documentation

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Generated: `zhiji-user/.claude/shared/contracts/codex-natural-language-routing.md`
- Generated: `zhiji-user/.claude/commands/review.md`
- Generated: `zhiji-user/.claude/agents/review-readiness-checker.md`
- Test: `tests/distribution-boundary.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: synchronized overlay runtime files.
- Produces: generated user-package runtime files matching overlay sources, release facts matching the new feature behavior.

- [ ] **Step 1: Write a failing distribution assertion**

Extend the readiness test to compare the three generated user-package files with their overlay source files and require all new no-scheduler, no-write and one-recommendation boundaries.

- [ ] **Step 2: Run the readiness test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure until the package is regenerated.

- [ ] **Step 3: Update release facts and export the package**

Increment the minor version because this is a backward-compatible user-visible capability. Update `PROJECT_STATUS.md` and add one top CHANGELOG entry describing the unified evidence-based readiness check and boundaries. Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

- [ ] **Step 4: Verify the package and focused integrations**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: every command exits 0 and prints PASS.

### Task 4: Run complete regression and record real-use validation

**Files:**
- Modify: `PROJECT_STATUS.md`
- Test: all `tests/*.tests.ps1`

**Interfaces:**
- Consumes: completed runtime files, generated package, and future real user invocations.
- Produces: verified release state and an explicit evidence requirement for future threshold adjustment.

- [ ] **Step 1: Run the complete PowerShell regression suite**

Run:

```powershell
$testFiles = Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | Sort-Object Name
foreach ($testFile in $testFiles) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $testFile.FullName
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Expected: every test script exits 0.

- [ ] **Step 2: Perform acceptance audit**

Confirm from the final diff that no changed path is `settings.json`, `.claude/workflows/`, a new scheduler/state file, or a personal-content file. Confirm there is no second priority list outside `review-readiness-checker`.

- [ ] **Step 3: Record the real-use gate**

In `PROJECT_STATUS.md`, add a high-priority validation item requiring three actual readiness checks. For each, observe whether the recommendation was actionable, ignored as noise, or failed to identify a needed action. Do not change thresholds or add categories without a repeated real-use finding.

- [ ] **Step 4: Commit the completed behavior**

Run the project’s local commit flow after all tests pass. Do not push or merge without an explicit user request.
