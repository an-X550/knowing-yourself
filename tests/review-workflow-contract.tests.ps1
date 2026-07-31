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

function Assert-Matches {
  param([string]$RelativePath, [string]$Pattern)
  $content = Read-Utf8 $RelativePath
  if ($content -notmatch $Pattern) {
    Add-Failure "$RelativePath missing expected pattern: $Pattern"
  }
}

$agentPaths = @(
  '.claude/agents/weekly-synthesis.md',
  '.claude/agents/monthly-synthesis.md',
  '.claude/agents/project-synthesis.md',
  '.claude/agents/yearly-synthesis.md'
)

foreach ($agentPath in $agentPaths) {
  $content = Read-Utf8 $agentPath
  if ($content -match '\u53ea\u8fd4\u56de|\u4e0d\u8981.*\u5b8c\u6574\u62a5\u544a.*\u56de') {
    Add-Failure "$agentPath still instructs the agent to return only an acknowledgement"
  }
  foreach ($pattern in @(
    '\u8fd4\u56de\u5b8c\u6574\u62a5\u544a\u5168\u6587',
    '#{1,2}\s*\u804a\u5929\u6458\u8981',
    '\[\u804a\u5929\u6458\u8981\u7ed3\u675f\u3002\u4ee5\u4e0b\u4e3a\u5b8c\u6574\u62a5\u544a\]'
  )) {
    if ($content -notmatch $pattern) {
      Add-Failure "$agentPath missing return contract pattern: $pattern"
    }
  }
}

$weeklySynthesis = Read-Utf8 '.claude/agents/weekly-synthesis.md'
foreach ($pattern in @(
  '##\s*\u7528\u6237\u56de\u5e94\u533a',
  'AI\s*\u6ca1\u63d0\uff0c\u4f46\u6211\u8ba4\u4e3a\u91cd\u8981\u7684\u4e8b',
  '\u4e0b\u5468\u4e0d\u53ef\u4e22\u7684\u786c\u7ea6\u675f',
  '\u4e0d\u8981\u66ff\u7528\u6237\u586b\u5199'
)) {
  if ($weeklySynthesis -notmatch $pattern) {
    Add-Failure ".claude/agents/weekly-synthesis.md missing user response contract: $pattern"
  }
}

foreach ($relativePath in @(
  '.claude/shared/contracts/review-synthesis.md',
  '.claude/agents/weekly-synthesis.md',
  '.claude/agents/monthly-synthesis.md',
  '.claude/agents/project-synthesis.md'
)) {
  Assert-Matches $relativePath '\u5224\u65ad\u9a71\u52a8\u5c55\u5f00'
  Assert-Matches $relativePath '\u65e0\u65b0\u589e\u5224\u65ad'
}
Assert-Matches '.claude/agents/weekly-synthesis.md' '1\u20133\s*\u4e2a\u5f71\u54cd\u4e0b\u5468\u51b3\u7b56\u7684\u5224\u65ad'
Assert-Matches '.claude/agents/monthly-synthesis.md' '2\u20133\s*\u4e2a\u5f71\u54cd\u4e0b\u6708\u51b3\u7b56\u7684\u5224\u65ad'
Assert-Matches '.claude/agents/project-synthesis.md' '\u7531\u9879\u76ee\u590d\u6742\u5ea6\u51b3\u5b9a'

$weeklyCommand = Read-Utf8 '.claude/commands/weekly-review.md'
foreach ($pattern in @(
  '\u7528\u6237\u56de\u5e94\u533a',
  '\u7528\u6237\u5728\u56de\u5e94\u533a\u590d\u76d8\u65b9\u5411\u3001\u53d6\u820d\u548c\u9057\u6f0f'
)) {
  if ($weeklyCommand -notmatch $pattern) {
    Add-Failure ".claude/commands/weekly-review.md missing user response entry: $pattern"
  }
}

$nodeScript = Join-Path ([System.IO.Path]::GetTempPath()) ('zhiji-review-contract-' + [System.Guid]::NewGuid().ToString('N') + '.mjs')
$sharedPath = (Join-Path $repoRoot '.claude/workflows/shared.js').Replace('\', '/')
$scriptTemplate = @'
import { extractChatSummary } from '__SHARED_PATH__'

const cases = [
  ['## \u804a\u5929\u6458\u8981\n\n\u53d1\u73b0 A\n---\n[\u804a\u5929\u6458\u8981\u7ed3\u675f\u3002\u4ee5\u4e0b\u4e3a\u5b8c\u6574\u62a5\u544a]\n## \u4e00\u3001\u56de\u987e\u76ee\u6807', '\u53d1\u73b0 A'],
  ['# \u804a\u5929\u6458\u8981\n\n\u53d1\u73b0 B\n---\n[\u804a\u5929\u6458\u8981\u7ed3\u675f]\n## \u4e00\u3001\u56de\u987e\u76ee\u6807', '\u53d1\u73b0 B'],
  ['## \u804a\u5929\u6458\u8981\n\n\u53d1\u73b0 C\n## \u4e00\u3001\u56de\u987e\u76ee\u6807', '\u53d1\u73b0 C'],
]

let failed = false
for (const [input, expected] of cases) {
  const actual = extractChatSummary(input)
  if (actual !== expected) {
    console.log(`extractChatSummary mismatch: expected="${expected}" actual="${actual}"`)
    failed = true
  }
}
if (failed) process.exit(1)
'@
$script = $scriptTemplate.Replace('__SHARED_PATH__', "file:///$sharedPath")

try {
  Set-Content -LiteralPath $nodeScript -Encoding UTF8 -Value $script
  node $nodeScript
  if ($LASTEXITCODE -ne 0) {
    Add-Failure 'extractChatSummary does not handle all required summary formats'
  }
}
finally {
  if (Test-Path -LiteralPath $nodeScript) {
    Remove-Item -LiteralPath $nodeScript -Force
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: review workflow contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: review workflow contract checks' -ForegroundColor Green
exit 0
