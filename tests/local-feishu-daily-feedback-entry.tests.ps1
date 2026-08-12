$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$workflowPath = Join-Path $repoRoot ".claude/workflows/local-feishu-daily-feedback.ps1"
$failures = New-Object System.Collections.Generic.List[string]

function Add-Failure {
  param([string]$Message)
  $failures.Add($Message) | Out-Null
}

function Assert-Equal {
  param($Actual, $Expected, [string]$Message)
  if ($Actual -cne $Expected) {
    Add-Failure "$Message (expected=$Expected actual=$Actual)"
  }
}

function Assert-Null {
  param($Actual, [string]$Message)
  if ($null -ne $Actual) {
    Add-Failure "$Message (actual=$Actual)"
  }
}

if (-not (Test-Path -LiteralPath $workflowPath -PathType Leaf)) {
  Add-Failure "missing workflow: .claude/workflows/local-feishu-daily-feedback.ps1"
} else {
  . $workflowPath
}

if (Get-Command ConvertTo-ZhijiEntryDecision -ErrorAction SilentlyContinue) {
  $valid = [pscustomobject]@{
    message_id = "om_valid"
    sender_id = "ou_owner"
    chat_type = "p2p"
    message_type = "text"
    content = "日志：第一行`n第二行"
    create_time = "1786500000000"
  }
  $decision = ConvertTo-ZhijiEntryDecision -Event $valid -AllowedOpenId "ou_owner"
  Assert-Equal $decision.action "process" "owner p2p journal must process"
  Assert-Equal $decision.message_id "om_valid" "message id must be preserved"
  Assert-Equal $decision.journal_text "第一行`n第二行" "journal text must remain unchanged"
  Assert-Equal $decision.journal_date "2026-08-12" "message time must use Asia/Shanghai date"
  Assert-Null $decision.error_code "valid journal must not have an error"

  $halfWidth = [pscustomobject]@{
    message_id = "om_half"
    sender_id = "ou_owner"
    chat_type = "p2p"
    message_type = "text"
    content = "日志:原文"
    create_time = "1786500000000"
  }
  Assert-Equal (ConvertTo-ZhijiEntryDecision -Event $halfWidth -AllowedOpenId "ou_owner").journal_text "原文" "half-width colon must be accepted"

  $wrongSender = $valid.PSObject.Copy()
  $wrongSender.sender_id = "ou_other"
  Assert-Equal (ConvertTo-ZhijiEntryDecision -Event $wrongSender -AllowedOpenId "ou_owner").action "reject_sender" "other sender must be rejected"

  $group = $valid.PSObject.Copy()
  $group.chat_type = "group"
  Assert-Equal (ConvertTo-ZhijiEntryDecision -Event $group -AllowedOpenId "ou_owner").action "reject_chat" "group chat must be rejected"

  $image = $valid.PSObject.Copy()
  $image.message_type = "image"
  Assert-Equal (ConvertTo-ZhijiEntryDecision -Event $image -AllowedOpenId "ou_owner").action "reject_type" "non-text message must be rejected"

  $empty = $valid.PSObject.Copy()
  $empty.content = "日志：   `n"
  $usage = ConvertTo-ZhijiEntryDecision -Event $empty -AllowedOpenId "ou_owner"
  Assert-Equal $usage.action "usage" "empty journal must return usage"
  Assert-Equal $usage.reply_text "请发送：日志：<当天日志原文>" "usage reply must be stable"

  $plain = $valid.PSObject.Copy()
  $plain.content = "今天过得不错"
  Assert-Equal (ConvertTo-ZhijiEntryDecision -Event $plain -AllowedOpenId "ou_owner").action "usage" "plain text must not become a journal"

  $badTime = $valid.PSObject.Copy()
  $badTime.create_time = "not-a-time"
  Assert-Equal (ConvertTo-ZhijiEntryDecision -Event $badTime -AllowedOpenId "ou_owner").action "reject_event" "invalid event time must be rejected"
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: local Feishu daily feedback entry checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host "PASS: local Feishu daily feedback entry checks" -ForegroundColor Green
