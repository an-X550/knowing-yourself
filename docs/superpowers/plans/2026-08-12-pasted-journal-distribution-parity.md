# Pasted Journal Distribution Parity Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the pasted-journal route invoke the existing daily-feedback distribution contract after a verified new local write and verification persistence.

**Architecture:** Keep `.claude/skills/log.md` as the primary runtime route and mirror the new single-day post-write distribution semantics into the user overlay. Preserve the overlay's declared multi-day import override, reuse the existing `result-distribution.md` contract, and do not introduce a new executable distributor or change analysis behavior.

**Tech Stack:** Markdown runtime contracts, PowerShell regression tests, Git version governance.

## Global Constraints

- Only distribute after a current-turn new write has been re-read as non-empty and structurally valid.
- Update `context.verified_patterns` before invoking external distribution.
- Skip distribution for local-only requests, D-level input, unknown dates, analysis failure, or invalid writes.
- External failures never roll back or downgrade local feedback or verification persistence.
- Do not change daily analysis, weekly/monthly review, reminder, Feishu folder, or TickTick action rules.

---

### Task 1: Close pasted-journal distribution parity

**Files:**
- Modify: `tests/result-distribution-routing.tests.ps1`
- Modify: `.claude/skills/log.md`
- Modify: `packaging/zhiji-user-overlay/.claude/skills/log.md`
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md`
- Modify: `docs/specs/evolution-roadmap.md`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Modify: `zhiji-user/README.md`

**Interfaces:**
- Consumes: `distribute output.daily_feedback <resolved-local-path>` from `.claude/shared/contracts/result-distribution.md`.
- Produces: identical post-write behavior for `/daily-review` and single pasted-journal inputs.

- [x] **Step 1: Write the failing route assertions**

Add assertions for both main and overlay `log.md` requiring the distribution contract, current-turn new-write proof, disk re-read, local-only skip, failure boundaries, and the ordered route `write -> re-read -> verified-patterns -> distribute`.

- [x] **Step 2: Run the targeted test and verify RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-routing.tests.ps1`

Expected: FAIL because `.claude/skills/log.md` does not reference `result-distribution.md` or `distribute output.daily_feedback`.

- [x] **Step 3: Add the minimal post-write distribution route**

Update `.claude/skills/log.md` so a formally generated single-day feedback is re-read and structurally checked, verification persistence completes, and then—unless the request is local-only—the existing distribution contract is invoked. Explicitly skip D-level, date-unknown, analysis-failed, write-failed, and cache/read-only paths. Apply the same single-day post-write semantics to the overlay without changing its declared multi-day import override.

- [x] **Step 4: Run the targeted test and verify GREEN**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-routing.tests.ps1`

Expected: `PASS: result distribution routing checks`.

- [x] **Step 5: Synchronize release facts**

Increment `VERSION` from `1.15.3` to `1.15.4`, update `PROJECT_STATUS.md` to record pasted-journal distribution parity, prepend one `[修复]` entry to `CHANGELOG.md`, and mechanically synchronize all tracked current-version references. Do not otherwise rewrite README content because entry names, installation, command table, and public directory structure do not change.

- [x] **Step 6: Run focused and full verification**

Run the targeted routing test, all `tests/*.tests.ps1`, the shared semantic assertions for both `log.md` files, version consistency checks, and `git diff --check`.

Expected: all commands exit `0`, all test scripts report PASS, both `log.md` files satisfy the same single-day distribution assertions, and version is `1.15.4` in all required governance files.

- [x] **Step 7: Commit the implementation**

Stage only the files listed above plus this implementation plan. Commit with the newest `CHANGELOG.md` entry as the message. Do not stage unrelated untracked files and do not push.
