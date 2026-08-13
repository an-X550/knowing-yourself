# 飞书弹性日志入口 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 飞书智能体能安全接收常用带日期日志和结构化日记，无前缀时不误存普通聊天，并让分析与滴答分发复用确认日期。

**Architecture:** 在 `local-feishu-daily-feedback.ps1` 增加单一的日期与入口解析层：它只从首个非空行提取确定性日期，并决定是否允许无前缀处理。随后以同一 `journal_date` 驱动归档、分析提示、反馈与分发；栏目解析只生成分析定位线索，原文仍是唯一证据。既有工作流副本继续由 overlay 导出，避免运行逻辑分叉。

**Tech Stack:** PowerShell 5.1+、Pester 风格自包含 PowerShell 回归测试、现有 Codex CLI / lark-cli 工作流。

## Global Constraints

- 只修改 `.claude/` 运行真相；`packaging/zhiji-user-overlay/` 和 `zhiji-user/` 必须镜像工作流。
- 无年份日期固定使用飞书消息接收年份；不推断相对日期。
- 无前缀消息必须具备明确日志信号，普通聊天不得写入。
- 日反馈保持一条洞察、一条行动、一条可观察预测；栏目不是证据。
- 版本按兼容性新功能从 `1.18.1` 升为 `1.19.0`，并同步发布事实。

---

### Task 1: 为明确日期和无前缀入口建立失败回归测试

**Files:**
- Modify: `tests/local-feishu-daily-feedback-entry.tests.ps1`

**Interfaces:**
- Consumes: `ConvertTo-ZhijiEntryDecision -Event <event> -AllowedOpenId <owner>`
- Produces: 入口测试覆盖 `process`、`usage` 和最终 `journal_date`。

- [x] **Step 1: 写入会失败的日期格式测试**

在现有 `ConvertTo-ZhijiEntryDecision` 测试块加入表驱动用例：

```powershell
$dateCases = @(
  @{ body = "幸福日志 8.10`n思考：内容"; expected = "2026-08-10" },
  @{ body = "日记 2026年8月10日`n感受：内容"; expected = "2026-08-10" },
  @{ body = "# 日期：8/10`n开心的事情：a"; expected = "2026-08-10" },
  @{ body = "2026/8/10`n思考：内容"; expected = "2026-08-10" }
)
foreach ($case in $dateCases) {
  $event.content = "日志：$($case.body)"
  $result = ConvertTo-ZhijiEntryDecision -Event $event -AllowedOpenId "ou_owner"
  Assert-Equal $result.journal_date $case.expected "explicit journal must parse $($case.body)"
}
```

再加入 `日志：幸福日志 2.30` 应回退为接收日 `2026-08-12` 的断言。

- [x] **Step 2: 写入会失败的无前缀入口测试**

```powershell
$event.content = "幸福日志 8.10`n思考：内容"
$namedEntry = ConvertTo-ZhijiEntryDecision -Event $event -AllowedOpenId "ou_owner"
Assert-Equal $namedEntry.action "process" "named dated journal must not require 日志 prefix"
Assert-Equal $namedEntry.journal_date "2026-08-10" "named dated journal must retain parsed date"

$event.content = "8月10日`n开心的事情：a`n思考：b"
$structuredEntry = ConvertTo-ZhijiEntryDecision -Event $event -AllowedOpenId "ou_owner"
Assert-Equal $structuredEntry.action "process" "dated journal with two sections must not require prefix"

$event.content = "8月10日`n思考：b"
$oneSection = ConvertTo-ZhijiEntryDecision -Event $event -AllowedOpenId "ou_owner"
Assert-Equal $oneSection.action "usage" "one section must not auto-archive"

$event.content = "明天 8月10日一起吃饭"
$chat = ConvertTo-ZhijiEntryDecision -Event $event -AllowedOpenId "ou_owner"
Assert-Equal $chat.action "usage" "ordinary chat must not auto-archive"
```

- [x] **Step 3: 运行测试，确认失败**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`

Expected: FAIL，缺少无前缀入口或部分日期格式解析。

### Task 2: 实现单一日期、栏目和入口解析层

**Files:**
- Modify: `.claude/workflows/local-feishu-daily-feedback.ps1`
- Test: `tests/local-feishu-daily-feedback-entry.tests.ps1`

**Interfaces:**
- Consumes: 飞书事件 `content`、`create_time`。
- Produces: `ConvertTo-ZhijiEntryDecision` 返回 `process` 时的原文与唯一 `journal_date`；`Get-ZhijiJournalStructureHint` 返回可选栏目摘要。

- [x] **Step 1: 实现首行和日期候选解析函数**

在 `ConvertTo-ZhijiEntryDecision` 前新增 `Get-ZhijiJournalDateCandidate`，接收 `$JournalText` 和 `$FallbackDate`。它仅读取首个非空行，去掉可选 `#` 与 `日期：` 前缀，依次匹配含年份和不含年份的 ISO、斜杠、中文、点号、横杠格式；用 `[datetime]::new()` 校验年月日并返回 `{ date; has_explicit_date }`，非法时返回 `$null`。

- [x] **Step 2: 实现栏目提示解析函数**

新增 `Get-ZhijiJournalStructureHint -JournalText <text>`：逐行匹配可选 Markdown 标记后的栏目名和中英文冒号，映射为规格中的六类；保留每个栏目原名及非空正文。返回 `{ section_count; sections }`，其中 `section_count` 是不同类别数。

- [x] **Step 3: 以解析结果决定入口并保留回退边界**

将前缀判定改为：

```powershell
$hasExplicitPrefix = $content -match '^[\s\p{Cf}]*日志[\s\p{Cf}]*[：:][\s\p{Cf}]*(?<body>[\s\S]*?)$'
$journalText = if ($hasExplicitPrefix) { $Matches.body.TrimStart([char[]]@("`r", "`n")) } else { $content.Trim() }
$dateCandidate = Get-ZhijiJournalDateCandidate -JournalText $journalText -FallbackDate $messageDate
$structureHint = Get-ZhijiJournalStructureHint -JournalText $journalText
$namedEntry = $journalText -match '^\s*(?:#{1,2}\s*)?(?:幸福日志|日志|日记|复盘)\b'
$mayProcess = $hasExplicitPrefix -or ($null -ne $dateCandidate -and ($namedEntry -or $structureHint.section_count -ge 2))
```

`$mayProcess` 为假时返回现有 `usage`；显式前缀且日期候选无效时保留 `$messageDate`；无前缀时必须有合法候选。为便于后续提示，将栏目提示放入 `New-ZhijiEntryDecision` 的可选 `structure_hint` 字段，但状态文件不得写入该字段。

- [x] **Step 4: 更新分析提示，使栏目只作定位线索**

找到生成 Codex 日反馈提示的函数，在传入 `Analyze $journalDate` 和原文处增加：确认日期、JSON 化栏目摘要，以及“原文是唯一证据；栏目只用于定位；不得把 ToDo 或计划写成完成事实；输出仍严格遵守 daily-analyzer 格式”的说明。

- [x] **Step 5: 运行入口测试，确认通过**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`

Expected: `PASS: local Feishu daily feedback entry checks`。

### Task 3: 覆盖栏目边界和最终日期传播

**Files:**
- Modify: `tests/local-feishu-daily-feedback-entry.tests.ps1`
- Modify: `.claude/workflows/local-feishu-daily-feedback.ps1`

**Interfaces:**
- Consumes: `Get-ZhijiJournalStructureHint` 与 `Invoke-ZhijiEntryDecision`。
- Produces: 原文分段边界、提示上下文与归档/反馈/滴答一致日期的回归保证。

- [x] **Step 1: 写入结构提示的失败测试**

```powershell
$hint = Get-ZhijiJournalStructureHint -JournalText "开心的事情：散步`n思考：慢下来`nToDo：写三条"
Assert-Equal $hint.section_count 3 "three distinct sections must be recognized"
Assert-Equal $hint.sections.intentions.title "ToDo" "English ToDo must retain original title"
Assert-True ($hint.sections.reflections.content -match "慢下来") "section content must retain text"
```

并断言自由叙事返回 `section_count` 为 0，栏目为空时不进入 `sections`。

- [x] **Step 2: 运行测试，确认失败**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`

Expected: FAIL，直到结构函数与提示接线完成。

- [x] **Step 3: 实现最小修正并验证提示数据流**

让 `Invoke-ZhijiEntryDecision` 把 `$Decision.structure_hint` 传入 Codex prompt 构建路径；不得改变保存原文、反馈或分发的调用签名。新增测试断言 Codex mock 收到确认日期、原文和 `ToDo` 线索。

- [ ] **Step 4: 运行完整相关测试**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1; powershell -ExecutionPolicy Bypass -File tests\result-distribution-contract.tests.ps1; powershell -ExecutionPolicy Bypass -File tests\distribution-boundary.tests.ps1`

Expected: 三项均 `PASS`。

### Task 4: 同步用户包、发布事实并做最终验证

**Files:**
- Modify: `packaging/zhiji-user-overlay/.claude/workflows/local-feishu-daily-feedback.ps1`
- Modify: `zhiji-user/.claude/workflows/local-feishu-daily-feedback.ps1`
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/superpowers/specs/2026-08-13-feishu-flexible-journal-entry-design.md`

**Interfaces:**
- Consumes: 主运行工作流与 `scripts/export-zhiji-user.ps1`。
- Produces: 三份工作流内容一致、版本 `1.19.0`、用户可见发布记录。

- [ ] **Step 1: 同步 overlay 和用户包**

复制主工作流到 `packaging/zhiji-user-overlay/.claude/workflows/local-feishu-daily-feedback.ps1`，再运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\export-zhiji-user.ps1
```

确认主工作流、overlay 与 `zhiji-user` 的 SHA256 相同。

- [ ] **Step 2: 更新版本和事实记录**

把 `VERSION` 改为 `1.19.0`；更新 `PROJECT_STATUS.md` 的“本地飞书日反馈入口”事实为：支持明确的日期标题和无前缀结构化日志，仍需真实新日志观察自动滴答写入；在 `CHANGELOG.md` 顶部增加 `[功能]` 记录，列出入口、日期、栏目线索及误触发保护。

- [ ] **Step 3: 最终验证**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1
powershell -ExecutionPolicy Bypass -File tests\result-distribution-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests\distribution-boundary.tests.ps1
git diff --check
git diff --no-index -- .claude\workflows\local-feishu-daily-feedback.ps1 packaging\zhiji-user-overlay\.claude\workflows\local-feishu-daily-feedback.ps1
git diff --no-index -- .claude\workflows\local-feishu-daily-feedback.ps1 zhiji-user\.claude\workflows\local-feishu-daily-feedback.ps1
```

Expected: 三项测试通过，`git diff --check` 无错误，两个文件比较退出码为 0。

- [ ] **Step 4: 提交本地变更**

仅暂存本计划列出的运行、测试和发布文件，不暂存现有的 Nozomi 草案：

```powershell
git add .claude/workflows/local-feishu-daily-feedback.ps1 packaging/zhiji-user-overlay/.claude/workflows/local-feishu-daily-feedback.ps1 zhiji-user/.claude/workflows/local-feishu-daily-feedback.ps1 tests/local-feishu-daily-feedback-entry.tests.ps1 VERSION PROJECT_STATUS.md CHANGELOG.md docs/superpowers/specs/2026-08-13-feishu-flexible-journal-entry-design.md docs/superpowers/plans/2026-08-13-feishu-flexible-journal-entry.md
git commit -m "feat: accept flexible Feishu journal formats"
```
