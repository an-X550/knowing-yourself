# 飞书日反馈追问 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让飞书私聊中的用户可自然追问一份每日反馈，同时保证追问零业务写入、零分发和零会话记忆。

**Architecture:** 在现有飞书监听器中新增独立的追问决策与执行路径。日志路由保持最高优先级；追问路由只读取一份目标反馈和可选同日日志，调用现有的隔离只读 Codex 适配器，并把回复直接发回飞书。追问从不调用存档、每日分析或结果分发函数。

**Tech Stack:** PowerShell 5.1+、现有 `codex exec` 只读隔离调用、lark-cli、现有自包含 PowerShell 回归测试。

## Global Constraints

- 只处理配置中唯一用户的文本私聊，且日志入口始终先于追问入口。
- 追问不写日志、每日反馈、分发状态、滴答或飞书文档；不保存问题、回答、会话或回复关系。
- 日期格式、非法日期和缺少年份规则复用现有 `Get-ZhijiJournalDateCandidate`；缺少年份采用消息接收年份。
- 无日期时仅选择本地最近修改的一份有效每日反馈；不查询飞书历史。
- 提示用户可直接回复、可写 `追问：`，以及可按日期引用旧反馈。
- 基于当前 `1.20.0`，完成后升为 `1.21.0`；主工作流、overlay 和 `zhiji-user` 必须逐字一致。

---

### Task 1: 建立追问路由与上下文选择的失败测试

**Files:**
- Modify: `tests/local-feishu-daily-feedback-entry.tests.ps1`

**Interfaces:**
- Consumes: `ConvertTo-ZhijiFollowUpDecision -Event <event> -AllowedOpenId <owner> -RepoRoot <root>`。
- Produces: `follow_up`、`usage`、`reject_*` 决策，携带 `question` 和 `journal_date`。

- [x] **Step 1: 写入追问路由的失败测试**

在临时仓库创建 `复盘/每日反馈/2026-08-10.md`、`2026-08-12.md`，其中后者更新时间更新。加入：

```powershell
$followUp.content = '追问：为什么我总是迁就对方？'
$explicit = ConvertTo-ZhijiFollowUpDecision -Event $followUp -AllowedOpenId 'ou_owner' -RepoRoot $tempRoot
Assert-Equal $explicit.action 'follow_up' 'explicit follow-up must route'
Assert-Equal $explicit.journal_date '2026-08-12' 'follow-up without date must choose latest feedback'
Assert-Equal $explicit.question '为什么我总是迁就对方？' 'prefix must be removed from question'

$followUp.content = '问 8月10日：那条反馈哪里有证据？'
$dated = ConvertTo-ZhijiFollowUpDecision -Event $followUp -AllowedOpenId 'ou_owner' -RepoRoot $tempRoot
Assert-Equal $dated.journal_date '2026-08-10' 'dated follow-up must select named feedback'

$followUp.content = '今天吃了什么？'
Assert-Equal (ConvertTo-ZhijiFollowUpDecision -Event $followUp -AllowedOpenId 'ou_owner' -RepoRoot $tempRoot).action 'usage' 'ordinary chat must not invoke follow-up'
```

还要断言日志消息仍由 `ConvertTo-ZhijiEntryDecision` 处理，不被追问函数误判。

- [x] **Step 2: 运行测试，确认失败**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`

Expected: FAIL，缺少 `ConvertTo-ZhijiFollowUpDecision`。

### Task 2: 实现无状态追问判定与只读执行

**Files:**
- Modify: `.claude/workflows/local-feishu-daily-feedback.ps1`
- Test: `tests/local-feishu-daily-feedback-entry.tests.ps1`

**Interfaces:**
- Consumes: `ConvertTo-ZhijiFollowUpDecision` 的目标日期与问题。
- Produces: `Invoke-ZhijiFollowUpDecision -Decision <decision> -Config <config>` 的纯飞书回复结果。

- [x] **Step 1: 新增追问入口解析**

实现 `ConvertTo-ZhijiFollowUpDecision`：先复用发送者、私聊与文本验证；将首个非空文本匹配 `追问/想问/问`（可有中英文冒号）、`关于刚才`、`展开说说`、`为什么`、`那我该怎么做`、`我还是不懂`。日期引用也算明确追问。空问题和普通聊天返回稳定用法文本。

实现 `Find-ZhijiLatestDailyFeedbackDate` 与 `Get-ZhijiFollowUpDate`：只允许 `复盘/每日反馈/YYYY-MM-DD.md`；存在显式日期时必须目标文件存在，否则返回 `follow_up_feedback_missing`；无日期时按 `LastWriteTimeUtc` 选最新文件。

- [x] **Step 2: 新增只读追问执行函数**

实现 `Invoke-ZhijiFollowUpDecision`：读取目标反馈和可选 `日志/YYYY-MM-DD.md`，建立只读提示，复用 `Get-ZhijiCodexArguments` / `Invoke-ZhijiExternalCommand`，回复成功文本与固定帮助。它只通过 `Send-ZhijiEntryReply` 写回飞书，不调用 `Invoke-ZhijiEntryDecision`、`Invoke-ZhijiResultDistribution`、`Write-ZhijiEntryState` 或任何业务写文件函数。

固定帮助：

```text
💬 继续追问：直接回复这条消息，或发送“追问：你的问题”。
查看旧反馈可写：“问 8月10日：你的问题”。追问不会改写日志、创建任务或保存聊天记录。
```

- [x] **Step 3: 在监听器中按优先级接线**

将当前 `Start-ZhijiEntryListener` 路由改成：先运行日志决策；仅当它返回 `usage` 时再运行追问决策；两者都不匹配才回复包含日志和追问用法的统一帮助。追问成功后使用 `follow-up-result` 幂等后缀。

- [x] **Step 4: 运行测试，确认通过**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`

Expected: `PASS: local Feishu daily feedback entry checks`。

### Task 3: 验证提示上下文与零副作用

**Files:**
- Modify: `tests/local-feishu-daily-feedback-entry.tests.ps1`
- Modify: `.claude/workflows/local-feishu-daily-feedback.ps1`

**Interfaces:**
- Consumes: 目标反馈、同日日志、`CodexInvoker` 与 `ReplyInvoker` 测试替身。
- Produces: 只含必要证据的提示与不变业务文件哈希。

- [x] **Step 1: 写入失败的追问执行测试**

创建目标反馈、同日日志和 `.result-distribution-state.json`，记录三者哈希。以 mock 调用 `Invoke-ZhijiFollowUpDecision`，断言：

```powershell
Assert-True ($capturedPrompt -match '目标每日反馈') 'prompt must include feedback context'
Assert-True ($capturedPrompt -match '原文是唯一证据') 'prompt must state evidence boundary'
Assert-True ($capturedPrompt -match '不得修改文件') 'prompt must remain read-only'
Assert-True ($replyText -match '直接回复这条消息') 'reply must advertise follow-up use'
Assert-Equal (Get-ZhijiFileSha256 -Path $feedbackPath) $feedbackHash 'follow-up must not rewrite feedback'
Assert-Equal (Get-ZhijiFileSha256 -Path $journalPath) $journalHash 'follow-up must not rewrite journal'
Assert-Equal (Get-ZhijiFileSha256 -Path $statePath) $stateHash 'follow-up must not change distribution state'
```

- [x] **Step 2: 运行测试，确认失败**

Run: `powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1`

Expected: FAIL，直到执行函数和提示符合断言。

- [x] **Step 3: 最小实现修正并转绿**

只修正提示、回复或依赖注入签名，不增加持久化、重试、聊天状态或外部 MCP。运行相同命令，Expected: PASS。

### Task 4: 显著用户提示、同步用户包与发布验证

**Files:**
- Modify: `.claude/workflows/local-feishu-daily-feedback.ps1`
- Modify: `packaging/zhiji-user-overlay/.claude/workflows/local-feishu-daily-feedback.ps1`
- Modify: `zhiji-user/.claude/workflows/local-feishu-daily-feedback.ps1`
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `docs/superpowers/specs/2026-08-13-feishu-feedback-follow-up-design.md`

- [x] **Step 1: 让每份日志反馈明确展示追问入口**

在 `Invoke-ZhijiEntryDecision` 的最终回复中，分发摘要之后追加固定追问帮助。更新无匹配消息的使用提示，展示日志提交和追问的示例。

- [x] **Step 2: 同步与发布事实**

复制主工作流到 overlay，运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts\export-zhiji-user.ps1
```

把版本由 `1.20.0` 升为 `1.21.0`；在 PROJECT_STATUS 飞书入口项加入无状态日反馈追问的能力与“真实使用待观察”边界；在 CHANGELOG 顶部增加 `[功能]` 记录；在规格末尾标记用户确认。

- [x] **Step 3: 最终验证与提交**

Run:

```powershell
powershell -ExecutionPolicy Bypass -File tests\local-feishu-daily-feedback-entry.tests.ps1
powershell -ExecutionPolicy Bypass -File tests\result-distribution-contract.tests.ps1
powershell -ExecutionPolicy Bypass -File tests\distribution-boundary.tests.ps1
git diff --check
```

比较三份工作流 SHA256 必须相等。只暂存本计划涉及的飞书工作流、测试、版本/状态/变更记录和本次规格/计划；不得暂存桌面客户端或 Nozomi 的既有改动。提交：

```powershell
git commit -m "feat: add Feishu feedback follow-ups"
```
