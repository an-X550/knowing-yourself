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
