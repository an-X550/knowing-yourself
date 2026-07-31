$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $PSScriptRoot
$failures = New-Object System.Collections.Generic.List[string]
$missingFiles = New-Object System.Collections.Generic.HashSet[string]

function Add-Failure {
  param([string]$Message)
  $failures.Add($Message) | Out-Null
}

function ConvertFrom-Utf8Base64 {
  param([string]$Value)
  [Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Value))
}

function Read-Utf8 {
  param([string]$RelativePath)
  $path = Join-Path $repoRoot $RelativePath
  if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
    if ($missingFiles.Add($RelativePath)) {
      Add-Failure "missing file: $RelativePath"
    }
    return ''
  }
  Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

function Assert-Contains {
  param([string]$Path, [string]$Expected)
  $content = Read-Utf8 $Path
  if ($content -notmatch [regex]::Escape($Expected)) {
    Add-Failure "$Path does not contain: $Expected"
  }
}

function Assert-Hash-Matches {
  param([string]$FirstPath, [string]$SecondPath)
  $first = Join-Path $repoRoot $FirstPath
  $second = Join-Path $repoRoot $SecondPath
  if (-not (Test-Path -LiteralPath $first -PathType Leaf) -or -not (Test-Path -LiteralPath $second -PathType Leaf)) {
    Add-Failure "cannot compare missing files: $FirstPath, $SecondPath"
    return
  }
  if ((Get-FileHash -LiteralPath $first -Algorithm SHA256).Hash -ne (Get-FileHash -LiteralPath $second -Algorithm SHA256).Hash) {
    Add-Failure "mirror drift: $FirstPath and $SecondPath"
  }
}

$contract = '.claude/shared/contracts/codex-natural-language-routing.md'
$expectedContractPhrases = @(
  (ConvertFrom-Utf8Base64 '55Sf5oiQIDIwMjYtVzI4IOWRqOaKpQ=='),
  (ConvertFrom-Utf8Base64 '55Sf5oiQIDIwMjYg5bm0IDYg5pyI5pyI5oql'),
  (ConvertFrom-Utf8Base64 '5a+5IFgg5YGa6aG555uu5aSN55uY'),
  'output.weekly_report',
  'output.monthly_report',
  'output.project_report',
  (ConvertFrom-Utf8Base64 '5LiN6LCD55So5LiN5a2Y5Zyo55qEIENsYXVkZSBgV29ya2Zsb3dgIC8gYFRhc2tgIOW3peWFtw==')
)
foreach ($expected in $expectedContractPhrases) {
  Assert-Contains $contract $expected
}

Assert-Contains 'AGENTS.md' (ConvertFrom-Utf8Base64 'Q29kZXgg6Ieq54S26K+t6KiA5aSN55uY5YWl5Y+j')
Assert-Hash-Matches 'AGENTS.md' 'CLAUDE.md'
Assert-Hash-Matches 'zhiji-user/AGENTS.md' 'zhiji-user/CLAUDE.md'

$boundaryText = Read-Utf8 'packaging/zhiji-user-boundaries.json'
if ($boundaryText) {
  try {
    $boundary = $boundaryText | ConvertFrom-Json
    if (@($boundary.shared) -notcontains $contract) {
      Add-Failure "routing contract is not declared shared: $contract"
    }
  } catch {
    Add-Failure 'cannot parse packaging/zhiji-user-boundaries.json'
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: Codex natural-language routing contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host (ConvertFrom-Utf8Base64 'UEFTUzogQ29kZXggbmF0dXJhbC1sYW5ndWFnZSByb3V0aW5nIGNvbnRyYWN0IGNoZWNrcw==') -ForegroundColor Green
exit 0
