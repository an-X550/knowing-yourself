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

function Assert-True {
  param([bool]$Actual, [string]$Message)
  if (-not $Actual) {
    Add-Failure $Message
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

  if (Get-Command Invoke-ZhijiEntryDecision -ErrorAction SilentlyContinue) {
    $tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("zhiji-entry-test-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempRoot | Out-Null
    try {
      $config = [pscustomobject]@{
        state_path = Join-Path $tempRoot "state.json"
        repo_root = $repoRoot
        codex_path = "codex-test"
        lark_cli_path = "lark-test"
      }
      $calls = [ordered]@{ codex = 0; reply = 0; last_reply = $null }
      $codex = {
        param($Prompt, $JournalText, $RepoRoot, $CodexPath)
        $calls.codex++
        Assert-True ($Prompt -match "2026-08-12") "Codex prompt must contain the confirmed date"
        Assert-Equal $JournalText "第一行`n第二行" "Codex stdin must receive only the journal text"
        Assert-Equal $RepoRoot $repoRoot "Codex must run from the repository root"
        [pscustomobject]@{ exit_code = 0; output = "反馈正文"; error_code = $null }
      }
      $reply = {
        param($MessageId, $Text, $LarkCliPath, $Suffix)
        $calls.reply++
        $calls.last_reply = $Text
        [pscustomobject]@{ exit_code = 0; error_code = $null }
      }

      $result = Invoke-ZhijiEntryDecision -Decision $decision -Config $config -CodexInvoker $codex -ReplyInvoker $reply
      Assert-Equal $result.status "success" "first request must succeed"
      Assert-Equal $calls.codex 1 "Codex must run once"
      Assert-Equal $calls.reply 1 "successful analysis must reply once"
      Assert-Equal $calls.last_reply "反馈正文" "reply must use the final Codex output"

      $state = Get-Content -LiteralPath $config.state_path -Raw -Encoding UTF8 | ConvertFrom-Json
      Assert-Equal $state.schema_version 1 "state schema must be version 1"
      Assert-Equal $state.messages.om_valid.status "success" "successful message must be persisted"
      Assert-Equal $state.messages.om_valid.journal_date "2026-08-12" "state may retain the confirmed date"
      Assert-True (-not ($state.messages.om_valid.PSObject.Properties.Name -contains "journal_text")) "state must not store journal text"
      Assert-True (-not ($state.messages.om_valid.PSObject.Properties.Name -contains "feedback")) "state must not store feedback text"

      $duplicate = Invoke-ZhijiEntryDecision -Decision $decision -Config $config -CodexInvoker $codex -ReplyInvoker $reply
      Assert-Equal $duplicate.status "success" "successful duplicate must remain successful"
      Assert-Equal $duplicate.error_code "duplicate_success" "successful duplicate must be classified"
      Assert-Equal $calls.codex 1 "successful duplicate must not rerun Codex"
      Assert-Equal $calls.reply 2 "successful duplicate must receive one idempotent acknowledgement"

      $failedDecision = $decision.PSObject.Copy()
      $failedDecision.message_id = "om_codex_failed"
      $failedCodex = {
        param($Prompt, $JournalText, $RepoRoot, $CodexPath)
        $calls.codex++
        [pscustomobject]@{ exit_code = 1; output = $null; error_code = "runtime_unavailable" }
      }
      $failed = Invoke-ZhijiEntryDecision -Decision $failedDecision -Config $config -CodexInvoker $failedCodex -ReplyInvoker $reply
      Assert-Equal $failed.status "failed" "Codex failure must fail the request"
      Assert-Equal $failed.error_code "runtime_unavailable" "Codex failure must retain a normalized code"
      Assert-Equal $calls.reply 3 "Codex failure must send one concise failure reply"

      $replyFailureDecision = $decision.PSObject.Copy()
      $replyFailureDecision.message_id = "om_reply_failed"
      $replyFailureCodexCalls = 0
      $replyFailureCodex = {
        param($Prompt, $JournalText, $RepoRoot, $CodexPath)
        $script:replyFailureCodexCalls++
        [pscustomobject]@{ exit_code = 0; output = "已生成但未回复"; error_code = $null }
      }
      $failedReply = {
        param($MessageId, $Text, $LarkCliPath, $Suffix)
        [pscustomobject]@{ exit_code = 1; error_code = "reply_failed" }
      }
      $replyFailedResult = Invoke-ZhijiEntryDecision -Decision $replyFailureDecision -Config $config -CodexInvoker $replyFailureCodex -ReplyInvoker $failedReply
      Assert-Equal $replyFailedResult.status "failed" "reply failure must be recorded"
      Assert-Equal $replyFailedResult.error_code "reply_failed" "reply failure must be classified"
      $replyFailureRepeat = Invoke-ZhijiEntryDecision -Decision $replyFailureDecision -Config $config -CodexInvoker $replyFailureCodex -ReplyInvoker $reply
      Assert-Equal $replyFailureRepeat.error_code "duplicate_reply_failed" "reply-failed duplicate must not reanalyze"
      Assert-Equal $script:replyFailureCodexCalls 1 "reply-failed duplicate must not rerun Codex"
    } finally {
      Remove-Item -LiteralPath $tempRoot -Recurse -Force
    }
  } else {
    Add-Failure "missing function: Invoke-ZhijiEntryDecision"
  }
}

if ($failures.Count -gt 0) {
  Write-Host "FAIL: local Feishu daily feedback entry checks ($($failures.Count))" -ForegroundColor Red
  $failures | ForEach-Object { Write-Host "- $_" -ForegroundColor Red }
  exit 1
}

Write-Host "PASS: local Feishu daily feedback entry checks" -ForegroundColor Green
