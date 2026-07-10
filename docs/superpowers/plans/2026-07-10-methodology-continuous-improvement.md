# Methodology Continuous Improvement Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在当前开发阶段顺序完成信号采集、双触发审计和分级自动优化，让视角与方法论在正常使用期依据真实反馈持续演进，同时固定复盘六问一级标题。

**Architecture:** 使用一个 PowerShell 状态引擎维护 gitignored 的 JSONL 信号账本和 JSON 状态文件，由 `methodology-auditor` 代理与 `methodology-audit` workflow 编排审计。开发阶段依次完成“可观测 -> 可判断 -> 可演进”三期；运行阶段由真实信号阈值决定审计和 L1/L2 自动修改是否触发，L3 始终等待人工批准。

**Tech Stack:** Markdown/YAML 运行契约、JSON 风险策略、PowerShell 5.1+、Claude Code agents/commands/skills/workflows、原生 PowerShell 回归测试、Git。

## Global Constraints

- `.claude/` remains the only runtime truth for product logic.
- 复盘六问继续作为周报、月报和项目复盘的用户可见一级标题。
- 用户原文、身份和可反推个人的信息不进入方法论信号账本。
- GPT 自检只能生成 C 级信号，不能单独触发自动修改。
- L1/L2 自动修改只在工作区干净、证据阈值满足、回放通过时执行；L3 必须等待人工批准。
- 三期在当前开发阶段顺序实现；真实信号只控制运行时触发，不阻塞第二、第三期编码。
- 用户版只采集和导出脱敏汇总，不自行修改公共方法论。
- 不增加正常用户的必做步骤，不引入后台常驻服务或外部定时平台。
- 所有中文 Markdown、JSON 和 PowerShell 文件使用 UTF-8；PowerShell 读取文本时显式指定 UTF-8。
- 本功能是向后兼容的新能力，完成全部任务后将当前 `1.5.22` 次版本升级为 `1.6.0`；若执行前版本已变化，按当时版本执行一次次版本递增。
- 每个任务独立测试和提交；推送始终由用户手动执行。

---

## File Map

### Main runtime truth

- Create `.claude/shared/contracts/methodology-improvement.md`: 人类可读的信号、触发、风险和观察期契约。
- Create `.claude/shared/methodology-risk-policy.json`: PowerShell 与测试共同消费的机器策略和私有路径镜像。
- Create `.claude/agents/methodology-auditor.md`: 记录信号、生成审计报告、执行风险闸门和候选补丁。
- Create `.claude/commands/methodology-audit.md`: 手动审计、强制轻/深审计和调试入口。
- Create `.claude/workflows/methodology-audit.js`: 自动/手动审计编排。
- Create `.claude/skills/methodology-feedback.md`: 将明确的用户评价转换为脱敏 A/B 级信号。
- Modify `.claude/shared/paths.md`: 增加信号、状态、审计输出路径 key。
- Modify `.claude/shared/runtime-contracts.js`: 增加 workflow 运行镜像。
- Modify `.claude/shared/prompt-rules.md`: 增加反馈路由和运行维护边界。
- Modify `.claude/commands/daily-review.md`, `.claude/skills/log.md`: 日反馈完成后记录运行与验证信号。
- Modify `.claude/commands/weekly-review.md`, `.claude/commands/monthly-review.md`, `.claude/commands/project-review.md`, `.claude/commands/yearly-review.md`, `.claude/commands/life-design.md`: 报告完成后的轻量维护步骤。
- Modify `.claude/workflows/weekly-review.js`, `.claude/workflows/monthly-review.js`, `.claude/workflows/project-review.js`, `.claude/workflows/yearly-review.js`: 综合成功后调用维护代理。

### Deterministic engine and tests

- Create `scripts/methodology-audit-state.ps1`: JSONL 追加、状态迁移、双触发判断、聚合导入导出。
- Create `scripts/test-methodology-candidate.ps1`: 候选补丁的确定性测试入口。
- Create `tests/methodology-audit-contract.tests.ps1`: 契约、信号、触发、风险、观察期和同步测试。
- Create `tests/fixtures/methodology-audit-signals.json`: A/B/C、月度、季度、异常和观察期样本。
- Create `tests/fixtures/methodology-replay-cases.json`: 六问、证据和视角边界回放断言。

### Maintainer docs and distribution

- Create `docs/methodology-improvement.md`: 维护者使用、审计报告和风险决策说明。
- Create `packaging/zhiji-user-overlay/.claude/shared/contracts/methodology-feedback.md`: 用户版采集边界。
- Create `packaging/zhiji-user-overlay/.claude/skills/methodology-feedback.md`: 用户版本地反馈采集。
- Create `packaging/zhiji-user-overlay/.claude/commands/export-methodology-feedback.md`: 用户主动导出脱敏汇总的可选入口。
- Create `packaging/zhiji-user-overlay/scripts/export-methodology-feedback.ps1`: 聚合导出脚本，不导出原始信号。
- Modify `packaging/zhiji-user-overlay/.claude/shared/paths.md`, `prompt-rules.md` and relevant review commands: 接入用户版本地采集。
- Regenerate `zhiji-user/` through `scripts/export-zhiji-user.ps1`; do not hand-edit exported product files.

---

## Phase 1 — 可观测

### Task 1: Establish the Methodology Signal Contract

**Files:**
- Create: `.claude/shared/contracts/methodology-improvement.md`
- Create: `.claude/shared/methodology-risk-policy.json`
- Modify: `.claude/shared/paths.md`
- Modify: `.claude/shared/runtime-contracts.js`
- Test: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Consumes: design spec `docs/superpowers/specs/2026-07-10-methodology-continuous-improvement-design.md`.
- Produces: `METHODOLOGY_AUDIT_PATHS`, `METHODOLOGY_AUDIT_POLICY`, canonical signal schema, risk levels `L1|L2|L3`.

- [ ] **Step 1: Write the failing contract test**

Create `tests/methodology-audit-contract.tests.ps1` with UTF-8 helpers and these first assertions:

```powershell
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure([string]$Message) { $failures.Add($Message) | Out-Null }
function Read-Utf8([string]$RelativePath) {
  $path = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path)) { Add-Failure "missing file: $RelativePath"; return '' }
  Get-Content -LiteralPath $path -Raw -Encoding UTF8
}
function Assert-Contains([string]$RelativePath, [string]$Expected) {
  if ((Read-Utf8 $RelativePath) -notmatch [regex]::Escape($Expected)) {
    Add-Failure "$RelativePath does not contain: $Expected"
  }
}

Assert-Contains '.claude/shared/paths.md' 'context.methodology_signals'
Assert-Contains '.claude/shared/paths.md' 'context.methodology_audit_state'
Assert-Contains '.claude/shared/paths.md' 'output.methodology_audit'
Assert-Contains '.claude/shared/runtime-contracts.js' 'METHODOLOGY_AUDIT_PATHS'
Assert-Contains '.claude/shared/runtime-contracts.js' 'METHODOLOGY_AUDIT_POLICY'

$policyPath = Join-Path $repoRoot '.claude/shared/methodology-risk-policy.json'
if (-not (Test-Path -LiteralPath $policyPath)) {
  Add-Failure 'missing file: .claude/shared/methodology-risk-policy.json'
} else {
  $policy = Get-Content -LiteralPath $policyPath -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($policy.schema_version -ne 1) { Add-Failure 'policy schema_version must be 1' }
  if (@($policy.signal_types).Count -ne 8) { Add-Failure 'policy must define 8 signal types' }
  if ($policy.schedule.light_days -ne 30) { Add-Failure 'light audit must use 30 days' }
  if ($policy.schedule.deep_days -ne 90) { Add-Failure 'deep audit must use 90 days' }
  if ($policy.observation.minimum_runs -ne 3) { Add-Failure 'observation minimum must be 3 runs' }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: methodology audit contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}
Write-Host 'PASS: methodology audit contract checks' -ForegroundColor Green
```

- [ ] **Step 2: Run the contract test and verify RED**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/methodology-audit-contract.tests.ps1
```

Expected: exit `1`, reporting the missing contract, JSON policy, paths and runtime mirrors.

- [ ] **Step 3: Create the human-readable contract**

Write `.claude/shared/contracts/methodology-improvement.md` with these exact normative sections:

```markdown
---
type: runtime_contract
purpose: 方法论信号、双触发审计、风险闸门与观察期契约
last_updated: 2026-07-10
---

# 方法论持续优化契约

## 不变量
- 复盘六问一级标题固定，内部内容允许演进。
- 原文、身份和可反推个人的信息不得写入信号账本。
- C 级信号不能单独触发自动修改。
- L3 变更必须等待人工批准。

## 信号
可信度只使用 `A / B / C`；类型只使用 `useful / rejected / missing / repetitive / unsupported / overreach / action_effective / action_failed`。

## 时间触发
轻审计为 30 天且至少 5 次运行或 3 条 A/B 信号；深审计为 90 天且至少 15 次运行。

## 异常触发
严重隐私、安全或无证据心理归因立即审计；普通异常必须满足设计 spec 的跨日期、跨来源或重复次数阈值。

## 风险
`L1` 自动执行；`L2` 达到更高证据和回放门槛后自动执行；`L3` 只生成提案。

## 观察
同一方法单元修改后进入 30 天或至少 3 次真实运行的观察期。观察期内普通重复信号累计但不再次修改。
```

- [ ] **Step 4: Create the machine policy**

Create `.claude/shared/methodology-risk-policy.json` exactly as:

```json
{
  "schema_version": 1,
  "paths": {
    "signals": "data/methodology-audit/signals.jsonl",
    "state": "data/methodology-audit/state.json",
    "audit_output": "output/methodology-audits"
  },
  "confidence_levels": ["A", "B", "C"],
  "signal_types": [
    "useful", "rejected", "missing", "repetitive",
    "unsupported", "overreach", "action_effective", "action_failed"
  ],
  "incident_kinds": ["none", "privacy", "safety", "psychological_overreach"],
  "negative_signal_types": ["rejected", "missing", "repetitive", "unsupported", "overreach", "action_failed"],
  "schedule": {
    "light_days": 30,
    "light_minimum_runs": 5,
    "light_minimum_ab_signals": 3,
    "deep_days": 90,
    "deep_minimum_runs": 15
  },
  "incident": {
    "same_unit_ab_count": 3,
    "same_unit_minimum_dates": 2,
    "repetitive_count_30_days": 5,
    "action_failed_count": 3,
    "observation_rejected_a_count": 2
  },
  "observation": { "cooldown_days": 30, "minimum_runs": 3 },
  "risk": {
    "L1": { "minimum_signals": 3, "minimum_ab_signals": 1, "minimum_replays": 1, "auto_apply": true },
    "L2": { "minimum_ab_signals": 5, "minimum_dates": 3, "minimum_replays": 5, "auto_apply": true },
    "L3": { "auto_apply": false }
  }
}
```

- [ ] **Step 5: Add path keys and runtime mirrors**

Add these rows to `.claude/shared/paths.md`:

```markdown
| `context.methodology_signals` | `data/methodology-audit/signals.jsonl` | 脱敏方法论信号账本 |
| `context.methodology_audit_state` | `data/methodology-audit/state.json` | 审计时间、运行计数与观察期状态 |
| `output.methodology_audit` | `output/methodology-audits/YYYY-MM-DD-{kind}.md` | `methodology-auditor` |
```

Add these exports to `.claude/shared/runtime-contracts.js`, using values identical to the JSON policy:

```javascript
export var METHODOLOGY_AUDIT_PATHS = {
  signals: 'data/methodology-audit/signals.jsonl',
  state: 'data/methodology-audit/state.json',
  audit_output: 'output/methodology-audits',
}

export var METHODOLOGY_AUDIT_POLICY = {
  light_days: 30,
  light_minimum_runs: 5,
  light_minimum_ab_signals: 3,
  deep_days: 90,
  deep_minimum_runs: 15,
  cooldown_days: 30,
  observation_minimum_runs: 3,
}
```

- [ ] **Step 6: Run the contract test and verify GREEN**

Run the same PowerShell command. Expected: `PASS: methodology audit contract checks` and exit `0`.

- [ ] **Step 7: Commit Task 1**

```powershell
git add .claude/shared/contracts/methodology-improvement.md .claude/shared/methodology-risk-policy.json .claude/shared/paths.md .claude/shared/runtime-contracts.js tests/methodology-audit-contract.tests.ps1
git commit -m "feat: add methodology improvement contract"
```

### Task 2: Implement the Private Signal Ledger

**Files:**
- Create: `scripts/methodology-audit-state.ps1`
- Create: `tests/fixtures/methodology-audit-signals.json`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Consumes: `.claude/shared/methodology-risk-policy.json`.
- Produces CLI actions `Initialize`, `RecordRun`, `AppendSignal`, `Evaluate`, `MarkAudit`, `ExportBeta`, `ImportBeta`; JSON output on stdout.

- [ ] **Step 1: Add fixture cases and failing ledger tests**

Create `tests/fixtures/methodology-audit-signals.json`:

```json
[
  {
    "date": "2026-07-01",
    "source_type": "maintainer",
    "feature": "monthly-review",
    "method_unit": "perspective:coach",
    "signal": "repetitive",
    "confidence": "A",
    "count": 1,
    "period": "2026-07",
    "summary": "目标视角与情绪视角结论重复",
    "status": "open",
    "incident_kind": "none"
  },
  {
    "date": "2026-07-02",
    "source_type": "system_check",
    "feature": "monthly-review",
    "method_unit": "perspective:therapist",
    "signal": "unsupported",
    "confidence": "C",
    "count": 1,
    "period": "2026-07",
    "summary": "心理归因缺少跨日证据",
    "status": "open",
    "incident_kind": "none"
  }
]
```

Extend the test to create a temporary repo-local directory under `$TestDrive = Join-Path $env:TEMP ('zhiji-methodology-' + [guid]::NewGuid())`, invoke the script with an overridden `-DataRoot`, and assert:

```powershell
$scriptPath = Join-Path $repoRoot 'scripts/methodology-audit-state.ps1'
& $scriptPath -Action Initialize -DataRoot $TestDrive | Out-Null
& $scriptPath -Action RecordRun -DataRoot $TestDrive -Feature daily-review -Now '2026-07-01' | Out-Null
$state = Get-Content -LiteralPath (Join-Path $TestDrive 'state.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($state.total_runs -ne 1) { Add-Failure 'RecordRun must increment total_runs' }

$signal = (Get-Content -LiteralPath (Join-Path $repoRoot 'tests/fixtures/methodology-audit-signals.json') -Raw -Encoding UTF8 | ConvertFrom-Json)[0]
& $scriptPath -Action AppendSignal -DataRoot $TestDrive -SignalJson ($signal | ConvertTo-Json -Compress) | Out-Null
$lines = @(Get-Content -LiteralPath (Join-Path $TestDrive 'signals.jsonl') -Encoding UTF8)
if ($lines.Count -ne 1) { Add-Failure 'AppendSignal must append one JSONL record' }
```

- [ ] **Step 2: Run tests and verify RED**

Expected: missing `scripts/methodology-audit-state.ps1`.

- [ ] **Step 3: Implement initialization, run counting and signal validation**

Create `scripts/methodology-audit-state.ps1` with this CLI and state schema:

```powershell
param(
  [Parameter(Mandatory=$true)]
  [ValidateSet('Initialize','RecordRun','AppendSignal','Evaluate','MarkAudit','ExportBeta','ImportBeta')]
  [string]$Action,
  [string]$DataRoot,
  [string]$Feature,
  [string]$SignalJson,
  [string]$Kind,
  [string]$InputPath,
  [string]$OutputPath,
  [datetime]$Now = (Get-Date)
)

$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$policyPath = Join-Path $repoRoot '.claude/shared/methodology-risk-policy.json'
$policy = Get-Content -LiteralPath $policyPath -Raw -Encoding UTF8 | ConvertFrom-Json
if (-not $DataRoot) { $DataRoot = Join-Path $repoRoot 'data/methodology-audit' }
$signalsPath = Join-Path $DataRoot 'signals.jsonl'
$statePath = Join-Path $DataRoot 'state.json'

function New-AuditState {
  [ordered]@{
    schema_version = 1
    initialized_at = $Now.ToString('yyyy-MM-ddTHH:mm:ssK')
    total_runs = 0
    runs_since_light = 0
    runs_since_deep = 0
    last_light_audit = $null
    last_deep_audit = $null
    last_successful_audit = $null
    observations = @()
  }
}

function Ensure-Store {
  if (-not (Test-Path -LiteralPath $DataRoot)) { New-Item -ItemType Directory -Force -Path $DataRoot | Out-Null }
  if (-not (Test-Path -LiteralPath $signalsPath)) { New-Item -ItemType File -Force -Path $signalsPath | Out-Null }
  if (-not (Test-Path -LiteralPath $statePath)) {
    New-AuditState | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
  }
}

function Read-State { Ensure-Store; Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json }
function Write-State($State) { $State | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8 }

function Test-Signal($Signal) {
  $required = @('date','source_type','feature','method_unit','signal','confidence','count','period','summary','status','incident_kind')
  foreach ($name in $required) { if ($null -eq $Signal.$name -or [string]::IsNullOrWhiteSpace([string]$Signal.$name)) { throw "missing signal field: $name" } }
  if ($policy.confidence_levels -notcontains $Signal.confidence) { throw "invalid confidence: $($Signal.confidence)" }
  if ($policy.signal_types -notcontains $Signal.signal) { throw "invalid signal type: $($Signal.signal)" }
  if ($policy.incident_kinds -notcontains $Signal.incident_kind) { throw "invalid incident kind: $($Signal.incident_kind)" }
  if ($Signal.summary -match '[“”"].{8,}[“”"]') { throw 'summary appears to contain quoted source text' }
  if ($Signal.PSObject.Properties.Name -contains 'user_name') { throw 'identity fields are forbidden' }
}

Ensure-Store
switch ($Action) {
  'Initialize' { New-AuditState | ConvertTo-Json -Depth 8 }
  'RecordRun' {
    $state = Read-State
    $state.total_runs = [int]$state.total_runs + 1
    $state.runs_since_light = [int]$state.runs_since_light + 1
    $state.runs_since_deep = [int]$state.runs_since_deep + 1
    Write-State $state
    $state | ConvertTo-Json -Depth 8
  }
  'AppendSignal' {
    $signal = $SignalJson | ConvertFrom-Json
    Test-Signal $signal
    Add-Content -LiteralPath $signalsPath -Value ($signal | ConvertTo-Json -Compress -Depth 8) -Encoding UTF8
    $signal | ConvertTo-Json -Compress
  }
}
```

Keep unimplemented switch branches absent until Tasks 4 and 6 add them; the ValidateSet reserves the stable CLI now.

- [ ] **Step 4: Run tests and verify GREEN for Phase 1 actions**

Expected: state initializes, run count becomes `1`, one JSONL line is written, invalid confidence and identity fields exit non-zero.

- [ ] **Step 5: Commit Task 2**

```powershell
git add scripts/methodology-audit-state.ps1 tests/fixtures/methodology-audit-signals.json tests/methodology-audit-contract.tests.ps1
git commit -m "feat: add private methodology signal ledger"
```

### Task 3: Connect Explicit Feedback and Runtime Collection

**Files:**
- Create: `.claude/skills/methodology-feedback.md`
- Modify: `.claude/shared/prompt-rules.md`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`
- Modify: `.claude/commands/weekly-review.md`
- Modify: `.claude/commands/monthly-review.md`
- Modify: `.claude/commands/project-review.md`
- Modify: `.claude/commands/yearly-review.md`
- Modify: `.claude/commands/life-design.md`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Consumes: `scripts/methodology-audit-state.ps1 -Action RecordRun|AppendSignal`.
- Produces: natural feedback routing and post-report maintenance prompts; no tracked-file mutations.

- [ ] **Step 1: Add failing consumer assertions**

Append assertions that every relevant command references `contracts/methodology-improvement.md`, `RecordRun`, and the rule “采集失败不影响正常报告”; assert the new skill contains `AppendSignal`, `不得复制用户原文`, and confidence mapping.

```powershell
$consumers = @(
  '.claude/commands/daily-review.md', '.claude/skills/log.md',
  '.claude/commands/weekly-review.md', '.claude/commands/monthly-review.md',
  '.claude/commands/project-review.md', '.claude/commands/yearly-review.md',
  '.claude/commands/life-design.md'
)
foreach ($consumer in $consumers) {
  Assert-Contains $consumer 'contracts/methodology-improvement.md'
  Assert-Contains $consumer 'RecordRun'
  Assert-Contains $consumer '采集失败不影响正常报告'
}
Assert-Contains '.claude/skills/methodology-feedback.md' 'AppendSignal'
Assert-Contains '.claude/skills/methodology-feedback.md' '不得复制用户原文'
```

- [ ] **Step 2: Run tests and verify RED**

Expected: missing skill and missing consumer references.

- [ ] **Step 3: Create the explicit feedback skill**

Create `.claude/skills/methodology-feedback.md` with this contract:

```markdown
---
description: 用户明确评价刚才的日志反馈或复盘结果，例如认可、反驳、指出遗漏、重复、无证据、越界或行动效果时触发；只记录脱敏方法论信号，不保存用户原文。
---

# 方法论反馈采集

1. 读取 `.claude/shared/contracts/methodology-improvement.md` 和 `.claude/shared/paths.md`。
2. 仅在用户明确评价分析结果时记录；含义不清时标记待澄清，不强行归因。
3. 明确认可/反驳/遗漏/重复/越界为 A；后续行动和验证为 B；模型自检为 C。
4. 将反馈定位到最小 `method_unit`；无法定位时使用 `feature:{name}`。
5. `summary` 只写脱敏问题摘要，不得复制用户原文、姓名、地点、单位或可识别细节。
6. 调用 `scripts/methodology-audit-state.ps1 -Action AppendSignal -SignalJson '<json>'`。
7. 写入失败只提示“方法论信号未记录”，不得改变或重做原报告。
8. 成功后只回复：`✓ 方法论反馈已脱敏记录`。
```

- [ ] **Step 4: Add one shared post-report maintenance block**

Add this exact block to the end of each listed command/skill, after normal output is saved and displayed:

````markdown
### 方法论维护（正常输出之后）

读取 `.claude/shared/contracts/methodology-improvement.md`。调用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/methodology-audit-state.ps1 -Action RecordRun -Feature <当前功能>
```

如果当前材料存在可确定的无证据、重复或职责越界，只能按 C 级写入脱敏信号。采集失败不影响正常报告，不重跑分析、不向用户展开错误堆栈。第一期只记录，不修改任何方法论文件。
````

Replace `<当前功能>` with the literal feature name in each consumer.

- [ ] **Step 5: Add feedback routing to shared prompt rules**

Add:

```markdown
## 方法论反馈路由

用户明确评价刚生成的分析时，读取 `.claude/skills/methodology-feedback.md`。不要把普通生活反馈误路由为方法论反馈；只有评价分析结果本身，或说明建议执行/失效时才记录。
```

- [ ] **Step 6: Run Phase 1 tests**

Run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tests/methodology-audit-contract.tests.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File tests/journal-input-contract.tests.ps1
```

Expected: both scripts print `PASS` and exit `0`.

- [ ] **Step 7: Commit Task 3**

```powershell
git add .claude/skills/methodology-feedback.md .claude/shared/prompt-rules.md .claude/commands/daily-review.md .claude/commands/weekly-review.md .claude/commands/monthly-review.md .claude/commands/project-review.md .claude/commands/yearly-review.md .claude/commands/life-design.md .claude/skills/log.md tests/methodology-audit-contract.tests.ps1
git commit -m "feat: collect methodology quality signals"
```

---

## Phase 2 — 可判断

### Task 4: Implement Time and Incident Trigger Evaluation

**Files:**
- Modify: `scripts/methodology-audit-state.ps1`
- Modify: `tests/fixtures/methodology-audit-signals.json`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Consumes: state JSON, signal JSONL, policy JSON, `-Now`.
- Produces: `Evaluate` JSON `{ kind, triggered, reasons }`; priority `incident > deep > light > none`.

- [ ] **Step 1: Add failing trigger tests**

Use isolated data roots to assert:

```powershell
$decision = & $scriptPath -Action Evaluate -DataRoot $TestDrive -Now '2026-08-01' | ConvertFrom-Json
if ($decision.triggered) { Add-Failure 'empty store must not trigger an audit' }

1..5 | ForEach-Object { & $scriptPath -Action RecordRun -DataRoot $TestDrive -Feature daily-review -Now "2026-07-0$_" | Out-Null }
$statePath = Join-Path $TestDrive 'state.json'
$state = Get-Content -LiteralPath $statePath -Raw -Encoding UTF8 | ConvertFrom-Json
$state.last_light_audit = '2026-06-30'
$state | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $statePath -Encoding UTF8
$decision = & $scriptPath -Action Evaluate -DataRoot $TestDrive -Now '2026-07-31' | ConvertFrom-Json
if ($decision.kind -ne 'light') { Add-Failure '30 days and 5 runs must trigger light audit' }
```

Add separate roots for `deep`, same-unit A/B negative signals across two dates, critical incident, C-only signals, and observation cooldown.

- [ ] **Step 2: Run tests and verify RED**

Expected: `Evaluate` returns no JSON because the switch branch is absent.

- [ ] **Step 3: Implement trigger calculation**

Add these complete helpers and switch branch:

```powershell
function Read-Signals {
  Ensure-Store
  $items = @()
  foreach ($line in @(Get-Content -LiteralPath $signalsPath -Encoding UTF8)) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }
    try { $items += ($line | ConvertFrom-Json) } catch {
      Write-Warning 'isolated malformed methodology signal line'
      continue
    }
  }
  @($items)
}

function Days-Since($DateValue, [datetime]$Reference) {
  if (-not $DateValue) { return [int]::MaxValue }
  [int][math]::Floor(($Reference - [datetime]$DateValue).TotalDays)
}

function Get-AuditDecision($State, $Signals, [datetime]$Reference) {
  $reasons = New-Object System.Collections.Generic.List[string]
  $critical = @($Signals | Where-Object { $_.incident_kind -ne 'none' })
  if ($critical.Count -gt 0) {
    $reasons.Add('critical_incident') | Out-Null
    return [ordered]@{ kind='incident'; triggered=$true; reasons=@($reasons) }
  }

  $negativeAB = @($Signals | Where-Object {
    $_.confidence -in @('A','B') -and $policy.negative_signal_types -contains $_.signal
  })

  $activeCooldownUnits = @($State.observations | Where-Object {
    $_.status -eq 'observing' -and (Days-Since $_.started_at $Reference) -lt $policy.observation.cooldown_days
  } | ForEach-Object { $_.method_unit })
  $negativeABOutsideCooldown = @($negativeAB | Where-Object {
    $activeCooldownUnits -notcontains $_.method_unit
  })
  $sameUnit = $negativeABOutsideCooldown | Group-Object method_unit, signal | Where-Object {
    ($_.Group | Measure-Object -Property count -Sum).Sum -ge $policy.incident.same_unit_ab_count -and
    @($_.Group.date | Sort-Object -Unique).Count -ge $policy.incident.same_unit_minimum_dates
  }
  if (@($sameUnit).Count -gt 0) {
    $reasons.Add('same_unit_repeated_negative') | Out-Null
    return [ordered]@{ kind='incident'; triggered=$true; reasons=@($reasons) }
  }

  $crossSource = $negativeABOutsideCooldown | Group-Object method_unit, signal | Where-Object {
    $sources = @($_.Group.source_type | Sort-Object -Unique)
    $sources -contains 'maintainer' -and $sources -contains 'beta_aggregate'
  }
  if (@($crossSource).Count -gt 0) {
    $reasons.Add('cross_source_negative') | Out-Null
    return [ordered]@{ kind='incident'; triggered=$true; reasons=@($reasons) }
  }

  $windowStart = $Reference.AddDays(-30)
  $repetitiveCount = ($negativeABOutsideCooldown | Where-Object {
    $_.signal -eq 'repetitive' -and [datetime]$_.date -ge $windowStart
  } | Measure-Object -Property count -Sum).Sum
  if ([int]$repetitiveCount -ge $policy.incident.repetitive_count_30_days) {
    $reasons.Add('repetitive_30_days') | Out-Null
    return [ordered]@{ kind='incident'; triggered=$true; reasons=@($reasons) }
  }

  $actionFailed = $negativeABOutsideCooldown | Where-Object { $_.signal -eq 'action_failed' } |
    Group-Object method_unit | Where-Object {
      ($_.Group | Measure-Object -Property count -Sum).Sum -ge $policy.incident.action_failed_count
    }
  if (@($actionFailed).Count -gt 0) {
    $reasons.Add('repeated_action_failure') | Out-Null
    return [ordered]@{ kind='incident'; triggered=$true; reasons=@($reasons) }
  }

  $deepAnchor = if ($State.last_deep_audit) { $State.last_deep_audit } else { $State.initialized_at }
  if ((Days-Since $deepAnchor $Reference) -ge $policy.schedule.deep_days -and
      [int]$State.runs_since_deep -ge $policy.schedule.deep_minimum_runs) {
    $reasons.Add('deep_due') | Out-Null
    return [ordered]@{ kind='deep'; triggered=$true; reasons=@($reasons) }
  }

  $abCount = @($Signals | Where-Object { $_.confidence -in @('A','B') }).Count
  $lightEnoughData = [int]$State.runs_since_light -ge $policy.schedule.light_minimum_runs -or
    $abCount -ge $policy.schedule.light_minimum_ab_signals
  $lightAnchor = if ($State.last_light_audit) { $State.last_light_audit } else { $State.initialized_at }
  if ((Days-Since $lightAnchor $Reference) -ge $policy.schedule.light_days -and $lightEnoughData) {
    $reasons.Add('light_due') | Out-Null
    return [ordered]@{ kind='light'; triggered=$true; reasons=@($reasons) }
  }
  [ordered]@{ kind='none'; triggered=$false; reasons=@() }
}
```

```powershell
'Evaluate' {
  $decision = Get-AuditDecision (Read-State) (Read-Signals) $Now
  $decision | ConvertTo-Json -Depth 8
}
```

- [ ] **Step 4: Run tests and verify GREEN**

Expected: none/light/deep/incident, cross-source, 30-day repetition, repeated action failure and cooldown cases pass; C-only negative signals do not produce an incident.

- [ ] **Step 5: Commit Task 4**

```powershell
git add scripts/methodology-audit-state.ps1 tests/fixtures/methodology-audit-signals.json tests/methodology-audit-contract.tests.ps1
git commit -m "feat: evaluate methodology audit triggers"
```

### Task 5: Add the Auditor Agent, Command and Workflow

**Files:**
- Create: `.claude/agents/methodology-auditor.md`
- Create: `.claude/commands/methodology-audit.md`
- Create: `.claude/workflows/methodology-audit.js`
- Modify: `.claude/shared/runtime-contracts.js`
- Modify: `scripts/methodology-audit-state.ps1`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Workflow args: `{ kind: "auto|light|deep|incident", feature?: string, period?: string }`.
- Agent prompt: `Audit methodology kind=<kind> feature=<feature> period=<period>`.
- Agent output: JSON summary line plus report written to `output.methodology_audit`.

- [ ] **Step 1: Add failing orchestration assertions**

Assert the new files exist and contain the stable interfaces:

```powershell
Assert-Contains '.claude/workflows/methodology-audit.js' "agentType: 'methodology-auditor'"
Assert-Contains '.claude/workflows/methodology-audit.js' 'kind: selectedKind'
Assert-Contains '.claude/commands/methodology-audit.md' 'Workflow({ name: "methodology-audit"'
Assert-Contains '.claude/agents/methodology-auditor.md' '不得在 L3 自动修改'
Assert-Contains '.claude/agents/methodology-auditor.md' '执行偏差 / 样本问题 / 方法论缺陷'
```

- [ ] **Step 2: Run tests and verify RED**

Expected: all three runtime files are missing.

- [ ] **Step 3: Add `MarkAudit` state transition**

Implement:

```powershell
'MarkAudit' {
  if ($Kind -notin @('light','deep','incident')) { throw "invalid audit kind: $Kind" }
  $state = Read-State
  $stamp = $Now.ToString('yyyy-MM-ddTHH:mm:ssK')
  $state.last_successful_audit = $stamp
  if ($Kind -eq 'light') { $state.last_light_audit = $stamp; $state.runs_since_light = 0 }
  if ($Kind -eq 'deep') {
    $state.last_deep_audit = $stamp
    $state.last_light_audit = $stamp
    $state.runs_since_deep = 0
    $state.runs_since_light = 0
  }
  Write-State $state
  $state | ConvertTo-Json -Depth 8
}
```

Only call `MarkAudit` after the report is successfully written.

- [ ] **Step 4: Create the auditor agent**

The agent file must define this sequence:

```markdown
1. 读取 `paths.md`、`contracts/methodology-improvement.md` 和 `methodology-risk-policy.json`。
2. `kind=auto` 时先运行 `Evaluate`；`triggered=false` 立即返回 `{"triggered":false}`。
3. 读取脱敏信号和状态，不读取用户原始日志；回放需要本地材料时只读取明确传入的样本路径。
4. 将每个问题归类为 `执行偏差 / 样本问题 / 方法论缺陷`。
5. 每个方法论缺陷必须写出：方法单元、A/B/C 证据计数、反例、单变量修改假说、风险等级、回放要求。
6. 计算新洞察率、证据支持率、用户反驳率、内容重复率、行动转化率和后续验证率；没有足够 A/B 证据的指标必须写“未知”。
7. 报告列出被隔离的损坏信号数量，但不得因此中止其余有效信号审计。
8. 第一、二期运行时只生成报告，不修改跟踪文件。
9. 报告成功保存后运行 `MarkAudit`；失败时不得更新时间。
10. 不得在 L3 自动修改，不得自动放宽风险规则，不得读取或写出用户原文。
```

Give it `Read, Glob, Grep, Write, Edit, Bash` tools and `model: inherit`.

- [ ] **Step 5: Create the command and workflow**

Command argument mapping:

```markdown
- 无参数或 `--auto` -> `kind: "auto"`
- `--light` -> `kind: "light"`
- `--deep` -> `kind: "deep"`
- `--incident <unit>` -> `kind: "incident"`
```

Workflow implementation:

```javascript
export const meta = {
  name: 'methodology-audit',
  description: 'Evaluate methodology signals and produce a risk-gated audit report',
  phases: [
    { title: 'Evaluate', detail: 'Check schedule and incident thresholds' },
    { title: 'Audit', detail: 'Classify evidence and propose one-variable changes' },
  ],
}

var selectedKind = args.kind || 'auto'
var feature = args.feature || ''
var period = args.period || ''
phase('Evaluate')
var result = await agent(
  'Audit methodology kind=' + selectedKind + ' feature=' + feature + ' period=' + period,
  { label: '方法论审计', phase: 'Audit', agentType: 'methodology-auditor' }
)
log(result || '方法论审计未产生报告')
return { kind: selectedKind, feature: feature, period: period, result: result }
```

- [ ] **Step 6: Run tests and a dry manual audit**

Run contract tests, then:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/methodology-audit-state.ps1 -Action Evaluate -Now '2026-07-10'
```

Expected on a new store: `{"kind":"none","triggered":false,"reasons":[]}`. Do not force a real audit yet.

- [ ] **Step 7: Commit Task 5**

```powershell
git add .claude/agents/methodology-auditor.md .claude/commands/methodology-audit.md .claude/workflows/methodology-audit.js .claude/shared/runtime-contracts.js scripts/methodology-audit-state.ps1 tests/methodology-audit-contract.tests.ps1
git commit -m "feat: add methodology audit orchestration"
```

### Task 6: Build the Replay and Risk Classification Gate

**Files:**
- Create: `scripts/test-methodology-candidate.ps1`
- Create: `tests/fixtures/methodology-replay-cases.json`
- Modify: `.claude/agents/methodology-auditor.md`
- Modify: `.claude/shared/methodology-risk-policy.json`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Candidate manifest JSON: `{ audit_id, risk, changed_files, method_units, signal_count, ab_signal_count, independent_dates, counterexample_checked, replay_count }`.
- Deterministic validator exit `0` only when invariants, project tests and risk thresholds pass.

- [ ] **Step 1: Create replay fixtures and failing gate tests**

Create:

```json
[
  { "id": "weekly-six-headings", "type": "structure", "required": ["## 一、回顾目标", "## 二、评估结果", "## 三、分析原因（正向）", "## 四、分析原因（负向）", "## 五、重来演练", "## 六、下周规划"] },
  { "id": "monthly-six-headings", "type": "structure", "required": ["## 一、回顾目标", "## 二、评估结果", "## 三、分析原因（正向）", "## 四、分析原因（负向）", "## 五、重来演练", "## 六、下月规划"] },
  { "id": "evidence-boundary", "type": "contract", "required": ["证据不足", "反例"] },
  { "id": "perspective-boundary", "type": "contract", "forbidden": ["最终总结", "人生诊断"] }
]
```

Add tests that a manifest with `risk=L3` fails auto-apply; L1 without 3 total signals or 1 A/B signal fails; L2 without 5 A/B signals, 3 independent dates, a counterexample check or 5 replays fails; and a valid L1 manifest passes after project tests.

- [ ] **Step 2: Run tests and verify RED**

Expected: missing candidate test script.

- [ ] **Step 3: Implement deterministic candidate validation**

Create a script with parameters `-ManifestPath`, `-SkipProjectTests`, read the policy, verify clean JSON, then enforce:

```powershell
if ($manifest.risk -eq 'L3') { throw 'L3 cannot auto-apply' }
$rule = $policy.risk.($manifest.risk)
if (-not $rule.auto_apply) { throw "$($manifest.risk) cannot auto-apply" }
if ([int]$manifest.signal_count -lt [int]$rule.minimum_signals -and $manifest.risk -eq 'L1') { throw 'insufficient signal count' }
if ([int]$manifest.ab_signal_count -lt [int]$rule.minimum_ab_signals) { throw 'insufficient A/B signal count' }
if ($manifest.risk -eq 'L2' -and [int]$manifest.independent_dates -lt [int]$rule.minimum_dates) { throw 'insufficient independent dates' }
if ($manifest.risk -eq 'L2' -and -not [bool]$manifest.counterexample_checked) { throw 'counterexample check required' }
if ([int]$manifest.replay_count -lt [int]$rule.minimum_replays) { throw 'insufficient replay count' }
if (@($manifest.changed_files).Count -eq 0) { throw 'candidate has no changed files' }
if (@($manifest.method_units).Count -ne 1 -and $manifest.risk -eq 'L2') { throw 'L2 must change exactly one method unit' }
```

Reject changes to `methodology-risk-policy.json`, `review-synthesis.md` six-question headings, settings hooks, command names, paths, or perspective registry as L3. Unless `-SkipProjectTests`, run every `tests/*.tests.ps1` and fail on the first non-zero exit.

- [ ] **Step 4: Add risk classification instructions to the auditor**

Add a deterministic table matching the design spec. The agent must write a candidate manifest before touching tracked files and call the script. Content-quality pairwise comparison goes into the report, but cannot override a deterministic failure.

- [ ] **Step 5: Run tests and verify GREEN**

Expected: valid L1 passes; undersampled L2 and all L3 manifests fail with the exact messages above.

- [ ] **Step 6: Commit Task 6**

```powershell
git add scripts/test-methodology-candidate.ps1 tests/fixtures/methodology-replay-cases.json .claude/agents/methodology-auditor.md .claude/shared/methodology-risk-policy.json tests/methodology-audit-contract.tests.ps1
git commit -m "feat: add methodology replay and risk gate"
```

---

## Phase 3 — 可演进

### Task 7: Enable Risk-Gated Automatic Methodology Updates

**Files:**
- Modify: `.claude/agents/methodology-auditor.md`
- Modify: `.claude/commands/methodology-audit.md`
- Modify: `scripts/methodology-audit-state.ps1`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Agent candidate states: `proposed|validated|applied|observing|resolved|dismissed`.
- Observation record: `{ audit_id, method_unit, commit, started_at, runs, rejected_a_count, status }`.

- [ ] **Step 1: Add failing observation and safety tests**

Test that:

- a dirty worktree forces `proposal_only`;
- L3 always forces `proposal_only`;
- validated L1/L2 can enter `observing`;
- two A-level rejections during observation produce `recommend_rollback` but do not run `git revert`;
- three real runs satisfy the minimum observation count.

Use a temporary state file; do not create actual commits in the contract test.

- [ ] **Step 2: Run tests and verify RED**

Expected: observation state actions are absent.

- [ ] **Step 3: Add observation state actions**

Extend the script ValidateSet with `StartObservation` and `RecordObservationRun`, and implement records under `state.observations`. Each action must update only the matching `audit_id`; unknown IDs fail non-zero. When `rejected_a_count >= 2`, set `status = 'recommend_rollback'`.

Use this record shape:

```powershell
[ordered]@{
  audit_id = $AuditId
  method_unit = $MethodUnit
  commit = $Commit
  started_at = $Now.ToString('yyyy-MM-ddTHH:mm:ssK')
  runs = 0
  rejected_a_count = 0
  status = 'observing'
}
```

Add corresponding CLI parameters `AuditId`, `MethodUnit`, `Commit`, and `RejectedACount`.

Implement the two switch branches as:

```powershell
'StartObservation' {
  if ([string]::IsNullOrWhiteSpace($AuditId) -or [string]::IsNullOrWhiteSpace($MethodUnit) -or [string]::IsNullOrWhiteSpace($Commit)) { throw 'AuditId, MethodUnit and Commit are required' }
  $state = Read-State
  if (@($state.observations | Where-Object { $_.audit_id -eq $AuditId }).Count -gt 0) { throw "observation already exists: $AuditId" }
  $record = [pscustomobject][ordered]@{ audit_id=$AuditId; method_unit=$MethodUnit; commit=$Commit; started_at=$Now.ToString('yyyy-MM-ddTHH:mm:ssK'); runs=0; rejected_a_count=0; status='observing' }
  $state.observations = @($state.observations) + $record
  Write-State $state
  $record | ConvertTo-Json -Depth 8
}
'RecordObservationRun' {
  $state = Read-State
  $record = @($state.observations | Where-Object { $_.audit_id -eq $AuditId }) | Select-Object -First 1
  if (-not $record) { throw "unknown observation: $AuditId" }
  $record.runs = [int]$record.runs + 1
  $record.rejected_a_count = [int]$record.rejected_a_count + [int]$RejectedACount
  if ($record.rejected_a_count -ge $policy.incident.observation_rejected_a_count) { $record.status = 'recommend_rollback' }
  elseif ($record.runs -ge $policy.observation.minimum_runs) { $record.status = 'resolved' }
  Write-State $state
  $record | ConvertTo-Json -Depth 8
}
```

- [ ] **Step 4: Enable auto-apply only after all preconditions**

Update the agent with this exact order:

```text
1. Run `git status --porcelain`; non-empty -> proposal_only.
2. Compare VERSION with PROJECT_STATUS; mismatch -> proposal_only.
3. Build one candidate manifest and classify risk using the fixed policy.
4. L3 -> write proposal and stop.
5. Apply only the candidate patch; do not edit unrelated files.
6. Run `scripts/test-methodology-candidate.ps1` and all repository tests.
7. Failure -> reverse only this turn's patch with an exact inverse edit; do not use reset/checkout.
8. Success -> update VERSION, PROJECT_STATUS, CHANGELOG and affected public/runtime mirrors.
9. Bundle all L1 fixes from the same audit into one release and one commit; L2 remains one method unit per candidate.
10. Run `/提交` semantics for one local commit containing `[audit-id]`; never push.
11. If commit fails, keep the verified working-tree patch and report the exact failure; never claim completion.
12. Start observation using the actual commit hash.
13. Return one short maintenance notice after the normal user output.
```

The agent must not claim success before commit verification. A post-commit negative observation only recommends rollback and waits for confirmation, preserving the repository rollback rule.

- [ ] **Step 5: Test proposal-only and observing paths**

Run contract tests with temporary state and a deliberately dirty temporary Git fixture or mocked status string. Expected: no tracked project files change during tests; statuses match the assertions.

- [ ] **Step 6: Commit Task 7**

```powershell
git add .claude/agents/methodology-auditor.md .claude/commands/methodology-audit.md scripts/methodology-audit-state.ps1 tests/methodology-audit-contract.tests.ps1
git commit -m "feat: enable risk-gated methodology evolution"
```

### Task 8: Integrate Automatic Due Checks into Review Workflows

**Files:**
- Modify: `.claude/workflows/weekly-review.js`
- Modify: `.claude/workflows/monthly-review.js`
- Modify: `.claude/workflows/project-review.js`
- Modify: `.claude/workflows/yearly-review.js`
- Modify: `.claude/commands/daily-review.md`
- Modify: `.claude/skills/log.md`
- Modify: `.claude/commands/life-design.md`
- Modify: `tests/methodology-audit-contract.tests.ps1`

**Interfaces:**
- Workflow maintenance prompt: `Audit methodology kind=auto feature=<feature> period=<period>`.
- Normal report result remains unchanged; maintenance result is optional metadata only.

- [ ] **Step 1: Add failing workflow integration assertions**

Assert every workflow contains `agentType: 'methodology-auditor'`, `kind=auto`, and invokes it only after synthesis success. Assert daily/log/life-design use the same prompt through Task after displaying the report.

- [ ] **Step 2: Run tests and verify RED**

Expected: workflows do not yet invoke the auditor.

- [ ] **Step 3: Add a post-output maintenance call to each workflow**

After logging the successful report path, add:

```javascript
var maintenance = await agent(
  'Audit methodology kind=auto feature=monthly-review period=' + month,
  { label: '方法论维护', phase: 'Maintain', agentType: 'methodology-auditor' }
)
if (maintenance && maintenance.indexOf('"triggered":true') !== -1) {
  log('🔧 ' + maintenance)
}
```

Use literal feature/period variables for weekly, monthly, project and yearly workflows. Add `{ title: 'Maintain', detail: 'Record run and evaluate methodology audit triggers' }` to each workflow `meta.phases`.

Do not change the existing return fields; optionally append `maintenanceTriggered: !!maintenance` without removing consumers' fields.

- [ ] **Step 4: Add equivalent Task calls to non-workflow entrypoints**

After the normal response has been displayed, call `methodology-auditor` with `kind=auto`; if it returns `triggered=false`, show nothing. A maintenance failure is logged internally and must not change the saved report.

- [ ] **Step 5: Run all runtime contract tests**

```powershell
Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | ForEach-Object {
  powershell -NoProfile -ExecutionPolicy Bypass -File $_.FullName
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Expected: every test prints `PASS`; existing weekly/monthly/project return contracts remain present.

- [ ] **Step 6: Commit Task 8**

```powershell
git add .claude/workflows/weekly-review.js .claude/workflows/monthly-review.js .claude/workflows/project-review.js .claude/workflows/yearly-review.js .claude/commands/daily-review.md .claude/commands/life-design.md .claude/skills/log.md tests/methodology-audit-contract.tests.ps1
git commit -m "feat: trigger methodology audits after reviews"
```

### Task 9: Add Privacy-Safe Beta Feedback Export

**Files:**
- Create: `packaging/zhiji-user-overlay/.claude/shared/contracts/methodology-feedback.md`
- Create: `packaging/zhiji-user-overlay/.claude/skills/methodology-feedback.md`
- Create: `packaging/zhiji-user-overlay/.claude/commands/export-methodology-feedback.md`
- Create: `packaging/zhiji-user-overlay/scripts/export-methodology-feedback.ps1`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/paths.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/prompt-rules.md`
- Modify: `tests/methodology-audit-contract.tests.ps1`
- Modify: `scripts/methodology-audit-state.ps1`
- Regenerate: `zhiji-user/`

**Interfaces:**
- User export JSON: `{ schema_version, generated_at, aggregates[] }`.
- Aggregate record contains only `period, feature, method_unit, signal, confidence, count, summary`; no date-level row, original quote, identity or incident detail.
- Main import action converts each aggregate to `source_type=beta_aggregate`, validates the schema and appends one aggregate signal without reconstructing identities.

- [ ] **Step 1: Add failing privacy and export-sync tests**

Add a fixture with two local signals and assert export groups them. Assert output JSON does not contain `user_name`, `source_text`, `quote`, or the original signal `date`. Add `Assert-SameFile` pairs for all new overlay/exported files.

Also call main `ImportBeta` with the exported fixture and assert that the appended JSONL row has `source_type=beta_aggregate`, preserves the aggregate `count`, and rejects any import containing identity or quote fields.

- [ ] **Step 2: Run tests and verify RED**

Expected: overlay contract, skill, command and script are missing.

- [ ] **Step 3: Implement the beta-only contract and skill**

The user version contract must say:

```markdown
- 反馈只保存在用户本地。
- 公共方法论不会在用户版中自动修改。
- 导出前按 `period + feature + method_unit + signal + confidence` 聚合。
- 导出文件不得包含日志、反馈原文、姓名、位置、单位或单条日期。
- 用户主动运行导出命令后才创建可分享文件。
```

The skill reuses the main signal vocabulary but writes only to the local ignored data path.

- [ ] **Step 4: Implement the aggregate export script**

The script reads JSONL, validates allowed fields, groups by the five keys, sums `count`, keeps only a sanitized summary no longer than 80 Chinese characters, and writes UTF-8 JSON:

```powershell
$aggregates = $signals | Group-Object period, feature, method_unit, signal, confidence | ForEach-Object {
  $first = $_.Group[0]
  [ordered]@{
    period = $first.period
    feature = $first.feature
    method_unit = $first.method_unit
    signal = $first.signal
    confidence = $first.confidence
    count = ($_.Group | Measure-Object -Property count -Sum).Sum
    summary = ([string]$first.summary).Substring(0, [math]::Min(80, ([string]$first.summary).Length))
  }
}
[ordered]@{
  schema_version = 1
  generated_at = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ssK')
  aggregates = @($aggregates)
} | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
```

Before writing, reject forbidden property names and summaries containing quoted source text.

- [ ] **Step 5: Implement main-project beta aggregate import**

Add the `ImportBeta` branch to `scripts/methodology-audit-state.ps1`:

```powershell
'ImportBeta' {
  if (-not (Test-Path -LiteralPath $InputPath)) { throw "import file not found: $InputPath" }
  $payload = Get-Content -LiteralPath $InputPath -Raw -Encoding UTF8 | ConvertFrom-Json
  if ($payload.schema_version -ne 1) { throw 'unsupported beta aggregate schema' }
  foreach ($item in @($payload.aggregates)) {
    foreach ($forbidden in @('user_name','source_text','quote','date')) {
      if ($item.PSObject.Properties.Name -contains $forbidden) { throw "forbidden beta field: $forbidden" }
    }
    $signal = [ordered]@{
      date = $Now.ToString('yyyy-MM-dd')
      source_type = 'beta_aggregate'
      feature = $item.feature
      method_unit = $item.method_unit
      signal = $item.signal
      confidence = $item.confidence
      count = [int]$item.count
      period = $item.period
      summary = $item.summary
      status = 'open'
      incident_kind = 'none'
    }
    Test-Signal ([pscustomobject]$signal)
    Add-Content -LiteralPath $signalsPath -Value (([pscustomobject]$signal) | ConvertTo-Json -Compress -Depth 8) -Encoding UTF8
  }
  [ordered]@{ imported = @($payload.aggregates).Count } | ConvertTo-Json -Compress
}
```

- [ ] **Step 6: Export the user package through the canonical script**

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/export-zhiji-user.ps1
```

Expected: export completes; no direct edits under `zhiji-user/` were made before this command.

- [ ] **Step 7: Run privacy, sync and existing user export tests**

Run all test scripts. Expected: privacy fields absent, new overlay files hash-match exported files, journal input tests still pass.

- [ ] **Step 8: Commit Task 9**

```powershell
git add packaging/zhiji-user-overlay/.claude/shared/contracts/methodology-feedback.md packaging/zhiji-user-overlay/.claude/skills/methodology-feedback.md packaging/zhiji-user-overlay/.claude/commands/export-methodology-feedback.md packaging/zhiji-user-overlay/.claude/shared/paths.md packaging/zhiji-user-overlay/.claude/shared/prompt-rules.md packaging/zhiji-user-overlay/scripts/export-methodology-feedback.ps1 scripts/methodology-audit-state.ps1 zhiji-user tests/methodology-audit-contract.tests.ps1
git commit -m "feat: export anonymized methodology feedback"
```

### Task 10: Document, Version and Release the Complete Capability

**Files:**
- Create: `docs/methodology-improvement.md`
- Modify: `README.md`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `VERSION`
- Modify: `packaging/zhiji-user-overlay/README.md`
- Regenerate: `zhiji-user/README.md`
- Test: all `tests/*.tests.ps1`

**Interfaces:**
- Public version after this task: `1.6.0` if starting from `1.5.22`.
- Maintainer entrypoint: `/methodology-audit [--auto|--light|--deep|--incident <unit>]`.
- User version entrypoint: optional `/export-methodology-feedback`.

- [ ] **Step 1: Write the maintainer guide**

Document:

- signal schema and A/B/C authority;
- monthly, quarterly and incident triggers;
- L1/L2/L3 examples;
- audit report interpretation;
- dirty-worktree proposal-only behavior;
- observation and rollback recommendation;
- beta aggregate import process;
- no auto-push guarantee.

Include exact command examples and paths; do not duplicate the full runtime contract.

- [ ] **Step 2: Update README and user README**

Main README adds the maintainer command and one paragraph explaining automatic due checks. User README explains that feedback export is optional, local-first and excludes original text.

- [ ] **Step 3: Update project status and version**

Set `VERSION` to `1.6.0`, update README badge and `PROJECT_STATUS.md` current version. Add completed rows for the three phases and a key decision that development implements all phases now while real signals gate runtime activation. Add a known limitation that early quality metrics may remain unknown until feedback accumulates.

- [ ] **Step 4: Add one release-level CHANGELOG entry**

Use one `[功能]` entry covering the entire capability, affected runtime/engine/tests/distribution/docs files, and `v1.5.22 -> v1.6.0` unless the starting version changed.

- [ ] **Step 5: Regenerate the user package**

Run the canonical export script again after README changes.

- [ ] **Step 6: Run full verification**

```powershell
Get-ChildItem -LiteralPath tests -Filter '*.tests.ps1' | Sort-Object Name | ForEach-Object {
  Write-Host "RUN $($_.Name)"
  powershell -NoProfile -ExecutionPolicy Bypass -File $_.FullName
  if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
```

Then verify:

```powershell
$version = (Get-Content -LiteralPath VERSION -Raw -Encoding UTF8).Trim()
if ((Get-Content -LiteralPath PROJECT_STATUS.md -Raw -Encoding UTF8) -notmatch [regex]::Escape("**当前版本**：$version")) { exit 1 }
if ((Get-Content -LiteralPath README.md -Raw -Encoding UTF8) -notmatch [regex]::Escape("版本-v$version")) { exit 1 }
git diff --check
git status --short
```

Expected: all tests pass, versions match, `git diff --check` has no output, and status contains only Task 10 files.

- [ ] **Step 7: Commit Task 10 using the project commit flow**

```powershell
git add .
git commit -m "[功能] 建立方法论持续优化机制 (v1.5.22 -> v1.6.0)"
git log -1 --oneline
```

Do not run `git push`.

---

## Final Acceptance Checklist

- [ ] Phase 1, 2 and 3 were implemented sequentially in the current development cycle.
- [ ] A clean installation with no signals remains silent and does not modify methodology.
- [ ] Five runs after 30 days trigger light audit; fifteen runs after 90 days trigger deep audit.
- [ ] Critical incidents trigger immediately; C-only ordinary signals cannot auto-modify.
- [ ] L1/L2 require deterministic validation and replay; L3 always waits for approval.
- [ ] Dirty worktree degrades to proposal-only and preserves user changes.
- [ ] Automatic changes are committed locally with audit IDs and never pushed.
- [ ] Observation requires three real runs; two A-level rejections recommend rollback without executing it.
- [ ] Beta exports contain aggregates only and no original text or identity.
- [ ] Six-question headings remain unchanged in weekly, monthly and project review contracts.
- [ ] Main runtime truth, overlay and exported user package pass sync checks.
- [ ] VERSION, README, PROJECT_STATUS and CHANGELOG are consistent.
