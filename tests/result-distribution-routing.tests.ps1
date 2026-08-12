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
  param([string]$RelativePath, [string[]]$Expected)
  $content = Read-Utf8 $RelativePath
  foreach ($value in $Expected) {
    if ($content -notmatch [regex]::Escape($value)) {
      Add-Failure "$RelativePath does not contain: $value"
    }
  }
}

function Assert-NotContains {
  param([string]$RelativePath, [string[]]$Unexpected)
  $content = Read-Utf8 $RelativePath
  foreach ($value in $Unexpected) {
    if ($content -match [regex]::Escape($value)) {
      Add-Failure "$RelativePath must not contain: $value"
    }
  }
}

function Assert-Sequence {
  param([string]$RelativePath, [string[]]$Expected)
  $content = Read-Utf8 $RelativePath
  $cursor = 0
  foreach ($value in $Expected) {
    $index = $content.IndexOf($value, $cursor, [System.StringComparison]::Ordinal)
    if ($index -lt 0) {
      Add-Failure "$RelativePath missing ordered route marker after offset ${cursor}: $value"
      return
    }
    $cursor = $index + $value.Length
  }
}

function Assert-SameFile {
  param([string]$ExpectedRelativePath, [string]$ActualRelativePath)
  $expected = Join-Path $repoRoot $ExpectedRelativePath
  $actual = Join-Path $repoRoot $ActualRelativePath
  if (-not (Test-Path -LiteralPath $expected -PathType Leaf) -or
      -not (Test-Path -LiteralPath $actual -PathType Leaf)) {
    Add-Failure "cannot compare missing files: $ExpectedRelativePath -> $ActualRelativePath"
    return
  }
  if ((Get-FileHash -LiteralPath $expected -Algorithm SHA256).Hash -ne
      (Get-FileHash -LiteralPath $actual -Algorithm SHA256).Hash) {
    Add-Failure "mirrored distribution route drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

$contractPath = '.claude/shared/contracts/result-distribution.md'
$commands = @{
  'daily-review.md' = 'output.daily_feedback'
  'weekly-review.md' = 'output.weekly_report'
  'monthly-review.md' = 'output.monthly_report'
  'project-review.md' = 'output.project_report'
  'yearly-review.md' = 'output.yearly_report'
  'life-design.md' = 'output.life_design_report'
}

foreach ($entry in $commands.GetEnumerator()) {
  foreach ($prefix in @('.claude/commands', 'packaging/zhiji-user-overlay/.claude/commands')) {
    $path = "$prefix/$($entry.Key)"
    Assert-Contains $path @(
      $contractPath,
      $entry.Value,
      '新写入',
      '重新读取',
      '非空',
      '分发摘要只追加到聊天',
      '不写入报告正文',
      'skipped_not_configured',
      '保持原有聊天输出不变',
      '不能只凭文件存在或非空证明本轮新写入',
      '本次请求明确包含“仅本地”',
      '不调用结果分发'
    )
  }
}

foreach ($path in @(
  '.claude/commands/daily-review.md',
  'packaging/zhiji-user-overlay/.claude/commands/daily-review.md'
)) {
  Assert-Contains $path @(
    'distribute output.daily_feedback <resolved-local-path>',
    '缓存命中',
    'D 级输入',
    '无日志',
    '分析失败',
    '都不调用结果分发'
  )
  Assert-Sequence $path @('写入文件', '重新读取', 'distribute output.daily_feedback <resolved-local-path>', '展示给用户')
}

foreach ($path in @(
  '.claude/commands/life-design.md',
  'packaging/zhiji-user-overlay/.claude/commands/life-design.md'
)) {
  Assert-Contains $path @(
    'distribute output.life_design_report <resolved-local-path>',
    '提出缺口问题',
    '不生成报告，也不调用结果分发'
  )
}

foreach ($entry in @(
  @{ File = 'weekly-review.md'; Key = 'output.weekly_report' },
  @{ File = 'monthly-review.md'; Key = 'output.monthly_report' },
  @{ File = 'project-review.md'; Key = 'output.project_report' },
  @{ File = 'yearly-review.md'; Key = 'output.yearly_report' }
)) {
  foreach ($prefix in @('.claude/commands', 'packaging/zhiji-user-overlay/.claude/commands')) {
    $path = "$prefix/$($entry.File)"
    Assert-Contains $path @(
      "distribute $($entry.Key) <resolved-local-path>",
      'workflow 返回的 distribution handoff',
      '不得二次分发'
    )
  }
}

$naturalRoutes = @(
  '.claude/shared/contracts/codex-natural-language-routing.md',
  'packaging/zhiji-user-overlay/.claude/shared/contracts/codex-natural-language-routing.md'
)
foreach ($path in $naturalRoutes) {
  Assert-Contains $path @(
    $contractPath,
    'Codex 直接路由',
    '不依赖 Claude `Task` / `Workflow`',
    '新写入',
    '重新读取',
    'distribute output.weekly_report <resolved-local-path>',
    'distribute output.monthly_report <resolved-local-path>',
    'distribute output.project_report <resolved-local-path>',
    '缓存命中',
    '只读展示',
    '分析失败',
    '分发摘要只追加到聊天',
    '不写入报告正文',
    '保持原有聊天输出不变',
    '本次请求明确包含“仅本地”',
    '不调用结果分发'
  )
}

$topicRoutes = @(
  '.claude/shared/contracts/topic-thinking-persistence.md',
  'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking-persistence.md'
)
foreach ($path in $topicRoutes) {
  Assert-Contains $path @(
    $contractPath,
    'distribute context.thinking_topic <resolved-local-path>',
    '用户明确确认',
    '新写入',
    '重新读取',
    '未经确认',
    '不调用结果分发',
    '分发摘要只追加到聊天',
    '本次请求明确包含“仅本地”'
  )
}

$workflows = @{
  'weekly-review.js' = 'output.weekly_report'
  'monthly-review.js' = 'output.monthly_report'
  'project-review.js' = 'output.project_report'
  'yearly-review.js' = 'output.yearly_report'
}

foreach ($entry in $workflows.GetEnumerator()) {
  $main = ".claude/workflows/$($entry.Key)"
  $overlay = "packaging/zhiji-user-overlay/.claude/workflows/$($entry.Key)"
  foreach ($path in @($main, $overlay)) {
    Assert-Contains $path @(
      $contractPath,
      'var distribution = {',
      "trigger: 'distribute $($entry.Value) ' + reportPath",
      'newWriteVerificationRequired: true',
      'rereadNonEmptyRequired: true',
      'localSuccessUnaffected: true',
      "synthesis: 'complete'",
      'distribution: distribution'
    )
    Assert-NotContains $path @('newWriteVerified: true')
    Assert-Sequence $path @("phase('Synthesize')", 'var distribution = {', 'return')
  }
  Assert-SameFile $main $overlay
}

Assert-SameFile $naturalRoutes[0] $naturalRoutes[1]
Assert-SameFile $topicRoutes[0] $topicRoutes[1]

$collectionRoutes = @(
  '.claude/skills/collection.md',
  'packaging/zhiji-user-overlay/.claude/skills/collection.md'
)
foreach ($path in $collectionRoutes) {
  Assert-Contains $path @(
    $contractPath,
    'distribute context.collection_topic <resolved-local-path>',
    'distribute context.collection_attachment <resolved-local-path>',
    '明确收录',
    '新写入',
    '重新读取',
    '本次请求明确包含“仅本地”',
    '不调用结果分发',
    '分发摘要只追加到聊天'
  )
  Assert-NotContains $path @('distribution: local_only')
}
Assert-SameFile $collectionRoutes[0] $collectionRoutes[1]

if ($failures.Count -gt 0) {
  Write-Host "FAIL: result distribution routing checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: result distribution routing checks' -ForegroundColor Green
exit 0
