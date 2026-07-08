# Context Budget Optimization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce unnecessary runtime context reading while preserving all existing skill output quality requirements.

**Architecture:** Split task-specific prompt contracts out of `.claude/shared/prompt-rules.md`, update agents to read only relevant contracts, fix stale command wording, then sync release metadata and verify references.

**Tech Stack:** Markdown prompt files, Claude Code command/agent contracts, semantic versioning, changelog governance.

## Global Constraints

- Do not change command names, arguments, workflow orchestration, output directories, output filenames, or report section structure.
- Keep `.claude/` as the only runtime truth.
- Keep all user-facing agent, command, workflow, and perspective output in Simplified Chinese.
- Preserve daily feedback quality: yesterday loop, one blind spot, optional pattern link, one atomic action, one verifiable prediction, and one `💊` line.
- Preserve review synthesis quality: explicit six-question structure, direction-anchor absence checks, evidence boundaries, and verification sediment consumption.
- Bump patch version and add one release-grade `CHANGELOG.md` entry after validation.

---

### Task 1: Create Focused Runtime Contract Files

**Files:**
- Create: `.claude/shared/contracts/daily-feedback.md`
- Create: `.claude/shared/contracts/review-synthesis.md`
- Create: `.claude/shared/contracts/evidence-and-verification.md`

**Interfaces:**
- Consumes: `.claude/shared/prompt-rules.md`, `docs/analysis-standards.md`, existing daily and review agent prompts.
- Produces: Three focused contract files that agents can read instead of the full shared prompt rules.

- [ ] **Step 1: Create the contracts directory and daily feedback contract**

Create `.claude/shared/contracts/daily-feedback.md` with YAML frontmatter and these sections:

```markdown
---
type: runtime_contract
purpose: 日反馈输出契约与 D0-D6 轻量质量门
last_updated: 2026-07-08
---

# 日反馈契约

## 输出结构

用户可见输出只包含：标题、可选昨日闭环、盲点、可选模式连接、一个明天动作、`💊` 追踪行。不要输出 D0-D6 自检行；默认只围绕一个核心洞察展开。

## 昨日闭环

有上一条反馈时，必须同时提取上一条 `⚡ 明天试试` 的行动、预测和 `💊` 行中的新认知，并用今天日志证据判断 `✅ 做到了` / `❌ 没做` / `⚠️ 证据不足`。对上一条新认知的说明只保留一句，不额外展开成独立分析段。无上一条反馈时，不显示昨日闭环段。

## 原文支撑

`🔍 你没注意到的` 至少引用一句当天日志原文，引用用 `「」` 标记；优先只引用最关键的一句。

## 一个动作

`⚡ 明天试试` 只能有一个动作，必须小于 5 分钟，且第一步不需要用户再拆解。

## 可验证预测

预测必须能在 24 小时内通过下一篇日志判断，禁止“会更好”“更稳定”这类模糊结果；不得把“明天”误写成“明年”等日期口误。

## 长度上限

常规输出控制在 260 中文字以内；只有昨日闭环证据复杂时可放宽到 320 字。

## 禁止重复解释

同一判断不得跨 `⏮️`、`🔍`、`🔗` 三段换说法重复；如果 `🔗` 不能补充新证据或改变明天动作，直接删除该段。

## D0-D6 内部质量门

| 标准 | 要求 |
|------|------|
| D0. 昨日闭环 | 有上一条每日反馈时，必须读取行动和预测，并用今天日志证据判断结果；无上一条反馈时内部标记 N/A，用户输出不显示该段。 |
| D1. 原文支撑 | `🔍 你没注意到的` 至少引用一句当天日志原文，引用必须支撑判断。 |
| D2. 指出盲点 | 指出用户写了但可能没意识到的矛盾、反证、未完成闭环或隐含动机；没有新洞察时诚实说明。 |
| D3. 模式连接 | 有可靠材料时连接月报、昨日反馈或近期重复主题；没有可靠连接时跳过 `🔗` 段。 |
| D4. 一个动作 | 只给 1 个基于今天日志内容的具体行动，不给备选项、组合动作或原则建议。 |
| D5. 原子粒度 | 行动必须 ≤5 分钟、24 小时内可验证，且用户看到后知道第一步怎么做。 |
| D6. 预测可验证 | 每个行动附带 1 条 24 小时内可验证预测，预测必须是日志中的具体表述、行为或栏目变化。 |

## 输出模板

```text
📋 M月D日 日志反馈

⏮️ 昨天你答应自己
[如果找到昨日反馈：行动 + 预测]
✅ 做到了 / ❌ 没做 / ⚠️ 证据不足 → [引用今天日志证据，≤60字；如有上一条新认知，只用一句说明它本次被支持、未执行或证据不足]

🔍 你没注意到的
[1句话优先，最多2句。必须引用当天日志原文「...」，只写一个最关键洞察]

🔗 和之前有关
[1句话。连接已知模式、昨日反馈或月报假说；若与🔍重复或不能改变明天动作，则跳过]

⚡ 明天试试
行动：[一个≤5分钟的原子行动]
预测：[如果做到了，下一篇日志里应能观察到的具体现象]

💊 新认知：[关键发现] | 行动：[即将执行] | 验证：[待明天]
```

## 返回前压缩检查

- `🔍` 是否已经承载唯一主洞察？如果不是，删到只剩一个。
- `⏮️`、`🔍`、`🔗` 是否在重复同一判断？如果是，保留最接近行动的一段。
- `🔗` 是否提供了新证据或改变了明天动作？如果没有，删除 `🔗`。
- 是否存在只是在解释前一句、却没有新增证据或行动的信息？如果有，删除。
```

- [ ] **Step 2: Create the review synthesis contract**

Create `.claude/shared/contracts/review-synthesis.md` with six-question structure, direction-anchor absence statuses, weekly/monthly depth differences, and the rule that synthesis organizes by theme instead of perspective order.

- [ ] **Step 3: Create the evidence and verification contract**

Create `.claude/shared/contracts/evidence-and-verification.md` with evidence rules, `verified-patterns.md` write-back states, weekly/monthly consumption rules, and the “证据不足” boundary.

- [ ] **Step 4: Verify frontmatter exists**

Run:

```powershell
Get-ChildItem -Path '.claude\shared\contracts' -File | ForEach-Object { Select-String -LiteralPath $_.FullName -Pattern '^---$' | Select-Object -First 1 }
```

Expected: each new contract file has a frontmatter delimiter result.

### Task 2: Convert Prompt Rules Into an Index

**Files:**
- Modify: `.claude/shared/prompt-rules.md`

**Interfaces:**
- Consumes: New contract files from Task 1.
- Produces: A shorter shared rule index that keeps global hard rules and points task-specific details to contracts.

- [ ] **Step 1: Replace detailed daily contract with contract reference**

In `.claude/shared/prompt-rules.md`, replace the long “日反馈输出契约” body with a short pointer:

```markdown
## 八、任务契约索引

| 场景 | 必读契约 |
|------|----------|
| 日反馈 | `.claude/shared/contracts/daily-feedback.md` + `.claude/shared/contracts/evidence-and-verification.md` |
| 周/月/项目复盘综合 | `.claude/shared/contracts/review-synthesis.md` + `.claude/shared/contracts/evidence-and-verification.md` |
| 证据、验证沉淀、周/月消费 | `.claude/shared/contracts/evidence-and-verification.md` |
```

- [ ] **Step 2: Keep only global rules**

Keep path rules, hook and entry rules, output responsibility, banned-phrase synchronization, and no-feature-change boundaries in `prompt-rules.md`.

- [ ] **Step 3: Remove duplicated detailed rules**

Remove detailed D0-D6, daily output template, verification write-back state table, and review six-question details from `prompt-rules.md` once they exist in focused contracts.

### Task 3: Update Daily Feedback Runtime Reads

**Files:**
- Modify: `.claude/agents/daily-analyzer.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`

**Interfaces:**
- Consumes: `.claude/shared/contracts/daily-feedback.md` and `.claude/shared/contracts/evidence-and-verification.md`.
- Produces: Daily feedback flow that no longer requires full `docs/analysis-standards.md` for D0-D6.

- [ ] **Step 1: Update `daily-analyzer` required reads**

Change required rules to:

```markdown
1. 先读取 `.claude/shared/paths.md`，所有日志、反馈、月报和上下文路径都以它为准。
2. 读取 `.claude/shared/contracts/daily-feedback.md`，遵守日反馈输出契约和 D0-D6 内部质量门。
3. 读取 `.claude/shared/contracts/evidence-and-verification.md`，遵守证据规则和验证沉淀边界。
4. 读取 `context.verified_patterns`（若存在），避免重复提出已经被证伪或连续没做的行动。
5. 单日日志反馈只由你这一层生成；调用方只负责确定日期、持久化输出与写回验证沉淀。
```

- [ ] **Step 2: Remove full analysis-standard dependency**

Remove the instruction that `daily-analyzer` must read `docs/analysis-standards.md` for D0-D6. Keep internal D0-D6 self-check language by referencing the daily contract.

- [ ] **Step 3: Update command and log wording**

In `/daily-review` and `log` skill docs, reference `.claude/shared/contracts/daily-feedback.md` for the visible output contract and `.claude/shared/contracts/evidence-and-verification.md` for write-back behavior.

### Task 4: Update Review Synthesis Runtime Reads

**Files:**
- Modify: `.claude/agents/weekly-synthesis.md`
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/commands/weekly-review.md`

**Interfaces:**
- Consumes: `.claude/shared/contracts/review-synthesis.md` and `.claude/shared/contracts/evidence-and-verification.md`.
- Produces: Weekly and monthly synthesis prompts with reduced duplicated protocol text and no stale command-level report structure.

- [ ] **Step 1: Update `weekly-synthesis` required reads**

Require `paths.md`, `review-synthesis.md`, and `evidence-and-verification.md`. Keep weekly-specific input, data loading, output file, and error handling in the agent.

- [ ] **Step 2: Update `monthly-synthesis` required reads**

Require `paths.md`, `review-synthesis.md`, and `evidence-and-verification.md`. Keep monthly-specific perspective list, theme merge process, output file, and error handling in the agent.

- [ ] **Step 3: Remove duplicated protocol detail only after contract coverage**

Shorten repeated six-question, direction-anchor status, and verification sediment paragraphs in weekly/monthly agents only where the contract already states the exact rule.

- [ ] **Step 4: Fix stale weekly command structure**

Replace the old “7章→5段” section in `.claude/commands/weekly-review.md` with the explicit six-question report structure:

```markdown
## 报告结构

周度报告使用复盘六问轻量版：

1. `## 一、回顾目标`
2. `## 二、评估结果`
3. `## 三、分析原因（正向）`
4. `## 四、分析原因（负向）`
5. `## 五、重来演练`
6. `## 六、下周规划`

仍需包含 `## 聊天摘要` 与 `## 质量自检`。
```

### Task 5: Sync Public Docs and Release Metadata

**Files:**
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`

**Interfaces:**
- Consumes: Repo governance rules in `AGENTS.md`.
- Produces: Versioned release note for context-budget optimization.

- [ ] **Step 1: Bump patch version**

Read `VERSION`, increment patch by 1, and write the same value to `PROJECT_STATUS.md` current version.

- [ ] **Step 2: Update project status**

Add or update a current-progress note that shared runtime contracts now use context-budgeted task contracts under `.claude/shared/contracts/`.

- [ ] **Step 3: Update README if shared-contract structure is described**

If README lists `.claude/shared/`, add `.claude/shared/contracts/` as the task-specific runtime contract directory.

- [ ] **Step 4: Add changelog entry**

Add a top `[重构]` entry describing that runtime prompt contracts were split by task to reduce unnecessary context reading while preserving output contracts.

### Task 6: Verify Consistency

**Files:**
- Verify: `.claude/shared/contracts/*.md`
- Verify: `.claude/shared/prompt-rules.md`
- Verify: `.claude/agents/daily-analyzer.md`
- Verify: `.claude/agents/weekly-synthesis.md`
- Verify: `.claude/agents/monthly-synthesis.md`
- Verify: `.claude/commands/weekly-review.md`
- Verify: `README.md`
- Verify: `PROJECT_STATUS.md`
- Verify: `CHANGELOG.md`
- Verify: `VERSION`

**Interfaces:**
- Consumes: All modified prompt and docs files.
- Produces: Evidence that context was split without behavior drift.

- [ ] **Step 1: Confirm daily analyzer no longer requires full analysis standards**

Run:

```powershell
Select-String -LiteralPath '.claude\agents\daily-analyzer.md' -Pattern 'analysis-standards'
```

Expected: no required-read instruction for full `docs/analysis-standards.md`.

- [ ] **Step 2: Confirm old weekly structure wording is gone**

Run:

```powershell
Select-String -LiteralPath '.claude\commands\weekly-review.md' -Pattern '7章|5段简化复盘'
```

Expected: no matches.

- [ ] **Step 3: Confirm contract references exist**

Run:

```powershell
Select-String -Path '.claude\agents\daily-analyzer.md','.claude\agents\weekly-synthesis.md','.claude\agents\monthly-synthesis.md' -Pattern 'contracts'
```

Expected: each agent references the relevant contract files.

- [ ] **Step 4: Confirm version consistency**

Run:

```powershell
$version = Get-Content -Encoding UTF8 -LiteralPath 'VERSION'
Select-String -LiteralPath 'PROJECT_STATUS.md','CHANGELOG.md' -Pattern $version
```

Expected: `PROJECT_STATUS.md` and latest `CHANGELOG.md` entry contain the same version.

- [ ] **Step 5: Review diff**

Run:

```powershell
git diff -- .claude docs README.md PROJECT_STATUS.md CHANGELOG.md VERSION
```

Expected: only context-contract refactor, stale weekly wording fix, docs, version, and changelog changes.

### Task 7: Commit

**Files:**
- Stage: all modified files from Tasks 1-6.

**Interfaces:**
- Consumes: Verified working tree changes.
- Produces: One local commit; push remains manual.

- [ ] **Step 1: Stage files**

Run:

```powershell
git add .claude docs README.md PROJECT_STATUS.md CHANGELOG.md VERSION
```

- [ ] **Step 2: Commit**

Run:

```powershell
git commit -m "refactor: split runtime prompt contracts by context budget"
```
