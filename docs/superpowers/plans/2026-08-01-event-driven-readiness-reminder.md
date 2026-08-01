# Event-Driven Readiness Reminder Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. User explicitly requires inline execution on `main`; do not dispatch subagents or create a worktree.

**Goal:** Deliver at most one evidence-based reminder after a successful new daily feedback while suppressing repeats for seven days without automatically changing personal content.

**Architecture:** Extend `review-readiness-checker` with an explicit `delivery` input mode. Only that mode may write the disposable readiness-delivery state; normal natural-language and `/review` checks remain read-only. `/daily-review` and the `log` skill invoke delivery mode only after saving a new daily feedback and completing existing `verified-patterns` writeback.

**Tech Stack:** Markdown runtime contracts, PowerShell contract tests, existing user-package export script.

## Global Constraints

- Do not add a scheduler, Stop hook, global keyword hook, report type, or automatic personal-content update.
- Keep all existing direct readiness checks read-only; only `delivery` mode may write `output.readiness_delivery_state`.
- Do not invoke delivery mode on the daily-feedback cache-hit path, D-grade input, missing journal, or analysis failure.
- The displayed reminder is a separate one-line chat message, never part of `output.daily_feedback`.
- A candidate is eligible for re-display only when its signature changes or seven days have elapsed.
- Mirror all runtime changes to `packaging/zhiji-user-overlay/` and regenerate `zhiji-user/`.

---

### Task 1: Define reminder state and delivery-mode contract

**Files:**
- Modify: `.claude/shared/paths.md`
- Create: `.claude/shared/contracts/readiness-delivery.md`
- Modify: `.claude/agents/review-readiness-checker.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/paths.md`
- Create: `packaging/zhiji-user-overlay/.claude/shared/contracts/readiness-delivery.md`
- Modify: `packaging/zhiji-user-overlay/.claude/agents/review-readiness-checker.md`
- Test: `tests/review-readiness-routing.tests.ps1`

**Interfaces:**
- Consumes: `delivery` input after a newly saved daily feedback, `paths.md`, current readiness candidate, and `output.readiness_delivery_state`.
- Produces: one `🔔 提醒：...` line or an empty string; state table keyed by candidate and stable signature.

- [x] **Step 1: Write the failing contract assertions**

Require `output.readiness_delivery_state` at `复盘/.readiness-delivery-state.md`; require delivery mode, candidate/signature/notified-on fields, seven-day suppression, signature-change re-display, stale-record removal, and read-only direct mode. Assert the agent allows `Write` only under explicit delivery-mode language.

- [x] **Step 2: Run the readiness test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure naming missing delivery state path and contract requirements.

- [x] **Step 3: Add the minimal delivery contract**

Add this path row to both `paths.md` files:

```markdown
| `output.readiness_delivery_state` | `复盘/.readiness-delivery-state.md` | `review-readiness-checker` in delivery mode |
```

Create `readiness-delivery.md` in both source trees. It must define the Markdown state table columns `candidate`, `signature`, and `notified_on`; the approved candidate signatures; seven-day suppression; signature-change re-display; candidate disappearance cleanup; and damaged/missing-state recovery.

Update both checker files: input `delivery` is valid only after successful new daily feedback; direct mode remains read-only; delivery mode reads/writes only `output.readiness_delivery_state`; it returns exactly `🔔 提醒：{recommendation}` or an empty string.

- [x] **Step 4: Run the readiness test and verify GREEN**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: `PASS: review readiness routing contract checks`.

### Task 2: Invoke delivery only after new daily feedback succeeds

**Files:**
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`
- Modify: `packaging/zhiji-user-overlay/.claude/commands/daily-review.md`
- Modify: `packaging/zhiji-user-overlay/.claude/skills/log.md`
- Test: `tests/review-readiness-routing.tests.ps1`

**Interfaces:**
- Consumes: saved `output.daily_feedback` and completed `context.verified_patterns` update.
- Produces: an optional separate reminder line after the existing daily-feedback chat output.

- [x] **Step 1: Write failing delivery-invocation assertions**

Require both daily entry files to invoke `review-readiness-checker` with `delivery` only after feedback save and verification writeback. Require cache-hit, D-grade, missing-journal, and failure paths to state that they do not invoke delivery. Require the visible output boundary `🔔 提醒：` to be separate from saved feedback.

- [x] **Step 2: Run the readiness test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure naming missing delivery invocation and skip boundaries.

- [x] **Step 3: Add the two minimal invocations**

In `/daily-review`, after step 5 saves feedback and writes verification state, invoke the checker with `delivery`; append its non-empty return as a separate chat line. Add an explicit no-delivery statement to the cache-hit, D-grade, missing-journal, and analysis-failure branches.

In `log.md`, after its saved feedback and verification writeback, perform the same invocation and display rule. Do not change the written feedback text or duplicate the readiness priority logic in either caller.

- [x] **Step 4: Mirror and run the readiness test**

Apply the same runtime behavior to the overlay files, then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1
```

Expected: PASS.

### Task 3: Export, release, and verify boundaries

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md` when the version badge changes
- Generated: `zhiji-user/`
- Test: `tests/distribution-boundary.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: synchronized overlay source.
- Produces: user package with matching delivery contract and release facts.

- [x] **Step 1: Add a failing generated-package comparison**

Extend the readiness test to compare the generated delivery contract, `paths.md`, daily command, and log skill with their overlay source files.

- [x] **Step 2: Run the readiness test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1`

Expected: failure until `zhiji-user/` is regenerated.

- [x] **Step 3: Update release facts and export**

Increment the minor version because event-driven user-visible reminders are a new backward-compatible capability. Update `PROJECT_STATUS.md` with a three-real-run effectiveness gate; add one top CHANGELOG entry; update the README badge; then run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

- [x] **Step 4: Run focused checks**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-readiness-routing.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: every script exits 0.

### Task 4: Full verification and local commit

**Files:**
- Test: all `tests/*.tests.ps1`

- [x] **Step 1: Run the full PowerShell suite**

```powershell
$testFiles = Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | Sort-Object Name
foreach ($testFile in $testFiles) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $testFile.FullName
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Expected: every script exits 0.

- [x] **Step 2: Audit exact boundaries**

Confirm the final diff contains no `settings.json`, `.claude/workflows/`, personal-content file, scheduler, Stop hook, or global keyword hook change. Confirm the only new automatic write target is `output.readiness_delivery_state`, and direct readiness checks remain read-only.

- [ ] **Step 3: Commit**

After verification, use the project local commit flow. Do not push.
