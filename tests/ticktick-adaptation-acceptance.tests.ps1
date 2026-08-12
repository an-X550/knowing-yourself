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

$contract = '.claude/shared/contracts/result-distribution.md'
$overlayContract = 'packaging/zhiji-user-overlay/.claude/shared/contracts/result-distribution.md'
$spec = 'docs/superpowers/specs/2026-08-12-ticktick-minimal-adaptation-design.md'
$setup = 'docs/result-distribution-setup.md'
$acceptance = 'tests/fixtures/result-distribution/ticktick-adaptation-acceptance.json'

foreach ($path in @($contract, $overlayContract)) {
  Assert-Contains $path @(
    'candidate_edit_does_not_rewrite_report'
    'local_only_non_retroactive'
    'direct_obvious_conflict_only'
    'candidate_reason_on_tradeoff_only'
    'legacy_state_no_cross_source_dedupe'
  )
}

Assert-Contains $spec @(
  'offline_end_to_end_acceptance'
  'official_mcp_smoke_test'
  'tests_pass_formal_use'
)

Assert-Contains $setup @(
  'offline_end_to_end_acceptance'
  'official_mcp_smoke_test'
  'tests_pass_formal_use'
)

Assert-Contains 'PROJECT_STATUS.md' @(
  'ticktick_adaptation: ready_for_formal_use'
)

$acceptanceText = Read-Utf8 $acceptance
if (-not [string]::IsNullOrWhiteSpace($acceptanceText)) {
  try {
    $cases = $acceptanceText | ConvertFrom-Json
    function Resolve-AcceptanceOutcome {
      param($Case)
      if ($Case.completion_signal -eq 'ticktick') { return 'ignored_for_completion' }
      if ($Case.local_only) { return 'skipped_local_only' }
      if (-not $Case.new_write) { return 'skipped_not_new_write' }
      if ($Case.existing_exact_action) { return 'skipped_duplicate' }
      if ($Case.retry_requested) { return 'retry_failed_once' }
      if ($Case.source -in @('weekly', 'monthly') -and -not $Case.confirmed) { return "candidate:$([Math]::Min([int]$Case.eligible_actions, 3))" }
      if ($Case.source -eq 'topic' -and -not $Case.confirmed) { return 'wait_for_save_confirmation' }
      if ($Case.source -eq 'daily') { return "create:$([Math]::Min([int]$Case.eligible_actions, 1))" }
      if ($Case.source -in @('weekly', 'monthly')) { return "create:$([Math]::Min([int]$Case.eligible_actions, 3))" }
      if ($Case.source -eq 'topic') { return "create:$([Math]::Min([int]$Case.eligible_actions, 1))" }
      return 'skipped_not_supported'
    }
    $requiredCases = @(
      'daily-auto-create-1'
      'daily-auto-create-2'
      'daily-auto-create-3'
      'weekly-confirmation-gate'
      'monthly-confirmation-gate'
      'topic-save-and-create'
      'local-only'
      'exact-deduplication'
      'legacy-state'
      'partial-failure-retry'
      'journal-only-completion'
    )
    $actualNames = @($cases.cases | ForEach-Object { $_.name })
    foreach ($name in $requiredCases) {
      if ($actualNames -notcontains $name) {
        Add-Failure "acceptance fixture missing case: $name"
      }
    }
    if (@($cases.cases).Count -ne $requiredCases.Count) {
      Add-Failure "acceptance fixture must contain exactly $($requiredCases.Count) high-value cases"
    }
    foreach ($case in @($cases.cases)) {
      if ($case.remote_write -ne $false) {
        Add-Failure "simulated acceptance case must not write remote data: $($case.name)"
      }
      if ([string]::IsNullOrWhiteSpace($case.expected)) {
        Add-Failure "acceptance case missing expected result: $($case.name)"
      }
      $actual = Resolve-AcceptanceOutcome -Case $case
      if ($actual -ne $case.expected) {
        Add-Failure "acceptance case $($case.name) expected $($case.expected), got $actual"
      }
    }
  } catch {
    Add-Failure "acceptance fixture is not valid JSON: $($_.Exception.Message)"
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: TickTick adaptation acceptance checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: TickTick adaptation acceptance checks' -ForegroundColor Green
exit 0
