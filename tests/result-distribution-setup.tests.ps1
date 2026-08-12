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

function Assert-SameFile {
  param([string]$ExpectedRelativePath, [string]$ActualRelativePath)
  $expected = Join-Path $repoRoot $ExpectedRelativePath
  $actual = Join-Path $repoRoot $ActualRelativePath
  if (-not (Test-Path -LiteralPath $expected -PathType Leaf) -or
      -not (Test-Path -LiteralPath $actual -PathType Leaf)) {
    Add-Failure "cannot compare missing files: $ExpectedRelativePath -> $ActualRelativePath"
    return
  }
  if ((Get-FileHash -LiteralPath $expected -Algorithm SHA256).Hash -ne
      (Get-FileHash -LiteralPath $actual -Algorithm SHA256).Hash) {
    Add-Failure "setup guide drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

$mainGuide = 'docs/result-distribution-setup.md'
$overlayGuide = 'packaging/zhiji-user-overlay/docs/result-distribution-setup.md'

foreach ($path in @($mainGuide, $overlayGuide)) {
  Assert-Contains $path @(
    '## 用户检查清单',
    '## 隐私与凭证边界',
    '默认关闭',
    '本次生成请求中直接说“仅本地”',
    '同时跳过飞书和滴答',
    '不写入永久标记',
    'cli_missing',
    'app_not_configured',
    'bot_ready',
    'folder_inaccessible',
    'ready',
    'mcp_missing',
    'wrong_region',
    'auth_required',
    'create_capability_ambiguous',
    'npx @larksuite/cli@latest install',
    'lark-cli config init --new',
    'lark-cli auth status',
    'application identity',
    '--as bot',
    '日常导入不要求每次重新执行用户授权',
    '只有 `permission_grant.status` 为 `skipped` 或 `failed`，或专用用户实际不可见时',
    '不得重新导入同一文件',
    'lark-cli auth login --domain docs --domain drive',
    'lark-cli drive +create-folder --name "知己" --as bot',
    'permission_grant.status = granted',
    'console_url',
    '--dry-run',
    '一次性脱敏 Markdown',
    'dida365',
    'ticktick',
    '账号区域对应的官方 MCP',
    '官方授权页面',
    '恰好一个 create-task',
    '一次性测试任务',
    '任务标题、截止时间和目标清单',
    '`project_id`',
    '正式分发不再查询清单',
    'offline_end_to_end_acceptance',
    'official_mcp_smoke_test',
    'tests_pass_formal_use',
    '每日反馈自动创建',
    '周复盘和月复盘',
    '最终整组',
    '主题思考',
    '完成判断只读取后续日志',
    '不读取任务',
    '"enabled": false',
    '## 回滚与停用',
    '保留状态文件',
    '不删除远端资源',
    '原有本地报告流程不变',
    '不要把 App Secret、access token 或 MCP token 粘贴到聊天、命令参数或项目文件'
  )
  Assert-NotContains $path @(
    '--app-secret',
    '--access-token',
    '--mcp-token',
    '.env',
    'list-tasks',
    'get-task',
    'search-tasks',
    'complete-task'
    '核对返回的标题、描述、清单'
  )
}

Assert-SameFile $mainGuide $overlayGuide

Assert-Contains 'README.md' @(
  'docs/result-distribution-setup.md',
  '结果分发',
  '默认关闭',
  '仅本地'
)
Assert-Contains 'packaging/zhiji-user-overlay/README.md' @(
  'docs/result-distribution-setup.md',
  '结果分发',
  '默认关闭',
  '仅本地'
)

if ($failures.Count -gt 0) {
  Write-Host "FAIL: result distribution setup checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: result distribution setup checks' -ForegroundColor Green
exit 0
