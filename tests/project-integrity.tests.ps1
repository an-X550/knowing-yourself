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
  if (-not (Test-Path -LiteralPath $path)) {
    Add-Failure "missing file: $RelativePath"
    return ''
  }
  return Get-Content -LiteralPath $path -Raw -Encoding UTF8
}

function Assert-Path {
  param([string]$RelativePath)

  if (-not (Test-Path -LiteralPath (Join-Path $repoRoot $RelativePath))) {
    Add-Failure "missing path: $RelativePath"
  }
}

function Assert-NoAbsoluteWorkspaceLinks {
  param([string]$RelativeRoot)

  $root = Join-Path $repoRoot $RelativeRoot
  Get-ChildItem -LiteralPath $root -Recurse -File -Filter '*.md' | ForEach-Object {
    $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
    if ($content -match '</?[A-Za-z]:/' -or $content -match '[A-Za-z]:\\Users\\') {
      Add-Failure "absolute workspace path leaked into: $($_.FullName.Substring($repoRoot.Length + 1))"
    }
  }
}

function Assert-ManagedExportMatches {
  $manifest = Read-Utf8 'packaging/zhiji-user-manifest.json' | ConvertFrom-Json
  $targetRoot = Join-Path $repoRoot 'zhiji-user'

  foreach ($task in $manifest.syncTasks) {
    $source = Join-Path $repoRoot $task.source
    $target = Join-Path $targetRoot $task.target

    if ($task.kind -eq 'mirrorDir') {
      $sourceFiles = Get-ChildItem -LiteralPath $source -Recurse -File -Force
      foreach ($sourceFile in $sourceFiles) {
        $relative = $sourceFile.FullName.Substring($source.Length + 1)
        $targetFile = Join-Path $target $relative
        if (-not (Test-Path -LiteralPath $targetFile)) {
          Add-Failure "managed export missing: $($task.target)/$relative"
        } elseif ((Get-FileHash -LiteralPath $sourceFile.FullName -Algorithm SHA256).Hash -ne
                  (Get-FileHash -LiteralPath $targetFile -Algorithm SHA256).Hash) {
          Add-Failure "managed export drift: $($task.target)/$relative"
        }
      }
    } elseif ($task.kind -eq 'overwriteFile') {
      if (-not (Test-Path -LiteralPath $target)) {
        Add-Failure "managed export missing: $($task.target)"
      } elseif ((Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash -ne
                (Get-FileHash -LiteralPath $target -Algorithm SHA256).Hash) {
        Add-Failure "managed export drift: $($task.target)"
      }
    }
  }
}

function Assert-ManifestSourcesTracked {
  $manifest = Read-Utf8 'packaging/zhiji-user-manifest.json' | ConvertFrom-Json
  $trackedFiles = @(git -c core.quotepath=false -C $repoRoot ls-files | ForEach-Object { $_.Replace('\', '/') })

  foreach ($task in $manifest.syncTasks) {
    $source = Join-Path $repoRoot $task.source
    $sourceFiles = @()
    if (Test-Path -LiteralPath $source -PathType Container) {
      $sourceFiles = Get-ChildItem -LiteralPath $source -Recurse -File -Force
    } elseif (Test-Path -LiteralPath $source -PathType Leaf) {
      $sourceFiles = @(Get-Item -LiteralPath $source)
    }

    foreach ($sourceFile in $sourceFiles) {
      $relative = $sourceFile.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
      if ($trackedFiles -notcontains $relative) {
        Add-Failure "manifest source is not tracked by the main repository: $relative"
      }
    }
  }
}

$routePositives = @(
  '日志：今天很累，但还是完成了报告',
  '日记：今天完成了报告',
  '记录一下：下午开会时我拒绝了临时加需求',
  '请分析这篇日志：今天拒绝了加班',
  '幸福日志 7.8 开心的事情：按时下班'
)
$routeNegatives = @(
  '如何修改日志分析项目的 README？',
  '请解释什么是日记。',
  '这个函数会记录一下调用次数。'
)

$codexHooks = Read-Utf8 'packaging/zhiji-user-overlay/.codex/hooks.json' | ConvertFrom-Json
$codexLogHook = $codexHooks.hooks.UserPromptSubmit |
  Where-Object { $_.hooks.command -contains 'skill log' } |
  Select-Object -First 1

if (-not $codexLogHook) {
  Add-Failure 'user Codex hooks have no skill log route'
} else {
  foreach ($sample in $routePositives) {
    if (-not [regex]::IsMatch($sample, $codexLogHook.matcher)) {
      Add-Failure "user Codex log hook missed positive sample: $sample"
    }
  }
  foreach ($sample in $routeNegatives) {
    if ([regex]::IsMatch($sample, $codexLogHook.matcher)) {
      Add-Failure "user Codex log hook matched negative sample: $sample"
    }
  }
}

$mainCodexHooks = Read-Utf8 '.codex/hooks.json'
if ($mainCodexHooks -match 'bash\s+-c') {
  Add-Failure 'main Codex Stop hook depends on bash/WSL in the Windows workspace'
}

Assert-NoAbsoluteWorkspaceLinks 'packaging/zhiji-user-overlay'
Assert-Path 'packaging/zhiji-user-overlay/复盘/年度回顾/.gitkeep'
Assert-Path 'zhiji-user/复盘/年度回顾/.gitkeep'

$userReadme = Read-Utf8 'packaging/zhiji-user-overlay/README.md'
$profileReadme = Read-Utf8 'packaging/zhiji-user-overlay/关于我/README.md'
if ($userReadme -match '画像类私有内容默认会被 Git 忽略') {
  Add-Failure 'user README claims tracked profile seed files are ignored by Git'
}
if ($profileReadme -match '运行时私有文件默认已被 Git 忽略') {
  Add-Failure 'profile README claims tracked profile seed files are ignored by Git'
}

Assert-ManagedExportMatches
Assert-ManifestSourcesTracked

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'tests/distribution-boundary.tests.ps1')
if ($LASTEXITCODE -ne 0) {
  Add-Failure 'distribution boundary checks failed'
}

& powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $repoRoot 'tests/quality-baseline.tests.ps1')
if ($LASTEXITCODE -ne 0) {
  Add-Failure 'quality baseline checks failed'
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: project integrity checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: project integrity checks' -ForegroundColor Green
exit 0






