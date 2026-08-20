$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$entryPath = Join-Path $repoRoot '.claude/workflows/workbuddy-message-entry.md'
$promptPath = Join-Path $repoRoot 'docs/workbuddy-agent-prompt.md'
$legacyEntryPath = Join-Path $repoRoot '.claude/workflows/workbuddy-feishu-entry.md'
$legacyPromptPath = Join-Path $repoRoot 'docs/workbuddy-feishu-agent-prompt.md'
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([Parameter(Mandatory = $true)][string]$Message)
  $script:failures.Add($Message)
}

function Assert-Contains {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Needle,
    [Parameter(Mandatory = $true)][string]$Message
  )
  if (-not $Text.Contains($Needle)) { Add-Failure $Message }
}

function Assert-NotContains {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Needle,
    [Parameter(Mandatory = $true)][string]$Message
  )
  if ($Text.Contains($Needle)) { Add-Failure $Message }
}

function Get-RouteLine {
  param(
    [Parameter(Mandatory = $true)][string]$Text,
    [Parameter(Mandatory = $true)][string]$Route
  )
  $line = @($Text -split "`r?`n" | Where-Object { $_.Contains($Route) -and $_.Contains('|') }) | Select-Object -First 1
  if ($null -eq $line) {
    Add-Failure "missing route line: $Route"
    return ''
  }
  return [string]$line
}

if (-not (Test-Path -LiteralPath $entryPath -PathType Leaf)) {
  Add-Failure 'missing WorkBuddy multi-channel runtime entry contract'
}
if (-not (Test-Path -LiteralPath $promptPath -PathType Leaf)) {
  Add-Failure 'missing copyable WorkBuddy agent prompt'
}
if (-not (Test-Path -LiteralPath $legacyEntryPath -PathType Leaf)) {
  Add-Failure 'missing legacy Feishu entry compatibility redirect'
}
if (-not (Test-Path -LiteralPath $legacyPromptPath -PathType Leaf)) {
  Add-Failure 'missing legacy Feishu prompt compatibility redirect'
}

if ($failures.Count -eq 0) {
  $entry = Get-Content -LiteralPath $entryPath -Raw -Encoding UTF8
  $prompt = Get-Content -LiteralPath $promptPath -Raw -Encoding UTF8

  foreach ($requiredReference in @(
    '.claude/shared/paths.md',
    '.claude/skills/log.md',
    '.claude/agents/daily-analyzer.md',
    '.claude/shared/contracts/daily-feedback.md',
    '.claude/shared/contracts/evidence-and-verification.md',
    '.claude/shared/contracts/result-distribution.md',
    '.claude/shared/contracts/codex-natural-language-routing.md',
    '.claude/shared/contracts/topic-thinking.md',
    '.claude/shared/contracts/topic-thinking-persistence.md',
    '.claude/commands/review.md',
    '.claude/agents/review-readiness-checker.md'
  )) {
    Assert-Contains $entry $requiredReference "entry must reference $requiredReference"
  }

  foreach ($requiredRoute in @('route.daily_log', 'route.weekly_review', 'route.monthly_review', 'route.project_review', 'route.topic_discussion', 'route.topic_persistence', 'route.readiness_check', 'route.yearly_review', 'route.life_design', 'route.journal_quality')) {
    Assert-Contains $entry $requiredRoute "entry must declare route $requiredRoute"
  }

  foreach ($requiredBoundary in @('policy.configured_distribution_default', 'policy.local_only_opt_out', 'policy.ingress_not_distribution_authorization', 'policy.channel_agnostic', 'policy.channel_independent', 'policy.no_direct_profile_write', 'policy.propose_long_term_changes', 'policy.topic_confirmation_required', 'policy.single_clarification', 'policy.readback_required', 'policy.no_template_duplication')) {
    Assert-Contains $entry $requiredBoundary "entry must enforce boundary: $requiredBoundary"
  }

  foreach ($routeExpectation in @{
    'route.daily_log' = @('.claude/skills/log.md', '.claude/agents/daily-analyzer.md', 'input.journal_dir', 'output.daily_feedback', 'context.verified_patterns', 'output.readiness_delivery_state')
    'route.weekly_review' = @('.claude/commands/weekly-review.md', '.claude/agents/weekly-synthesis.md', 'output.weekly_report')
    'route.monthly_review' = @('.claude/commands/monthly-review.md', '.claude/agents/monthly-synthesis.md', 'output.monthly_report')
    'route.project_review' = @('.claude/commands/project-review.md', '.claude/agents/project-synthesis.md', 'output.project_report')
    'route.topic_discussion' = @('.claude/shared/contracts/topic-thinking.md')
    'route.topic_persistence' = @('.claude/shared/contracts/topic-thinking-persistence.md', 'context.thinking_index')
    'route.readiness_check' = @('.claude/commands/review.md', '.claude/agents/review-readiness-checker.md')
    'route.yearly_review' = @('.claude/commands/yearly-review.md', '.claude/agents/yearly-synthesis.md', 'output.yearly_report')
    'route.life_design' = @('.claude/commands/life-design.md', '.claude/agents/life-design-synthesis.md', 'output.life_design_report')
    'route.journal_quality' = @('.claude/commands/journal-coach.md', '.claude/agents/journal-quality-coach.md', 'output.coach_report')
  }.GetEnumerator()) {
    $line = Get-RouteLine $entry $routeExpectation.Key
    foreach ($expectedValue in $routeExpectation.Value) {
      Assert-Contains $line $expectedValue "route $($routeExpectation.Key) must include $expectedValue"
    }
  }

  $dailyRouteLine = Get-RouteLine $entry 'route.daily_log'
  Assert-NotContains $dailyRouteLine 'context.core_profile' 'daily route must not write core profile'
  Assert-NotContains $dailyRouteLine 'context.current' 'daily route must not write current status'
  Assert-Contains $entry '.claude/shared/contracts/result-distribution.md' 'entry must delegate external distribution to the shared contract'
  Assert-Contains $entry 'distribute <path-key> <resolved-local-path>' 'entry must use the existing distribution handoff'
  Assert-Contains $entry 'distribute output.daily_feedback' 'daily route must hand a verified new feedback to result distribution'
  Assert-Contains $entry 'https://mcp.dida365.com' 'entry must bind TickTick to the WorkBuddy custom MCP connector'
  Assert-Contains $entry 'dida365_create_task' 'entry must bind the exact WorkBuddy dida365 create tool'
  Assert-Contains $entry 'disabledTools' 'entry must require platform-level denial of non-create TickTick tools'
  Assert-Contains $entry 'lark_cli_path' 'entry must resolve Feishu CLI from the local config path'
  Assert-Contains $entry 'mcp_missing' 'entry must expose a portable missing-connector failure'
  Assert-NotContains $entry 'policy.no_external_distribution' 'entry must not hard-code a permanent external-distribution ban'
  Assert-NotContains $entry 'policy.default_local_only' 'entry must not keep the obsolete default-local-only behavior'
  Assert-NotContains $entry 'policy.explicit_distribution_authorization' 'entry must not require per-message distribution authorization'
  Assert-NotContains $entry '```' 'entry must not duplicate report templates in code fences'
  Assert-Contains $entry 'policy.no_template_duplication' 'entry must forbid duplicate output templates'
  Assert-Contains $prompt '.claude/workflows/workbuddy-message-entry.md' 'prompt must direct the agent to the unique entry contract'
  Assert-Contains $prompt 'instruction.no_self_analysis' 'prompt must forbid self-authored analysis'
  Assert-Contains $prompt 'instruction.no_development' 'prompt must forbid development requests'
  Assert-Contains $prompt 'instruction.configured_distribution_default' 'prompt must honor enabled distribution config by default'
  Assert-Contains $prompt 'instruction.local_only_opt_out' 'prompt must preserve the per-request local-only opt-out'

  $legacyEntry = Get-Content -LiteralPath $legacyEntryPath -Raw -Encoding UTF8
  $legacyPrompt = Get-Content -LiteralPath $legacyPromptPath -Raw -Encoding UTF8
  Assert-Contains $legacyEntry '.claude/workflows/workbuddy-message-entry.md' 'legacy Feishu entry must redirect to the multi-channel entry'
  Assert-Contains $legacyPrompt 'workbuddy-agent-prompt.md' 'legacy Feishu prompt must redirect to the multi-channel prompt'
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Error "FAIL: $_" }
  exit 1
}

Write-Host 'PASS: WorkBuddy multi-channel runtime entry contract checks'
