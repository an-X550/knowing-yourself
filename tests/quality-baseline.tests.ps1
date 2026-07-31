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
  param([string]$RelativePath, [string]$Expected)
  $content = Read-Utf8 $RelativePath
  if ($content -notmatch [regex]::Escape($Expected)) {
    Add-Failure "$RelativePath does not contain: $Expected"
  }
}

function Assert-Matches {
  param([string]$RelativePath, [string]$Pattern, [string]$Label)
  $content = Read-Utf8 $RelativePath
  if ($content -notmatch $Pattern) {
    Add-Failure "$RelativePath missing $Label"
  }
}

$matrixPath = 'docs/quality-baseline-matrix.md'
foreach ($rowId in @(
  'daily-feedback',
  'weekly-monthly-review',
  'project-review',
  'yearly-review',
  'life-design',
  'user-package'
)) {
  Assert-Contains $matrixPath $rowId
}
foreach ($target in @(
  'archive',
  'evidence-level',
  'single-insight',
  'single-action',
  'verification-writeback',
  'multi-perspective',
  'six-question-report',
  'chat-summary',
  'output-path',
  'conversation-materials',
  'project-filename',
  'monthly-report-reading',
  'insufficient-material-degradation',
  'annual-summary',
  'mode-parameters',
  'evidence-scope',
  'seven-day-experiment',
  'first-principles-recheck',
  'user-response-section',
  'shared-capability-equivalence',
  'developer-capability-removal'
)) {
  Assert-Contains $matrixPath $target
}

Assert-Contains '.claude/shared/paths.md' 'output.daily_feedback'
Assert-Contains '.claude/shared/contracts/journal-input.md' 'previous_action_evidence'
Assert-Contains '.claude/shared/contracts/daily-feedback.md' 'D4.'
Assert-Contains '.claude/shared/contracts/daily-feedback.md' 'D5.'
Assert-Contains '.claude/shared/contracts/first-principles-analysis.md' '显式触发'
Assert-Contains '.claude/shared/contracts/daily-feedback.md' 'first-principles-analysis.md'
Assert-Contains '.claude/shared/contracts/review-synthesis.md' 'first-principles-analysis.md'
Assert-Contains '.claude/shared/contracts/topic-thinking.md' 'first-principles-analysis.md'
Assert-Contains '.claude/shared/prompt-rules.md' '第一性原理复核'
Assert-Contains '.claude/shared/contracts/evidence-and-verification.md' 'context.verified_patterns'
Assert-Contains 'tests/journal-input-contract.tests.ps1' 'expected_level'

if ((Get-FileHash AGENTS.md -Algorithm SHA256).Hash -ne (Get-FileHash CLAUDE.md -Algorithm SHA256).Hash) {
  Add-Failure 'main AGENTS.md and CLAUDE.md are not byte-identical'
}
if ((Get-FileHash 'packaging/zhiji-user-overlay/AGENTS.md' -Algorithm SHA256).Hash -ne (Get-FileHash 'packaging/zhiji-user-overlay/CLAUDE.md' -Algorithm SHA256).Hash) {
  Add-Failure 'user overlay AGENTS.md and CLAUDE.md are not byte-identical'
}
Assert-Contains 'AGENTS.md' '第一性原理复核'
Assert-Contains '.claude/shared/ai-operating-principles.md' '沟通与决策'
Assert-Contains 'packaging/zhiji-user-overlay/AGENTS.md' '第一性原理复核'
Assert-Contains 'packaging/zhiji-user-overlay/.claude/shared/ai-operating-principles.md' '沟通与决策'

foreach ($workflow in @('.claude/workflows/weekly-review.js', '.claude/workflows/monthly-review.js')) {
  Assert-Contains $workflow 'parallel(agentTasks)'
  Assert-Contains $workflow 'formatAnalyses'
  Assert-Contains $workflow 'extractChatSummary'
  Assert-Contains $workflow 'reportPath'
}
Assert-Contains '.claude/shared/contracts/review-synthesis.md' 'YAML frontmatter'
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '判断驱动展开'
Assert-Contains '.claude/shared/contracts/review-synthesis.md' '不为覆盖清单而重复正文'
Assert-Contains 'docs/quality-baseline-matrix.md' 'adaptive-depth'
Assert-Contains '.claude/workflows/weekly-review.js' 'output.weekly_report'
Assert-Contains '.claude/workflows/monthly-review.js' 'output.monthly_report'
Assert-Contains '.claude/agents/weekly-synthesis.md' '## 用户回应区'
Assert-Contains '.claude/commands/weekly-review.md' '用户回应区'

Assert-Contains '.claude/workflows/project-review.js' 'sanitizeProjectSlug'
Assert-Contains '.claude/workflows/project-review.js' 'output.project_report'
Assert-Contains '.claude/workflows/project-review.js' 'project review '
Assert-Contains '.claude/commands/project-review.md' 'mode: "standard|full"'

Assert-Contains '.claude/commands/yearly-review.md' '12'
Assert-Contains '.claude/commands/yearly-review.md' '6'
Assert-Contains '.claude/agents/yearly-synthesis.md' 'months_processed'
Assert-Contains '.claude/workflows/yearly-review.js' 'yearly_extra'
Assert-Contains '.claude/shared/paths.md' 'output.yearly_report'

Assert-Matches '.claude/commands/life-design.md' 'quick[\s\S]*standard[\s\S]*full[\s\S]*odyssey' 'life-design mode contract'
Assert-Contains '.claude/commands/life-design.md' '90'
Assert-Contains '.claude/agents/life-design-synthesis.md' 'quick'
Assert-Contains '.claude/agents/life-design-synthesis.md' 'standard'
Assert-Contains '.claude/agents/life-design-synthesis.md' 'full'
Assert-Contains '.claude/agents/life-design-synthesis.md' 'odyssey'
Assert-Contains '.claude/shared/paths.md' 'output.life_design_report'

Assert-Contains 'packaging/zhiji-user-boundaries.json' '"shared"'
Assert-Contains 'packaging/zhiji-user-boundaries.json' '"override"'
Assert-Contains 'packaging/zhiji-user-boundaries.json' '"user_only"'
Assert-Contains 'packaging/zhiji-user-boundaries.json' 'User package omits developer-only routing'
Assert-Contains 'tests/distribution-boundary.tests.ps1' 'RequireCleanUserRepo'

if ($failures.Count -gt 0) {
  Write-Host "FAIL: quality baseline checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: quality baseline checks' -ForegroundColor Green
exit 0
