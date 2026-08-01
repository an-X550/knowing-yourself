$ErrorActionPreference = "Stop"

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
    return ""
  }
  Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

function Assert-Contains {
  param([string]$RelativePath, [string]$Expected)
  $content = Read-Utf8 $RelativePath
  if ($content -notmatch [regex]::Escape($Expected)) {
    Add-Failure "$RelativePath does not contain: $Expected"
  }
}

function Assert-NotContains {
  param([string]$RelativePath, [string]$Unexpected)
  $content = Read-Utf8 $RelativePath
  if ($content -match [regex]::Escape($Unexpected)) {
    Add-Failure "$RelativePath must not contain: $Unexpected"
  }
}

$command = ".claude/commands/review.md"
$agent = ".claude/agents/review-readiness-checker.md"
$contract = ".claude/shared/contracts/codex-natural-language-routing.md"

Assert-Contains $command "review-readiness-checker"
Assert-Contains $command "manual_no_argument_dispatch: review-readiness-checker"
Assert-Contains $command "manual_readiness_writes: false"
Assert-Contains $command "manual_readiness_reports: false"
Assert-Contains $agent "manual_readiness_max_recommendations: 1"
Assert-Contains $agent "manual_readiness_writes: false"
Assert-Contains $agent "manual_readiness_reports: false"
Assert-Contains $contract "不是固定口令"
Assert-Contains $contract "非穷尽示例"
Assert-Contains $contract ".claude/commands/review.md"
Assert-Contains $contract ".claude/agents/review-readiness-checker.md"
Assert-Contains $contract "manual_readiness_max_recommendations: 1"
Assert-Contains $contract "manual_readiness_writes: false"
Assert-Contains $contract "manual_readiness_reports: false"
Assert-NotContains $contract "manual_readiness_intents:"

# Runtime behavior must be expressed in the Markdown body, not only YAML metadata.
Assert-Contains $contract "## 手动复盘前检查"
Assert-Contains $contract "不是固定口令"
Assert-Contains $contract "最近有什么该补？"
Assert-Contains $contract "我有遗漏吗？"
Assert-Contains $contract "明确指定日期、周期、项目或人生设计"
Assert-Contains $contract "普通闲聊、泛泛建议或单次情绪表达"
Assert-Contains $contract "只输出优先级最高的一条建议"
Assert-Contains $contract "不生成报告、不写入文件"
Assert-Contains $command "### 2. 手动复盘前检查（无参数）"
Assert-Contains $command "review-readiness-checker"
Assert-Contains $command "只输出优先级最高的一条建议"
Assert-Contains $command '资格条件与优先级只以 `review-readiness-checker` 为准'
Assert-NotContains $command "1. 月初 1-5 号"
Assert-Contains $agent "只输出优先级最高的一条建议"
Assert-Contains $agent "不生成报告、不写入文件"
Assert-Contains $agent "最近 7 天至少有 3 篇日志，且至少 2 篇没有对应日反馈"
Assert-Contains $agent "current.md 更新后 14 天内新增至少 3 篇日反馈"
Assert-Contains $agent "至少一篇明确含当前焦点、待决事项、健康/关系或方向变化"
Assert-Contains $agent "上次教练报告后新增至少 7 篇日志，且已间隔至少 14 天"
Assert-Contains $agent "不得仅凭文件修改时间"
Assert-Contains $agent "从第一个满足项开始，立刻停止"

foreach ($relativePath in @(
  "packaging/zhiji-user-overlay/.claude/commands/review.md",
  "packaging/zhiji-user-overlay/.claude/agents/review-readiness-checker.md",
  "packaging/zhiji-user-overlay/.claude/shared/contracts/codex-natural-language-routing.md"
)) {
  Assert-Contains $relativePath "manual_readiness_writes: false"
  Assert-Contains $relativePath "manual_readiness_reports: false"
  Assert-Contains $relativePath "只输出优先级最高的一条建议"
  Assert-Contains $relativePath "不生成报告、不写入文件"
}

foreach ($pair in @(
  @('packaging/zhiji-user-overlay/.claude/commands/review.md', 'zhiji-user/.claude/commands/review.md'),
  @('packaging/zhiji-user-overlay/.claude/agents/review-readiness-checker.md', 'zhiji-user/.claude/agents/review-readiness-checker.md'),
  @('packaging/zhiji-user-overlay/.claude/shared/contracts/codex-natural-language-routing.md', 'zhiji-user/.claude/shared/contracts/codex-natural-language-routing.md')
)) {
  if ((Read-Utf8 $pair[0]) -cne (Read-Utf8 $pair[1])) {
    Add-Failure "generated package differs from overlay: $($pair[1])"
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: review readiness routing contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host "PASS: review readiness routing contract checks" -ForegroundColor Green
