$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure { param([string]$Message) $failures.Add($Message) | Out-Null }

function Assert-Contains {
  param([string]$Path, [string]$Expected)
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $Path))) {
    Add-Failure "missing file: $Path"
    return
  }
  $content = Get-Content -LiteralPath (Join-Path $repoRoot $Path) -Raw -Encoding UTF8
  if ($content -notmatch [regex]::Escape($Expected)) { Add-Failure "$Path does not contain: $Expected" }
}

$settings = Get-Content -LiteralPath (Join-Path $repoRoot '.claude/settings.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$collectionHook = $settings.hooks.UserPromptSubmit | Where-Object { $_.hooks.command -contains 'skill collection' } | Select-Object -First 1
if (-not $collectionHook) {
  Add-Failure 'settings.json has no collection skill hook'
} else {
  foreach ($sample in @('收录到收藏吃灰库/健身：这篇文章', '请收录到收藏吃灰库的护肤目录')) {
    if (-not [regex]::IsMatch($sample, $collectionHook.matcher)) { Add-Failure "collection hook missed: $sample" }
  }
  if ([regex]::IsMatch('我想聊聊健身收藏的经验', $collectionHook.matcher)) { Add-Failure 'collection hook matched ordinary conversation' }
}

Assert-Contains '.claude/shared/paths.md' 'context.collection_dir'
Assert-Contains '.claude/skills/collection.md' '## 摘要'
Assert-Contains '.claude/skills/collection.md' '## 关键词'
Assert-Contains '.claude/skills/collection.md' '## 原文 / 摘录全文'
Assert-Contains '.claude/skills/collection.md' '## 原文链接'

if ($failures.Count -gt 0) {
  Write-Host "FAIL: collection contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: collection contract checks' -ForegroundColor Green

