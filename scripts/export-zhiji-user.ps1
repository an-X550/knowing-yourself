param(
  [string]$TargetRoot,
  [switch]$ForceSeedFiles
)

$repoRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $repoRoot 'packaging/zhiji-user-manifest.json'
$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json

if (-not $TargetRoot) {
  $TargetRoot = Join-Path $repoRoot $manifest.targetRoot
} elseif (-not [System.IO.Path]::IsPathRooted($TargetRoot)) {
  $TargetRoot = Join-Path $repoRoot $TargetRoot
}

if (-not (Test-Path -LiteralPath $TargetRoot)) {
  New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
}

function Ensure-ParentDirectory {
  param([string]$Path)

  $parent = Split-Path -Parent $Path
  if ($parent -and -not (Test-Path -LiteralPath $parent)) {
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
  }
}

$report = New-Object System.Collections.Generic.List[string]

foreach ($task in $manifest.syncTasks) {
  $source = Join-Path $repoRoot $task.source
  $target = Join-Path $TargetRoot $task.target

  if (-not (Test-Path -LiteralPath $source)) {
    throw "Sync source not found: $source"
  }

  switch ($task.kind) {
    'mirrorDir' {
      if (Test-Path -LiteralPath $target) {
        Remove-Item -LiteralPath $target -Recurse -Force
      }
      Ensure-ParentDirectory -Path $target
      New-Item -ItemType Directory -Force -Path $target | Out-Null
      Get-ChildItem -LiteralPath $source -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $target -Recurse -Force
      }
      $report.Add("mirrorDir  $($task.target)") | Out-Null
    }
    'overwriteFile' {
      Ensure-ParentDirectory -Path $target
      Copy-Item -LiteralPath $source -Destination $target -Force
      $report.Add("overwrite   $($task.target)") | Out-Null
    }
    'seedFile' {
      if ($ForceSeedFiles -or -not (Test-Path -LiteralPath $target)) {
        Ensure-ParentDirectory -Path $target
        Copy-Item -LiteralPath $source -Destination $target -Force
        $report.Add("seed       $($task.target)") | Out-Null
      } else {
        $report.Add("preserve   $($task.target)") | Out-Null
      }
    }
    default {
      throw "Unsupported sync task kind: $($task.kind)"
    }
  }
}

Write-Host "zhiji-user export complete:" -ForegroundColor Green
$report | ForEach-Object { Write-Host "  $_" }
Write-Host "Target: $TargetRoot" -ForegroundColor Cyan
Write-Host "Next: review git status in both repositories before committing." -ForegroundColor Yellow
