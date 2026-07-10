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
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "missing file: $RelativePath"
    return ''
  }
  return Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

function Assert-Contains {
  param(
    [string]$RelativePath,
    [string]$Expected
  )
  $content = Read-Utf8 $RelativePath
  if ($content -notmatch [regex]::Escape($Expected)) {
    Add-Failure "$RelativePath does not contain: $Expected"
  }
}

function Assert-NotContains {
  param(
    [string]$RelativePath,
    [string]$Unexpected
  )
  $content = Read-Utf8 $RelativePath
  if ($content -match [regex]::Escape($Unexpected)) {
    Add-Failure "$RelativePath still contains: $Unexpected"
  }
}

function Assert-Path {
  param([string]$RelativePath)
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $RelativePath))) {
    Add-Failure "missing path: $RelativePath"
  }
}

function Assert-SameFile {
  param(
    [string]$ExpectedRelativePath,
    [string]$ActualRelativePath
  )
  $expectedPath = Join-Path $repoRoot $ExpectedRelativePath
  $actualPath = Join-Path $repoRoot $ActualRelativePath
  if (-not (Test-Path -LiteralPath $expectedPath) -or -not (Test-Path -LiteralPath $actualPath)) {
    Add-Failure "cannot compare missing files: $ExpectedRelativePath -> $ActualRelativePath"
    return
  }
  $expectedHash = (Get-FileHash -LiteralPath $expectedPath -Algorithm SHA256).Hash
  $actualHash = (Get-FileHash -LiteralPath $actualPath -Algorithm SHA256).Hash
  if ($expectedHash -ne $actualHash) {
    Add-Failure "export drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

$settingsPath = Join-Path $repoRoot '.claude/settings.json'
$settings = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
$logHook = $settings.hooks.UserPromptSubmit |
  Where-Object { $_.hooks.command -contains 'skill log' } |
  Select-Object -First 1

if (-not $logHook) {
  Add-Failure 'settings.json has no skill log hook'
  $matcher = '(?!)'
} else {
  $matcher = $logHook.matcher
}

$routePositives = @(
  '日志：今天很累，但还是完成了报告',
  '日记：今天完成了报告',
  '记录一下：下午开会时我拒绝了临时加需求',
  '请分析这篇日志：今天拒绝了加班',
  '幸福日志 7.8 开心的事情：按时下班',
  '今天充实的事情：完成了三十道题'
)

foreach ($sample in $routePositives) {
  if (-not [regex]::IsMatch($sample, $matcher)) {
    Add-Failure "log hook missed positive sample: $sample"
  }
}

$routeNegatives = @(
  '如何修改日志分析项目的 README？',
  '请解释什么是日记。',
  '这个函数会记录一下调用次数。'
)

foreach ($sample in $routeNegatives) {
  if ([regex]::IsMatch($sample, $matcher)) {
    Add-Failure "log hook matched negative sample: $sample"
  }
}

$logSkill = Read-Utf8 '.claude/skills/log.md'
$patternMatches = [regex]::Matches($logSkill, '\|\s*[^|]+\s*\|\s*`([^`]+)`\s*\|')
$datePatterns = @($patternMatches | ForEach-Object { $_.Groups[1].Value })
$dateSamples = @(
  '# 7 月 8 日',
  '## 2026-07-08',
  '2026/7/8',
  '日志 7.8'
)

foreach ($sample in $dateSamples) {
  $matched = $false
  foreach ($pattern in $datePatterns) {
    if ([regex]::IsMatch($sample, $pattern)) {
      $matched = $true
      break
    }
  }
  if (-not $matched) {
    Add-Failure "date rules missed sample: $sample"
  }
}

Assert-Path '.claude/shared/contracts/journal-input.md'
Assert-Contains '.claude/shared/prompt-rules.md' 'contracts/journal-input.md'
Assert-Contains '.claude/skills/log.md' 'contracts/journal-input.md'
Assert-Contains '.claude/agents/daily-analyzer.md' 'contracts/journal-input.md'
Assert-Contains '.claude/shared/contracts/journal-input.md' 'A 级'
Assert-Contains '.claude/shared/contracts/journal-input.md' 'D 级'
Assert-Contains '.claude/shared/contracts/journal-input.md' 'previous_action_evidence'

$fixturePath = Join-Path $repoRoot 'tests/fixtures/journal-input-cases.json'
if (-not (Test-Path -LiteralPath $fixturePath)) {
  Add-Failure 'missing path: tests/fixtures/journal-input-cases.json'
} else {
  try {
    $fixtureCases = Get-Content -LiteralPath $fixturePath -Raw -Encoding UTF8 | ConvertFrom-Json
    $levels = @($fixtureCases | ForEach-Object { $_.expected_level } | Sort-Object -Unique)
    $formats = @($fixtureCases | ForEach-Object { $_.format } | Sort-Object -Unique)
    foreach ($level in @('A','B','C','D')) {
      if ($levels -notcontains $level) { Add-Failure "fixture cases missing level: $level" }
    }
    foreach ($format in @('template','freeform','bullets','ambiguous')) {
      if ($formats -notcontains $format) { Add-Failure "fixture cases missing format: $format" }
    }
  } catch {
    Add-Failure 'invalid JSON: tests/fixtures/journal-input-cases.json'
  }
}

Assert-Contains '.claude/shared/contracts/daily-feedback.md' '一个可能解释'
Assert-Contains '.claude/shared/contracts/daily-feedback.md' '不得从“没有写”推导“没有做”'

$verificationStates = @('待验证', '部分支持', '本次未奏效', '多次支持', '出现反例', '证据不足')
foreach ($state in $verificationStates) {
  Assert-Contains '.claude/shared/contracts/evidence-and-verification.md' $state
}
Assert-Contains '.claude/shared/contracts/evidence-and-verification.md' '至少 3 次'
Assert-Contains '.claude/shared/contracts/evidence-and-verification.md' '至少 2 个日期或情境'

Assert-Contains '.claude/commands/journal-coach.md' 'subagent_type: journal-quality-coach'
Assert-NotContains '.claude/commands/journal-coach.md' '平均得分：X/30'
Assert-Path '.claude/agents/journal-quality-coach.md'
Assert-Contains '.claude/agents/journal-quality-coach.md' '分析就绪度'
Assert-Contains '.claude/agents/journal-quality-coach.md' '分享讨论是可选增强项'

$overlaySettingsPath = Join-Path $repoRoot 'packaging/zhiji-user-overlay/.claude/settings.json'
$overlaySettings = Get-Content -LiteralPath $overlaySettingsPath -Raw -Encoding UTF8 | ConvertFrom-Json
$overlayLogHook = $overlaySettings.hooks.UserPromptSubmit |
  Where-Object { $_.hooks.command -contains 'skill log' } |
  Select-Object -First 1
if (-not $overlayLogHook) {
  Add-Failure 'overlay settings.json has no skill log hook'
} else {
  foreach ($sample in $routePositives) {
    if (-not [regex]::IsMatch($sample, $overlayLogHook.matcher)) {
      Add-Failure "overlay log hook missed positive sample: $sample"
    }
  }
  foreach ($sample in $routeNegatives) {
    if ([regex]::IsMatch($sample, $overlayLogHook.matcher)) {
      Add-Failure "overlay log hook matched negative sample: $sample"
    }
  }
}

Assert-Path 'packaging/zhiji-user-overlay/.claude/shared/contracts/journal-input.md'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/skills/log.md' 'contracts/journal-input.md'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/agents/daily-analyzer.md' 'contracts/journal-input.md'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/agents/journal-quality-coach.md' '分析就绪度'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/agents/journal-quality-coach.md' '分享讨论是可选增强项'
Assert-NotContains 'packaging/zhiji-user-overlay/.claude/commands/journal-coach.md' '平均得分：X/30'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/commands/daily-review.md' '部分支持'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/commands/daily-review.md' '本次未奏效'

$exportPairs = @(
  @('packaging/zhiji-user-overlay/.claude/settings.json', 'zhiji-user/.claude/settings.json'),
  @('packaging/zhiji-user-overlay/.claude/shared/contracts/journal-input.md', 'zhiji-user/.claude/shared/contracts/journal-input.md'),
  @('packaging/zhiji-user-overlay/.claude/shared/contracts/daily-feedback.md', 'zhiji-user/.claude/shared/contracts/daily-feedback.md'),
  @('packaging/zhiji-user-overlay/.claude/shared/contracts/evidence-and-verification.md', 'zhiji-user/.claude/shared/contracts/evidence-and-verification.md'),
  @('packaging/zhiji-user-overlay/.claude/shared/prompt-rules.md', 'zhiji-user/.claude/shared/prompt-rules.md'),
  @('packaging/zhiji-user-overlay/.claude/agents/daily-analyzer.md', 'zhiji-user/.claude/agents/daily-analyzer.md'),
  @('packaging/zhiji-user-overlay/.claude/agents/journal-quality-coach.md', 'zhiji-user/.claude/agents/journal-quality-coach.md'),
  @('packaging/zhiji-user-overlay/.claude/commands/daily-review.md', 'zhiji-user/.claude/commands/daily-review.md'),
  @('packaging/zhiji-user-overlay/.claude/commands/journal-coach.md', 'zhiji-user/.claude/commands/journal-coach.md'),
  @('packaging/zhiji-user-overlay/.claude/skills/log.md', 'zhiji-user/.claude/skills/log.md'),
  @('packaging/zhiji-user-overlay/perspectives/journal-quality.md', 'zhiji-user/perspectives/journal-quality.md'),
  @('packaging/zhiji-user-overlay/README.md', 'zhiji-user/README.md')
)
foreach ($pair in $exportPairs) {
  Assert-SameFile $pair[0] $pair[1]
}

$version = (Read-Utf8 'VERSION').Trim()
$projectStatus = Read-Utf8 'PROJECT_STATUS.md'
$readme = Read-Utf8 'README.md'
if ($projectStatus -notmatch [regex]::Escape("**当前版本**：$version")) {
  Add-Failure "PROJECT_STATUS.md version does not match VERSION ($version)"
}
if ($readme -notmatch [regex]::Escape("版本-v$version")) {
  Add-Failure "README.md badge does not match VERSION ($version)"
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: journal input contract regression checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: journal input contract regression checks' -ForegroundColor Green
exit 0

