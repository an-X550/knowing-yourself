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
    Add-Failure "shared distribution file drift: $ExpectedRelativePath != $ActualRelativePath"
  }
}

$mainPaths = '.claude/shared/paths.md'
$overlayPaths = 'packaging/zhiji-user-overlay/.claude/shared/paths.md'
$mainContract = '.claude/shared/contracts/result-distribution.md'
$overlayContract = 'packaging/zhiji-user-overlay/.claude/shared/contracts/result-distribution.md'
$mainExample = '.claude/shared/result-distribution-config.example.json'
$overlayExample = 'packaging/zhiji-user-overlay/.claude/shared/result-distribution-config.example.json'
$dailyFixture = 'tests/fixtures/result-distribution/sample-daily-feedback.md'
$weeklyFixture = 'tests/fixtures/result-distribution/sample-weekly-report.md'
$noActionFixture = 'tests/fixtures/result-distribution/sample-no-action-report.md'

foreach ($path in @($mainPaths, $overlayPaths)) {
  Assert-Contains $path @(
    'context.collection_topic',
    'context.collection_attachment',
    'output.result_distribution_config',
    '复盘/.result-distribution-config.json',
    'output.result_distribution_state',
    '复盘/.result-distribution-state.json'
  )
}

foreach ($path in @($mainContract, $overlayContract)) {
  Assert-Contains $path @(
    'output.daily_feedback',
    'output.weekly_report',
    'output.monthly_report',
    'output.project_report',
    'output.yearly_report',
    'output.life_design_report',
    'context.thinking_topic',
    'context.collection_topic',
    'context.collection_attachment',
    '用户在本次生成请求中明确说“仅本地”',
    '本轮不调用飞书或 TickTick',
    '不写入持久化标记、配置或状态',
    '知己/复盘/每日反馈',
    '知己/复盘/每周复盘',
    '知己/复盘/每月复盘',
    '知己/复盘/项目复盘',
    '知己/复盘/年度回顾',
    '知己/复盘/人生设计',
    '知己/关于我/思考',
    '知己/关于我/收藏吃灰库/{topic}',
    'lark-cli drive +upload',
    '不得扫描仓库或电脑寻找待上传文件',
    '用户明确确认',
    'input.*',
    'context.core_profile',
    'context.current',
    'context.verified_patterns',
    'analysis.*',
    '新写入',
    '重新读取',
    '非空',
    '本地已保存',
    'success',
    'failed',
    'skipped_not_configured',
    'skipped_duplicate',
    'skipped_no_action',
    'changed_after_delivery',
    'SHA-256',
    'source_path',
    'written_at',
    'current_sha256',
    'delivered_sha256',
    'last_attempt',
    '跳过或失败只更新 `last_attempt`',
    '不得覆盖任一渠道既有的 `delivered_sha256`',
    'feishu',
    'ticktick',
    '分别',
    '一个渠道失败',
    '另一个渠道',
    '.result-distribution-state.corrupt-YYYYMMDD-HHmmss.json',
    'App Secret',
    'access token',
    'MCP token',
    '凭证存储',
    '先说本地事实',
    '按来源和 TickTick 所处阶段返回',
    '不得宣称本地与外部“整体失败”'
    '直接纯提醒'
    '周期性纯提醒默认直接创建为滴答任务'
    '创建接口成功不等于通知已经送达'
  )
  Assert-NotContains $path @(
    'distribution: local_only',
    '读取滴答任务',
    '读取 TickTick 任务',
    '完成检测',
    '飞书聊天机器人',
    '"sha256": "<SHA-256>",'
  )
}

# Parse the production contract's state example. A single source-level SHA
# cannot preserve each channel's last successful delivery fingerprint.
$contractText = Read-Utf8 $mainContract
$stateMatch = [regex]::Match($contractText, '(?s)```json\s*(\{.*?"sources".*?\})\s*```')
if (-not $stateMatch.Success) {
  Add-Failure 'state model JSON example is missing from the production contract'
} else {
  try {
    $stateExample = $stateMatch.Groups[1].Value | ConvertFrom-Json
    $sourceEntry = @($stateExample.sources.PSObject.Properties)[0].Value
    if (-not $sourceEntry.PSObject.Properties['current_sha256']) {
      Add-Failure 'state example must keep current_sha256 separate from channel delivery fingerprints'
    }
    if ($sourceEntry.PSObject.Properties['sha256']) {
      Add-Failure 'state example must not use one overwriteable source-level sha256 as the delivery fingerprint'
    }
    foreach ($channel in @('feishu', 'ticktick')) {
      $channelState = $sourceEntry.$channel
      if (-not $channelState.PSObject.Properties['delivered_sha256']) {
        Add-Failure "state example missing $channel.delivered_sha256"
      }
      if (-not $channelState.PSObject.Properties['last_attempt'] -or
          -not $channelState.last_attempt.PSObject.Properties['sha256'] -or
          -not $channelState.last_attempt.PSObject.Properties['status']) {
        Add-Failure "state example missing complete $channel.last_attempt"
      }
    }
  } catch {
    Add-Failure "state model JSON example is invalid: $($_.Exception.Message)"
  }
}

Assert-SameFile $mainContract $overlayContract
Assert-SameFile $mainExample $overlayExample

$exampleText = Read-Utf8 $mainExample
if (-not [string]::IsNullOrWhiteSpace($exampleText)) {
  try {
    $example = $exampleText | ConvertFrom-Json
    if ($example.schema_version -ne 1) { Add-Failure 'example config schema_version must be 1' }
    if ($example.enabled -ne $false) { Add-Failure 'example config enabled must default to false' }
    if ($example.feishu.enabled -ne $false) { Add-Failure 'example config feishu.enabled must default to false' }
    if ($example.ticktick.enabled -ne $false) { Add-Failure 'example config ticktick.enabled must default to false' }
    if ($example.ticktick.list_name -ne '知己行动') { Add-Failure 'example config ticktick.list_name must default to 知己行动' }
    if ($example.feishu.folder_token -ne '') { Add-Failure 'example config must not contain a folder token' }
    foreach ($folderKey in @('daily_feedback','weekly_report','monthly_report','project_report','yearly_report','life_design_report','thinking_topic','collection_root')) {
      if (-not $example.feishu.folders.PSObject.Properties[$folderKey]) {
        Add-Failure "example config missing feishu.folders.$folderKey"
      } elseif ($example.feishu.folders.$folderKey -ne '') {
        Add-Failure "example config feishu.folders.$folderKey must default empty"
      }
    }
    foreach ($typeKey in @('collection_topic','collection_attachment')) {
      if (-not $example.result_types.PSObject.Properties[$typeKey]) {
        Add-Failure "example config missing result_types.$typeKey"
      }
    }
    foreach ($typeKey in @('project_report','yearly_report','life_design_report','collection_topic','collection_attachment')) {
      if ($example.result_types.$typeKey.ticktick -ne $false) {
        Add-Failure "example config must keep unsupported TickTick source disabled: $typeKey"
      }
    }
    if (@('dida365', 'ticktick') -notcontains $example.ticktick.region) {
      Add-Failure 'example config ticktick.region must be dida365 or ticktick'
    }
    foreach ($channel in @($example.result_types.psobject.Properties.Value)) {
      foreach ($switchValue in @($channel.psobject.Properties.Value)) {
        if ($switchValue -ne $false) { Add-Failure 'every result-type channel switch must default to false' }
      }
    }
  } catch {
    Add-Failure "example config is not valid JSON: $($_.Exception.Message)"
  }
}

$boundary = Read-Utf8 'packaging/zhiji-user-boundaries.json' | ConvertFrom-Json
foreach ($requiredShared in @($mainContract, $mainExample)) {
  if (@($boundary.shared) -notcontains $requiredShared) {
    Add-Failure "shared package boundary missing: $requiredShared"
  }
}

foreach ($runtimePath in @('复盘/.result-distribution-config.json', '复盘/.result-distribution-state.json')) {
  git -C $repoRoot check-ignore --quiet -- $runtimePath
  if ($LASTEXITCODE -ne 0) { Add-Failure "runtime distribution file is not ignored: $runtimePath" }
}

# Feishu adapter: assert the offline command contract, not a live CLI call.
foreach ($path in @($mainContract, $overlayContract)) {
  Assert-Contains $path @(
    'lark-cli --version',
    'lark-cli auth status',
    'application identity',
    'lark-cli drive +import',
    '--file "<workspace-relative-md-path>"',
    '--type docx',
    '--folder-token "<folder-token>"',
    '--name "<document-title>"',
    '--as bot',
    'argv',
    '同一 folder_token 串行',
    '232140101',
    '232140100',
    '233523001',
    '最多重试 3 次',
    'permission',
    'not_found',
    'missing_scope',
    '不重试',
    'ready=false',
    'ticket',
    'next_command',
    '只执行 CLI 返回的 next_command',
    'document_token',
    'url',
    'attempted_at',
    'error_code',
    '知己·每日反馈·YYYY-MM-DD',
    '知己·周度复盘·YYYY-Www',
    '知己·月度复盘·YYYY-MM',
    '知己·{type}·{local title}',
    '文件系统非法字符',
    '控制字符',
    '不得自动转移 owner'
  )
  Assert-Contains $path @(
    '仓库 cwd',
    '拒绝逃出 cwd 的 `..`'
  )
  Assert-NotContains $path @(
    '[System.IO.Path]::GetFullPath()',
    '<absolute-md-path>'
  )
}

$fixturePath = Join-Path $repoRoot $dailyFixture
if (-not (Test-Path -LiteralPath $fixturePath -PathType Leaf)) {
  Add-Failure "missing file: $dailyFixture"
} else {
  $workspaceRelativeFixturePath = $dailyFixture.Replace('\', '/')
  if ([System.IO.Path]::IsPathRooted($workspaceRelativeFixturePath)) {
    Add-Failure 'Feishu fixture path must remain relative to the repository cwd'
  }
  if (@($workspaceRelativeFixturePath -split '[\\/]') -contains '..') {
    Add-Failure 'Feishu fixture path must not escape the repository cwd'
  }
  $templateMatch = [regex]::Match($contractText, '(?m)^lark-cli drive \+import .+$')
  if (-not $templateMatch.Success) {
    Add-Failure 'production Feishu command template is missing'
  } else {
    $constructedCommand = $templateMatch.Value.TrimEnd("`r").
      Replace('<workspace-relative-md-path>', $workspaceRelativeFixturePath).
      Replace('<folder-token>', 'folder-token-placeholder').
      Replace('<document-title>', '知己·每日反馈·2026-08-11')
    $argvMatch = [regex]::Match(
      $constructedCommand,
      '^lark-cli drive \+import --file "(?<file>[^"]+)" --type (?<type>\S+) --folder-token "(?<folder>[^"]+)" --name "(?<name>[^"]+)" --as (?<identity>\S+)$'
    )
    if (-not $argvMatch.Success -or
        $argvMatch.Groups['file'].Value -ne $workspaceRelativeFixturePath -or
        $argvMatch.Groups['type'].Value -ne 'docx' -or
        $argvMatch.Groups['folder'].Value -ne 'folder-token-placeholder' -or
        $argvMatch.Groups['name'].Value -ne '知己·每日反馈·2026-08-11' -or
        $argvMatch.Groups['identity'].Value -ne 'bot') {
      Add-Failure 'production Feishu command template constructs incorrect argv or quoting'
    }
    if ($constructedCommand -match '(App Secret|access token|MCP token)') {
      Add-Failure 'production Feishu command contains a forbidden secret field'
    }
  }
}

# TickTick adapter: source extraction, due-date rules, and create-only MCP boundary.
foreach ($path in @($mainContract, $overlayContract)) {
  Assert-Contains $path @(
    'dida365',
    '中国区官方 MCP',
    'ticktick',
    '国际区官方 MCP',
    '恰好一个',
    '已授权',
    'create-task',
    'list/get/search/update/complete',
    '只有四类来源可以产生滴答任务',
    '`output.daily_feedback`',
    '`output.weekly_report`',
    '`output.monthly_report`',
    '`context.thinking_topic`',
    '只传任务标题、截止日期或时间以及目标清单',
    '`project_id`',
    '正式分发只使用已保存的 `project_id`',
    '不传 description',
    '⚡ 明天试试',
    '行动：',
    '最多 1 项',
    '## 六、下周规划',
    '## 六、下月规划',
    '周/月同一自然日合计默认最多 3 项',
    '0. 当前行动卡',
    'skipped_no_action',
    '原子、可控、可检查',
    '本次成功生成后的下一本地日历日',
    '下一 ISO 周的周日',
    '下一自然月末',
    '报告中的明确日期优先',
    '确认后的第 7 个本地日历日',
    '不自动顺延',
    '宽泛方向',
    '分析陈述',
    '升级提醒',
    '不得发明',
    'normalized_title + exact_due_date_or_time',
    '飞书继续使用 `source_path + SHA-256 + channel`',
    'TickTick 不使用报告 SHA-256 阻断新候选',
    '等待确认不调用 create-task，也不写 TickTick `last_attempt`',
    '摘要按来源和 TickTick 所处阶段返回',
    '完成判断只读取后续日志',
    'task_id',
    '每项任务分别记录'
  )
  Assert-NotContains $path @(
    '| 项目复盘 | 后续规划',
    '| 年度 / 人生设计 |',
    'source_path + normalized_title',
    '逐项传入 `action_title`、description'
    '返回以 `本地已保存：<source_path>` 开头的本地优先三行聊天摘要'
  )
}

$dailyText = Read-Utf8 $dailyFixture
if (-not [string]::IsNullOrWhiteSpace($dailyText)) {
  $dailyActions = [regex]::Matches($dailyText, '(?m)^行动：(?<title>\S.*)$')
  if ($dailyActions.Count -ne 1) { Add-Failure "daily extraction must return exactly 1 action, got $($dailyActions.Count)" }
  if ($dailyActions.Count -gt 0 -and $dailyActions[0].Groups['title'].Value.TrimEnd("`r") -ne '打开示例文件并检查第一行标题。') {
    Add-Failure 'daily extraction returned the wrong production fixture action'
  }
}

$weeklyText = Read-Utf8 $weeklyFixture
if (-not [string]::IsNullOrWhiteSpace($weeklyText)) {
  $planningSection = [regex]::Match($weeklyText, '(?ms)^## 六、下周规划\s*(?<body>.*?)(?=^## |\z)')
  $weeklyActions = if ($planningSection.Success) {
    [regex]::Matches($planningSection.Groups['body'].Value, '(?m)^- 行动：(?<title>.+?)；检查：(?<check>.+)$')
  } else { @() }
  if ($weeklyActions.Count -ne 2 -or $weeklyActions.Count -gt 3) {
    Add-Failure "weekly extraction must return 2 actions within the 3-item cap, got $($weeklyActions.Count)"
  }
  foreach ($action in $weeklyActions) {
    if ([string]::IsNullOrWhiteSpace($action.Groups['title'].Value) -or
        [string]::IsNullOrWhiteSpace($action.Groups['check'].Value)) {
      Add-Failure 'weekly extraction must preserve an atomic title and check condition'
    }
  }
  if ($weeklyActions.Value -match '方向：' -or $weeklyText -notmatch '(?m)^- 方向：') {
    Add-Failure 'weekly extraction must reject the broad direction rather than turn it into a task'
  }
}

$noActionText = Read-Utf8 $noActionFixture
if (-not [string]::IsNullOrWhiteSpace($noActionText)) {
  $noActionPlanning = [regex]::Match($noActionText, '(?ms)^## 六、下周规划\s*(?<body>.*?)(?=^## |\z)')
  $noActionCandidates = if ($noActionPlanning.Success) {
    [regex]::Matches($noActionPlanning.Groups['body'].Value, '(?m)^- 行动：(?<title>.+?)(?:；检查：(?<check>.+))?$')
  } else { @() }
  if ($noActionCandidates.Count -ne 0) {
    Add-Failure 'no-action fixture must contain zero action candidates'
  }
  if ($noActionText -notmatch '方向：') { Add-Failure 'no-action fixture must exercise broad-direction rejection' }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: result distribution contract checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host 'PASS: result distribution contract checks' -ForegroundColor Green
exit 0
