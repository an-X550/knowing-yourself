export const meta = {
  name: 'weekly-review',
  description: 'Process one week of journals through 3 core perspectives and synthesize into ONE Chinese report',
  phases: [
    { title: 'Analyze', detail: '3 core perspective agents in parallel' },
    { title: 'Synthesize', detail: 'Cross-perspective synthesis into simplified 复盘六问 report' },
  ],
}

var week = args.week

// ── 周度固定使用3个核心生活视角 ──────────────────────
// 周志 = 小的月志，复用复盘六问框架，只做减法
var PERSPECTIVES = [
  { key: 'chronicle',  name: '实际发生的事', desc: '本周发生了什么？（关键事件、时间线）' },
  { key: 'coach',      name: '目标与时间',   desc: '目标完成得怎样？时间都去哪了？' },
  { key: 'therapist',  name: '情绪与心理',   desc: '本周情绪状态如何？有什么心理模式？' },
]

phase('Analyze')

var agentTasks = PERSPECTIVES.map(function(p) {
  return function() {
    return agent('Process week ' + week + ' as ' + p.key, {
      label: p.name,
      phase: 'Analyze',
      agentType: 'monthly-processor',
    })
  }
})

var analyses = await parallel(agentTasks)

var successful = analyses.filter(Boolean)
log(successful.length + '/' + PERSPECTIVES.length + ' 个视角分析完成（' + week + '）')

if (successful.length < 2) {
  log('ERROR: 完成视角不足2个，无法综合。')
  return { error: 'Insufficient perspectives', count: successful.length }
}

// 组合分析结果传给综合引擎
var combinedAnalyses = ''
for (var i = 0; i < PERSPECTIVES.length; i++) {
  if (analyses[i]) {
    combinedAnalyses += '\n\n======= ' + PERSPECTIVES[i].key + ' ANALYSIS =======\n\n'
    combinedAnalyses += analyses[i]
  }
}

phase('Synthesize')

var synthResult = await agent(
  'Synthesize week ' + week + '。\n\n下面是' + successful.length + '个视角的分析结果。请综合这些分析，直接阅读日志原文补充细节，写出唯一一份中文周度复盘报告（复盘/每周复盘/' + week + '.md）。\n\n**重要**：报告最前面必须包含「## 聊天摘要」区块（≤150字，3个关键发现+1个调整建议），用于在聊天中即时展示。不要创建任何中间文件。\n\n' + combinedAnalyses,
  { label: '周度综合', phase: 'Synthesize', agentType: 'weekly-synthesis' }
)

// 提取聊天摘要并输出到聊天（带质量门槛）
if (synthResult && typeof synthResult === 'string') {
  var chatMatch = synthResult.match(/## 聊天摘要\n\n([\s\S]*?)(?=\n---\n\[聊天摘要结束\])/)
  var summaryText = chatMatch ? chatMatch[1].trim() : ''

  // 质量校验（禁用词权威来源：docs/analysis-standards.md 五 + .claude/shared/banned-phrases.json）
  var bannedPhrases = ['有波动', '总体还行', '有好有坏', '表现不错', '还可以', '情绪稳定', '整体良好', '继续努力', '保持下去', '有待提高', '需要改进', '要加强', '多注意', '总体不错', '还可以吧', '还行吧']
  var hasBanned = false
  for (var i = 0; i < bannedPhrases.length; i++) {
    if (summaryText.indexOf(bannedPhrases[i]) !== -1) { hasBanned = true; break }
  }
  var tooShort = summaryText.length < 50
  var tooVague = (summaryText.match(/具体/g) || []).length === 0 && (summaryText.match(/\d+/g) || []).length === 0

  if (summaryText && !tooShort && !hasBanned && !tooVague) {
    log('📊 周度复盘完成：' + week + '（' + successful.length + ' 视角）\n（日期范围见报告标题）')
    log(summaryText)
    log('→ 完整报告：复盘/每周复盘/' + week + '.md')
  } else {
    var skipReason = tooShort ? '摘要过短(' + summaryText.length + '字)' : hasBanned ? '含模糊词' : '缺具体数据'
    log('周度复盘完成 ' + week + ' — 1 份中文报告（' + successful.length + ' 视角，日期范围见报告标题）[' + skipReason + '，摘要跳过]')
    log('→ 完整报告：复盘/每周复盘/' + week + '.md')
  }
}
return { week: week, perspectives: successful.length, synthesis: 'complete' }
