---
created: 2026-07-07
status: 已完成
based_on:
  - 两轮第一性原理审计（2026-07-07）
  - 规划/2026-07-06~12.md（date_range 格式先例）
---

# 审计清理：消除冗余、统一格式、建立单一权威来源

> 两次全项目审计发现了三类问题：管道格式断裂（W-格式未同步）、重复定义漂移（禁用词列表 5 处不一致）、架构无文档（两种视角类型混在同一目录）。本计划按依赖顺序分 5 个阶段执行。

---

## 边界约束

- 不做什么：不新增功能、不改视角分析逻辑、不改评分体系
- 影响范围：~25 个文件（6 agent + 7 command + 3 workflow + 9 perspective + 5 文档）
- 原则：每个阶段独立可提交，不产生中间破碎状态

---

## 验收标准

- [x] `git status` 显示 0 个未跟踪文件（全部核心文件已提交）
- [x] `grep "YYYY-Www"` 在所有用户可见输出中附带日期范围
- [x] 禁用模糊词列表只在 `analysis-standards.md` 和 `.claude/shared/` 中出现，workflow 文件不内嵌
- [x] `weekly-processor` 不再出现在 README 和 PROJECT_STATUS 中
- [x] `perspectives/README.md` 存在，说明提取器 vs 评估器两种架构
- [x] `values-meaning.md` 不再硬编码用户个人数据
- [x] 所有 perspective Rules 段落统一使用中文

---

## 阶段 0：安全基线（必须先做）

> 36 个核心文件从未提交。在做任何改动之前，先建立安全基线。

### 0.1 审查 .gitignore

确认以下目录在 gitignore 中（已在）：
- `日志/` `复盘/` `规划/` `关于我/` `data/` `output/` `.vscode/`

确认以下目录**不在** gitignore 中：
- `.claude/` `docs/` `examples/` `perspectives/` `.github/`

### 0.2 提交所有未跟踪文件

```bash
git add .claude/ docs/ examples/ perspectives/growth-dimensions.md perspectives/journal-quality.md perspectives/review-coach.md .github/ CHANGELOG.md CLAUDE.md PROJECT_STATUS.md SETUP.md VERSION LICENSE
git commit -m "提交核心基础设施：agent/command/workflow/skill + 方法论文档 + 3个方法论视角 + 项目规范文件"
```

提交后验证：`git ls-files --others --exclude-standard` 应为 0（或仅剩个人数据目录）

---

## 阶段 1：建立单一权威来源

> 核心原则：每种约定只在一个文件中定义，其他地方引用。

### 1.1 创建 `.claude/shared/` 目录

新建目录，存放跨 agent/command/workflow 共享的配置。

### 1.2 创建 `.claude/shared/banned-phrases.json`

```json
{
  "common": [
    "有波动", "总体还行", "有好有坏", "表现不错", "还可以",
    "情绪稳定", "整体良好", "继续努力", "保持下去", "有待提高",
    "需要改进", "要加强", "多注意", "总体不错", "还可以吧", "还行吧"
  ],
  "yearly_extra": [
    "这一年有成长", "进步很大", "收获很多"
  ]
}
```

### 1.3 修改 3 个 workflow 文件

- `monthly-review.js`：删除内嵌 `bannedPhrases` 数组，改为导入 `.claude/workflows/shared.js` 的统一摘要质量门
- `weekly-review.js`：同上
- `yearly-review.js`：同上，并额外启用 `yearly_extra` 禁用词

### 1.4 修改 yearly-synthesis.md

- 删除第 178-179 行的自维护禁用词列表
- 改为引用 `docs/analysis-standards.md` 五、聊天摘要质量门（与 weekly-synthesis.md 第 208 行做法一致）

### 1.5 创建 `perspectives/README.md`

```markdown
# 视角体系

此目录包含两种架构不同的视角文件：

## 提取器视角（6个）— 数据采集层
chronicle / coach / therapist / relationships / strengths / values-meaning

- 职责：从日志中提取结构化数据，供综合引擎消费
- 共同约束：不跨期对比、不做最终判断、不写最终总结
- 输出：结构化数据表 + 初步观察

## 评估器视角（3个）— 独立评估层
growth-dimensions / journal-quality / review-coach

- 职责：按方法论标准独立评分（30分制）
- 共同约束：评分必须有文本证据、不分析日志内容本身
- 输出：评分量表 + 错误检测 + 改进建议

## 共同规则
- 所有输出使用简体中文（引用日志原文除外）
- 每个关键论断必须有日期引用
- 不与其他时期对比（跨时期对比是综合引擎的职责）
```

### 1.6 修正 PROJECT_STATUS 视角列表

在 PROJECT_STATUS.md 的"视角体系（9个）"章节中，将两个子分组标注为：
- **生活内容分析/提取器（6个）**
- **方法论分析/评估器（3个）**

---

## 阶段 2：修复管道断裂点

> 把规划文件的 date_range 先例系统化到整个周度管道。

### 2.1 定义标准：周标识双字段格式

所有周度输出统一使用：
- **文件名**：`YYYY-Www.md`（保留，保证排序）
- **frontmatter**：`week: YYYY-Www` + `date_range: YYYY-MM-DD ~ YYYY-MM-DD`
- **标题**：`# 周度复盘：YYYY-Www（M月D日-M月D日）`
- **用户可见消息**：附带日期范围

### 2.2 修改 weekly-synthesis.md（7处）

| 行 | 当前 | 改为 |
|----|------|------|
| 21 | `目标周（\`YYYY-Www\`）` | `目标周（\`YYYY-Www\` + 日期范围）` |
| 69 | `复盘/每周复盘/YYYY-Www.md` | 不变（文件名保留） |
| 75 | `week: YYYY-Www` | 添加 `date_range: [计算]` |
| 81 | `# 周度复盘：[YYYY-Www]（[起止日期]）` | 不变（已有起止日期占位，但需确保 agent 实际填充） |
| 93 | `复盘/每周复盘/YYYY-Www.md` | 不变 |
| 225 | `mkdir -p 复盘/周` | `mkdir -p 复盘/每周复盘` |
| 227 | `YYYY-Www` | 不变 |

### 2.3 修改 weekly-review.md（8处）

- 输入格式说明：`YYYY-Www` → `YYYY-Www（自动计算日期范围）`
- 所有用户可见输出消息：`YYYY-Www` → `YYYY-Www（M月D日-M月D日）`
- 输出路径保持不变

### 2.4 修改 weekly-review.js

- 日志消息中追加日期范围计算
- 输出路径不变

### 2.5 修改 review.md（2处）

- 路由表：`YYYY-Www` → `YYYY-Www（含日期范围）`

### 2.6 修改 review-readiness-checker.md（1处）

- 文件检测模式：追加日期范围到提示文本

### 2.7 修复 2026-W27-coach.md frontmatter bug

```yaml
# 当前（错误）
month: 2026-W27

# 修正
week: 2026-W27
date_range: 2026-06-29 ~ 2026-07-05
```

### 2.8 修复 yearly-synthesis.md mkdir bug

第 59 行：`mkdir -p 复盘/年` → `mkdir -p 复盘/年度回顾`

---

## 阶段 3：消除重复

### 3.1 精简 log.md（131行 → ~40行）

log.md 是一个"超级重复器"——它重复了 daily-analyzer 的输出格式、/import 命令的去重逻辑、review-readiness-checker 的检测逻辑。

**保留**（log.md 独有的逻辑）：
- 日期头匹配规则（4种正则）
- 单日/多日判定逻辑
- 日志存档的追加/去重逻辑

**删除并改为引用**：
- 第 46-58 行：删除 daily-analyzer 输出格式描述 → 改为 `遵循 .claude/agents/daily-analyzer.md 的输出格式`
- 第 70-120 行：删除多日导入的详细步骤 → 改为 `执行 /import 命令的步骤 2-4`
- 第 116-120 行：删除导完后提示逻辑 → 改为 `按 review-readiness-checker 的优先级规则提示`

### 3.2 消除「语言要求」块（12个文件 → 0个）

**策略**：在 CLAUDE.md 添加一条全局规则，替代所有分散的重复声明。

在 CLAUDE.md 的"四、代码风格"章节添加：

```markdown
- **全局语言规则**：所有 agent、command、workflow、perspective 的输出必须使用简体中文（面向中国用户）。引用日志原文可保留原语言。此规则适用于所有代理和视角文件，各文件不再单独声明。
```

然后从以下 12 个文件中删除「所有输出必须使用中文」块：
- 6 个 agent：daily-analyzer, monthly-processor, monthly-synthesis, weekly-synthesis, yearly-synthesis
- 6 个 perspective：chronicle, coach, therapist, relationships, strengths, values-meaning

> 注：review-coach 的语言要求在 Rules 段落末尾（第 166 行），与其他文件的格式不同，一并删除。growth-dimensions 和 journal-quality 本就没有此块，无需操作。

### 3.3 删除 PROJECT_STATUS 和 README 中的 切记.md 引用

- PROJECT_STATUS.md 第 155 行：删除 `切记.md` 条目
- README.md 第 65 行：`（替代原切记.md）` → 删除括号内容

---

## 阶段 4：统一格式与语言

### 4.1 清理 weekly-processor 幽灵引用（5处）

| 文件 | 位置 | 操作 |
|------|------|------|
| README.md 周期表 | 第 115 行 | `weekly-processor ×3` → `monthly-processor ×3` |
| README.md 代理表 | 第 191 行 | 删除 weekly-processor 行 |
| README.md 目录树 | 第 250 行 | 删除 `weekly-processor.md` 条目 |
| PROJECT_STATUS.md 周期表 | 第 49 行 | `weekly-processor` → `monthly-processor ×3 + weekly-synthesis` |
| PROJECT_STATUS.md 代理表 | 第 91 行 | 删除 weekly-processor 行；计数从 `（含1个待删除）` → 干净的 6/6 |

### 4.2 perspective Rules 段落中文化

| 文件 | 当前 | 改为 |
|------|------|------|
| `growth-dimensions.md:125` | `Don't force-fit entries` | `不要强行映射条目` |
| `growth-dimensions.md:127` | `Don't compare with other periods` | `不要与其他时期对比` |
| `journal-quality.md:180` | `Don't penalize for missing Step 6` | `不要因为缺少第六步而扣分` |

### 4.3 目录命名统一（可选，低优先级）

当前 `复盘/年度回顾/` 与其他三个 `复盘/每日反馈/`、`复盘/每周复盘/`、`复盘/每月复盘/` 模式不一致。如果要改：

- `复盘/年度回顾/` → `复盘/年度复盘/`
- 影响文件：yearly-synthesis.md（输出路径 + mkdir）、yearly-review.js（日志消息）、yearly-review.md（完成消息）、review-readiness-checker.md（检测路径）

**建议暂缓**——已有报告文件 `复盘/年度回顾/` 如果已存在则需要迁移，增加复杂度。可以作为 backlog 记录。

---

## 阶段 5：上下文精简

### 5.1 values-meaning.md 去硬编码

将 5 个核心价值观从源码移到数据文件：

1. 在 `关于我/core-profile.md` 确保有"核心价值观"章节
2. 修改 `values-meaning.md` 第 7-15 行：

```markdown
## 用户核心价值观

从 `关于我/core-profile.md` 读取用户的核心价值观列表。
如果 core-profile.md 不存在或缺少价值观章节，从日志中推断本月实际展现的价值观。
```

### 5.2 first-principles.md "诚实检查"改为动态引用

当前第 203-245 行的"诚实检查"章节包含写于 7/6 的具体数据（33天日志、1次日反馈等）。这些数据每过一个月就过时。

改为：
```markdown
## 诚实检查：项目是否在兑现承诺

> 每次月度复盘后更新此节。当前数据见最新月度报告。

[最新月度报告中的"执行摘要"和"模式与关注点"章节自动作为诚实检查的输入]
```

或者更简单地：将此节移到 PROJECT_STATUS.md 的"已知问题"中，first-principles.md 只保留检查框架（承诺 vs 实际的对照表结构），具体数据指向 PROJECT_STATUS。

### 5.3 PROJECT_STATUS.md 文件清单压缩

当前"配置与文档"章节逐行列出 20+ 个文件及其状态。改为分组折叠：

```markdown
### 配置与文档（全部完成 ✅）

| 类别 | 文件 |
|------|------|
| 项目规范 | CLAUDE.md, PROJECT_STATUS.md, CHANGELOG.md, VERSION, .gitignore, LICENSE |
| 设置 | .claude/settings.json, SETUP.md |
| 方法论 | docs/first-principles.md, docs/methodology-journal.md, docs/methodology-review.md, docs/analysis-standards.md |
| 示例 | examples/demo/sample-journal.md, examples/analyses/ |
| CI | .github/ISSUE_TEMPLATE/, .github/PULL_REQUEST_TEMPLATE.md |
| Spec | docs/specs/_TEMPLATE.md |
| Workflow | .claude/workflows/monthly-review.js, weekly-review.js, yearly-review.js |
```

节省 ~20 行，且更易读。

### 5.4 weekly-synthesis.md 和 monthly-synthesis.md 输出模板精简

当前两个文件各包含 80-170 行的完整输出模板。改为：

```markdown
## 输出模板

参考最近一份报告的结构：
- 周度：`复盘/每周复盘/` 下最新的报告文件
- 月度：`复盘/每月复盘/` 下最新的报告文件

关键要求：
- 最前面必须有「聊天摘要」区块（≤150字周度/≤200字月度）
- 末尾必须有「质量自检」表
- frontmatter 必须包含 week/month、date_range、perspectives、journals_analyzed
```

节省 ~200 行，且模板不会因代码和实际产出不一致而过时。

---

## 执行顺序

```
阶段 0（安全基线）
  └─ 0.1 审查 gitignore → 0.2 提交全部未跟踪文件
  
阶段 1（单一权威来源）
  └─ 1.1 创建 shared/ → 1.2 banned-phrases.json
     └─ 1.3 修改 3 workflow → 1.4 修改 yearly-synthesis
        └─ 1.5 创建 perspectives/README.md → 1.6 更新 PROJECT_STATUS

阶段 2（修复管道）
  └─ 2.2 weekly-synthesis.md → 2.3 weekly-review.md → 2.4 weekly-review.js
     └─ 2.5 review.md → 2.6 review-readiness-checker.md
        └─ 2.7 coach.md frontmatter → 2.8 yearly-synthesis mkdir

阶段 3（消除重复）
  └─ 3.1 精简 log.md → 3.2 全局语言规则 + 删除 12 处 → 3.3 清理切记引用

阶段 4（统一格式）
  └─ 4.1 幽灵代理 → 4.2 Rules 中文化

阶段 5（上下文精简）
  └─ 5.1 values-meaning 去硬编码 → 5.2 first-principles → 5.3 PROJECT_STATUS 压缩 → 5.4 模板精简
```

阶段 0 和 1 可以合并为一次提交（安全基线 + 基础设施建立）。阶段 2-5 每个阶段独立提交。

---

## 预期效果

| 指标 | 当前 | 目标 |
|------|------|------|
| 未跟踪文件 | 36 | 0 |
| 禁用词列表维护点 | 5 处 | 2 处（analysis-standards + shared/banned-phrases.json） |
| 「语言要求」重复声明 | 12 处 | 0 处（CLAUDE.md 全局规则替代） |
| 幽灵代理引用 | 5 处 | 0 处 |
| W-格式用户不可读 | 16 处 | 0 处（全部附带日期范围） |
| 用户数据硬编码 | 1 处（values-meaning） | 0 处 |
| CHANGELOG 上下文加载 | ~1,500 tokens | ~1,500 tokens（不变，已在 v1.1.0 优化） |
| CLAUDE.md + first-principles 加载 | ~14,000 tokens | ~11,000 tokens（削减 ~20%） |
| weekly/monthly-synthesis 模板 | ~250 行 | ~50 行 |

---

## 当前状态：已完成

> 五个阶段均已完成；禁用词运行镜像已集中到 `.claude/shared/runtime-contracts.js`，workflow 不再内嵌维护。
