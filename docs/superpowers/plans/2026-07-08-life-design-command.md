# life-design Command Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a low-frequency `/life-design` command and `life-design-synthesis` agent that turn long-term journal/review evidence into testable life-design prototypes.

**Architecture:** Follow the existing command → agent/shared-path pattern used by review commands. The command documents routing and modes, the agent owns evidence gathering and report generation, `paths.md` owns output paths, and monthly/yearly synthesis only emit upgrade reminders when direction conflicts are visible.

**Tech Stack:** Markdown command/agent definitions with YAML frontmatter, shared Markdown path contracts, existing Claude Code command/agent/workflow conventions, Git.

## Global Constraints

- Unique runtime truth is `.claude/`; product behavior belongs in `.claude/agents/`, `.claude/commands/`, `.claude/workflows/`, `.claude/skills/`, `.claude/settings.json`, and `.claude/shared/`.
- Root directory may only keep core files and repository metadata; remove or archive root-level `人生设计skill.md`.
- All Markdown files use YAML frontmatter.
- Chinese content files use Chinese; config fields and filenames use English.
- New product behavior must update `CHANGELOG.md`, `VERSION`, `PROJECT_STATUS.md`, and public docs when applicable.
- `/life-design` is a low-frequency direction calibration command, not a monthly perspective and not an automatic report after every review.
- Life-design output must be evidence-based, bounded in length, and end in 7-day prototype experiments with verification signals.

---

## File Structure

- Create `.claude/commands/life-design.md`: user-facing command contract, arguments, modes, routing to `life-design-synthesis`.
- Create `.claude/agents/life-design-synthesis.md`: full agent behavior, evidence strategy, report structure, limits, output path responsibility.
- Modify `.claude/shared/paths.md`: add `output.life_design_report`.
- Modify `.claude/commands/review.md`: route life-design related natural language to the new command/agent.
- Modify `.claude/agents/monthly-synthesis.md`: add direction-conflict reminder rule.
- Modify `.claude/agents/yearly-synthesis.md`: add direction-conflict reminder rule.
- Modify `README.md`: document the command/agent and command table if present.
- Modify `PROJECT_STATUS.md`: update version, command/agent counts, progress and decisions.
- Modify `VERSION`: increment minor version from `1.3.27` to `1.4.0`.
- Modify `CHANGELOG.md`: add one `[功能]` entry.
- Delete `人生设计skill.md`: remove root-level copied source material after its useful content has been migrated into command/agent/spec.

---

### Task 1: Add Shared Path Contract

**Files:**
- Modify: `.claude/shared/paths.md`

**Interfaces:**
- Produces: `output.life_design_report` path key used by `.claude/commands/life-design.md` and `.claude/agents/life-design-synthesis.md`.

- [ ] **Step 1: Add output path row**

In `.claude/shared/paths.md`, in the output path table, add:

```markdown
| `output.life_design_report` | `复盘/人生设计/YYYY-MM-DD-life-design.md` | `life-design-synthesis` |
```

Place it after `output.yearly_report`.

- [ ] **Step 2: Verify the key exists once**

Run:

```powershell
Select-String -Path '.claude\shared\paths.md' -Pattern 'output.life_design_report'
```

Expected: exactly one match.

---

### Task 2: Add `/life-design` Command

**Files:**
- Create: `.claude/commands/life-design.md`

**Interfaces:**
- Consumes: `output.life_design_report` from `.claude/shared/paths.md`.
- Produces: command contract for manual calls and argument modes.

- [ ] **Step 1: Create command file**

Create `.claude/commands/life-design.md` with:

```markdown
---
description: 基于长期日志、日反馈和复盘材料，做一次低频人生设计校准，生成可验证的未来原型实验
allowed-tools:
  - Task
  - Glob
  - Read
  - Write
---

# 人生设计命令

当用户在职业、身份、关系、生活结构或长期目标上卡住时，使用本命令做一次证据优先的人生设计校准。

本命令不是职业测评，不替用户决定人生；它负责把长期材料转成可测试的人生原型。

## 输入

参数来自：`$ARGUMENTS`

支持格式：

| 输入 | 模式 |
|------|------|
| 无参数 | `standard`，默认读取最近 90 天材料 |
| `主题` | `standard`，围绕指定主题校准 |
| `--quick` | 快速模式，只做问题重构 + 1 个 7 天原型实验 |
| `--full` | 深度模式，读取更长周期材料 |
| `--odyssey` | 奥德赛模式，聚焦三个五年人生原型 |

主题示例：`职业方向`、`生活节奏`、`关系选择`、`要不要继续当前路径`。

## 执行步骤

### 1. 解析参数

从 `$ARGUMENTS` 中解析：

- `mode`: `quick` / `standard` / `full` / `odyssey`
- `topic`: 用户指定主题；无主题时为 `general`

若同时出现多个模式，以最具体的最后一个模式为准。

### 2. 启动 agent

调用 Task 工具：

```text
subagent_type: life-design-synthesis
prompt: Life design {mode} {topic}
```

### 3. 返回结果

agent 创建报告后，向用户返回：

```text
人生设计校准已完成：复盘/人生设计/YYYY-MM-DD-life-design.md
```

如果 agent 因关键材料不足而提出缺口问题，先展示问题并等待用户回答，不生成报告。

## 输出边界

- `quick`: 1000-1800 字
- `standard`: 2000-3500 字
- `full`: 最多 5000 字
- `odyssey`: 2000-3500 字，重点放在三个奥德赛原型

## 质量要求

1. 先读证据，再做判断。
2. 只在关键证据缺失时提问，最多 3 个问题。
3. 报告必须包含“未来 7 天原型实验”和“下次如何验证”。
4. 不自动替用户选择唯一方案。
```

- [ ] **Step 2: Verify frontmatter**

Run:

```powershell
Get-Content -LiteralPath '.claude\commands\life-design.md' -TotalCount 10
```

Expected: file starts with YAML frontmatter and includes `description`.

---

### Task 3: Add `life-design-synthesis` Agent

**Files:**
- Create: `.claude/agents/life-design-synthesis.md`

**Interfaces:**
- Consumes: `paths.md`, `prompt-rules.md`, `analysis-standards.md`, personal profile/current state, journals, daily feedback, weekly/monthly/yearly reports.
- Produces: `复盘/人生设计/YYYY-MM-DD-life-design.md` or topic-suffixed report.

- [ ] **Step 1: Create agent file**

Create `.claude/agents/life-design-synthesis.md` with:

```markdown
---
name: life-design-synthesis
description: 基于长期日志、每日反馈、周/月/年度复盘和个人画像，进行低频人生设计校准，输出重力问题、指南针、能量地图、奥德赛原型和 7 天验证实验
model: inherit
color: cyan
allowed_tools: Read, Glob, Write
---

# 人生设计综合引擎

你负责把长期日志证据转化为可测试的人生原型。你不是职业测评工具，不替用户规划唯一人生道路；你帮助用户区分重力问题、可设计问题和伪问题，并把下一步压缩成低成本实验。

## 输入

用户提供：`Life design {mode} {topic}` 或类似格式。

- `mode`: `quick` / `standard` / `full` / `odyssey`
- `topic`: 主题；无主题时为 `general`

## 必读规则

1. 先读取 `.claude/shared/paths.md`，所有输入输出路径以它为准。
2. 读取 `.claude/shared/prompt-rules.md`，遵守证据规则、路径规则和输出契约。
3. 读取 `docs/analysis-standards.md`，尤其是事实基础、洞察深度、可执行改进、可讨论标准。

## 核心原则

1. 证据优先：先读长期材料，再判断是否需要提问。
2. 低频校准：只处理长期方向、生活结构、职业路径、身份选择等议题。
3. 重力问题识别：无法改变的现实不包装成“努力就能解决”的问题。
4. 原型优先：所有方向判断都要落成 7 天内可观察的低成本实验。
5. 多路径平等：三个奥德赛原型都是 A 计划，不写成主方案和备胎。

## 执行步骤

### 1. 解析模式与主题

从输入提取 `mode` 与 `topic`。

默认：

- `mode`: `standard`
- `topic`: `general`

字数边界：

| 模式 | 字数 |
|------|------|
| `quick` | 1000-1800 字 |
| `standard` | 2000-3500 字 |
| `full` | 最多 5000 字 |
| `odyssey` | 2000-3500 字 |

### 2. 收集证据

按模式读取材料：

| 模式 | 默认读取范围 |
|------|-------------|
| `quick` | 最近 30 天日志、最近 7 条日反馈、最近 1 份月报 |
| `standard` | 最近 90 天日志、最近 14 条日反馈、最近 1-3 份周/月复盘 |
| `full` | 最近 180 天日志、最近 30 条日反馈、最近 3-6 份月报、年度报告 |
| `odyssey` | 标准范围，额外聚焦长期选择、工作观、人生观、能量证据 |

始终尝试读取：

- `context.core_profile`
- `context.current`
- `output.monthly_report`
- `output.yearly_report`（若存在）
- `input.daily_feedback`
- `input.journal_dir`

材料缺失时，在报告中写明边界，不补造结论。

### 3. 内部形成假说

正式输出前，内部整理：

1. 当前最像卡住用户的长期问题是什么。
2. 哪些是重力问题，哪些是可设计问题。
3. 哪些问题可能是伪问题或错误前提。
4. 工作观与人生观是否冲突。
5. 哪些活动充电，哪些活动消耗。
6. 现有路径是否只是惯性延续。

如果关键材料不足以形成判断，最多提出 3 个缺口问题。缺口问题必须具体、一次只问必要内容。提出问题时不要生成报告。

### 4. 生成报告

写入 `.claude/shared/paths.md` 中的 `output.life_design_report`。

若 `topic` 不是 `general`，文件名可使用：

```text
复盘/人生设计/YYYY-MM-DD-life-design-{topic}.md
```

报告结构：

```markdown
---
created: YYYY-MM-DD
mode: standard|quick|full|odyssey
topic: 主题或 general
evidence_range: YYYY-MM-DD..YYYY-MM-DD
---

# 人生设计校准：YYYY-MM-DD

## 聊天摘要
[3 个关键判断 + 1 个本周原型行动]

## 一、你现在在哪里
[健康 / 工作 / 娱乐 / 爱四个仪表盘。必须引用日志、反馈或复盘证据。]

## 二、真正的问题是什么
[区分重力问题、可设计问题、伪问题或错误前提。]

## 三、你的指南针
[工作观、人生观，以及二者一致或冲突处。]

## 四、能量地图
[充电、消耗、擅长但透支、想试但未验证。]

## 五、三个奥德赛原型
[现有路径优化版、替代路径版、无惧评价版。每个都是 A 计划。]

## 六、未来 7 天原型实验
[最多 3 个低成本实验。每个包含行动、观察信号、验证方式。]

## 七、下次如何验证
[下一篇日志、日反馈、下次月报应观察哪些信号。]
```

### 5. 返回

创建文件后，只返回：

```text
人生设计校准已创建：YYYY-MM-DD
```

不要把完整报告内容读回主代理。

## 证据规则

1. 每个关键判断至少给出一条证据：日志日期、日反馈、周报、月报、年报或画像。
2. 没有证据时写“证据不足”，不写成结论。
3. 可以提出假说，但必须标注为“待验证假说”。
4. 原型实验必须能在 7 天内观察信号。
5. 报告必须包含反例、限制或边界，避免过度确定。

## 禁止事项

- 不写心理诊断。
- 不输出 8000-12000 字长报告。
- 不把不可控现实写成用户不够努力。
- 不给无法验证的长期建议。
- 不把三个奥德赛计划写成主方案、备胎和幻想。
```

- [ ] **Step 2: Verify agent metadata**

Run:

```powershell
Get-Content -LiteralPath '.claude\agents\life-design-synthesis.md' -TotalCount 12
```

Expected: file starts with YAML frontmatter and `name: life-design-synthesis`.

---

### Task 4: Route `/review` Life-Design Intent

**Files:**
- Modify: `.claude/commands/review.md`

**Interfaces:**
- Consumes: natural-language user intent.
- Produces: route to `life-design-synthesis` / `/life-design`.

- [ ] **Step 1: Add route row**

In `.claude/commands/review.md`, add this row to the route table after `项目复盘` or before yearly review:

```markdown
| `人生设计` `职业方向` `长期方向` `奥德赛计划` `人生规划` | life-design-synthesis agent |
```

- [ ] **Step 2: Add execution target**

In the execution routing list, add:

```markdown
- **life-design**: Task 工具，subagent_type: life-design-synthesis
```

- [ ] **Step 3: Add fallback hint**

In Error Handling, update the unrecognized hint to include:

```text
人生设计
```

- [ ] **Step 4: Verify route text**

Run:

```powershell
Select-String -Path '.claude\commands\review.md' -Pattern 'life-design|人生设计|奥德赛'
```

Expected: matches in route table and execution target.

---

### Task 5: Add Direction-Conflict Reminder to Monthly and Yearly Synthesis

**Files:**
- Modify: `.claude/agents/monthly-synthesis.md`
- Modify: `.claude/agents/yearly-synthesis.md`

**Interfaces:**
- Consumes: existing synthesis evidence.
- Produces: optional reminder text only; does not run `/life-design`.

- [ ] **Step 1: Add monthly reminder rule**

In `.claude/agents/monthly-synthesis.md`, under 综合原则, add:

```markdown
9. 如果本月材料显示长期方向冲突、重复卡点、工作观 / 人生观冲突，或下月规划只能做局部修补，必须在 `## 六、下月规划` 中增加一句升级提醒：`本次复盘出现长期方向冲突、重复卡点或人生议题，可输入 /life-design 做一次人生设计校准。` 不要自动生成 life-design 报告。
```

- [ ] **Step 2: Add yearly reminder rule**

In `.claude/agents/yearly-synthesis.md`, under 综合原则, add:

```markdown
5. 如果年度材料显示长期方向冲突、重复卡点、工作观 / 人生观冲突，或新年战略方向无法通过局部优化回答，必须在新年战略方向中增加一句升级提醒：`本次复盘出现长期方向冲突、重复卡点或人生议题，可输入 /life-design 做一次人生设计校准。` 不要自动生成 life-design 报告。
```

- [ ] **Step 3: Verify reminder exists**

Run:

```powershell
Select-String -Path '.claude\agents\monthly-synthesis.md','.claude\agents\yearly-synthesis.md' -Pattern '/life-design'
```

Expected: one match in each file.

---

### Task 6: Update Public Docs and Project Status

**Files:**
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `VERSION`
- Modify: `CHANGELOG.md`

**Interfaces:**
- Consumes: new command/agent/path from earlier tasks.
- Produces: published project state and version `1.4.0`.

- [ ] **Step 1: Inspect current README command/agent sections**

Run:

```powershell
Select-String -Path 'README.md' -Pattern '/project-review|/yearly-review|daily-analyzer|project-synthesis|命令|agent|代理' -Context 2,2
```

Expected: locate command and agent tables or sections.

- [ ] **Step 2: Update README**

Add `/life-design` to the command list and `life-design-synthesis` to the agent list, matching existing table style. Include the description:

```text
基于长期日志、日反馈和复盘证据，做低频人生设计校准，输出重力问题、能量地图、奥德赛原型和 7 天验证实验。
```

- [ ] **Step 3: Update VERSION**

Replace `1.3.27` with:

```text
1.4.0
```

- [ ] **Step 4: Update PROJECT_STATUS**

Update:

- `**当前版本**` to `1.4.0`.
- Command count from `11/11` to `12/12`.
- Agent count from `7/7` to `8/8`.
- Lifecycle table with a row:

```markdown
| 人生设计 | `/life-design` | `life-design-synthesis` |
```

- Core module progress to mention `/life-design` and `life-design-synthesis`.
- Key decision record:

```markdown
| 2026-07-08 | 新增人生设计专项命令作为低频方向校准层 | 支持用户主动处理重大迷茫，并在月报 / 年报发现方向冲突时提醒升级，不把人生设计做成常规月度视角 |
```

- [ ] **Step 5: Update CHANGELOG**

Add newest entry after the intro:

```markdown
## [2026-07-08 HH:MM] [功能] 新增人生设计专项命令与低频方向校准链路 (v1.3.27 → v1.4.0)

- **受影响文件**: `.claude/commands/life-design.md`, `.claude/agents/life-design-synthesis.md`, `.claude/shared/paths.md`, `.claude/commands/review.md`, `.claude/agents/monthly-synthesis.md`, `.claude/agents/yearly-synthesis.md`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`, `VERSION`, `人生设计skill.md`
- **改动摘要**: 新增 `/life-design` 专项命令与 `life-design-synthesis` agent，将原始人生设计 prompt 改造为证据优先、低频调用、可验证原型实验的方向校准链路；同步 `/review` 路由、月报 / 年报升级提醒和人生设计报告输出路径，并清理根目录临时来源文件。
```

Use the actual local time from PowerShell:

```powershell
Get-Date -Format 'yyyy-MM-dd HH:mm'
```

---

### Task 7: Remove Root-Level Copied Source File

**Files:**
- Delete: `人生设计skill.md`

**Interfaces:**
- Consumes: approved spec and migrated command/agent text.
- Produces: clean root directory aligned with AGENTS.md.

- [ ] **Step 1: Confirm source material has been migrated**

Run:

```powershell
Select-String -Path '.claude\agents\life-design-synthesis.md','docs\superpowers\specs\2026-07-08-life-design-command-design.md' -Pattern '重力问题|奥德赛|工作观|人生观|能量地图'
```

Expected: each core concept appears in the new agent/spec.

- [ ] **Step 2: Delete root copied file**

Use `apply_patch`:

```patch
*** Begin Patch
*** Delete File: 人生设计skill.md
*** End Patch
```

- [ ] **Step 3: Verify root is clean of copied file**

Run:

```powershell
Test-Path -LiteralPath '人生设计skill.md'
```

Expected: `False`.

---

### Task 8: Verification and Commit

**Files:**
- Verify all modified files.
- Commit all product changes.

**Interfaces:**
- Consumes: tasks 1-7.
- Produces: one local commit for implementation.

- [ ] **Step 1: Check version consistency**

Run:

```powershell
Get-Content -LiteralPath 'VERSION'
Select-String -Path 'PROJECT_STATUS.md' -Pattern '当前版本'
Select-String -Path 'README.md' -Pattern '1.4.0'
```

Expected: all public version references show `1.4.0` where applicable.

- [ ] **Step 2: Check key references**

Run:

```powershell
Select-String -Path '.claude\commands\life-design.md','.claude\agents\life-design-synthesis.md','.claude\shared\paths.md','.claude\commands\review.md','README.md','PROJECT_STATUS.md' -Pattern 'life-design|life_design|人生设计'
```

Expected: references are present in all relevant files.

- [ ] **Step 3: Check git status**

Run:

```powershell
git status --porcelain
```

Expected: only intended implementation files are modified/deleted/added.

- [ ] **Step 4: Stage and commit**

Run:

```powershell
git add -- .claude/commands/life-design.md .claude/agents/life-design-synthesis.md .claude/shared/paths.md .claude/commands/review.md .claude/agents/monthly-synthesis.md .claude/agents/yearly-synthesis.md README.md PROJECT_STATUS.md CHANGELOG.md VERSION 人生设计skill.md
git commit -m "feat: 新增 life-design 人生设计链路"
```

Expected: commit succeeds.

## Self-Review

Spec coverage:

1. Manual `/life-design` entry is covered by Task 2.
2. `life-design-synthesis` agent is covered by Task 3.
3. `output.life_design_report` is covered by Task 1.
4. `/review` routing is covered by Task 4.
5. Monthly/yearly upgrade reminders are covered by Task 5.
6. README, PROJECT_STATUS, CHANGELOG and VERSION updates are covered by Task 6.
7. Root copied file cleanup is covered by Task 7.
8. Verification and commit are covered by Task 8.

Placeholder scan: no `TBD`, `TODO`, or vague implementation steps are intentionally left.

Type consistency: command, agent and path names use `life-design`, `life-design-synthesis`, and `output.life_design_report` consistently.
