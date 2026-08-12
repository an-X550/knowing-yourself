# TickTick Four-Source Minimal Adaptation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 收敛知己现有 TickTick 分发，使每日反馈自动创建、周/月复盘确认后创建、已确认主题按确认创建，同时只写任务标题和截止时间，并继续只从后续日志判断行动完成。

**Architecture:** 保留现有本地权威与双渠道独立分发。共享结果分发契约把 TickTick 分为“提取候选”和“创建已确认候选”两个阶段：日反馈在写后直接进入创建，周/月写后只展示候选，主题的保存确认可携带创建授权；飞书仍按原规则即时分发。所有行为继续由 `.claude/` 的运行契约和既有入口表达，overlay 镜像后导出到 `zhiji-user/`，不新增 command、agent、workflow、服务或数据库。

**Tech Stack:** Markdown runtime contracts, Claude/Codex prompt routing, official Dida365/TickTick MCP create-task capability, JSON config/state, PowerShell contract/integrity tests.

## Global Constraints

- TickTick 只允许 create-task；禁止 list/get/search/update/complete/delete 和完成状态读取。
- 滴答任务的用户内容字段只有 SMART 化标题和截止日期/时间；目标清单来自固定配置，不写 description、路径、报告摘要、标签、优先级或自定义提醒。
- 只有 `output.daily_feedback`、`output.weekly_report`、`output.monthly_report`、`context.thinking_topic` 可产生滴答任务。
- 日反馈最多 1 项且新写后自动创建；周/月必须在最终整组确认后创建；主题保存确认同时决定是否创建，支持“只保存主题”。
- 周/月同一自然日默认合计最多 3 项；每日和主题不占该上限。
- 精确判重只使用 `normalized_title + exact_due_date_or_time`；不做语义相似或日期容差。
- “仅本地”在当前请求内同时跳过飞书和滴答；周/月不展示滴答候选，不持久化该选择。
- 完成判断只消费后续日志；不得把滴答状态作为证据。
- 外部失败不改变本地报告；无后台重试、历史批量补建、自动更新或删除远端任务。
- `.claude/` 是唯一运行真相；对应文件同步到 `packaging/zhiji-user-overlay/` 并重新导出 `zhiji-user/`。
- 保留用户未跟踪的 `AI agent 自动化工作流搭建教程.md`，不得暂存或修改。

---

### Task 1: 用失败测试锁定四来源、字段和精确判重

**Files:**
- Modify: `tests/result-distribution-contract.tests.ps1`
- Modify: `tests/result-distribution-routing.tests.ps1`
- Modify: `tests/result-distribution-setup.tests.ps1`
- Read: `docs/superpowers/specs/2026-08-12-ticktick-minimal-adaptation-design.md`

**Interfaces:**
- Consumes: 现有 `Assert-Contains`、`Assert-NotContains`、`Assert-Sequence`、`Assert-SameFile` 测试辅助函数。
- Produces: 对四来源白名单、确认门、字段限制、日期、上限、判重、失败和仅本地语义的可执行契约断言。

- [x] **Step 1: 改写 TickTick 适配器断言**

在 `result-distribution-contract.tests.ps1` 中要求主契约与 overlay 契约包含：

```powershell
Assert-Contains $path @(
  '只有四类来源可以产生滴答任务'
  '`output.daily_feedback`'
  '`output.weekly_report`'
  '`output.monthly_report`'
  '`context.thinking_topic`'
  'normalized_title + exact_due_date_or_time'
  '只传任务标题、截止日期或时间以及目标清单'
  '不传 description'
  '周/月同一自然日合计默认最多 3 项'
  '完成判断只读取后续日志'
)
Assert-NotContains $path @(
  '| 项目复盘 | 后续规划'
  '| 年度 / 人生设计 |'
  'source_path + normalized_title'
  '逐项传入 `action_title`、description'
)
```

同时断言默认日反馈日期按“本次成功生成后的下一本地日历日”，周/月相对日期锚定报告规划周期，主题无日期时为确认后第 7 日；过期日期不得自动顺延。

- [x] **Step 2: 增加路由确认门断言**

在 `result-distribution-routing.tests.ps1` 中要求：

```powershell
Assert-Contains '.claude/commands/daily-review.md' @('自动创建', '同一天', '重新分析', '历史补写')
Assert-Contains '.claude/commands/weekly-review.md' @('只展示候选', '最终整组', '明确确认后', '不创建')
Assert-Contains '.claude/commands/monthly-review.md' @('只展示候选', '最终整组', '明确确认后', '不创建')
Assert-Contains '.claude/shared/contracts/topic-thinking-persistence.md' @('保存并创建', '只保存主题', '第 7 个本地日历日')
```

对 Codex 自然语言路由添加相同周/月确认断言，并要求项目复盘 handoff 不产生 TickTick 候选。

- [x] **Step 3: 修正设置文档测试预期**

要求设置文档的一次性任务只核对标题、截止时间和目标清单，明确四来源以及周/月确认门；禁止继续要求 description。

- [x] **Step 4: 运行聚焦测试确认 RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-routing.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-setup.tests.ps1
```

Expected: 三个测试至少各有一项失败，指出旧契约仍含多余来源/description、周月缺少确认门、设置说明字段过时。

### Task 2: 收敛共享契约和四个入口

**Files:**
- Modify: `.claude/shared/contracts/result-distribution.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/commands/weekly-review.md`
- Modify: `.claude/commands/monthly-review.md`
- Modify: `.claude/shared/contracts/codex-natural-language-routing.md`
- Modify: `.claude/shared/contracts/topic-thinking-persistence.md`
- Mirror: corresponding files under `packaging/zhiji-user-overlay/`
- Test: `tests/result-distribution-contract.tests.ps1`
- Test: `tests/result-distribution-routing.tests.ps1`

**Interfaces:**
- Consumes: `distribute <path-key> <resolved-local-path>` 的既有写后入口与独立 Feishu/TickTick 渠道状态。
- Produces: `extract_ticktick_candidates(source_type, source_path, content, cycle_anchor, confirmation_context)` 语义；`create_confirmed_ticktick_tasks(candidates)` 只在来源策略允许时调用唯一 create-task 能力。

- [x] **Step 1: 重写 TickTick 契约章节**

将共享契约的 TickTick 部分明确为：

```text
daily_feedback -> extract -> exact dedupe -> create immediately
weekly/monthly -> extract -> show title|absolute due -> user edits -> show final group -> explicit confirm -> create
thinking_topic -> final save confirmation includes create authorization unless user says 只保存主题
all other source types -> skipped_not_supported for TickTick; Feishu behavior unchanged
```

任务创建只传 `title`、`due_date_or_time` 和配置目标清单；状态保存来源标识、规范化标题、精确截止时间、结果、`task_id`、`attempted_at`。定义当日周/月上限、精确判重、过期日期、部分失败一次显式重试、状态写入失败和报告后改动语义。

- [x] **Step 2: 修正日反馈路由**

在新反馈写入、复读、验证沉淀后，按契约自动创建唯一行动。今天或昨天的反馈截止到本次成功生成后的下一本地日历日；更早历史补写只展示候选并要求新的未来日期。同日重跑相同键跳过，不同键要求替代确认，旧任务不修改。

- [x] **Step 3: 添加周/月确认门**

保留写后 Feishu 分发；TickTick 在报告写后只提取并显示 `标题｜绝对日期`。没有候选时输出固定一句。允许自然语言修改，修改后重显最终整组；只有明确确认该整组后才创建。生成请求中的“同步到滴答”只表示意图，不算最终确认；未确认候选不入队、不催办、不写待创建状态。“仅本地”不显示候选。

- [x] **Step 4: 添加主题合并确认**

在主题最终沉淀确认中同时展示唯一合格行动与绝对截止时间。用户确认保存即授权保存并创建；“只保存主题”只写本地/按既有 Feishu 规则分发，不创建滴答。等待条件或当前不行动时不创建。

- [x] **Step 5: 同步 Codex 路由和 overlay**

Codex 自然语言周/月入口采用相同候选确认门，项目复盘仍可执行通用分发以支持 Feishu，但 TickTick 返回 `skipped_not_supported`。逐字复制被修改的共享/命令文件到 overlay 对应路径。

- [x] **Step 6: 运行聚焦测试确认 GREEN**

Run the Task 1 three commands. Expected: all PASS.

### Task 3: 收敛配置、设置说明和用户文档

**Files:**
- Modify: `.claude/shared/result-distribution-config.example.json`
- Modify: `复盘/.result-distribution-config.json` (gitignored runtime only)
- Modify: `docs/result-distribution-setup.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Modify: `packaging/zhiji-user-overlay/docs/result-distribution-setup.md`
- Mirror/Generate: `zhiji-user/`
- Test: `tests/result-distribution-setup.tests.ps1`
- Test: `tests/distribution-boundary.tests.ps1`
- Test: `tests/project-integrity.tests.ps1`

**Interfaces:**
- Consumes: schema version 1 config and existing export manifest.
- Produces: default-off example with TickTick eligible only for four sources; local runtime enables those four source triggers in the existing “知己行动” list without invoking them immediately.

- [x] **Step 1: 更新配置语义**

示例配置继续全关闭，但项目/年度/人生设计明确保持 TickTick false，只有 daily/weekly/monthly/thinking 被文档列为可启用。忽略的运行配置把这四项 `ticktick` 设为 true；这只让各来源在实际生成时可用，不会在本次开发中调用或批量创建任务。

- [x] **Step 2: 更新设置文档和 README**

设置测试任务只核对标题、截止时间和“知己行动”；说明日反馈自动、周/月最终确认、主题保存确认，以及完成判断来自后续日志。README 只保留一段高层说明，详细规则链接到设置文档。

- [x] **Step 3: 更新项目状态**

把“可选结果分发”状态改为四来源最小适配已实现、待真实验收；真实验收清单写入 3 次日反馈、1 次周复盘和 1 次月复盘或主题。不得宣称尚未发生的真实创建已经完成。

- [x] **Step 4: 导出用户版并验证镜像**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-setup.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/distribution-boundary.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/project-integrity.tests.ps1
```

Expected: export completes; all three tests PASS.

### Task 4: 发布、全量验证和本地提交

**Files:**
- Modify: `VERSION`
- Modify: `README.md`
- Modify: `zhiji-user/README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Test: all `tests/*.tests.ps1`

**Interfaces:**
- Consumes: 完成的四来源运行契约和同步用户版。
- Produces: version `1.15.0`，发布记录、完整验证证据和单个本地实现提交。

- [x] **Step 1: 递增版本并写发布记录**

将 `VERSION`、根 README 徽章、PROJECT_STATUS 当前版本和用户版版本统一为 `1.15.0`。在 CHANGELOG 顶部新增 `[功能]` 条目，说明四来源、确认门、最小字段、精确判重与排除的复杂能力。

- [x] **Step 2: 运行全量测试**

Run:

```powershell
$failed = @()
Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | Sort-Object Name | ForEach-Object {
  & powershell -NoProfile -ExecutionPolicy Bypass -File $_.FullName
  if ($LASTEXITCODE -ne 0) { $failed += $_.Name }
}
if ($failed.Count -gt 0) { throw "Failed suites: $($failed -join ', ')" }
```

Expected: 13 suites PASS and `$failed.Count` is 0.

- [x] **Step 3: 运行发布一致性审计**

验证：`VERSION`、PROJECT_STATUS、两个 README 均为 `1.15.0`；AGENTS/CLAUDE 哈希相同；主契约、overlay、用户版哈希相同；搜索不到旧 description 传递、项目/年度/人生设计 TickTick 提取表；`git diff --check` 通过。

- [x] **Step 4: 仅暂存本次实现文件并提交**

使用 `git status --short` 建立明确文件清单，排除 `AI agent 自动化工作流搭建教程.md` 和忽略的运行配置/状态。按 CHANGELOG 最新条目生成提交信息，执行 `git add -- <explicit files>`、`git diff --cached --check`、`git commit`，最后用 `git log -1 --oneline` 和 `git status --short` 验证。
