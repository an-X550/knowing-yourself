# Reminder and Result Distribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remind the user to start reviews, then independently copy successfully written local results to Feishu and create only qualified next-cycle actions in TickTick without adding any reverse synchronization.

**Architecture:** Keep Codex reminders outside the repository and keep local files authoritative. After a new local result passes write verification, a shared runtime contract invokes two isolated distributors: the official Feishu CLI imports the Markdown file as docx, and the official regional TickTick MCP creates extracted actions. A gitignored local config enables channels; a gitignored state ledger provides per-channel idempotency and retry evidence.

**Tech Stack:** Markdown runtime contracts, Claude/Codex prompt routing, official `@larksuite/cli`, official TickTick/Dida365 MCP, JSON local config/state, PowerShell contract and integrity tests.

## Global Constraints

- Do not create a review automatically from a schedule. A scheduled task may only remind the user to start an existing review entry.
- Do not add a Feishu chat bot, Notion, a daemon, a queue, a database, or a new report type.
- Do not read TickTick tasks, completion state, habits, projects, or history. The only TickTick write is create-task.
- Do not upload journals, profiles, verification stores, intermediate perspective analyses, config, or state.
- Treat the successful local write as the primary transaction. External failures never delete, rewrite, or downgrade it.
- Invoke Feishu and TickTick independently and persist their results independently; one channel failure must not skip the other.
- Never persist App Secret, access token, refresh token, tenant token, device code, or MCP bearer token in the repository or `复盘/`.
- Use the official Feishu CLI instead of a custom Feishu REST client. Use application identity for routine imports.
- Same-folder Feishu imports are serialized. There is no unbounded automatic retry.
- Same source path plus same SHA-256 plus successful channel state is a no-op. Changed content after delivery requires explicit redispatch confirmation.
- Mirror runtime changes into `packaging/zhiji-user-overlay/` and regenerate `zhiji-user/` before release.
- Do not update `VERSION`, `CHANGELOG.md`, `PROJECT_STATUS.md`, or README until implementation and live opt-in behavior are accepted as release facts.

---

### Task 1: Lock the distribution boundary with failing tests

**Files:**
- Create: `tests/result-distribution-contract.tests.ps1`
- Read: `.claude/shared/paths.md`
- Read: `.claude/shared/contracts/daily-feedback.md`
- Read: `.claude/shared/contracts/review-synthesis.md`
- Read: `.claude/shared/contracts/topic-thinking-persistence.md`
- Read: `packaging/zhiji-user-boundaries.json`

**Interfaces:**
- Allowed sources: `output.daily_feedback`, `output.weekly_report`, `output.monthly_report`, `output.project_report`, `output.yearly_report`, `output.life_design_report`, and confirmed `context.thinking_topic`.
- Forbidden sources: `input.*`, `context.core_profile`, `context.current`, `context.verified_patterns`, `analysis.*`, config, and state.

- [ ] **Step 1: Write failing path and privacy assertions**

Require `output.result_distribution_config` at `复盘/.result-distribution-config.json` and `output.result_distribution_state` at `复盘/.result-distribution-state.json`. Require a shared `result-distribution.md` contract, an example config, explicit allowed/forbidden source lists, local-write-first semantics, two independent channel results, and secrets-outside-project language.

- [ ] **Step 2: Write failing behavior assertions**

Require the contract to distinguish `success`, `failed`, `skipped_not_configured`, `skipped_duplicate`, `skipped_no_action`, and `changed_after_delivery`; require SHA-256 idempotency; require Feishu failure not to suppress TickTick and the reverse; require no TickTick read/completion behavior.

- [ ] **Step 3: Run the focused test and verify RED**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-contract.tests.ps1
```

Expected: non-zero exit naming the missing paths, contract, and example config.

### Task 2: Define config, state, and the shared post-write contract

**Files:**
- Modify: `.claude/shared/paths.md`
- Create: `.claude/shared/contracts/result-distribution.md`
- Create: `.claude/shared/result-distribution-config.example.json`
- Modify: `packaging/zhiji-user-boundaries.json`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/paths.md`
- Create: `packaging/zhiji-user-overlay/.claude/shared/contracts/result-distribution.md`
- Create: `packaging/zhiji-user-overlay/.claude/shared/result-distribution-config.example.json`
- Test: `tests/result-distribution-contract.tests.ps1`

**Interfaces:**
- Config schema version: `1`.
- Config keys: `enabled`, `feishu.enabled`, `feishu.folder_token`, `ticktick.enabled`, `ticktick.region`, `ticktick.list_name`, and per-result-type channel switches.
- State schema version: `1`; each source path stores `sha256`, `written_at`, and separate `feishu` / `ticktick` status objects.

- [ ] **Step 1: Add the two runtime path keys**

Add identical semantic keys to both main and overlay `paths.md`. Keep concrete paths inside ignored `复盘/`; do not put credentials under `.claude/`.

- [ ] **Step 2: Add a disabled-by-default example config**

Use valid JSON with every channel and result-type switch `false`, `ticktick.region` limited to `dida365` or `ticktick`, and no real folder token. Document that the runtime file is copied to `output.result_distribution_config` and remains ignored.

- [ ] **Step 3: Write the minimum shared contract**

Define this order exactly:

1. confirm the caller has newly written and re-read a non-empty allowed source;
2. load config; return per-channel `skipped_not_configured` when missing or disabled;
3. compute SHA-256 and load/recover state;
4. classify duplicates and changed-after-delivery per channel;
5. call Feishu and TickTick independently even if the first call fails;
6. persist each channel result without credentials;
7. return a local-first three-line summary.

On damaged state, rename it to `.result-distribution-state.corrupt-YYYYMMDD-HHmmss.json`, create clean state, and never alter remote resources.

- [ ] **Step 4: Register shared package files and mirror them**

Add the new contract and example JSON to `packaging/zhiji-user-boundaries.json` as shared files. Keep `paths.md` as an override and make its two new keys behavior-equivalent.

- [ ] **Step 5: Run the focused test and verify GREEN**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-contract.tests.ps1
```

Expected: `PASS: result distribution contract checks`.

### Task 3: Specify and test the Feishu distributor

**Files:**
- Modify: `.claude/shared/contracts/result-distribution.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/result-distribution.md`
- Modify: `tests/result-distribution-contract.tests.ps1`
- Create: `tests/fixtures/result-distribution/sample-daily-feedback.md`

**Interfaces:**
- Preflight: `lark-cli --version`, `lark-cli auth status`, configured application identity, accessible `folder_token`.
- Write command: `lark-cli drive +import --file <absolute-md-path> --type docx --folder-token <folder-token> --name <title> --as bot`.
- Output record: `status`, `document_token`, `url`, `ticket`, `attempted_at`, and normalized `error_code`; no secret fields.

- [ ] **Step 1: Extend the test with failing Feishu assertions**

Require official CLI usage, `--type docx`, explicit `--folder-token`, explicit `--name`, `--as bot`, same-folder serialization, async `next_command` handling, a maximum of three retries only for documented concurrent-import codes, and zero retries for permission/not-found/missing-scope errors.

- [ ] **Step 2: Run the focused test and verify RED**

Expected: failure naming the missing Feishu adapter contract.

- [ ] **Step 3: Add the Feishu adapter contract**

Derive titles without reading report content beyond frontmatter/title:

- daily: `知己·每日反馈·YYYY-MM-DD`;
- weekly: `知己·周度复盘·YYYY-Www`;
- monthly: `知己·月度复盘·YYYY-MM`;
- project/yearly/life-design/thinking: `知己·{type}·{local title}` with filesystem-invalid/control characters removed.

Treat `ready=false` plus a ticket as pending, execute only the CLI-provided `next_command`, and mark success only after a final token/URL is returned. Never transfer owner automatically.

- [ ] **Step 4: Run offline Feishu command-construction tests**

Use the fixture path containing Chinese characters and assert correct quoting, absolute-path resolution, title, folder token placement, and absence of secret values. Do not call Feishu during this test.

- [ ] **Step 5: Run the focused test and verify GREEN**

Expected: PASS.

### Task 4: Specify and test TickTick action extraction and creation

**Files:**
- Modify: `.claude/shared/contracts/result-distribution.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/result-distribution.md`
- Modify: `tests/result-distribution-contract.tests.ps1`
- Create: `tests/fixtures/result-distribution/sample-weekly-report.md`
- Create: `tests/fixtures/result-distribution/sample-no-action-report.md`

**Interfaces:**
- Provider selection: `dida365` binds the official China-region MCP; `ticktick` binds the official international MCP.
- Capability: discover exactly one authenticated operation whose schema creates a task. Never bind list/get/search/update/complete operations.
- Task fields: action title, source-path and check-condition description, configured list name, and a due date only when derivable by contract.

- [ ] **Step 1: Add failing source-extraction assertions**

Require exactly one daily task from `⚡ 明天试试` → `行动：`; at most three weekly/monthly/project actions from their planning section; at most three explicit near-term experiments for yearly/life-design; and at most three items from confirmed topic thinking `0. 当前行动卡`. Require `skipped_no_action` when no atomic, controllable, checkable action exists.

- [ ] **Step 2: Add failing date and anti-invention assertions**

Daily due date is the next local calendar day. Weekly defaults to the next ISO week Sunday and monthly to the next calendar month end, but an explicit report date wins. Project/yearly/life-design/thinking actions have no due date unless the source states one. Require the contract to reject broad directions, analysis statements, upgrade reminders, and invented tasks.

- [ ] **Step 3: Add failing MCP boundary assertions**

Require semantic capability discovery, exactly-one-candidate selection, auth and region gates, create-only calls, per-task result IDs, and no task reads. Require deterministic action keys from source path plus normalized title so a retry cannot duplicate a successful task.

- [ ] **Step 4: Run the focused test and verify RED**

Expected: failure naming missing extraction, date, and MCP boundaries.

- [ ] **Step 5: Add the TickTick adapter contract and fixtures**

Write explicit extraction tables and skip rules into both contracts. The weekly fixture contains two valid actions and one broad direction that must be rejected; the no-action fixture must produce zero task candidates.

- [ ] **Step 6: Run the focused test and verify GREEN**

Expected: PASS.

### Task 5: Attach distribution only to successful new local writes

**Files:**
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/commands/weekly-review.md`
- Modify: `.claude/commands/monthly-review.md`
- Modify: `.claude/commands/project-review.md`
- Modify: `.claude/commands/yearly-review.md`
- Modify: `.claude/commands/life-design.md`
- Modify: `.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `.claude/shared/contracts/topic-thinking-persistence.md`
- Modify: `.claude/workflows/weekly-review.js`
- Modify: `.claude/workflows/monthly-review.js`
- Modify: `.claude/workflows/project-review.js`
- Modify: `.claude/workflows/yearly-review.js`
- Mirror: corresponding files under `packaging/zhiji-user-overlay/`
- Test: `tests/result-distribution-routing.tests.ps1`

**Interfaces:**
- Trigger input: `distribute <path-key> <resolved-local-path>` after verified write.
- Skip inputs: cache hit/read-only display, D-grade daily input, missing source, analysis failure, unconfirmed topic thinking, or changed-after-delivery without confirmation.

- [ ] **Step 1: Create failing routing tests**

Assert every supported entry reads the shared distribution contract and invokes it only after a new successful write. Assert daily cache-hit and error branches skip it; topic thinking invokes it only after existing user confirmation; Codex natural-language routes use the same contract without requiring Claude `Task`/`Workflow`.

- [ ] **Step 2: Run routing tests and verify RED**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-routing.tests.ps1
```

Expected: non-zero exit naming missing post-write routes.

- [ ] **Step 3: Add the command and Codex routes**

After each caller has written and re-read its output, execute the shared contract and append its local-first summary to chat. Do not place distribution status inside the report file. Preserve all existing reminder/readiness behavior.

- [ ] **Step 4: Add workflow completion handoff**

Extend the workflow completion phase to hand the resolved `reportPath` to the shared distribution contract after synthesis success. The workflow must still return `synthesis: 'complete'` when distribution partially fails, and add a separate `distribution` result object rather than changing report status.

- [ ] **Step 5: Mirror runtime routes and run tests**

Run both focused suites. Expected: both PASS.

### Task 6: Verify installation gates without collecting secrets

**Files:**
- Create: `docs/result-distribution-setup.md`
- Modify: `README.md`
- Mirror: `packaging/zhiji-user-overlay/docs/result-distribution-setup.md`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Test: `tests/result-distribution-setup.tests.ps1`

**Interfaces:**
- Feishu setup statuses: `cli_missing`, `app_not_configured`, `bot_ready`, `folder_inaccessible`, `ready`.
- TickTick setup statuses: `mcp_missing`, `wrong_region`, `auth_required`, `create_capability_ambiguous`, `ready`.
- No setup command accepts secrets as positional arguments in recorded project instructions.

- [ ] **Step 1: Write failing setup-document assertions**

Require a user checklist, privacy warning, Feishu official installation/config/status commands, application-identity explanation, target-folder test, TickTick region/auth/create-only checks, disabled-by-default behavior, and exact rollback instructions.

- [ ] **Step 2: Write the setup guide**

Document this Feishu sequence:

```powershell
npx @larksuite/cli@latest install
lark-cli config init --new
lark-cli auth status
```

Explain that routine imports use `--as bot`; user login is only used during setup if needed to identify and grant the current user access. When that grant is needed, authorize only Docs and Drive with `lark-cli auth login --domain docs --domain drive`, then create the dedicated folder with `lark-cli drive +create-folder --name "知己" --as bot` and require `permission_grant.status = granted`. Perform one dry-run and one disposable Markdown import before enabling real result types. Do not run `auth login` as a remedy for missing bot scopes; follow the CLI's `console_url` and enable only the missing application scope.

For TickTick, document selecting the account-region official MCP, completing its official authorization UI, discovering the create-task schema, and creating one disposable task in the configured list. Do not document or test task-reading calls.

- [ ] **Step 3: Add a short README entry and mirror docs**

Link the setup guide from the usage/integration section. Keep the root README concise and keep standalone-user wording in the overlay README.

- [ ] **Step 4: Run setup tests and verify GREEN**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-setup.tests.ps1
```

Expected: PASS.

### Task 7: Perform credential-gated live smoke tests

**Files:**
- Runtime only, gitignored: `复盘/.result-distribution-config.json`
- Runtime only, gitignored: `复盘/.result-distribution-state.json`
- Test source: `tests/fixtures/result-distribution/sample-daily-feedback.md`

**User-provided gates:**
- Exact Codex reminder schedule and timezone.
- Feishu app setup cooperation plus target folder access.
- TickTick/Dida365 region, completed MCP authorization, and destination list name.

- [ ] **Step 1: Stop cleanly if any channel gate is missing**

Report only the missing status. Do not ask the user to paste a secret. Leave that channel disabled and continue testing the other configured channel.

- [ ] **Step 2: Test Feishu with disposable content**

Run preflight, import the fixture once, verify the returned URL opens for the user and appears in the specified folder, then run the identical dispatch again and verify no second document is created.

- [ ] **Step 3: Test TickTick with one disposable action**

Create one fixture action in the configured list, verify title/description/due date in the MCP response or user-visible client, then run the identical dispatch again and verify no second task is created. Do not inspect unrelated tasks.

- [ ] **Step 4: Test partial failure isolation**

Disable or invalidate only the Feishu folder setting while leaving TickTick ready. Dispatch a new fixture hash and verify local success plus Feishu failure plus TickTick success. Repeat with TickTick disabled and Feishu ready.

- [ ] **Step 5: Enable only user-approved result types**

Copy the example config to the ignored runtime path and set only the result-type/channel switches the user explicitly approved. Do not enable every type by default.

### Task 8: Create reminder-only Codex automations

**Files:**
- No repository files. Use Codex scheduled-task configuration only.

**Interfaces:**
- Required input per reminder: name, schedule, timezone, and reminder text.
- Reminder text must say to open/start the relevant Zhiji review and must explicitly prohibit automatic review execution.

- [ ] **Step 1: Validate the supplied reminder schedule**

If name, recurrence, exact local time, or timezone is missing, stop with `reminder_schedule_missing`. Do not infer a schedule from examples.

- [ ] **Step 2: Create one pilot reminder**

Use the Codex automation tool. The prompt must be reminder-only and must not request reading the repository, generating a report, or invoking either distributor.

- [ ] **Step 3: Verify one delivery and then add remaining reminders**

Confirm the reminder arrives at the intended time and the user still explicitly starts the review. Only then create additional schedules supplied by the user.

### Task 9: Package, release, and verify

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md` if its version badge or current feature list changes
- Generated: `zhiji-user/`
- Test: `tests/distribution-boundary.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`
- Test: all `tests/*.tests.ps1`

- [ ] **Step 1: Export the standalone package**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

Expected: generated package matches overlay and shared-boundary rules.

- [ ] **Step 2: Update release facts**

After offline tests and the two live channel smoke tests pass, increment the minor version for the new opt-in integration capability. Add one top CHANGELOG entry, update `PROJECT_STATUS.md` with the enabled boundaries and remaining real-use observation gate, and update the README badge if present. Keep `AGENTS.md` and `CLAUDE.md` byte-identical if either is touched; this plan should not require touching them.

- [ ] **Step 3: Run focused checks**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-routing.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-setup.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: every script exits `0`.

- [ ] **Step 4: Run the full PowerShell suite**

```powershell
$testFiles = Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | Sort-Object Name
foreach ($testFile in $testFiles) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $testFile.FullName
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Expected: every script exits `0`.

- [ ] **Step 5: Audit the final diff**

Confirm there is no secret, `.env`, raw token, personal journal/review content, TickTick read operation, Feishu messaging behavior, scheduler-driven analysis, daemon, or database. Confirm local reports still complete when config is absent and partial distribution failures are represented separately.

- [ ] **Step 6: Commit locally**

Use the project local commit flow after verification. Do not push.

### Task 10: Measure three real uses before expanding scope

**Files:**
- Modify after evidence exists: `PROJECT_STATUS.md`

- [ ] **Step 1: Observe three real post-write dispatches**

Record only operational results: result type, local success, Feishu outcome, TickTick task count, duplicate outcome, and whether manual copying was still required. Do not record private report content in development docs.

- [ ] **Step 2: Apply the expansion gate**

Keep the MVP unchanged unless real evidence shows one of these failures: repeated remote duplicates, unclear action extraction, recurring auth interruption, or user need to update an already delivered cloud copy. Do not add reverse sync, completion monitoring, background queues, or more channels without a separate necessity review.
