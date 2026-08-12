param(
  [ValidateSet("Run", "Preflight")]
  [string]$Mode = "Run",
  [string]$ConfigPath
)

$ErrorActionPreference = "Stop"

function New-ZhijiEntryDecision {
  param(
    [string]$Action,
    $MessageId,
    $JournalText,
    $JournalDate,
    $ReplyText,
    $ErrorCode
  )

  [pscustomobject]@{
    action = $Action
    message_id = $MessageId
    journal_text = $JournalText
    journal_date = $JournalDate
    reply_text = $ReplyText
    error_code = $ErrorCode
  }
}

function ConvertFrom-ZhijiUnixMilliseconds {
  param([Parameter(Mandatory = $true)][string]$Value)

  $milliseconds = 0L
  if (-not [long]::TryParse($Value, [ref]$milliseconds)) {
    return $null
  }

  try {
    $instant = [DateTimeOffset]::FromUnixTimeMilliseconds($milliseconds)
    $chinaTime = [TimeZoneInfo]::ConvertTimeBySystemTimeZoneId($instant, "China Standard Time")
    return $chinaTime.ToString("yyyy-MM-dd")
  } catch {
    return $null
  }
}

function ConvertTo-ZhijiEntryDecision {
  param(
    [Parameter(Mandatory = $true)][pscustomobject]$Event,
    [Parameter(Mandatory = $true)][string]$AllowedOpenId
  )

  $messageId = [string]$Event.message_id
  if ([string]::IsNullOrWhiteSpace($messageId)) {
    return New-ZhijiEntryDecision -Action "reject_event" -ErrorCode "message_id_missing"
  }

  if ([string]$Event.sender_id -cne $AllowedOpenId) {
    return New-ZhijiEntryDecision -Action "reject_sender" -MessageId $messageId -ErrorCode "sender_not_allowed"
  }
  if ([string]$Event.chat_type -cne "p2p") {
    return New-ZhijiEntryDecision -Action "reject_chat" -MessageId $messageId -ErrorCode "chat_not_allowed"
  }
  if ([string]$Event.message_type -cne "text") {
    return New-ZhijiEntryDecision -Action "reject_type" -MessageId $messageId -ErrorCode "message_type_not_supported"
  }

  $content = [string]$Event.content
  if ($content -notmatch '^日志[：:]([\s\S]*)$' -or [string]::IsNullOrWhiteSpace($Matches[1])) {
    return New-ZhijiEntryDecision -Action "usage" -MessageId $messageId -ReplyText "请发送：日志：<当天日志原文>" -ErrorCode "journal_prefix_required"
  }

  $journalDate = ConvertFrom-ZhijiUnixMilliseconds -Value ([string]$Event.create_time)
  if ([string]::IsNullOrWhiteSpace($journalDate)) {
    return New-ZhijiEntryDecision -Action "reject_event" -MessageId $messageId -ErrorCode "create_time_invalid"
  }

  $journalText = $Matches[1].TrimStart([char[]]@("`r", "`n"))
  return New-ZhijiEntryDecision -Action "process" -MessageId $messageId -JournalText $journalText -JournalDate $journalDate
}

if ($MyInvocation.InvocationName -ne ".") {
  throw "Runtime modes are not implemented yet."
}
