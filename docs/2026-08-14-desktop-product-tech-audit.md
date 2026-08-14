# 知己桌面端全面审计报告（产品 × 技术 × 契约一致性）

- 日期：2026-08-14
- 性质：只读审计，未修改任何产品代码；由产品审计（Alex）、前后端技术审计（Sam）、契约一致性审计（Tina）三线并行调查后汇总
- 方法依据：`docs/first-principles.md`（原子价值公式：价值 = 洞察质量 × 可行动性 × 闭环速度 ÷ 使用摩擦）、`.claude/shared/contracts/first-principles-analysis.md`、高性价比处理原则（低成本高收益优先，禁止扩项）
- 验证基线：`npm test` 52 文件 / 268 测试全部通过；`tsc --noEmit` 通过

---

## 一、核心结论（结论先行）

1. **主题思考：保留，但只做"恢复对话式写入便利"的针对性改造。** 该功能不是"做坏了"而是"做孤立了"——讨论→归纳→确认→写入链路完整且有测试，但被装进独立页面，丢掉了 Skill 侧"对话即写入"的零摩擦体验。用户抱怨的根因是入口隔离 + 讨论无上下文，两项改造成本均为低-中。
2. **首页"输入即跳转"：不是 bug，是有意设计的意图路由，且实际是两步确认（输入→出发→前往），但交互表达违背直觉。** 用户的"奇怪"感受有充分依据：输入框文案暗示对话式 AI，实际只是把自然语言映射到 6 个固定功能的分发器；确定性关键词过宽（如"这个月"一律判月度复盘）；无 API Key 时错误分类混淆。建议保留机制、降低存在感、修正文案，不建议删除（删除需过必要性闸门且损失已验收能力）。
3. **整体工程质量高于预期。** 分层清晰（application/domain/skill-runtime/prompts/infrastructure）、IPC 契约三件套同步、安全基线扎实、防漂移测试（金样本、契约断言）执行到位。问题集中在错误文案、契约层反向依赖、少量重复逻辑与"台账登记遗漏"。
4. **最严重的结构性问题是数据平面分裂（D1）**：桌面端与 Skill 系统的日志/复盘文件命名格式完全非对称、互不可消费——这是已知教训"并行系统契约漂移"的最终形态。短期应显式登记为已知差异，中期按真实使用情况评估单向只读桥，不建议立即实现双向互通（成本高、触碰隔离设计约束）。
5. **共性机制问题：实现对齐做得好、台账登记有遗漏。** 本次新发现的漂移点中多数是"历史审计窗口内存在但未登记"的偏差，建议将"任何与 Skill 侧不同构的行为必须在 mapping 表或兼容矩阵有一行登记"固化为测试断言。

---

## 二、主题思考功能：产品决策与改造方案

### 2.1 Skill 侧契约要点（对照基准）

权威来源：`.claude/shared/contracts/topic-thinking.md` + `topic-thinking-persistence.md` + `AGENTS.md`「主题思考入口」段。

| 环节 | Skill 侧定义 |
|---|---|
| 入口 | 无独立入口；任何对话涉及长期困惑/既有观点/价值判断即自动路由 |
| 召回 | 读 `context.thinking_index` 语义匹配，最多读 2 个相关主题并告知 |
| 首稿 | 一条可检验主线：问题→可回查事实与约束→当前判断（含反例/代价/未知）→验证/继续/沉淀/等待 |
| 上下文 | 对话天然携带当日日志、反馈、画像 |
| 确认与写入 | 用户确认即由 Agent 归纳→展示→写入主题文件并更新索引；更新时先分类影响（补强/修正/反驳/分支）再重组整篇，保留观点演化 |
| 写入后闭环 | 行动卡可分发飞书/滴答，形成"认识→行动"闭环 |
| 护栏 | 未确认零写入、不从日志自动摘录、近义主题先询问 |

Skill 侧"写入便利"的本质：**写入发生在对话内部**，用户说一句"这个沉淀下来"，索引更新、文件重组、任务分发全部由 Agent 在一次对话内完成，用户零操作成本。

### 2.2 桌面端体验差距清单（按对抱怨的解释力排序）

载体：`src/renderer/pages/topics-page.tsx`、`src/main-process/application/topic-thinking.ts`、`src/main-process/prompts/topic-thinking-v1.ts`、`src/main-process/infrastructure/topics/topic-repository.ts`、`src/renderer/app/navigation.ts`。

1. 【核心】入口隔离，对话式写入链路被"页面化"：必须先导航到独立页面、在空 textarea 里重新表述问题；日志页/复盘页/日反馈均无"就这个问题深入探讨"的跳转意图。**探讨无法从思考发生的地方开始。**
2. 【核心】讨论是无上下文的孤岛：`start()` 只接收 question + 召回主题，不注入当日日志、日反馈、画像；用户必须手工重述背景。
3. 更新语义退化为覆盖：契约要求"分类影响后重组整篇、保留观点演化"；桌面端 `saveTopic` 原子覆盖旧文件，UI 文案即"将被新归纳覆盖"，且归纳提示词未接收旧正文。
4. 沉淀结构精简为三段（已登记的设计性差异），缺"判断性短句标题"等约束。
5. 写入后闭环缺失（有意排除 result-distribution，已登记）。
6. 召回机制降级：确定性子串匹配 ≥2 字符，且只在首轮注入。
7. 数据位置分裂：桌面端写 `dataRoot/topics/`，Skill 写 `zhiji-user/关于我/思考/`，两套主题库互不可见。
8. 次要：归纳提案存内存 Map，重启后需重新归纳；讨论区用纯文本 `<pre>` 渲染，Markdown 结构失效。

### 2.3 去留决策

| 选项 | 用户价值 | 实现成本 | 与产品定位关系 | 判断 |
|---|---|---|---|---|
| A. 保留并改造 | 高：直击用户点名抱怨；主题沉淀是"校准"环节的长期认识载体 | 中低：复用现有链路，无架构前置 | 补全"校准"一环 | **推荐** |
| B. 降级弱化（只读+引导回 Skill） | 低：桌面端永远二流，切换摩擦正是真实痛点 | 低 | "校准"环在桌面端断裂 | 仅作退路：改造后 4 周无真实使用时评估 |
| C. 下线 | 负：删除用户主动索要的能力，40+ 相关测试白拆 | 低 | 直接砍掉校准环 | 不推荐 |

历史佐证：2026-08-14 P3 规格曾以"无真实需求证据"否决桌面端主题思考扩展，其预设的重评估触发条件"用户主动要求在桌面端做主题思考"如今已满足——前提反转，闸门应重新通过。

### 2.4 改造方案（严格限定范围，防扩张）

1. **入口连通**（低-中成本）：`navigation.ts` 增加 `topics.start` 意图；日反馈卡片、周/月复盘处提供"就这个深入探讨"按钮，跳转并预填问题与来源摘录；空 textarea 仅作兜底。
2. **讨论上下文注入**（低成本）：`start()`/首稿提示词扩展可选 context 字段（来源页传入的日志/反馈摘录，限长）；不动会话 checkpoint 结构。
3. **更新从"覆盖"改为"合并重组"**（低成本）：`proposeSummary` 在 update 模式把旧正文传给归纳提示词，要求重组整篇当前论证；UI 差异区展示合并后全文。三段结构暂保留，不强行上 0-6。
4. **归纳提案持久化**（极低成本）：proposals 从内存 Map 移入会话 checkpoint 文件。
5. **明确不做/延后**：语义级召回、result-distribution 分发、与 `zhiji-user/关于我/思考/` 双向互通、0-6 完整结构与观点演化——待真实使用量与质量样本再评估。
6. **验收钩子**：以"用户在桌面端完成过一次带上下文的探讨→确认→写入"为唯一验证指标；4 周内无真实使用则回退评估选项 B。

---

## 三、首页"输入即跳转"专项结论

**事实**：`start-page.tsx` 输入框不监听 onChange/onKeyDown，必须点"出发"按钮调用 `intent.resolve`，命中后还需点"前往：XXX"才导航——三步交互，不存在输入即跳转（`tests/unit/start-page.test.tsx` 已固化）。路由逻辑（`intent-routing.ts`）先走 6 条确定性正则、未命中才调模型、模型仅限 6 值枚举、失败回退澄清，有护栏有测试，与 Skill 侧意图路由同构。

**用户觉得奇怪的四个真实原因**：

1. 心智模型错位：占位文案"聊聊职业选择…"暗示对话式 AI，实际只是 6 个固定功能的分发器；输入形态与输出形态不匹配。
2. 确定性关键词过宽：`这个月|本月|上个月` 命中即判月度复盘；`想不通|困惑` 一律进主题思考。两步确认兜住了误判，但每次误判都在消耗信任。
3. 无 API Key 时体验断裂：非关键词输入落到模型兜底抛裸 Error，被包成澄清气泡；首页明明有 `hasApiKey` prop 却没有用它 gate 输入框。
4. 价值存疑：首页已有"建议下一步"卡片、能力链接和侧边栏导航，意图输入框是第四种导航方式且唯一依赖模型。

**建议（均低成本）**：保留机制；把文案从"想做点什么？"改为明确的"快速跳转"语义并列出 6 个可路由能力；无 `hasApiKey` 时禁用模型兜底路径；补 Enter 提交；收窄过宽关键词。删除整个功能属产品决策，需用户拍板且过必要性闸门。

**附加风险提示**：用户实际运行的打包产物可能滞后于源码（历史审计已证实存在旧构建滞后）。若用户观察到的行为与源码（两步确认）不符，优先重新 `npm run package` 后复核。

---

## 四、前后端问题清单

### 4.1 前端（renderer）

| # | 问题 | 证据 | 严重度 | 成本 | 建议 |
|---|---|---|---|---|---|
| F1 | 主题思考页 AI 回复/主题正文用 `<p>`/`<pre>` 纯文本渲染，违反"所有 AI 内容必须经 MarkdownDocument"的架构硬约束 | `pages/topics-page.tsx` L123、L138、L162、L175 | 中 | 低 | 换用 `MarkdownDocument` |
| F2 | 首页意图输入把"AI 未配置/网络错误"与"意图未识别"混为一类澄清文案，且未按 `hasApiKey` gate | `pages/start-page.tsx` L26-27、L38-39 | 中 | 低 | 区分错误类型；无 Key 时仅走确定性匹配 |
| F3 | 周期复盘 clarification（补证问题）以 error 红色横幅展示，语义应为 info | `pages/reviews-page.tsx` L55 | 低 | 低 | 改为 info 态 |
| F4 | 三个页面模块级计算 `today`，跨零点不重启则日期判断全部过期 | `start-page.tsx` L9、`today-page.tsx` L12、`reviews-page.tsx` L17 | 低 | 低 | 组件内 `useMemo` 或 App 层下发 |
| F5 | reviews-page 用类型强转合并 periodic/insight 两种入参，绕过类型安全 | `pages/reviews-page.tsx` L54-55 | 中 | 中 | 拆分两套 input 构造函数 |
| F6 | 意图输入框、主题讨论输入框均不支持 Enter 提交 | `start-page.tsx` L38、`topics-page.tsx` L103、L127 | 低 | 低 | 补 `onKeyDown` |
| F7 | 草稿保护用原生 `window.confirm`，阻塞且风格割裂 | `app/app.tsx` L21、`today-page.tsx` L27 | 低 | 中 | 可接受现状；有 UI 预算再换 |
| F8 | 全量 `refresh()` 拉取 5 份列表是唯一状态同步方式 | `hooks/use-app-data.ts` L8 | 低 | 高 | 维持现状（规模假设内），数据增长后再加缓存层 |

### 4.2 后端（main-process）

| # | 问题 | 证据 | 严重度 | 成本 | 建议 |
|---|---|---|---|---|---|
| B1 | 无 message 字段的 AppError（INVALID_API_KEY/RATE_LIMITED 等 8 个 code）用户直接看到裸英文码 | `shared/errors/app-error.ts` L17-19 | **高** | 低 | `appError()` 工厂内补中文默认文案，一处修复全站受益 |
| B2 | AppError 结构化 `code` 过 IPC 后丢失，前端无法按 code 差异化处理（如跳设置页） | `app-error.ts` + 各页面 catch | 中 | 中 | handler 层转为 `{code, message}` 结构化 reject |
| B3 | `projects:delete`、`configure-ai.ts` 抛裸 `new Error` 违反 AppError 约定 | `ipc/register-handlers.ts` L50、`application/configure-ai.ts` L40、L53 | 低 | 低 | 改用 `appError()` |
| B4 | SSE 流解析 `JSON.parse(data)` 无 try/catch，单帧畸形即整个生成任务裸异常失败 | `infrastructure/ai/openai-compatible-provider.ts` L41 | 中 | 低 | 帧级 try/catch |
| B5 | 联网搜索 fetch 无超时；`sessions` Map 无 TTL/上限，会话常驻至进程退出 | `infrastructure/web/web-search-service.ts` L61、L53/L91 | 中 | 低 | AbortSignal.timeout + 容量上限 |
| B6 | previews/proposals/web sessions 四处内存 Map 只在成功路径删除，放弃的 token 常驻 | `generate-periodic-review.ts` L17/L25 等 | 低 | 低 | 统一加 TTL 或容量上限 |
| B7 | 仓储所有读写全目录扫描 + 逐文件 parse；`create` 不走 `updateQueue` 串行队列 | `journal-repository.ts` L36-66 | 低 | 中 | 维持现状（规模假设内） |
| B8 | `journals:list` handler 内联业务过滤；部分 zod 校验内联在 handler 而非 `ipc.ts` | `ipc/register-handlers.ts` L41、L61、L36 | 低 | 低 | 下沉仓储/迁入 shared schema |
| B9 | 仓储个别错误文案为英文（'Invalid journal id.'） | `journal-repository.ts` L101 | 低 | 低 | 换成中文 |
| B10 | IPC 无 event.sender 校验（2026-08-13 审计遗留，单窗口风险低） | `ipc/register-handlers.ts` | 低 | 中 | 维持登记；多窗口时再补 |

### 4.3 契约与工程质量

| # | 问题 | 证据 | 严重度 | 成本 | 建议 |
|---|---|---|---|---|---|
| C1 | 共享契约层反向依赖主进程：`desktop-api.ts` 从 main-process 导入类型，renderer 同样如此，破坏 shared 独立性 | `shared/contracts/desktop-api.ts` L3-5、`hooks/use-app-data.ts` L3-4 | 中 | 低 | 3 个类型移入 `shared/schemas/domain.ts` |
| C2 | transfer/preview/topics 返回类型匿名内联声明，与 handler 实际形状重复维护，是契约漂移温床 | `desktop-api.ts` L11-14、L40-42、L52-59 | 中 | 低 | 定义命名 schema，契约引用之 |
| C3 | 日反馈新鲜度（sourceVersions 对比）前后端各一份重复实现，改一侧忘另一侧即行为分叉 | `renderer/domain/next-step.ts` L22-24、`application/generate-daily-review.ts` L21-23 | 中 | 低 | 抽到 shared 纯函数 + 双端对照测试 |
| C4 | 5 个依赖声明未使用（react-router-dom/zustand/react-hook-form 等）；react-query 仅包了 Provider 无任何消费，属死接线 | `package.json` L49-61、`renderer.tsx` L3、L8 | 低 | 低 | 删除 Provider 包裹与 5 个依赖 |
| C5 | e2e 仅 1 条 spec（无 AI 日志主链路）；意图路由、主题思考、设置、备份恢复均无真实 Electron 覆盖 | `e2e/desktop.spec.ts` | 中 | 中 | 补 1-2 条 spec |
| C6 | 架构文档数字过期（写 50 文件/229 测试，实测 52/268）；react-query 描述与实际不符 | `docs/architecture.md` L43、L52 | 低 | 低 | 修正文档口径 |
| C7 | `pretest:e2e` 每次完整重新打包，迭代成本高 | `package.json` L15-16 | 低 | 中 | 加产物缓存判断 |
| C8 | 测试有效性总体良好：金样本、防漂移断言、确认门/审计门覆盖到位，AI 一律注入假 Provider | `tests/unit/`（38）、`tests/integration/`（14） | — | — | 无需动作 |

---

## 五、Skill 契约一致性：漂移点清单

历史审计结论抽查复核（3+1 项）全部仍成立：主题思考 6 入口在码、D 级语义复核在码、月报深度四条契约在码、洞察三链路版本修复在码。git 核对确认阶段 C（6237a6f）之后仅有一次文档修正提交，无新代码变更，故以下均为"历史审计窗口内存在但未登记"的漂移。

| # | 漂移点 | 影响 | 对齐成本 | 建议 |
|---|---|---|---|---|
| D1 | **数据平面文件命名/格式完全非对称**：桌面端 `journals/{年}/{日期}--{id}.md` vs Skill `日志/YYYY-MM-DD.md`、`reviews/{type}/...` vs `复盘/每日反馈/YYYY-MM-DD.md`；双轨数据互不可消费 | **高** | 高 | 立即在兼容矩阵登记为已知差异；若实际双轨使用，优先评估"桌面端导出→Skill 目录导入"单向只读桥；不建议立即双向互通 |
| D2 | **复盘消费验证沉淀规则缺失**：`evidence-and-verification.md` 的周/月/项目复盘消费五条在桌面端周期复盘提示词与材料组装中无承载，且未登记 | 中 | 中 | P0 处理：先补登记，再按闸门评估实现（patterns 快照注入 + 提示词消费规则 + 版本递增） |
| D3 | 月报渲染额外一级标题（`## 主主题`、`## 方向锚点缺席检查`），Skill 契约要求主题只在六问内归并；兼容矩阵却称"同构" | 低 | 低 | 推荐登记为有意差异（方向锚点显式披露有价值），消除台账失真 |
| D4 | 月复盘缺视角证据包层（Skill 侧 monthly-processor 按视角生成证据包），未登记 | 中 | 高 | 只登记为设计性差异，不实现（复刻视角层不符合桌面单次调用架构） |
| D5 | 排除行登记不全：本地飞书入口、收藏吃灰库未列入 mapping 表"有意排除"行 | 低 | 低 | 补两行排除登记 |
| D6 | Skill 侧自身不一致：yearly 输出文件名两处矛盾（`YYYY.md` vs `YYYY-annual-review.md`） | 低 | 低 | Skill 侧单点修订 |

**机制建议**：把"任何与 Skill 侧不同构的行为（含数据面）必须在 mapping 表或兼容矩阵有一行登记"固化为 `tests/unit/contract-prompt-mapping.test.ts` 的断言范围。

---

## 六、高性价比修复总优先级

### P0（低成本、直接消除用户可感问题）

1. **B1 错误码中文化**：`app-error.ts` 工厂补默认中文文案，单文件改动 + 一组单测。
2. **F2 首页意图框 gate 与错误分类** + 文案降调为"快速跳转" + 收窄过宽关键词 + Enter 提交：一次解决用户对首页交互的核心疑点。
3. **主题思考改造三件套**（入口连通、上下文注入、合并式更新）+ F1 换 MarkdownDocument：恢复对话式写入便利，以一次真实沉淀为唯一验收标准。
4. **D2 复盘消费规则**：先补登记，再按必要性闸门评估实现。

### P1（低成本、防漂移与健壮性）

5. C4 清理 5 个未使用依赖 + react-query 死接线（纯删除，零行为风险）。
6. C1+C2 契约层类型归位 + 返回类型命名化（为 B2 结构化错误铺路）。
7. B4+B5 网络健壮性小修（SSE 帧级 try/catch、fetch 超时、sessions 上限）。
8. C3 新鲜度逻辑抽 shared + 双端对照测试。
9. D1/D3/D4/D5/D6 台账登记与文档修订（全部为文档级动作）。

### P2（中成本、择机）

10. B2 IPC 错误结构化；C5 补 1-2 条 e2e；F5 拆分 reviews 入参构造；F4 跨零点日期修复。

### 明确不做（防扩张）

- 语义级主题召回、result-distribution 分发接入、主题库双向互通、0-6 完整沉淀结构、仓储缓存层、多窗口 IPC 校验——均待真实使用证据再评估。

---

## 七、风险与假设

- 本审计为静态审计 + 测试套件验证，未实际运行打包产物做 UI 走查；用户实际运行的 `out/` 构建可能滞后于源码，观察到的行为异常优先怀疑旧构建。
- D1 的真实影响取决于用户是否同时使用桌面端与 Skill 两套系统双轨记录；若单轨使用则影响降级。
- 意图路由与主题思考的去留属产品决策，本报告给出保留-改造推荐与低成本修缮路径；删除需过 AGENTS.md 必要性闸门并由用户拍板。
- Skill 侧 agent 运行时行为以契约文本为准，未实际执行各 command 对照输出。

---

## 附：证据索引（关键文件）

- Skill 契约：`.claude/shared/contracts/topic-thinking.md`、`topic-thinking-persistence.md`、`evidence-and-verification.md`、`review-synthesis.md`、`daily-feedback.md`、`.claude/shared/paths.md`
- 桌面端实现：`apps/zhiji-desktop/src/renderer/pages/{start,topics,today,reviews}-page.tsx`、`src/renderer/app/navigation.ts`、`src/main-process/application/{topic-thinking,intent-routing}.ts`、`src/main-process/prompts/{topic-thinking-v1,daily-review-v1,periodic-review-v1}.ts`、`src/main-process/infrastructure/{topics,markdown,ai,web}/`、`src/shared/contracts/desktop-api.ts`、`src/shared/errors/app-error.ts`
- 台账：`apps/zhiji-desktop/docs/{contract-prompt-mapping.md,skill-compatibility-matrix.md,architecture.md}`
- 历史审计：`docs/2026-08-14-desktop-skill-output-quality-audit.md`、`docs/2026-08-14-insight-contract-audit.md`、`docs/2026-08-14-r2-evidence-grading-comparison.md`、`docs/2026-08-14-topic-thinking-release-task-brief.md`
- 方法论：`docs/first-principles.md`、`.claude/shared/contracts/first-principles-analysis.md`
