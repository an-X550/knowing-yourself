param([switch]$RequireCleanUserRepo)

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

function Get-Hash {
  param([string]$RelativePath)
  (Get-FileHash -LiteralPath (Join-Path $repoRoot $RelativePath) -Algorithm SHA256).Hash
}

function Normalize-Path {
  param([string]$Path)
  $Path.Replace('\', '/')
}

$boundaryPath = 'packaging/zhiji-user-boundaries.json'
$boundary = Read-Utf8 $boundaryPath | ConvertFrom-Json

$shared = @($boundary.shared | ForEach-Object { [string]$_ })
$override = @($boundary.override)
$overridePaths = @($override | ForEach-Object { [string]$_.path })
$userOnly = @($boundary.user_only | ForEach-Object { [string]$_ })

if ($shared -notcontains '.claude/shared/contracts/first-principles-analysis.md') {
  Add-Failure 'explicit first-principles contract is not declared shared'
}

if ($shared -notcontains '.claude/shared/contracts/codex-natural-language-routing.md') {
  Add-Failure 'Codex natural-language routing contract is not declared shared'
}

foreach ($requiredShared in @(
  '.claude/workflows/local-feishu-daily-feedback.ps1',
  '.claude/shared/local-feishu-daily-feedback-config.example.json'
)) {
  if ($shared -notcontains $requiredShared) {
    Add-Failure "local Feishu runtime is not declared shared: $requiredShared"
  }
}

$userDeploymentSource = 'packaging/zhiji-user-overlay/docs/feishu-ai-deployment.md'
$userEntrySource = 'packaging/zhiji-user-overlay/docs/local-feishu-daily-feedback-entry.md'
$userReadmeSource = 'packaging/zhiji-user-overlay/README.md'
foreach ($requiredSource in @($userDeploymentSource, $userEntrySource)) {
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $requiredSource) -PathType Leaf)) {
    Add-Failure "missing user Feishu deployment source: $requiredSource"
  }
}

$deploymentText = Read-Utf8 $userDeploymentSource
foreach ($requiredTerm in @('Codex', 'Claude', 'DeepSeek', 'lark-cli', 'dida365', 'API key', 'human authorization')) {
  if ($deploymentText -notmatch [regex]::Escape($requiredTerm)) {
    Add-Failure "user Feishu deployment guide is missing: $requiredTerm"
  }
}

$userReadmeText = Read-Utf8 $userReadmeSource
if ($userReadmeText -notmatch 'docs/feishu-ai-deployment\.md') {
  Add-Failure 'user README does not link the Feishu AI deployment guide'
}

$mainFeishuWorkflow = Read-Utf8 '.claude/workflows/local-feishu-daily-feedback.ps1'
if ($mainFeishuWorkflow -notmatch '"--model", "gpt-5\.4"') {
  Add-Failure 'local Feishu runtime does not pin GPT-5.4'
}
if ($mainFeishuWorkflow -notmatch '@\("login", "status"\)' -or $mainFeishuWorkflow -match 'probePrompt') {
  Add-Failure 'local Feishu runtime preflight must check login without generating model output'
}

$overlayRoot = Join-Path $repoRoot 'packaging/zhiji-user-overlay'
$overlayFiles = Get-ChildItem -LiteralPath $overlayRoot -Recurse -File -Force | ForEach-Object {
  Normalize-Path $_.FullName.Substring($overlayRoot.Length + 1)
}

foreach ($relativePath in $overlayFiles) {
  $mainPath = Join-Path $repoRoot $relativePath
  $hasMain = Test-Path -LiteralPath $mainPath -PathType Leaf

  if ($hasMain) {
    $classified = ($shared -contains $relativePath) -or ($overridePaths -contains $relativePath)
    if (-not $classified) {
      Add-Failure "same-path pair is unclassified: $relativePath"
    }
  } elseif (($userOnly -notcontains $relativePath) -and ($overridePaths -notcontains $relativePath)) {
    Add-Failure "overlay-only file is neither declared user_only nor an allowed private override: $relativePath"
  }
}

foreach ($relativePath in $shared) {
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath) -PathType Leaf)) {
    Add-Failure "shared path missing in main runtime: $relativePath"
    continue
  }
  $overlayPath = "packaging/zhiji-user-overlay/$relativePath"
  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $overlayPath) -PathType Leaf)) {
    Add-Failure "shared path missing in overlay: $relativePath"
    continue
  }
  if ((Get-Hash $relativePath) -ne (Get-Hash $overlayPath)) {
    Add-Failure "shared path is not byte-identical: $relativePath"
  }
}

foreach ($item in $override) {
  if ([string]::IsNullOrWhiteSpace([string]$item.path)) {
    Add-Failure 'override entry has empty path'
  }
  if ([string]::IsNullOrWhiteSpace([string]$item.reason)) {
    Add-Failure "override entry has empty reason: $($item.path)"
  }
}

foreach ($relativePath in $userOnly) {
  if (Test-Path -LiteralPath (Join-Path $repoRoot $relativePath) -PathType Leaf) {
    Add-Failure "user_only path also exists in main repository: $relativePath"
  }
}

$manifest = Read-Utf8 'packaging/zhiji-user-manifest.json' | ConvertFrom-Json
$skillSource = 'packaging/zhiji-user-overlay/SKILL.md'
$skillTasks = @($manifest.syncTasks | Where-Object {
  $_.source -eq $skillSource -and $_.target -eq 'SKILL.md' -and $_.kind -eq 'overwriteFile'
})
if ($skillTasks.Count -ne 1) {
  Add-Failure 'user package must export exactly one root SKILL.md compatibility entry'
}

$skillText = Read-Utf8 $skillSource
if ($skillText -notmatch '(?ms)^---\s*\r?\nname:\s*knowing-yourself-zhiji\s*\r?\ndescription:\s*.+?\r?\n---') {
  Add-Failure 'user package SKILL.md must contain WorkBuddy-compatible name and description frontmatter'
}

$trackedFiles = @(git -c core.quotepath=false -C $repoRoot ls-files | ForEach-Object { Normalize-Path $_ })
foreach ($task in $manifest.syncTasks) {
  $source = Join-Path $repoRoot $task.source
  $sourceFiles = @()
  if (Test-Path -LiteralPath $source -PathType Container) {
    $sourceFiles = Get-ChildItem -LiteralPath $source -Recurse -File -Force
  } elseif (Test-Path -LiteralPath $source -PathType Leaf) {
    $sourceFiles = @(Get-Item -LiteralPath $source)
  }

  foreach ($sourceFile in $sourceFiles) {
    $relative = Normalize-Path $sourceFile.FullName.Substring($repoRoot.Length + 1)
    if ($trackedFiles -notcontains $relative) {
      Add-Failure "manifest source is not tracked by the main repository: $relative"
    }
  }
}

foreach ($task in $manifest.syncTasks) {
  $source = Join-Path $repoRoot $task.source
  $target = Join-Path (Join-Path $repoRoot 'zhiji-user') $task.target

  if ($task.kind -eq 'mirrorDir') {
    Get-ChildItem -LiteralPath $source -Recurse -File -Force | ForEach-Object {
      $relative = $_.FullName.Substring($source.Length + 1)
      $targetFile = Join-Path $target $relative
      if (-not (Test-Path -LiteralPath $targetFile -PathType Leaf)) {
        Add-Failure "generated user package missing managed file: $($task.target)/$relative"
      } elseif ((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash -ne
                (Get-FileHash -LiteralPath $targetFile -Algorithm SHA256).Hash) {
        Add-Failure "generated user package drift: $($task.target)/$relative"
      }
    }
  } elseif ($task.kind -eq 'overwriteFile') {
    if (-not (Test-Path -LiteralPath $target -PathType Leaf)) {
      Add-Failure "generated user package missing managed file: $($task.target)"
    } elseif ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ne
              (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash) {
      Add-Failure "generated user package drift: $($task.target)"
    }
  }
}

if ($RequireCleanUserRepo) {
  $userStatus = @(git -C (Join-Path $repoRoot 'zhiji-user') status --short)
  if ($userStatus.Count -gt 0) {
    Add-Failure "zhiji-user repository has uncommitted release changes: $($userStatus -join '; ')"
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: distribution boundary checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: distribution boundary checks' -ForegroundColor Green
exit 0
