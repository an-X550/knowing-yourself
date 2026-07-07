export const meta = {
  name: 'yearly-review',
  description: 'Synthesize 12 monthly reports into an annual growth review',
  phases: [
    { title: 'Gather', detail: 'Read monthly reports' },
    { title: 'Synthesize', detail: 'Generate annual synthesis' },
  ],
}

var year = args.year

phase('Gather')
log('Reading monthly reports for ' + year + '...')

phase('Synthesize')

var result = await agent(
  'Synthesize yearly ' + year + '。**重要**：报告最前面必须包含「## 聊天摘要」区块（≤250字，3个关键发现+1个新年建议），用于在聊天中即时展示。',
  { label: 'synthesis', phase: 'Synthesize', agentType: 'yearly-synthesis' }
)

// 提取聊天摘要并输出到聊天（带质量门槛）
if (result && typeof result === 'string') {
  var chatMatch = result.match(/## 聊天摘要\n\n([\s\S]*?)(?=\n---\n\[聊天摘要结束\])/)
  var summaryText = chatMatch ? chatMatch[1].trim() : ''

  // 质量校验（禁用词权威来源：docs/analysis-standards.md 五 + .claude/shared/banned-phrases.json）
  // 年度额外禁用词来自 banned-phrases.json 的 yearly_extra 字段
  var bannedPhrases = ['有波动', '总体还行', '有好有坏', '表现不错', '还可以', '情绪稳定', '整体良好', '继续努力', '保持下去', '有待提高', '需要改进', '要加强', '多注意', '总体不错', '还可以吧', '还行吧', '这一年有成长', '进步很大', '收获很多']
  var hasBanned = false
  for (var i = 0; i < bannedPhrases.length; i++) {
    if (summaryText.indexOf(bannedPhrases[i]) !== -1) { hasBanned = true; break }
  }
  var tooShort = summaryText.length < 50
  var tooVague = (summaryText.match(/具体/g) || []).length === 0 && (summaryText.match(/\d+/g) || []).length === 0

  if (summaryText && !tooShort && !hasBanned && !tooVague) {
    log('📊 年度回顾完成：' + year + '\n')
    log(summaryText)
    log('→ 完整报告：复盘/年度回顾/' + year + '-annual-review.md')
  } else {
    var skipReason = tooShort ? '摘要过短(' + summaryText.length + '字)' : hasBanned ? '含模糊词' : '缺具体数据'
    log('年度回顾完成 ' + year + ' [' + skipReason + '，摘要跳过]')
    log('→ 完整报告：复盘/年度回顾/' + year + '-annual-review.md')
  }
}
return { year: year, status: 'complete' }
