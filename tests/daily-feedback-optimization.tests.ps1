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

function Assert-Contains {
  param([string]$RelativePath, [string]$Expected)
  if ((Read-Utf8 $RelativePath) -notmatch [regex]::Escape($Expected)) {
    Add-Failure "$RelativePath does not contain: $Expected"
  }
}

function Assert-NotContains {
  param([string]$RelativePath, [string]$Unexpected)
  if ((Read-Utf8 $RelativePath) -match [regex]::Escape($Unexpected)) {
    Add-Failure "$RelativePath still contains: $Unexpected"
  }
}

function Assert-SameFile {
  param([string]$ExpectedRelativePath, [string]$ActualRelativePath)
  $expectedPath = Join-Path $repoRoot $ExpectedRelativePath
  $actualPath = Join-Path $repoRoot $ActualRelativePath
  if ((Get-FileHash -LiteralPath $expectedPath -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $actualPath -Algorithm SHA256).Hash) {
    Add-Failure "export drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

$contracts = @(
  '.claude/shared/contracts/daily-feedback.md',
  'packaging/zhiji-user-overlay/.claude/shared/contracts/daily-feedback.md',
  'zhiji-user/.claude/shared/contracts/daily-feedback.md'
)
$analyzers = @(
  '.claude/agents/daily-analyzer.md',
  'packaging/zhiji-user-overlay/.claude/agents/daily-analyzer.md',
  'zhiji-user/.claude/agents/daily-analyzer.md'
)

foreach ($path in $contracts) {
  Assert-Contains $path '预测的判断对象是用户在 24 小时内实际发生的行为、结果或情境变化。'
  Assert-Contains $path '日志中的文字只能作为验证证据，不能成为行动是否有效的唯一判据。'
  Assert-Contains $path '不得把“下一篇日志里会出现某句记录”当作预测成立。'
  Assert-Contains $path '只有昨日闭环证据复杂或当天材料存在直接证据冲突时，才可增加必要说明。'
  Assert-Contains $path '普通情况仍控制在 260 中文字以内；例外也不得超过 320 中文字。'
  Assert-Contains $path '不得借此加入第二个洞察、第二个行动或长篇心理分析。'
  Assert-Contains $path '预测：[明天可观察到的真实行为、结果或情境变化]'
  Assert-NotContains $path '预测：[如果做到了，下一篇日志里应能观察到的具体现象]'
}

foreach ($path in $analyzers) {
  Assert-Contains $path '预测的判断对象必须是明天可观察的真实行为、结果或情境变化。'
  Assert-Contains $path '日志内容只能作为验证证据，不能是行动有效性的唯一结果。'
  Assert-Contains $path '只有昨日闭环证据复杂或当天材料存在直接证据冲突时，才可为澄清同一个判断增加必要说明。'
  Assert-Contains $path '预测：[明天可观察到的真实行为、结果或情境变化]'
  Assert-NotContains $path '预测：[如果做到了，下一篇日志里应能观察到的具体现象]'
}

Assert-SameFile $contracts[0] $contracts[1]
Assert-SameFile $contracts[0] $contracts[2]
Assert-SameFile $analyzers[0] $analyzers[1]
Assert-SameFile $analyzers[0] $analyzers[2]

if ($failures.Count -gt 0) {
  Write-Host "FAIL: daily-feedback optimization checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host "PASS: daily-feedback optimization checks" -ForegroundColor Green
