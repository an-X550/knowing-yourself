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

function Assert-ContainsAll {
  param([string]$RelativePath, [string[]]$Patterns)
  $content = Read-Utf8 $RelativePath
  foreach ($pattern in $Patterns) {
    if ($content -notmatch $pattern) {
      Add-Failure "$RelativePath missing contract pattern: $pattern"
    }
  }
}

function Assert-GitIgnored {
  param([string]$RepositoryRoot, [string]$RelativePath)

  git -C (Join-Path $repoRoot $RepositoryRoot) check-ignore --quiet -- $RelativePath
  if ($LASTEXITCODE -ne 0) {
    Add-Failure "$RepositoryRoot does not ignore private runtime path: $RelativePath"
  }
}

function Assert-SameFile {
  param([string]$ExpectedRelativePath, [string]$ActualRelativePath)

  $expected = Join-Path $repoRoot $ExpectedRelativePath
  $actual = Join-Path $repoRoot $ActualRelativePath
  if (-not (Test-Path -LiteralPath $expected) -or -not (Test-Path -LiteralPath $actual)) {
    Add-Failure "cannot compare missing files: $ExpectedRelativePath -> $ActualRelativePath"
    return
  }

  if ((Get-FileHash -LiteralPath $expected -Algorithm SHA256).Hash -ne
      (Get-FileHash -LiteralPath $actual -Algorithm SHA256).Hash) {
    Add-Failure "shared topic-thinking file drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

$contractPaths = @(
  '.claude/shared/contracts/topic-thinking.md',
  'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md',
  'zhiji-user/.claude/shared/contracts/topic-thinking.md'
)

Assert-SameFile '.claude/shared/contracts/topic-thinking.md' 'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md'
Assert-SameFile 'packaging/zhiji-user-overlay/.claude/shared/contracts/topic-thinking.md' 'zhiji-user/.claude/shared/contracts/topic-thinking.md'

foreach ($path in $contractPaths) {
  Assert-ContainsAll $path @(
    '\u672a\u7ecf\u7528\u6237\u786e\u8ba4\u4e0d\u5f97(?:\u521b\u5efa|\u5199\u5165|\u66f4\u65b0)',
    '\u4e0d\u4ece\u65e5\u5fd7.*\u81ea\u52a8\u6458\u5f55',
    '\u4efb\u610f\u65b0\u4e3b\u9898',
    '\u8def\u5f84\u5206\u9694\u7b26',
    '\u4e0d\u5f97.*\u9759\u9ed8\u8986\u76d6',
    '\u6700\u591a.*2.*\u4e3b\u9898',
    '\u660e\u786e\u544a\u77e5\u7528\u6237.*\u4e3b\u9898',
    '\u5f53\u524d\u8868\u8fbe.*\u4f18\u5148',
    '\u4e8b\u5b9e.*\u63a8\u65ad.*\u5efa\u8bae',
    '\u8bc1\u636e\u7f3a\u53e3|\u53cd\u4f8b|\u63a8\u7406\u8df3\u8dc3|\u4ef7\u503c\u51b2\u7a81|\u66ff\u4ee3\u89e3\u91ca',
    '\u4e00\u4e2a.*\u8fdb\u884c\u4e2d.*\u884c\u52a8\u5b9e\u9a8c',
    '\u5b9e\u8d28\u53d8\u5316.*\u89c2\u70b9\u6f14\u5316',
    '\u5f53\u524d\u884c\u52a8\u5361',
    '\u516d\u4e2a\u9648\u8ff0\u5f0f\u677f\u5757',
    '\u4e0d\u8981\u6c42.*\u7bc7\u5e45\u76f8\u7b49',
    '\u8bc1\u636e.*\u95ee\u9898\u590d\u6742\u5ea6.*\u884c\u52a8\u9700\u8981',
    '\u6267\u884c\u4fe1\u606f\u524d\u7f6e|\u8bfb\u8005\u4e0d\u5fc5\u8bfb\u5b8c\u6574\u7bc7'
  )
}

foreach ($path in @('.claude/shared/paths.md', 'packaging/zhiji-user-overlay/.claude/shared/paths.md', 'zhiji-user/.claude/shared/paths.md')) {
  Assert-ContainsAll $path @('context\.thinking_dir', 'context\.thinking_index', 'context\.thinking_topic')
}

foreach ($path in @('AGENTS.md', 'CLAUDE.md', 'packaging/zhiji-user-overlay/AGENTS.md', 'packaging/zhiji-user-overlay/CLAUDE.md', 'zhiji-user/AGENTS.md', 'zhiji-user/CLAUDE.md')) {
  Assert-ContainsAll $path @('topic-thinking\.md', 'thinking_index', '\u6ca1\u6709\u660e\u663e\u5339\u914d.*\u4e0d\u8bfb\u53d6')
}

$mainAgents = Read-Utf8 'AGENTS.md'
$mainClaude = Read-Utf8 'CLAUDE.md'
if ($mainAgents -cne $mainClaude) { Add-Failure 'AGENTS.md and CLAUDE.md are not byte-for-byte identical' }

$userAgents = Read-Utf8 'packaging/zhiji-user-overlay/AGENTS.md'
$userClaude = Read-Utf8 'packaging/zhiji-user-overlay/CLAUDE.md'
if ($userAgents -cne $userClaude) { Add-Failure 'user AGENTS.md and CLAUDE.md are not byte-for-byte identical' }

$aboutMe = -join @([char]0x5173, [char]0x4e8e, [char]0x6211)
$thinkingDir = -join @([char]0x601d, [char]0x8003)
$relationshipBoundaryTopic = -join @(
  [char]0x4eb2, [char]0x5bc6, [char]0x5173, [char]0x7cfb,
  [char]0x4e2d, [char]0x7684, [char]0x8fb9, [char]0x754c
)
$topicTemplate = Read-Utf8 "packaging/zhiji-user-overlay/$aboutMe/templates/thinking-topic.template.md"
foreach ($requiredHeading in @(
  '## \u5f53\u524d\u884c\u52a8\u5361',
  '## \u5f53\u524d\u95ee\u9898',
  '## \u5f53\u524d\u5224\u65ad',
  '## \u4f9d\u636e\u6765\u6e90\u4e0e\u601d\u8003\u6821\u6b63',
  '## \u503c\u5f97\u4fdd\u7559\u7684\u884c\u52a8',
  '## \u4e0b\u4e00\u6b21\u600e\u4e48\u505a',
  '## \u6211\u7684\u89c2\u70b9\u6f14\u5316\u8def\u5f84'
)) {
  if ($topicTemplate -notmatch $requiredHeading) { Add-Failure "topic template missing pattern: $requiredHeading" }
}
if ($topicTemplate -notmatch '\u4e0d\u8981\u6c42\u6bcf\u4e00\u8282\u7b49\u957f') {
  Add-Failure 'topic template does not state that sections may have unequal length'
}
if ($topicTemplate -match '\u4fe1\u606f\u8f93\u5165\u4e0e\u6ce8\u610f\u529b|\u5de5\u4f5c\u4e0e\u5065\u5eb7|\u804c\u4e1a\u9009\u62e9') {
  Add-Failure 'generic topic template contains a fixed example topic'
}

$indexTemplate = Read-Utf8 "packaging/zhiji-user-overlay/$aboutMe/templates/thinking-index.template.md"
if ($indexTemplate -notmatch '\|\s*\u4e3b\u9898\s*\|\s*\u522b\u540d/\u5173\u952e\u8bcd\s*\|\s*\u5f53\u524d\u6838\u5fc3\u95ee\u9898\s*\|\s*\u6700\u8fd1\u66f4\u65b0\s*\|') {
  Add-Failure 'thinking index template does not contain the routing table'
}
if ($indexTemplate -match '\u4fe1\u606f\u8f93\u5165\u4e0e\u6ce8\u610f\u529b|\u5de5\u4f5c\u4e0e\u5065\u5eb7|\u804c\u4e1a\u9009\u62e9|\u4eb2\u5bc6\u5173\u7cfb') {
  Add-Failure 'generic index template contains a concrete user topic'
}

Assert-GitIgnored 'zhiji-user' "$aboutMe/$thinkingDir/index.md"
Assert-GitIgnored 'zhiji-user' "$aboutMe/$thinkingDir/$relationshipBoundaryTopic.md"

git -C (Join-Path $repoRoot 'zhiji-user') check-ignore --quiet -- "$aboutMe/templates/thinking-topic.template.md"
if ($LASTEXITCODE -eq 0) {
  Add-Failure 'zhiji-user incorrectly ignores the tracked generic thinking template'
}

$manifest = Read-Utf8 'packaging/zhiji-user-manifest.json' | ConvertFrom-Json
foreach ($target in @('AGENTS.md', 'CLAUDE.md')) {
  if (-not ($manifest.syncTasks | Where-Object { $_.target -eq $target -and $_.kind -eq 'overwriteFile' })) {
    Add-Failure "manifest does not overwrite user runtime entry: $target"
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: topic thinking contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: topic thinking contract checks' -ForegroundColor Green
exit 0
