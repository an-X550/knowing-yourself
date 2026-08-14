# 知己桌面端优化执行方案（基于 2026-08-14 全面审计）

- 日期：2026-08-14
- 依据：`docs/2026-08-14-desktop-product-tech-audit.md`（三线并行审计汇总）
- 方法：第一性原理（价值 = 洞察质量 × 可行动性 × 闭环速度 ÷ 使用摩擦）+ 高性价比原则（低成本高收益优先，禁止扩项，TDD）
- 用户决策：① 删除首页"输入即跳转"（意图路由）功能；② 认可审计报告其余结论，执行 P0+P1。

---

## 一、范围与决策

### 本方案做（P0+P1）

| # | 事项 | 审计编号 | 价值论证（第一性原理） |
|---|---|---|---|
| S1 | **删除首页意图路由功能**（用户拍板） | 覆盖 F2/F6 部分 | 删除冗余：首页已有"建议下一步"卡片、能力链接与侧边栏导航三种入口，意图框是第四种且唯一依赖模型；删除降低使用摩擦与维护面 |
| S2 | 错误码中文化 + 裸 Error 收敛 | B1/B3/B9 | 唯一高严重度项；单文件修复全站受益，消除用户看到 `RATE_LIMITED` 裸码 |
| S3 | 主题思考改造三件套 + F1 + 提案持久化 | 差距 1/2/3/8、F1 | 恢复"对话式写入便利"（用户点名痛点）：入口连通、上下文注入、合并式更新；验收钩子=一次真实带上下文沉淀 |
| S4 | 网络健壮性小修 | B4/B5/B6 | 降低"生成莫名失败/挂死"概率，共约几十行 |
| S5 | 契约层类型归位 + 返回类型命名化 | C1/C2 | 消除 shared 反向依赖与契约漂移温床 |
| S6 | 新鲜度逻辑抽 shared + 双端对照测试 | C3 | 消除前后端唯一明确重复业务逻辑 |
| S7 | 清理未使用依赖 + react-query 死接线 | C4 | 纯删除，零行为风险 |
| S8 | 台账登记与文档修订 | D1-D6、C6 | "实现对齐好、登记有遗漏"的机制修复；全部文档级动作 |

### 明确不做（防扩张，用户已认可的审计边界）

- P2 全部延后：B2 IPC 错误结构化、C5 e2e 补测、F5 reviews 入参拆分、F4 跨零点日期。
- D2 复盘消费规则**仅登记不实现**（实现需另过必要性闸门与金样本验证）。
- 语义级主题召回、result-distribution 分发接入、主题库双向互通、0-6 完整沉淀结构、仓储缓存层、多窗口 IPC 校验、F3/F7 次要 UI 项——均待真实使用证据再评估。

---

## 二、S1 意图路由删除的完整边界

删除对象（连同测试与台账行）：

- 前端：`start-page.tsx` 意图输入框/出发按钮/前往按钮/澄清气泡；`domain/intent-target.ts`
- 后端：`application/intent-routing.ts`、`application/configure-ai.ts` 中仅服务于意图兜底的裸 Error（configure-ai 本体保留，裸 Error 改 appError 归 S2）
- 提示词：`prompts/intent-routing-v1.ts`
- IPC：`intent.resolve` handler（`register-handlers.ts`）、`shared/schemas/ipc.ts` 与 `shared/contracts/desktop-api.ts` 中 intent 条目、`preload.ts` 暴露
- 测试：`tests/unit/start-page.test.tsx` 意图用例、intent-routing 相关单测/集成测试；其余用例保留
- 台账：`docs/contract-prompt-mapping.md` 意图路由行改为"已下线（2026-08-14 用户决策）"；`skill-compatibility-matrix.md` 对应更新

保留：`next-step.ts` 建议下一步卡片、能力链接、侧边栏导航；首页其余结构不动。
同步：`AGENTS.md`/`CLAUDE.md` 若提及桌面端意图路由入口需逐字同步修订（二者必须保持逐字同步）。

## 三、S3 主题思考改造的实施规格

1. **入口连通**：`navigation.ts` 增加 `topics.start` 意图（携带预填问题与来源摘录）；日反馈卡片（today-page 或对应展示位）与周/月复盘结果处加"就这个深入探讨"按钮；空 textarea 保留为兜底入口。
2. **上下文注入**：`topic-thinking.start()` 与首稿提示词增加可选 `contextExcerpt` 字段（来源页传入，限长 500 字），提示词注明"以下为相关背景摘录，可回查引用"；不改会话 checkpoint 结构。
3. **合并式更新**：`proposeSummary` 在 update 模式将旧主题正文传入归纳提示词，要求"重组整篇当前论证而非仅写新内容"；UI 差异区从"将被覆盖"改为展示合并后全文；三段结构保留。
4. **提案持久化**：proposals 从内存 Map 移入会话 checkpoint 文件，重启后 confirm 可用。
5. **F1**：主题页 AI 回复与主题正文全部改用 `MarkdownDocument` 渲染。
6. **TDD**：每项先写失败测试（红）再最小实现（绿）；`topic-thinking-v1` 提示词版本号按治理规则递增并同步 mapping 表。

## 四、执行波次（依赖串行，波内并行）

| 波次 | 任务 | 涉及主要文件域 | 依赖 |
|---|---|---|---|
| W1a | S1 删除意图路由 | renderer/start-page、intent 链路、IPC、mapping 台账 | 无 |
| W1b | S2 错误码中文化 + S4 网络健壮性 | shared/errors、infrastructure/ai、infrastructure/web、journal-repository 文案 | 无 |
| W2 | S3 主题思考改造 | renderer/pages/{topics,today,reviews}-page、navigation.ts、application/topic-thinking.ts、prompts/topic-thinking-v1.ts | W1a 完成 |
| W3 | S5+S6+S7+S8（类型归位、新鲜度抽取、依赖清理、台账/文档/治理同步） | shared/contracts、hooks/use-app-data.ts、renderer/domain/next-step.ts、generate-daily-review.ts、package.json、renderer.tsx、docs 台账、CHANGELOG/PROJECT_STATUS/VERSION | W1b、W2 完成 |
| W4 | 全量验证：`npm test`、`tsc --noEmit`、lint | apps/zhiji-desktop | W3 完成 |
| W5 | 三维并行评审（完整性/正确性/影响面） | 本会话全部变更 | W4 通过 |

## 五、验收标准

1. `npm test`（unit+integration）与 `tsc --noEmit` 全部通过；无死导入与未使用符号。
2. 意图路由：首页无输入框/出发/前往元素；全仓库无 intent.resolve 残留引用；mapping/兼容矩阵已登记下线。
3. 主题思考：带上下文跳转→讨论→确认→合并写入链路有集成测试覆盖；Markdown 渲染生效；重启后 confirm 可用。
4. 错误文案：全部用户可见错误为中文；无裸英文错误码暴露。
5. 治理：CHANGELOG 新增条目、PROJECT_STATUS 同步、VERSION 按 `docs/development-governance.md` 递增；AGENTS.md 与 CLAUDE.md 逐字同步。

## 六、风险

- S3 入口按钮挂载位需以实际页面结构为准（日反馈卡片所在页），实施时以代码现状定位，不新增页面。
- 意图路由删除后，Skill 侧 `codex-natural-language-routing` 契约不受影响（该契约属 CLI 域），仅桌面端台账登记下线。
- 若 W4 验证失败，仅对失败范围回炉修复，不重跑全流程。
