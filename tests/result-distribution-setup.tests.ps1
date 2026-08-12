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
Assert-SameFile $overlayGuide 'zhiji-user/docs/result-distribution-setup.md'

foreach ($path in @($mainGuide, $overlayGuide, 'zhiji-user/docs/result-distribution-setup.md')) {
  Assert-Contains $path @(
    '不是解压即用',
    '本地日志、日反馈和复盘仍可正常使用',
    '主项目或维护者环境中的验收结果，不能替代你在自己的电脑和账号上完成首次设置',
    '复盘/.result-distribution-config.json',
    '复制配置示例',
    '完成一次脱敏测试后再打开开关',
    '## 给 AI 的执行契约',
    '每次只要求用户完成一个动作',
    '用户回复“继续”后从暂停点继续',
    '不得要求用户把 App Secret、access token、OAuth token 或 MCP token 发到聊天中',
    'folder_token',
    '本地状态',
    '飞书状态',
    '滴答状态'
  )
}

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
  '仅本地',
  '不是解压即用',
  '主项目中的验收结果不等于你的电脑和账号已经完成授权',
  '复盘/.result-distribution-config.json',
  '## 功能一览：你可以让 AI 做什么',
  '年度回顾',
  '飞书沉淀',
  '滴答行动',
  '普通提醒',
  '## 可选：让 AI 帮你配置飞书和滴答',
  '请为当前知己用户版完成首次检查和可选结果分发配置',
  '我回复“继续”后，从暂停处接着执行',
  '## 必须由你完成的操作',
  'App Secret、access token、OAuth token、MCP token',
  'folder_token',
  'project_id',
  '## 配好后，日常可以直接这样说',
  '本次仅本地，不要同步飞书和滴答',
  '只报告本地、飞书、滴答三项状态'
)
Assert-Contains 'zhiji-user/README.md' @(
  'docs/result-distribution-setup.md',
  '结果分发',
  '默认关闭',
  '仅本地',
  '不是解压即用',
  '主项目中的验收结果不等于你的电脑和账号已经完成授权',
  '复盘/.result-distribution-config.json',
  '## 功能一览：你可以让 AI 做什么',
  '年度回顾',
  '飞书沉淀',
  '滴答行动',
  '普通提醒',
  '## 可选：让 AI 帮你配置飞书和滴答',
  '请为当前知己用户版完成首次检查和可选结果分发配置',
  '我回复“继续”后，从暂停处接着执行',
  '## 必须由你完成的操作',
  'App Secret、access token、OAuth token、MCP token',
  'folder_token',
  'project_id',
  '## 配好后，日常可以直接这样说',
  '本次仅本地，不要同步飞书和滴答',
  '只报告本地、飞书、滴答三项状态'
)

foreach ($path in @('packaging/zhiji-user-overlay/.gitignore', 'zhiji-user/.gitignore')) {
  Assert-Contains $path @(
    '/复盘/.result-distribution-config.json',
    '/复盘/.result-distribution-state.json'
  )
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: result distribution setup checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: result distribution setup checks' -ForegroundColor Green
exit 0
