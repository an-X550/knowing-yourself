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

function Assert-DoesNotMatch {
  param([string]$Path, [string]$Pattern, [string]$Message)
  $content = Read-Utf8 $Path
  if ($content -match $Pattern) {
    Add-Failure "$Path $Message"
  }
}

function Get-Path-Mapping {
  param([string]$Key, [string]$PathsText)
  $escapedKey = [regex]::Escape($Key)
  $match = [regex]::Match($PathsText, "(?m)^\|\s*`?$escapedKey`?\s*\|\s*`?([^`|]+)`?\s*\|")
  if (-not $match.Success) {
    Add-Failure "authoritative path mapping is missing: $Key"
    return ''
  }
  $match.Groups[1].Value.Trim()
}

function Get-Route-Blocks {
  param([string]$Text)
  [regex]::Matches($Text, '(?ms)^#{2,}[^\r\n]*\r?\n.*?(?=^#{2,}|\z)')
}

function Assert-Route-Block-Mapping {
  param([string]$Trigger, [string]$OutputKey, [string]$ContractText, [string]$PathsText, [string]$Label)
  if (-not $contractText) { return }

  $blocks = Get-Route-Blocks $ContractText
  $matchingBlocks = @($blocks | Where-Object { $_.Value -match [regex]::Escape($Trigger) })
  if ($matchingBlocks.Count -ne 1) {
    Add-Failure "$Label routing block count for '$Trigger' is $($matchingBlocks.Count), expected 1"
    return
  }

  $routeBlock = $matchingBlocks[0].Value
  $expectedPath = Get-Path-Mapping $OutputKey $PathsText
  if ($routeBlock -notmatch [regex]::Escape($OutputKey)) {
    Add-Failure "$Label routing block for '$Trigger' does not contain: $OutputKey"
  }
  if ($expectedPath -and $routeBlock -notmatch [regex]::Escape($expectedPath)) {
    Add-Failure "$Label routing block for '$Trigger' does not contain authoritative path: $expectedPath"
  }
}

function Test-IsExecutable-Claude-Dispatch {
  param([string]$Text)
  [regex]::IsMatch($Text, $claudeDispatchPattern)
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

$routeDefinitions = @(
  @{ trigger = ConvertFrom-Utf8Base64 '55Sf5oiQIDIwMjYtVzI4IOWRqOaKpQ=='; output = 'output.weekly_report' },
  @{ trigger = ConvertFrom-Utf8Base64 '55Sf5oiQIDIwMjYg5bm0IDYg5pyI5pyI5oql'; output = 'output.monthly_report' },
  @{ trigger = ConvertFrom-Utf8Base64 '5a+5IFgg5YGa6aG555uu5aSN55uY'; output = 'output.project_report' }
)

$dispatchVerb = ConvertFrom-Utf8Base64 '6LCD55SofOiwg+W6pnzmiafooYx85L2/55SofOWnlOa0vue7mXzkuqTnu5l86YCa6L+H'
$dispatchPrefix = '(?:\|\s*)?(?:(?:[-*+]|\d+[.)])\s*)?'
$claudeDispatchPattern = "(?im)^\s*$dispatchPrefix(?:$dispatchVerb|call|invoke|run|execute|dispatch|use).{0,80}(?:Claude\s*)?`?(?:Workflow|Task)`?\b"

$fixturePaths = @(
  '| output.weekly_report | weekly-path |',
  '| output.monthly_report | monthly-path |',
  '| output.project_report | project-path |'
) -join "`n"
$fixtureRoutes = @(
  '## weekly', $routeDefinitions[0].trigger, 'output.weekly_report', 'weekly-path',
  '## monthly', $routeDefinitions[1].trigger, 'output.monthly_report', 'monthly-path',
  '## project', $routeDefinitions[2].trigger, 'output.project_report', 'project-path'
) -join "`n"
foreach ($route in $routeDefinitions) {
  Assert-Route-Block-Mapping $route.trigger $route.output $fixtureRoutes $fixturePaths 'fixture'
}
foreach ($dispatchFixture in @(
  (ConvertFrom-Utf8Base64 'MS4g6LCD55SoIFRhc2sgcnVu'),
  (ConvertFrom-Utf8Base64 'fCDlp5TmtL7nu5kgV29ya2Zsb3cgfA=='),
  (ConvertFrom-Utf8Base64 '6YCa6L+HIFRhc2sg5omn6KGM')
)) {
  if (-not (Test-IsExecutable-Claude-Dispatch $dispatchFixture)) {
    Add-Failure "fixture did not detect executable Claude dispatch: $dispatchFixture"
  }
}
if (Test-IsExecutable-Claude-Dispatch (ConvertFrom-Utf8Base64 '5LiN6LCD55So5LiN5a2Y5Zyo55qEIENsYXVkZSBgV29ya2Zsb3dgIC8gYFRhc2tgIOW3peWFtw==')) {
  Add-Failure 'fixture misclassified the required prohibition as executable Claude dispatch'
}

$contract = '.claude/shared/contracts/codex-natural-language-routing.md'
$expectedContractPhrases = @($routeDefinitions.trigger) + (ConvertFrom-Utf8Base64 '5LiN6LCD55So5LiN5a2Y5Zyo55qEIENsYXVkZSBgV29ya2Zsb3dgIC8gYFRhc2tgIOW3peWFtw==')
foreach ($expected in $expectedContractPhrases) { Assert-Contains $contract $expected }
foreach ($key in $routeDefinitions.output) { Assert-Contains $contract $key }

$pathsText = Read-Utf8 '.claude/shared/paths.md'
foreach ($route in $routeDefinitions) {
  Assert-Route-Block-Mapping $route.trigger $route.output (Read-Utf8 $contract) $pathsText 'contract'
}
Assert-DoesNotMatch $contract $claudeDispatchPattern 'contains executable Claude Workflow/Task dispatch instructions'

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
