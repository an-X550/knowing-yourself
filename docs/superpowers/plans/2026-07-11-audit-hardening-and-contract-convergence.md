# Audit Hardening and Contract Convergence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Preserve every current feature while fixing the topic-thinking privacy gap, proving its real operating boundaries, repairing review-summary contracts, and making intentional main/user differences explicit and testable.

**Architecture:** Keep `.claude/` as the only product runtime truth, keep `packaging/zhiji-user-overlay/` as a thin user-distribution variant, and keep `zhiji-user/` generated from the overlay. Add focused executable checks at component boundaries: private-data protection, main-to-overlay shared-contract equality, synthesis-agent return shape, summary extraction, and nested user-repository release state.

**Tech Stack:** Markdown runtime contracts, JavaScript workflow helpers, PowerShell regression tests, JSON distribution manifest, Git, existing PowerShell export workflow.

## Global Constraints

- Preserve every current user capability, command, parameter, report path, report filename, and report section structure.
- Do not add a command, agent, skill, workflow, keyword hook, full-text search, tag system, or knowledge graph.
- Do not automatically extract topic thinking from journals, daily feedback, or reviews.
- Do not write or update a topic without explicit user confirmation.
- Read the thinking index first and at most two clearly related topic files; never preload the full library.
- Current user statements override historical topic views.
- `.claude/` remains the sole product runtime truth; `zhiji-user/` remains an exported distribution package.
- Main `AGENTS.md` and `CLAUDE.md` must remain byte-for-byte identical.
- Overlay `AGENTS.md` and `CLAUDE.md` must remain byte-for-byte identical.
- Follow TDD for automated defects: observe the new test fail for the intended reason before changing production or distribution files.
- Prompt-only behavior that cannot be executed deterministically must use a recorded manual acceptance walkthrough; do not pretend static keyword assertions prove LLM behavior.
- This maintenance release targets `1.6.1`; do not increase the minor version again.

---

## File Map

### Create

- `tests/review-workflow-contract.tests.ps1` — verifies synthesis return contracts and executes summary extraction cases.
- `tests/distribution-boundary.tests.ps1` — verifies shared-file equality, declared overrides, private topic paths, and user-package repository state.
- `packaging/zhiji-user-boundaries.json` — classifies user-distribution files as `shared`, `override`, or `user_only` with reasons for every override.
- `docs/topic-thinking-acceptance.md` — records the real prompt-level acceptance procedure and evidence without claiming automation.

### Modify

- `tests/topic-thinking-contract.tests.ps1` — add privacy and exact shared-contract equality assertions.
- `packaging/zhiji-user-overlay/.gitignore` — ignore dynamically generated `关于我/思考/` private data.
- `zhiji-user/.gitignore` — generated only through `scripts/export-zhiji-user.ps1`.
- `.claude/workflows/shared.js` — use the tolerant, tested chat-summary extraction behavior already present in the user variant.
- `.claude/agents/weekly-synthesis.md` — return the report text required by the calling workflow.
- `.claude/agents/monthly-synthesis.md` — return the report text required by the calling workflow.
- `.claude/agents/project-synthesis.md` — return the report text required by the calling workflow.
- `.claude/agents/yearly-synthesis.md` — return the report text required by the calling workflow.
- `packaging/zhiji-user-overlay/.claude/agents/*.md` and `packaging/zhiji-user-overlay/.claude/workflows/shared.js` — remain the user source and are aligned only where behavior is shared.
- `tests/project-integrity.tests.ps1` — call or incorporate distribution-boundary checks.
- `docs/zhiji-user-sync-workflow.md` — document the boundary manifest and nested-repository release check.
- `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION` — synchronize release state to `1.6.1` after verification.

---

### Task 1: Protect dynamic topic thinking in the user package

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1`
- Modify: `packaging/zhiji-user-overlay/.gitignore`
- Modify: generated `zhiji-user/.gitignore`
- Modify: `packaging/zhiji-user-overlay/关于我/README.md`
- Modify: generated `zhiji-user/关于我/README.md`

**Interfaces:**
- Consumes: dynamic runtime path `关于我/思考/` from `context.thinking_dir`.
- Produces: user-package Git behavior in which every generated topic and index file is ignored while generic templates remain tracked.

- [ ] **Step 1: Add a failing Git-ignore behavior test**

Append a helper and assertions to `tests/topic-thinking-contract.tests.ps1`:

```powershell
function Assert-GitIgnored {
  param([string]$RepositoryRoot, [string]$RelativePath)

  git -C (Join-Path $repoRoot $RepositoryRoot) check-ignore --quiet -- $RelativePath
  if ($LASTEXITCODE -ne 0) {
    Add-Failure "$RepositoryRoot does not ignore private runtime path: $RelativePath"
  }
}

Assert-GitIgnored 'zhiji-user' '关于我/思考/index.md'
Assert-GitIgnored 'zhiji-user' '关于我/思考/亲密关系中的边界.md'

git -C (Join-Path $repoRoot 'zhiji-user') check-ignore --quiet -- '关于我/templates/thinking-topic.template.md'
if ($LASTEXITCODE -eq 0) {
  Add-Failure 'zhiji-user incorrectly ignores the tracked generic thinking template'
}
```

- [ ] **Step 2: Run the focused test and verify RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
```

Expected: `FAIL` naming both `关于我/思考/` runtime paths as not ignored.

- [ ] **Step 3: Add the minimal privacy rule at the overlay source**

Add this block to `packaging/zhiji-user-overlay/.gitignore` after the other `关于我` private-data rules:

```gitignore
# Dynamically generated topic-thinking library
/关于我/思考/
```

Do not ignore `/关于我/templates/`.

- [ ] **Step 4: Make the privacy documentation exact**

In `packaging/zhiji-user-overlay/关于我/README.md`, replace the generic instruction for topic files with an explicit statement that `关于我/思考/` is ignored by the distributed `.gitignore`, while the templates remain tracked. Keep the warning that private data still requires backup appropriate to the user's environment.

- [ ] **Step 5: Export and verify GREEN**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: export completes; both tests print `PASS` and exit `0`.

- [ ] **Step 6: Commit the isolated privacy fix**

```powershell
git add tests/topic-thinking-contract.tests.ps1 packaging/zhiji-user-overlay/.gitignore packaging/zhiji-user-overlay/关于我/README.md zhiji-user/.gitignore zhiji-user/关于我/README.md
git commit -m "fix: protect user topic thinking data"
```

---

### Task 2: Turn topic-thinking checks into honest acceptance evidence

**Files:**
- Modify: `tests/topic-thinking-contract.tests.ps1`
- Create: `docs/topic-thinking-acceptance.md`

**Interfaces:**
- Consumes: main contract, overlay contract, exported contract, templates, root entry rules.
- Produces: exact equality checks for deterministic artifacts plus a reproducible manual walkthrough for prompt-only behavior.

- [ ] **Step 1: Add failing exact-equality assertions**

Add this helper to `tests/topic-thinking-contract.tests.ps1`:

```powershell
function Assert-SameFile {
  param([string]$ExpectedRelativePath, [string]$ActualRelativePath)

  $expected = Join-Path $repoRoot $ExpectedRelativePath
  $actual = Join-Path $repoRoot $ActualRelativePath
  if (-not (Test-Path -LiteralPath $expected) -or -not (Test-Path -LiteralPath $actual)) {
    Add-Failure "cannot compare missing files: $ExpectedRelativePath -> $ActualRelativePath"
    return
  }

  if ((Get-FileHash -LiteralPath $expected -Algorithm SHA256).Hash -ne
      (Get-FileHash -LiteralPath $actual -Algorithm SHA256).Hash) {
    Add-Failure "shared topic-thinking file drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

Assert-SameFile '.claude/shared/contracts/topic-thinking.md' 'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md'
Assert-SameFile 'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md' 'zhiji-user/.claude/shared/contracts/topic-thinking.md'
```

Temporarily change one byte in a temporary copy used by the test, or run the helper against a known-different fixture, and verify it reports `shared topic-thinking file drift`. Restore the fixture immediately; do not alter production files to manufacture RED.

- [ ] **Step 2: Add deterministic template assertions**

Assert that the index template contains only the routing table, the topic template contains all five required sections, and neither template contains a concrete user topic. Keep these as artifact checks, not behavior claims.

- [ ] **Step 3: Write the manual acceptance document**

Create `docs/topic-thinking-acceptance.md` with this exact result table:

```markdown
# 主题思考端到端验收

| 场景 | 操作 | 必须观察到 | 失败条件 |
|---|---|---|---|
| 未确认 | 探讨后明确说“先不要保存” | `关于我/思考/` 零文件变化 | 创建或更新任何文件 |
| 新主题 | 确认保存“亲密关系中的边界” | 同时创建索引项与安全主题文件 | 只创建一个、写到目录外、静默覆盖 |
| 日志隔离 | 粘贴含观点的普通日志 | 走日志反馈，不自动写主题库 | 自动摘录或反复询问保存 |
| 相关召回 | 再问关系边界问题 | 先读索引，最多读取两个主题，并说明来源 | 全量读取或不透明引用 |
| 当前优先 | 明确否定旧观点 | 以当前表达回答，更新前重新确认 | 旧观点压过当前表达或自动改写 |
| 删除 | 请求删除主题 | 展示主题文件和索引影响，确认后删除 | 未确认删除或留下失效索引 |
```

Include fields for date, model, workspace, created files, referenced topics, observed result, and pass/fail. State explicitly that static tests do not replace this walkthrough.

- [ ] **Step 4: Run all topic and distribution checks**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: both print `PASS`.

- [ ] **Step 5: Perform one real walkthrough in disposable personal data**

Use a temporary, non-personal topic and record the evidence in `docs/topic-thinking-acceptance.md`. Remove only the disposable runtime data after recording evidence; do not delete user-owned data. Expected: all six rows pass, or the plan stops and records the precise failed behavior before Task 3.

- [ ] **Step 6: Commit acceptance hardening**

```powershell
git add tests/topic-thinking-contract.tests.ps1 docs/topic-thinking-acceptance.md
git commit -m "test: harden topic thinking acceptance"
```

---

### Task 3: Repair the review workflow-to-agent summary contract

**Files:**
- Create: `tests/review-workflow-contract.tests.ps1`
- Modify: `.claude/workflows/shared.js`
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/agents/project-synthesis.md`
- Modify: `.claude/agents/yearly-synthesis.md`
- Modify corresponding shared behavior in `packaging/zhiji-user-overlay/.claude/`
- Modify generated corresponding files in `zhiji-user/.claude/`

**Interfaces:**
- Consumes: synthesis result strings beginning with `# 聊天摘要` or `## 聊天摘要` and containing either the explicit end marker or a following report heading.
- Produces: `extractChatSummary(result): string` and a stable synthesis-agent contract that returns the written report text to the calling workflow.

- [ ] **Step 1: Create the failing workflow contract test**

Create `tests/review-workflow-contract.tests.ps1` that:

1. Reads the four main synthesis agents and fails unless each requires returning the complete report beginning with a chat-summary block.
2. Fails if an agent says only to return “已创建”.
3. Executes `.claude/workflows/shared.js` through the configured Node runtime and calls `extractChatSummary` with these cases:

```javascript
[
  ['## 聊天摘要\n\n发现 A\n---\n[聊天摘要结束。以下为完整报告]\n## 一、回顾目标', '发现 A'],
  ['# 聊天摘要\n\n发现 B\n---\n[聊天摘要结束]\n## 一、回顾目标', '发现 B'],
  ['## 聊天摘要\n\n发现 C\n## 一、回顾目标', '发现 C'],
]
```

The test must fail if any extracted value differs from the expected value.

- [ ] **Step 2: Run the test and verify RED**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
```

Expected: failure for all four main synthesis agents and at least the tolerant parser cases.

- [ ] **Step 3: Align the shared parser**

Replace the main `extractChatSummary` implementation with the already proven tolerant pattern array from `packaging/zhiji-user-overlay/.claude/workflows/shared.js`. Do not change validation thresholds or any unrelated helper.

- [ ] **Step 4: Align the four agent return contracts**

For each main synthesis agent, replace the “只返回已创建” instruction with:

```markdown
创建文件后，返回完整报告全文，且必须满足：

- 以 `# 聊天摘要` 或 `## 聊天摘要` 开始摘要区块
- 摘要后保留分隔线与 `[聊天摘要结束。以下为完整报告]`
- 继续输出完整正文，供上游 workflow 提取摘要并展示

不要额外附加“已创建”提示语，不要再返回第二份简写结果。
```

Keep each report's existing headings, evidence rules, paths, and domain-specific content unchanged.

- [ ] **Step 5: Align only shared user behavior and export**

Compare each overlay file before editing. If the overlay already has the required return contract or tolerant parser, leave it unchanged. Export through `scripts/export-zhiji-user.ps1`; do not hand-edit generated user files.

- [ ] **Step 6: Verify GREEN and regression safety**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
```

Expected: all print `PASS`.

- [ ] **Step 7: Commit the contract repair**

```powershell
git add tests/review-workflow-contract.tests.ps1 .claude/workflows/shared.js .claude/agents packaging/zhiji-user-overlay/.claude zhiji-user/.claude
git commit -m "fix: align review summary contracts"
```

---

### Task 4: Declare and enforce user-distribution boundaries

**Files:**
- Create: `packaging/zhiji-user-boundaries.json`
- Create: `tests/distribution-boundary.tests.ps1`
- Modify: `tests/project-integrity.tests.ps1`
- Modify: `docs/zhiji-user-sync-workflow.md`

**Interfaces:**
- Consumes: main `.claude/` files, overlay files, manifest sync tasks.
- Produces: an allowlist in which every same-path main/overlay file is either byte-identical `shared` or explicitly justified `override`; overlay-only files are `user_only`.

- [ ] **Step 1: Generate a read-only inventory for review**

List every overlay file that has a same-relative-path main counterpart and calculate SHA256 equality. Classify without changing files:

```json
{
  "shared": [
    ".claude/shared/contracts/topic-thinking.md"
  ],
  "override": [
    {
      "path": ".claude/settings.json",
      "reason": "User package omits developer-only grill-me routing and commit reminder"
    }
  ],
  "user_only": [
    "AGENTS.md",
    "CLAUDE.md"
  ]
}
```

Do not classify a behavior difference as `override` merely because files currently differ. Every override must identify the user/developer boundary that requires it.

- [ ] **Step 2: Write a failing boundary test**

Create `tests/distribution-boundary.tests.ps1` that fails when:

- a same-path pair is absent from the boundary file;
- a `shared` pair has different SHA256 hashes;
- an `override` has an empty reason;
- a `user_only` path also exists as a main runtime file without an explanation;
- any manifest source is untracked;
- overlay and generated user files differ;
- `git -C zhiji-user status --short` contains exported product changes at release verification time.

Run it before completing the boundary JSON. Expected: `FAIL` listing unclassified pairs.

- [ ] **Step 3: Complete the boundary JSON using audit evidence**

Classify all current pairs. Prefer `shared` for contracts, paths, prompt rules, workflow helpers, and agents unless the user package intentionally excludes developer-only behavior. Keep settings and root governance entries as explicit overrides where appropriate.

- [ ] **Step 4: Resolve accidental drift one pair at a time**

For each unintentional difference:

1. Add or identify a focused test proving the shared behavior.
2. Make the main runtime the authoritative implementation.
3. Copy the shared behavior to the overlay source.
4. Export the user package.
5. Run the boundary and relevant functional test.

Do not perform an unreviewed bulk copy of all 27 previously divergent files.

- [ ] **Step 5: Integrate the boundary check**

Invoke `tests/distribution-boundary.tests.ps1` from the documented full verification flow and add its deterministic checks to `tests/project-integrity.tests.ps1` or call it as a separate required suite. Avoid duplicating the same assertions in both files.

- [ ] **Step 6: Document the maintenance rule**

Update `docs/zhiji-user-sync-workflow.md` with:

- `shared` means byte-identical and main-authoritative;
- `override` requires a stable reason;
- `user_only` is distribution-only;
- export success is not release success until the nested `zhiji-user` repository is clean and committed;
- runtime personal data is never part of export verification.

- [ ] **Step 7: Verify and commit boundary governance**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
git add packaging/zhiji-user-boundaries.json tests/distribution-boundary.tests.ps1 tests/project-integrity.tests.ps1 docs/zhiji-user-sync-workflow.md packaging/zhiji-user-overlay zhiji-user
git commit -m "refactor: declare user distribution boundaries"
```

Expected: both tests pass. If the nested `zhiji-user` repository is intentionally awaiting its own commit, the boundary test must report that state explicitly and the release task must remain incomplete.

---

### Task 5: Synchronize release state and complete both repositories

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md` only if verification commands or public behavior need correction

**Interfaces:**
- Consumes: completed Tasks 1–4 and their verification evidence.
- Produces: version `1.6.1`, release-level documentation, a clean main repository, and a clean committed `zhiji-user` repository without pushing either repository.

- [ ] **Step 1: Run the full verification suite before release edits**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/review-workflow-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: every script prints `PASS` and exits `0` except the explicitly expected nested-repository release-state gate, which is resolved in Step 4.

- [ ] **Step 2: Update version and status**

Set `VERSION` and `PROJECT_STATUS.md` to `1.6.1`. Update current progress to state:

- topic-thinking privacy protection is complete;
- topic-thinking has a recorded real acceptance walkthrough;
- review summary contracts are aligned;
- distribution differences are classified and enforced.

Remove an existing known issue only when the corresponding test proves it is resolved. Do not claim that real long-term topic recall value is validated from a single mechanical walkthrough.

- [ ] **Step 3: Add one release-level changelog entry**

Add a `[修复]` entry for `v1.6.0 -> v1.6.1` covering the privacy rule, honest acceptance boundary, review-summary contract, and distribution-boundary enforcement. List only files actually changed during execution.

- [ ] **Step 4: Commit the generated user package in its own repository**

Inside `zhiji-user`, verify that only intended exported product files are changed, then create a local commit using the same release description. Do not include runtime logs, reviews, profile data, or topic files. Do not push.

```powershell
git -C zhiji-user status --short
git -C zhiji-user add .gitignore .claude AGENTS.md CLAUDE.md README.md 关于我/README.md 关于我/templates
git -C zhiji-user commit -m "fix: harden topic thinking privacy and runtime contracts"
```

Expected: local user-package commit succeeds and `git -C zhiji-user status --short` is empty.

- [ ] **Step 5: Re-run the complete verification suite after both commits**

Run the five scripts from Step 1, then:

```powershell
git diff --check
git status --short
git -C zhiji-user status --short
```

Expected: all tests pass; both status commands are empty; `git diff --check` prints nothing.

- [ ] **Step 6: Commit the main release state**

Use the repository's changelog-derived local commit flow:

```powershell
git add VERSION PROJECT_STATUS.md CHANGELOG.md README.md
git commit -m "[修复] 收敛主题思考隐私与运行契约 (v1.6.0 -> v1.6.1)"
```

Do not push either repository. The user performs both pushes manually.

---

## Final Acceptance Checklist

- [ ] Every existing feature, command, parameter, report path, and report structure remains available.
- [ ] `zhiji-user` ignores `关于我/思考/` but tracks generic templates.
- [ ] Topic-thinking main and overlay contracts are byte-identical.
- [ ] Static contract tests are described only as artifact checks, not behavior proof.
- [ ] A real topic-thinking walkthrough is recorded with no personal content.
- [ ] Weekly, monthly, project, and yearly workflows can extract the agent-returned chat summary.
- [ ] Every main/overlay pair is classified as `shared`, `override`, or `user_only`.
- [ ] Every override has a concrete user/developer boundary reason.
- [ ] Overlay and exported user files match.
- [ ] Main and nested user repositories are both clean after local commits.
- [ ] All five regression scripts pass on version `1.6.1`.
