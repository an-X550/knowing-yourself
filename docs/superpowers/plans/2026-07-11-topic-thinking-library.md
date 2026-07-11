# Lightweight Topic Thinking Library Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a user-confirmed, dynamically extensible topic thinking library that can save arbitrary new themes and transparently recall relevant prior thinking in later conversations.

**Architecture:** Detailed behavior lives in one focused runtime contract referenced by shared paths and prompt rules. Root `AGENTS.md` / `CLAUDE.md` provide only the minimal always-loaded discovery rule; an index routes the AI to at most two relevant topic files, and user confirmation gates every write. User-distribution sources mirror the same contract and ship only generic empty templates, never fixed example topics or maintainer data.

**Tech Stack:** Markdown runtime contracts, YAML frontmatter, PowerShell contract tests, JSON distribution manifest, existing PowerShell export workflow, Git.

## Global Constraints

- Do not automatically extract thinking from journals, daily feedback, or reviews.
- Do not write or update a topic without explicit user confirmation of the proposed summary or change summary.
- Topic files are created dynamically from user-approved topic names; examples are never a whitelist or required files.
- Sanitize path separators and unsafe filename characters; never write outside `关于我/思考/` and never silently overwrite an unrelated file.
- Read `index.md` first and at most two clearly related topic files; do not preload all topics.
- Tell the user which historical topics were referenced.
- Current user statements override historical views; conflicts require a proposed update and fresh confirmation.
- Do not add a command, agent, skill, workflow, keyword hook, full-text search, tag system, or knowledge graph.
- Main `AGENTS.md` and `CLAUDE.md` must remain byte-for-byte identical.
- Product behavior changes require version `1.5.26 -> 1.6.0`, synchronized public docs, `PROJECT_STATUS.md`, and one top-of-file `CHANGELOG.md` entry.

---

## File Map

### Create

- `.claude/shared/contracts/topic-thinking.md` — authoritative runtime contract for discussion, confirmation, dynamic file creation, update, recall, and errors.
- `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md` — user-distribution source copy of the contract.
- `packaging/zhiji-user-overlay/AGENTS.md` — minimal cross-tool user runtime entry.
- `packaging/zhiji-user-overlay/CLAUDE.md` — identical minimal Claude runtime entry.
- `packaging/zhiji-user-overlay/关于我/templates/thinking-index.template.md` — generic empty index template.
- `packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md` — generic empty topic template with placeholders, not a fixed topic.
- `tests/topic-thinking-contract.tests.ps1` — focused static contract, safety, distribution, and entry-point checks.

### Modify

- `.claude/shared/paths.md` — add `context.thinking_dir`, `context.thinking_index`, `context.thinking_topic`, and missing-path behavior.
- `.claude/shared/prompt-rules.md` — index the new contract and define minimal recall/write routing.
- `AGENTS.md` and `CLAUDE.md` — add the same short always-loaded topic-thinking discovery rule.
- `packaging/zhiji-user-overlay/.claude/shared/paths.md` — user source path keys.
- `packaging/zhiji-user-overlay/.claude/shared/prompt-rules.md` — user source contract index and routing.
- `packaging/zhiji-user-manifest.json` — export root runtime entries; existing template mirror exports both generic templates.
- `packaging/zhiji-user-overlay/README.md` and `packaging/zhiji-user-overlay/关于我/README.md` — explain user-controlled thinking storage and privacy.
- `README.md` — document the natural-language thinking workflow and storage location.
- `PROJECT_STATUS.md` — version, progress, and key decision.
- `CHANGELOG.md` — release-level feature entry.
- `VERSION` — set to `1.6.0`.
- Export-generated `zhiji-user/` files — refresh only through `scripts/export-zhiji-user.ps1`.

---

### Task 1: Define failing topic-thinking contract tests

**Files:**
- Create: `tests/topic-thinking-contract.tests.ps1`

**Interfaces:**
- Consumes: repository-relative runtime and distribution paths.
- Produces: a PowerShell test that exits `0` only when main runtime, user source, exported user package, dynamic-topic safety, and minimal entry rules agree.

- [ ] **Step 1: Create the focused failing test**

Create `tests/topic-thinking-contract.tests.ps1` with this complete structure:

```powershell
$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $failures.Add($Message) | Out-Null
}

function Read-Utf8 {
  param([string]$RelativePath)
  $path = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    Add-Failure "missing file: $RelativePath"
    return ''
  }
  Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

function Assert-ContainsAll {
  param([string]$RelativePath, [string[]]$Patterns)
  $content = Read-Utf8 $RelativePath
  foreach ($pattern in $Patterns) {
    if ($content -notmatch $pattern) {
      Add-Failure "$RelativePath missing contract pattern: $pattern"
    }
  }
}

$contractPaths = @(
  '.claude/shared/contracts/topic-thinking.md',
  'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md',
  'zhiji-user/.claude/shared/contracts/topic-thinking.md'
)

foreach ($path in $contractPaths) {
  Assert-ContainsAll $path @(
    '未经用户确认不得(?:创建|写入|更新)',
    '不从日志.*自动摘录',
    '任意新主题',
    '路径分隔符',
    '不得.*静默覆盖',
    '最多.*2.*主题',
    '明确告知用户.*主题',
    '当前表达.*优先'
  )
}

foreach ($path in @('.claude/shared/paths.md', 'packaging/zhiji-user-overlay/.claude/shared/paths.md', 'zhiji-user/.claude/shared/paths.md')) {
  Assert-ContainsAll $path @('context\.thinking_dir', 'context\.thinking_index', 'context\.thinking_topic')
}

foreach ($path in @('AGENTS.md', 'CLAUDE.md', 'packaging/zhiji-user-overlay/AGENTS.md', 'packaging/zhiji-user-overlay/CLAUDE.md', 'zhiji-user/AGENTS.md', 'zhiji-user/CLAUDE.md')) {
  Assert-ContainsAll $path @('topic-thinking\.md', 'thinking_index', '没有明显匹配.*不读取')
}

$mainAgents = Read-Utf8 'AGENTS.md'
$mainClaude = Read-Utf8 'CLAUDE.md'
if ($mainAgents -cne $mainClaude) { Add-Failure 'AGENTS.md and CLAUDE.md are not byte-for-byte identical' }

$userAgents = Read-Utf8 'packaging/zhiji-user-overlay/AGENTS.md'
$userClaude = Read-Utf8 'packaging/zhiji-user-overlay/CLAUDE.md'
if ($userAgents -cne $userClaude) { Add-Failure 'user AGENTS.md and CLAUDE.md are not byte-for-byte identical' }

$topicTemplate = Read-Utf8 'packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md'
foreach ($requiredHeading in @('## 当前认识', '## 形成依据', '## 限制与反例', '## 未决问题', '## 观点演化')) {
  if ($topicTemplate -notmatch [regex]::Escape($requiredHeading)) { Add-Failure "topic template missing: $requiredHeading" }
}
if ($topicTemplate -match '信息输入与注意力|工作与健康|职业选择') {
  Add-Failure 'generic topic template contains a fixed example topic'
}

$manifest = Read-Utf8 'packaging/zhiji-user-manifest.json' | ConvertFrom-Json
foreach ($target in @('AGENTS.md', 'CLAUDE.md')) {
  if (-not ($manifest.syncTasks | Where-Object { $_.target -eq $target -and $_.kind -eq 'overwriteFile' })) {
    Add-Failure "manifest does not overwrite user runtime entry: $target"
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: topic thinking contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: topic thinking contract checks' -ForegroundColor Green
exit 0
```

- [ ] **Step 2: Run the test and verify the expected failure**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
```

Expected: exit `1` with missing-file failures for `topic-thinking.md`, user root runtime entries, and thinking templates.

- [ ] **Step 3: Commit the failing test**

```powershell
git add tests/topic-thinking-contract.tests.ps1
git commit -m "test: define topic thinking library contract"
```

---

### Task 2: Implement the main runtime contract and always-loaded discovery rule

**Files:**
- Create: `.claude/shared/contracts/topic-thinking.md`
- Modify: `.claude/shared/paths.md`
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `AGENTS.md`
- Modify: `CLAUDE.md`

**Interfaces:**
- Consumes: `context.thinking_dir`, `context.thinking_index`, and `context.thinking_topic` path keys.
- Produces: one authoritative contract that any ordinary conversation can discover through the root instruction and use without a command or agent.

- [ ] **Step 1: Add the named paths**

Add these rows to both the input/context portions of `.claude/shared/paths.md` as appropriate:

```markdown
| `context.thinking_dir` | `关于我/思考/` | 用户确认后的主题思考根目录 |
| `context.thinking_index` | `关于我/思考/index.md` | 主题、别名、核心问题与更新时间的轻量路由索引 |
| `context.thinking_topic` | `关于我/思考/{topic}.md` | 按用户确认主题动态创建的思考文件，不是预置分类 |
```

Add missing-path behavior:

```markdown
| `context.thinking_index` | `关于我/思考/index.md` | 缺失时不预读主题；首次确认保存时创建目录与空索引 |
| `context.thinking_topic` | `关于我/思考/{topic}.md` | 缺失时只在用户确认新主题摘要后创建 |
```

Update frontmatter `last_updated` to `2026-07-11`.

- [ ] **Step 2: Write the authoritative topic-thinking contract**

Create `.claude/shared/contracts/topic-thinking.md` with these exact sections and rules:

```markdown
---
type: runtime_contract
purpose: 用户主动探讨后的主题思考确认、动态写入、演化与透明召回契约
last_updated: 2026-07-11
---

# 主题思考契约

## 适用边界

本契约只处理用户主动与 AI 探讨后形成、且经用户确认值得长期保留的认识。不得从日志、日反馈或复盘自动摘录思考，不保存完整聊天记录，也不把 AI 单方面观点写成用户认识。

## 探讨与确认

讨论时区分事实、感受、推断和价值判断，检查依据、反例、适用边界与未决问题。形成可沉淀认识后，先向用户展示“当前认识 / 形成依据 / 限制与反例 / 未决问题”。未经用户确认不得创建、写入或更新任何主题文件。

## 动态主题与文件安全

主题不使用白名单或预置分类，允许根据用户确认的主题名创建任意新主题。将主题名映射为 `context.thinking_topic` 前，去除 `/`、`\`、`:`、`*`、`?`、`"`、`<`、`>`、`|` 等路径分隔符或不安全字符，并确认解析后的目标仍位于 `context.thinking_dir` 内。

名称与已有主题相同或近义时，优先更新已有主题或请用户选择。不得越界写入，不得静默覆盖无关文件。首次保存时创建目录和 `context.thinking_index`；新主题同时写入主题文件与索引。

## 主题文件结构

主题文件包含 YAML frontmatter，以及“当前认识 / 形成依据 / 限制与反例 / 未决问题 / 观点演化”。新认识与旧观点冲突时，先展示“保留 / 修正 / 新增反例 / 仍未解决”的变更摘要；确认后更新当前认识，并在观点演化中记录日期、旧观点、改变依据和新观点。

## 自动召回

普通提问涉及用户既有观点、长期困惑或价值判断时，先读取 `context.thinking_index`。只有主题、别名或核心问题明显相关时，才读取最多 2 个最相关主题文件；没有明显匹配就不读取详细主题。

回答必须明确告知用户参考了哪些历史主题。历史认识只是用户曾认可的起点，不是永久事实；当前表达与历史观点冲突时，以当前表达优先，指出可能的观点变化，并在需要更新时重新走确认流程。

## 高频链路边界

日反馈默认不读取思考库；只有当天日志明确涉及某主题，且不读取会导致重复或冲突建议时，才按需读取 1 个主题。周/月复盘只在思考已经影响行动、方向选择或反复困境时引用。

## 异常处理

- 索引存在但主题文件缺失：提示索引失效，不根据缺失内容回答。
- 多个近义主题：建议合并或请用户选择。
- 用户拒绝保存：不写文件，也不反复劝说。
- 用户请求删除：展示影响范围，确认后删除主题并更新索引。
- 主题长期未更新：说明更新时间并检查是否仍认可，不自动判定失效。
```

- [ ] **Step 3: Register the contract in shared prompt rules**

Add this task-index row to `.claude/shared/prompt-rules.md`:

```markdown
| 主动思考探讨 / 确认沉淀 / 相关问题召回 | `.claude/shared/contracts/topic-thinking.md` |
```

Add a focused section:

```markdown
## 十、主题思考入口

1. 用户主动探讨长期问题并形成可沉淀认识时，读取主题思考契约；未经确认不写入。
2. 普通提问涉及用户既有观点、长期困惑或价值判断时，先检查 `context.thinking_index`；没有明显匹配则不读取详细主题。
3. 不从日志自动摘录，不使用关键词 hook 覆盖任意主题，不预读全部主题文件。
```

Update frontmatter `last_updated` to `2026-07-11`.

- [ ] **Step 4: Add the identical minimal root discovery rule**

Add this subsection to `AGENTS.md`, then copy the complete resulting file byte-for-byte to `CLAUDE.md`:

```markdown
### 主题思考入口

普通提问涉及用户既有观点、长期困惑或价值判断时，先读取 `.claude/shared/contracts/topic-thinking.md`，按契约检查 `context.thinking_index`；没有明显匹配则不读取详细主题。用户主动探讨形成可沉淀认识时，必须先展示归纳并获得确认，不能从日志自动摘录。
```

- [ ] **Step 5: Run the focused test and confirm only distribution failures remain**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
```

Expected: main contract/path/entry assertions pass; exit remains `1` only because overlay/export files and templates are not implemented.

- [ ] **Step 6: Verify governance files remain identical**

Run:

```powershell
$a = Get-FileHash -LiteralPath AGENTS.md -Algorithm SHA256
$c = Get-FileHash -LiteralPath CLAUDE.md -Algorithm SHA256
if ($a.Hash -ne $c.Hash) { throw 'AGENTS.md and CLAUDE.md differ' }
```

Expected: no output and exit `0`.

- [ ] **Step 7: Commit the main runtime contract**

```powershell
git add .claude/shared/contracts/topic-thinking.md .claude/shared/paths.md .claude/shared/prompt-rules.md AGENTS.md CLAUDE.md
git commit -m "feat: add topic thinking runtime contract"
```

---

### Task 3: Add user-distribution runtime entries and generic templates

**Files:**
- Create: `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`
- Create: `packaging/zhiji-user-overlay/AGENTS.md`
- Create: `packaging/zhiji-user-overlay/CLAUDE.md`
- Create: `packaging/zhiji-user-overlay/关于我/templates/thinking-index.template.md`
- Create: `packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/paths.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/prompt-rules.md`
- Modify: `packaging/zhiji-user-manifest.json`
- Modify: generated `zhiji-user/` files through export only

**Interfaces:**
- Consumes: authoritative main contract wording and existing manifest/export semantics.
- Produces: a self-contained user package with an always-loaded discovery entry, dynamic generic templates, and no maintainer topics.

- [ ] **Step 1: Mirror the runtime contract and path/prompt changes into overlay sources**

Copy the complete content of `.claude/shared/contracts/topic-thinking.md` to `packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md`. Apply the same three path keys, missing-path behavior, task-index row, and “主题思考入口” section from Task 2 to the overlay `paths.md` and `prompt-rules.md`.

- [ ] **Step 2: Create identical minimal user root entries**

Create both `packaging/zhiji-user-overlay/AGENTS.md` and `packaging/zhiji-user-overlay/CLAUDE.md` with identical content:

```markdown
# 知己运行入口

## 最小上下文

按任务读取 `.claude/shared/paths.md` 和 `.claude/shared/prompt-rules.md`，不要默认读取全部日志、报告或主题文件。

## 主题思考

普通提问涉及用户既有观点、长期困惑或价值判断时，先读取 `.claude/shared/contracts/topic-thinking.md`，按契约检查 `context.thinking_index`；没有明显匹配则不读取详细主题。用户主动探讨形成可沉淀认识时，必须先展示归纳并获得确认，不能从日志自动摘录。

## 输出边界

用户可见输出使用简体中文。区分事实、推断和建议；证据不足时明确说明，不补全故事。
```

- [ ] **Step 3: Create the generic index template**

Create `packaging/zhiji-user-overlay/关于我/templates/thinking-index.template.md`:

```markdown
---
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
---

# 主题思考索引

| 主题 | 别名/关键词 | 当前核心问题 | 最近更新 |
|---|---|---|---|
```

- [ ] **Step 4: Create the generic topic template**

Create `packaging/zhiji-user-overlay/关于我/templates/thinking-topic.template.md`:

```markdown
---
topic: "{用户确认的主题名}"
aliases: []
created: YYYY-MM-DD
last_updated: YYYY-MM-DD
status: active
---

# {用户确认的主题名}

## 当前认识

## 形成依据

## 限制与反例

## 未决问题

## 观点演化
```

Do not add any concrete topic filename or example content.

- [ ] **Step 5: Export the root runtime entries through the manifest**

Add these manifest tasks before the existing root README task:

```json
{ "kind": "overwriteFile", "source": "packaging/zhiji-user-overlay/AGENTS.md", "target": "AGENTS.md" },
{ "kind": "overwriteFile", "source": "packaging/zhiji-user-overlay/CLAUDE.md", "target": "CLAUDE.md" },
```

Do not add fixed topic files to the manifest. The existing `关于我/templates` mirror exports the two generic templates.

- [ ] **Step 6: Refresh the generated user package**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

Expected output includes `mirrorDir  .claude`, `overwrite   AGENTS.md`, `overwrite   CLAUDE.md`, and `mirrorDir  关于我/templates`.

- [ ] **Step 7: Run focused and distribution integrity tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: both print `PASS` and exit `0`.

- [ ] **Step 8: Commit distribution support**

```powershell
git add packaging/zhiji-user-overlay packaging/zhiji-user-manifest.json zhiji-user tests/topic-thinking-contract.tests.ps1
git commit -m "feat: distribute dynamic topic thinking library"
```

---

### Task 4: Document user workflow and privacy boundaries

**Files:**
- Modify: `README.md`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Modify: `packaging/zhiji-user-overlay/关于我/README.md`
- Modify: generated `zhiji-user/README.md`
- Modify: generated `zhiji-user/关于我/README.md`

**Interfaces:**
- Consumes: natural-language behavior from `topic-thinking.md`.
- Produces: public instructions that describe dynamic topics, confirmation, transparent recall, and private storage without implying fixed examples.

- [ ] **Step 1: Add the main README feature section**

Add a concise “主题思考：让观点持续演化” section near other user capabilities:

```markdown
### 主题思考：让观点持续演化

适合：你想与 AI 深入讨论信息输入、工作与健康、关系边界或任何其他长期问题，并希望以后继续沿用这次形成的认识。

直接用自然语言开始探讨。形成相对明确的认识后，AI 会先展示“当前认识、形成依据、限制与反例、未决问题”；只有你确认后，才会在 `关于我/思考/` 动态创建或更新对应主题文件。这里没有固定主题清单。

以后遇到明显相关的问题时，AI 会先检查轻量索引，最多读取两个相关主题，并说明参考了哪些历史思考。你当前的表达始终优先于旧观点。
```

- [ ] **Step 2: Add equivalent user-facing instructions to overlay README**

Add the same capability under “你可以使用的功能”, including this example:

```text
我想和你讨论：持续摄入信息正在怎样影响我的生活。先不要保存；讨论形成明确认识后，再问我是否写入主题思考库。
```

Add `关于我/思考/` to “结果保存在哪里”, described as “用户确认后动态创建的主题认识、依据、反例与演化记录”.

- [ ] **Step 3: Document personal-data handling in the profile README**

Explain that `关于我/思考/` is created during use, contains personal views, should not be shipped as example content, and is covered by the user package's private-data precautions. State that templates are generic and do not restrict possible topics.

- [ ] **Step 4: Refresh export and verify no fixed topic files were generated**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
Get-ChildItem -LiteralPath 'zhiji-user/关于我' -Recurse -File | Where-Object { $_.FullName -match '信息输入与注意力|工作与健康|职业选择' }
```

Expected: export succeeds; the second command produces no output.

- [ ] **Step 5: Run all current tests**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: every script prints `PASS` and exits `0`.

- [ ] **Step 6: Commit public documentation**

```powershell
git add README.md packaging/zhiji-user-overlay/README.md packaging/zhiji-user-overlay/关于我/README.md zhiji-user/README.md zhiji-user/关于我/README.md
git commit -m "docs: explain topic thinking workflow"
```

---

### Task 5: Synchronize release state and perform final verification

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: completed feature and passing verification evidence.
- Produces: synchronized release state for version `1.6.0` and a clean, verified implementation ready for local commit.

- [ ] **Step 1: Update the release version**

Replace `VERSION` content with:

```text
1.6.0
```

Update `PROJECT_STATUS.md` current version to `1.6.0`, frontmatter `last_updated` to `2026-07-11`, add a completed progress row for the lightweight topic thinking library, and record the key decision: detailed logic belongs in one runtime contract; root entries only make the index discoverable; topics are dynamic and user-confirmed.

- [ ] **Step 2: Add the release-level changelog entry**

Insert at the top of `CHANGELOG.md` after frontmatter:

```markdown
## [2026-07-11 HH:MM] [功能] 新增轻量主题思考库 (v1.5.26 -> v1.6.0)

- **受影响文件**: `.claude/shared/`, `AGENTS.md`, `CLAUDE.md`, `packaging/zhiji-user-overlay/`, `packaging/zhiji-user-manifest.json`, `zhiji-user/`, `tests/topic-thinking-contract.tests.ps1`, `README.md`, `PROJECT_STATUS.md`, `VERSION`
- **改动摘要**: 用户现在可以主动与 AI 探讨任意长期问题，在确认归纳后按主题动态沉淀当前认识、依据、反例、未决问题与观点演化；后续相关提问通过轻量索引按需召回并透明说明来源，同时保持日志不自动摘录、未经确认不写入和当前表达优先等边界。
```

Replace `HH:MM` with the actual local time.

- [ ] **Step 3: Verify version and governance synchronization**

Run:

```powershell
$version = (Get-Content -LiteralPath VERSION -Raw -Encoding utf8).Trim()
$status = Get-Content -LiteralPath PROJECT_STATUS.md -Raw -Encoding utf8
$readme = Get-Content -LiteralPath README.md -Raw -Encoding utf8
if ($status -notmatch [regex]::Escape("**当前版本**：$version")) { throw 'PROJECT_STATUS version mismatch' }
if ($readme -match '版本-v([0-9.]+)' -and $Matches[1] -ne $version) { throw 'README badge version mismatch' }
if ((Get-FileHash AGENTS.md -Algorithm SHA256).Hash -ne (Get-FileHash CLAUDE.md -Algorithm SHA256).Hash) { throw 'governance files differ' }
```

Expected: no output and exit `0`.

- [ ] **Step 4: Run the complete verification suite**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/topic-thinking-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
git diff --check
git status --short
```

Expected: all three tests print `PASS`; `git diff --check` prints nothing; `git status --short` lists only intended feature, distribution, documentation, release, and generated user-package changes.

- [ ] **Step 5: Perform a contract-level acceptance walkthrough**

Check these three prompts manually against the final instructions:

```text
1. 日志：今天刷了很多资讯，晚上很累。
   Expected: normal log flow; no topic-thinking write proposal solely because the journal mentions a thought.

2. 我想和你探讨亲密关系中的边界。讨论清楚后，请归纳，但先别写入。
   Expected: arbitrary new topic is supported; AI proposes a structured summary and waits for confirmation.

3. 我最近又不知道该如何设定关系边界。
   Expected: AI checks the index, reads only a clearly related topic when present, names the referenced topic, and prioritizes the user's current statement over history.
```

Record any mismatch as a contract or entry-rule defect and fix it before committing.

- [ ] **Step 6: Commit the synchronized release state**

Use the changelog-derived local commit flow required by the repository:

```powershell
git add VERSION PROJECT_STATUS.md CHANGELOG.md
git commit -m "[功能] 新增轻量主题思考库 (v1.5.26 -> v1.6.0)"
```

Do not push. The user performs `git push` manually.
