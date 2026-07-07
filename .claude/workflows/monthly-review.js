export const meta = {
  name: 'monthly-review',
  description: 'Process month of journals through selected perspectives and synthesize into ONE Chinese report',
  phases: [
    { title: 'Select', detail: 'Determine active perspectives' },
    { title: 'Analyze', detail: 'Perspective agents in parallel' },
    { title: 'Synthesize', detail: 'Cross-perspective synthesis' },
  ],
}

// ── 视角注册表 ──────────────────────────────────────────
// 每个视角回答用户一个具体的生活问题
var PERSPECTIVE_REGISTRY = [
  { key: 'chronicle',         name: '实际发生的事', desc: '这个月实际发生了什么？（关键事件、时间线）',               category: 'core',        number: 1 },
  { key: 'coach',             name: '目标与时间',   desc: '目标完成得怎样？时间都去哪了？',                         category: 'core',        number: 2 },
  { key: 'therapist',         name: '情绪与心理',   desc: '这个月的情绪状态如何？有什么心理模式？',                 category: 'core',        number: 3 },
  { key: 'strengths',         name: '优势与成就',   desc: '这个月做对了什么？有哪些被忽略的优势？',                 category: 'extended',    number: 4 },
  { key: 'relationships',     name: '人际与关系',   desc: '和重要的人相处得怎样？社交活跃度如何？',                 category: 'extended',    number: 5 },
  { key: 'values-meaning',    name: '意义与价值',   desc: '这个月过得有意义吗？做的事和价值观一致吗？',             category: 'extended',    number: 6 },
  { key: 'growth-dimensions', name: '成长平衡度',   desc: '六个成长维度是否均衡？哪个维度被忽视了？',               category: 'methodology', number: 7 },
  { key: 'journal-quality',   name: '日志写作力',   desc: '日志写作本身有进步吗？（方法论评分）',                   category: 'methodology', number: 8 },
  { key: 'review-coach',      name: '复盘方法论',   desc: '自我复盘的能力有提升吗？（方法论点评）',                 category: 'methodology', number: 9 },
]

// ── 模式定义 ────────────────────────────────────────────
var MODES = {
  fast:     { categories: ['core'],                    timeEstimate: '2-4分钟' },
  standard: { categories: ['core', 'extended'],        timeEstimate: '5-8分钟' },
  full:     { categories: ['core', 'extended', 'methodology'], timeEstimate: '10-18分钟' },
}

// ── 辅助函数 ────────────────────────────────────────────
function resolvePerspectives(mode, perspectiveKeys) {
  // 自定义视角优先
  if (perspectiveKeys && perspectiveKeys.length > 0) {
    var selected = []
    for (var i = 0; i < perspectiveKeys.length; i++) {
      var found = PERSPECTIVE_REGISTRY.filter(function(p) { return p.key === perspectiveKeys[i] })[0]
      if (found) selected.push(found)
    }
    if (selected.length > 0) return selected
  }

  // 模式选择
  var modeConfig = MODES[mode] || MODES['standard']
  var categories = modeConfig.categories
  return PERSPECTIVE_REGISTRY.filter(function(p) {
    return categories.indexOf(p.category) !== -1
  })
}

function estimateTime(perspectives) {
  // 线性估算：每个视角约 0.7-1.5 分钟，综合约 1-3 分钟
  var count = perspectives.length
  var min = Math.round((count * 0.7 + 1))
  var max = Math.round((count * 1.5 + 3))
  return min + '-' + max + '分钟'
}

// ── 主流程 ──────────────────────────────────────────────
var month = args.month
var mode = args.mode || 'standard'
var perspectiveKeys = args.perspectives || []

phase('Select')

var activePerspectives = resolvePerspectives(mode, perspectiveKeys)
var timeEstimate = estimateTime(activePerspectives)
var activeKeys = activePerspectives.map(function(p) { return p.key })

log('月度复盘 ' + month + ' — ' + activePerspectives.length + ' 个视角（预计 ' + timeEstimate + '）')
log('已选视角：' + activePerspectives.map(function(p) { return '[' + p.number + '] ' + p.name }).join('、'))

// 边界情况提示
var coreCount = activePerspectives.filter(function(p) { return p.category === 'core' }).length
if (coreCount === 0) {
  log('⚠️ 未选择任何核心视角（实际发生的事/目标与时间/情绪与心理），可能影响报告完整性')
}
if (activePerspectives.length === 1) {
  log('⚠️ 仅选择单一视角，无法交叉验证，报告深度受限')
}

phase('Analyze')

// 构建代理调用列表
var agentTasks = activePerspectives.map(function(p) {
  return function() {
    return agent('Process ' + month + ' as ' + p.key, {
      label: p.name,
      phase: 'Analyze',
      agentType: 'monthly-processor',
    })
  }
})

var analyses = await parallel(agentTasks)

var successful = analyses.filter(Boolean)
log(successful.length + '/' + activePerspectives.length + ' 个视角分析完成')

if (successful.length < 2) {
  log('ERROR: 完成视角不足2个，无法综合。')
  return { error: 'Insufficient perspectives', count: successful.length }
}

// 组合分析结果传给综合引擎
var combinedAnalyses = ''
for (var i = 0; i < activePerspectives.length; i++) {
  if (analyses[i]) {
    // 使用视角注册表中的 key 作为分隔标记
    combinedAnalyses += '\n\n======= ' + activePerspectives[i].key + ' ANALYSIS =======\n\n'
    combinedAnalyses += analyses[i]
  }
}

phase('Synthesize')

var synthResult = await agent(
  'Synthesize ' + month + '。\n\n下面是' + successful.length + '个视角的分析结果。请综合这些分析，写出唯一一份中文月度综合报告（复盘/每月复盘/' + month + '.md）。\n\n**重要**：报告最前面必须包含「## 聊天摘要」区块（≤200字，3个关键发现+1个建议），用于在聊天中即时展示。不要创建任何中间文件。\n\n**CRITICAL**: Do NOT re-read original journal files, methodology documents (analysis-standards.md, methodology-journal.md, methodology-review.md). All necessary data is in the perspective analyses below. Cross-reference perspective analyses when details are uncertain.\n\n' + combinedAnalyses,
  { label: '综合引擎', phase: 'Synthesize', agentType: 'monthly-synthesis' }
)

// 提取聊天摘要并输出到聊天（带质量门槛）
if (synthResult && typeof synthResult === 'string') {
  var chatMatch = synthResult.match(/## 聊天摘要\n\n([\s\S]*?)(?=\n---\n\[聊天摘要结束\])/)
  var summaryText = chatMatch ? chatMatch[1].trim() : ''

  // 质量校验（禁用词列表权威来源：docs/analysis-standards.md 五、聊天摘要质量门）
  // 运行时从 analysis-standards.md 读取，此处内嵌同步副本；修改时需同步两处
  var bannedPhrases = ['有波动', '总体还行', '有好有坏', '表现不错', '还可以', '情绪稳定', '整体良好', '继续努力', '保持下去', '有待提高', '需要改进', '要加强', '多注意', '总体不错', '还可以吧', '还行吧']
  var hasBanned = false
  for (var i = 0; i < bannedPhrases.length; i++) {
    if (summaryText.indexOf(bannedPhrases[i]) !== -1) { hasBanned = true; break }
  }
  var tooShort = summaryText.length < 50
  var tooVague = (summaryText.match(/具体/g) || []).length === 0 && (summaryText.match(/\d+/g) || []).length === 0

  if (summaryText && !tooShort && !hasBanned && !tooVague) {
    // 通过质量门槛 → 输出摘要
    log('📊 月度复盘完成：' + month + '（' + activePerspectives.length + ' 视角，' + mode + ' 模式）\n')
    log(summaryText)
    log('→ 完整报告：复盘/每月复盘/' + month + '.md')
  } else {
    // 未通过质量门槛 → 静默跳过摘要，仅输出文件路径
    var skipReason = tooShort ? '摘要过短(' + summaryText.length + '字)' : hasBanned ? '含模糊词' : '缺具体数据'
    log('月度复盘完成 ' + month + ' — 1 份中文报告（' + activePerspectives.length + ' 视角）[' + skipReason + '，摘要跳过]')
    log('→ 完整报告：复盘/每月复盘/' + month + '.md')
  }
}
return { month: month, perspectives: successful.length, mode: mode, synthesis: 'complete' }
