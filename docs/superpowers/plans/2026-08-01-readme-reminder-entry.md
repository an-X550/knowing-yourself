# README Reminder Entry Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. The user explicitly requires inline execution on `main`; do not create a worktree or dispatch subagents.

**Goal:** Make both README audiences understand how the existing closed-loop reminder is triggered and what it will not do.

**Architecture:** Keep runtime behavior unchanged. Add concise audience-specific copy to the main README and the user-package overlay, then export the overlay to `zhiji-user/`. Extend the existing PowerShell integrity test so the documented manual entry and no-background boundary cannot drift again.

**Tech Stack:** Markdown documentation, PowerShell contract tests, `scripts/export-zhiji-user.ps1`.

## Global Constraints

- Do not add a command, reminder candidate, scheduler, hook, state file, or automatic personal-content update.
- Keep the manual route natural-language based; do not prescribe a fixed command phrase.
- State that automatic delivery runs only after a successful new formal daily feedback and verification writeback.
- State that no new journal means no background popup; the user may still ask for a check in natural language.
- Regenerate `zhiji-user/` from `packaging/zhiji-user-overlay/`.
- Bump the patch version and synchronize `VERSION`, `PROJECT_STATUS.md`, `README.md`, and `CHANGELOG.md`; do not push.

---

### Task 1: Lock the README contract with a regression test

**Files:**
- Modify: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: root `README.md`, `packaging/zhiji-user-overlay/README.md`, and `VERSION`.
- Produces: test failures when either README omits the manual natural-language route or the no-background boundary.

- [x] **Step 1: Add failing assertions after the existing `$userReadme` assignment**

```powershell
$mainReadme = Read-Utf8 'README.md'
if ($mainReadme -notmatch [regex]::Escape('自然语言手动检查')) {
  Add-Failure 'main README does not describe the manual natural-language readiness check'
}
if ($mainReadme -notmatch [regex]::Escape('不是后台定时任务')) {
  Add-Failure 'main README does not state the no-background boundary'
}
if ($userReadme -notmatch [regex]::Escape('最近有什么该补？')) {
  Add-Failure 'user README does not expose a natural-language readiness example'
}
if ($userReadme -notmatch [regex]::Escape('不会后台弹窗')) {
  Add-Failure 'user README does not state the no-background boundary'
}
```

- [x] **Step 2: Run the test to verify RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: exit code `1`, naming the missing README reminder-entry assertions.

### Task 2: Add audience-specific reminder entry copy

**Files:**
- Modify: `README.md`
- Modify: `packaging/zhiji-user-overlay/README.md`

**Interfaces:**
- Consumes: the existing `review-readiness-checker` delivery contract.
- Produces: concise maintainer and end-user explanations without changing runtime contracts.

- [x] **Step 1: Amend the main README capability row**

Replace the existing closed-loop capability description with this copy:

```markdown
| 闭环缺口检查与低噪声提醒 | 可通过自然语言手动检查；成功新日反馈完成验证沉淀后也会检查一次。它不是后台定时任务，只提示一项最优先、需要你手动完成的日反馈、复盘或上下文沉淀 | [`.claude/agents/review-readiness-checker.md`](.claude/agents/review-readiness-checker.md) / [提醒契约](.claude/shared/contracts/readiness-delivery.md) |
```

- [x] **Step 2: Amend the user README reminder paragraph**

Replace the reminder paragraph with this copy:

```markdown
你随时可以自然地问“最近有什么该补？”或“我有遗漏吗？”，系统会只推荐一项最优先路径。每次成功生成新的正式日反馈并完成验证沉淀后，系统也会额外检查一次；只有需要行动且同类提醒未在 7 天内出现过时，才显示一条 `🔔 提醒`。如果长时间没有新日志，系统不会后台弹窗或催办；提醒只建议你手动执行，不会自动修改 `current.md`、报告或其他个人内容。
```

- [x] **Step 3: Run the test to verify GREEN**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: `PASS: project integrity checks`.

### Task 3: Export, release facts, and verify

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `README.md`
- Modify: `CHANGELOG.md`
- Generated: `zhiji-user/README.md`

**Interfaces:**
- Consumes: the synchronized overlay README.
- Produces: a v1.12.2 user package whose README matches the overlay and whose release facts match the root version.

- [x] **Step 1: Synchronize patch release facts**

Make these exact edits:

```text
VERSION: 1.12.2
PROJECT_STATUS.md: **当前版本**：1.12.2
README.md badge: v1.12.2
packaging/zhiji-user-overlay/README.md: 当前用户版对应 `v1.12.2`
```

Add this top CHANGELOG entry after verification:

```markdown
## [2026-08-01 13:24] [文档] 明确闭环提醒的触发与边界 (v1.12.1 -> v1.12.2)

- **受影响文件**: `README.md`, `zhiji-user/README.md`, `tests/project-integrity.tests.ps1`
- **改动摘要**: 明确自然语言手动检查、日反馈后单次检查和无后台催办边界，减少对提醒时机的错误预期。
```

- [x] **Step 2: Export the user package**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

Expected: `zhiji-user export complete` and `zhiji-user/README.md` matches the overlay source.

- [x] **Step 3: Run full verification**

Run:

```powershell
$testFiles = Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | Sort-Object Name
foreach ($testFile in $testFiles) {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $testFile.FullName
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
git diff --check
```

Expected: every test exits `0` and `git diff --check` has no output.

- [x] **Step 4: Commit the verified documentation update locally**

Run:

```powershell
git add README.md VERSION PROJECT_STATUS.md CHANGELOG.md packaging/zhiji-user-overlay/README.md zhiji-user/README.md tests/project-integrity.tests.ps1 docs/superpowers/plans/2026-08-01-readme-reminder-entry.md
git commit -m "[文档] 明确闭环提醒的触发与边界 (v1.12.1 -> v1.12.2)"
```

Expected: a new local commit; do not push.
