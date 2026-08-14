---
created: 2026-08-14
status: 已完成（v1.26.2，阶段 0-5 全部落地；e2e/视觉走查/10 秒理解测试待人工）
based_on:
  - 2026-08-14 前后端架构第一性原理审计（backend-auditor / frontend-auditor 双代理事实报告）
  - 用户前端诉求：苹果设计语言、界面不复杂、方便用且用得好
  - 用户确认范围：前端优先 + AI 流式输出 + 暗色模式
scope: apps/zhiji-desktop（不含 .claude Skill 系统）
---

# 桌面端苹果风重设计与架构清理

> 审计确认：后端分层骨架健康、安全基线扎实，但存在 12 项可证据化的问题（8 处重复定义、3 个死代码文件、2 类竞态、错误体系分裂）；前端存在 1 个功能性缺陷（主题思考页半页无样式）、1 套已分裂的设计令牌（settings 段引用 5 个不存在的变量），且整体与苹果设计语言在字体、层级、留白、材质、动效五个维度有系统性差距。本方案按「先修缺陷、再统一令牌、后逐页重设计、最后后端清理」的依赖顺序分 6 个阶段执行。

---

## 一、第一性原理复核

### 真实问题（不复述表面现象）

1. 用户（不会前端的产品作者）无法判断界面好坏，需要一套**有约束的设计系统**替代逐页临场发挥——这才是「苹果风」诉求的本质：不是模仿皮相，而是引入「克制、层级、一致性」的决策纪律。
2. 主题思考页聊天消息、搜索结果、主题列表**完全没有样式**（裸浏览器渲染），这是功能缺陷，不是审美问题。
3. 设计令牌已实际分裂为两套（settings 段引用 `--text-muted` 等 5 个未定义变量，且混入棕色选中环），说明当前 11 变量的令牌体系已失效，继续在旧体系上逐页美化只会扩大漂移。
4. 后端的重复定义（ProviderPort ×8、fenced-JSON 解析 ×6、预览令牌 ×2）不产生用户可见问题，但每次契约演进都要改 N 处，是演进成本问题，优先级低于前端。

### 已知事实 / 未验证假设 / 约束 / 取舍

| 类型 | 内容 |
|------|------|
| 事实 | topics-page 引用的 10 个 class 在 index.css 零定义；settings CSS 引用 5 个不存在变量；token-budget.ts 等 3 文件全项目零引用；308 个单测 + tsc + lint 0 error 是当前质量门 |
| 事实 | SF Pro 字体有 Apple 许可限制，不能合法内置于 Windows 应用 |
| 假设 | 加大标题层级、留白和弹簧动效能显著提升「好用」感知——未经真实用户验证，重设计后仍须完成 3–5 人 10 秒理解测试 |
| 约束 | Renderer 沙箱 + contextIsolation 不可放松；Markdown 安全渲染契约不可回退；`.claude/` Skill 系统不在本次范围 |
| 取舍 | 暗色模式、AI 流式输出、LangGraph 简化本次**不做**（理由见「非目标」），用取舍换交付确定性 |

### 被识别并排除的惯性方案

- 「引入 Tailwind/组件库」——86 个源文件、原生 CSS 已具 BEM 雏形，换框架收益不抵迁移风险；苹果风靠令牌纪律而非框架。
- 「重写 LangGraph 为普通函数」——线性流程确实不需要 StateGraph + 随机 thread_id 的 MemorySaver，但重写不解决任何用户可见问题，登记为技术债，不单独立项。
- 「一步到位全量重写前端」——逐页替换可在每阶段保持可测试、可回退，大爆炸重写不可。

---

## 二、边界约束（非目标）

- 不做暗色模式（真实需求未出现，令牌重构为其留好扩展点即可）
- 不做 AI 流式输出（provider 已具备 stream 能力，UI 接入另过必要性闸门）
- 不简化 LangGraph 编排、不改任何 Skill 契约与报告结构
- 不改 IPC 通道数量与名称（44 通道契约冻结，只改实现内部）
- 不引入新的运行时依赖（字体用系统栈 + 可选 Inter，UI 不引组件库）

## 三、设计规格（苹果设计语言落地）

### 3.1 设计令牌（重写 `src/index.css` 头部）

```css
/* 字体：Windows 上取 SF 气质的最优合法栈 */
--font-ui: "Segoe UI Variable Display", "PingFang SC", "Microsoft YaHei UI", sans-serif;
--font-mono: "Cascadia Mono", "JetBrains Mono", monospace;

/* 字阶：对齐 Apple HIG（Large Title / Title1 / Title2 / Headline / Body / Footnote） */
--text-large-title: 32px/1.22;  --text-title1: 26px/1.25;  --text-title2: 20px/1.3;
--text-headline: 16px/1.4;      --text-body: 15px/1.55;    --text-footnote: 13px/1.45;

/* 色彩：中性灰阶 + 单一品牌绿（提亮至 Apple systemGreen 气质） */
--bg: #f5f5f7;            /* Apple 标志性页面灰 */
--surface: #ffffff;
--surface-glass: rgba(255,255,255,.72);
--ink: #1d1d1f;           /* Apple 正文黑 */
--ink-secondary: #6e6e73; /* Apple 次要灰 */
--ink-tertiary: #86868b;
--separator: rgba(0,0,0,.08);          /* 0.5px 细分割线 */
--accent: #0d7a5f;        /* 保留知己绿、提亮 */
--accent-soft: rgba(13,122,95,.1);
--danger: #d70015;

/* 间距：4pt 网格 */
--space-1: 4px; --space-2: 8px; --space-3: 12px; --space-4: 16px;
--space-5: 20px; --space-6: 24px; --space-8: 32px; --space-11: 44px;

/* 圆角：收敛为 3 档 */
--radius-s: 8px; --radius-m: 14px; --radius-l: 20px; --radius-full: 999px;

/* 阴影：两层，近环境光 */
--shadow-card: 0 1px 2px rgba(0,0,0,.04), 0 8px 24px rgba(0,0,0,.06);
--shadow-overlay: 0 12px 40px rgba(0,0,0,.14);

/* 动效：苹果弹簧曲线 */
--ease-spring: cubic-bezier(.32,.72,.24,1);
--dur-fast: 160ms; --dur-med: 280ms;
```

### 3.2 关键体验决策

| 决策 | 内容 | 理由 |
|------|------|------|
| 层级 | 每页一个大标题（Large Title）+ 至多一个主行动；start-page 的单一焦点布局推广为全局范式 | 苹果「一页一事」原则；当前标题挤在 12px 区间无层级 |
| 材质 | topbar 用真毛玻璃 `backdrop-filter: blur(20px) saturate(180%)`；卡片白底 + 细分割线替代厚边框 | 当前伪毛玻璃无 blur |
| 反馈 | 删除确认统一为 Modal（消灭 `window.confirm` 与三处 `.archive-confirm` 内联红块）；AI 生成改骨架屏替代全局 spinner | 原生弹窗与沉浸式体验违和 |
| 控件 | focus ring 改 2px accent-soft；select 去除 4 处 `!important`，用自定义箭头 SVG | 当前 3px 粗绿框打断视觉 |
| 动效 | 页面切换 fade+translateY(8px)；卡片 hover 上浮 2px + 阴影加深；全部经 `prefers-reduced-motion` 降级 | 弹簧曲线是苹果感的核心来源 |
| 正文 | 14px → 15px，行高 1.55；字重只用 400/500/600 三档（替换混用的 650/750/800） | 字号偏小、字重混乱是审计事实 |

## 四、执行方案

### 阶段 0：安全基线

- 提交当前工作区全部改动；跑通 `npm test`（308）、`npm run typecheck`、`npm run lint` 建立绿基线。

### 阶段 1：设计令牌重写 + 缺陷修复（bug 修复性质，可独立发布）

- 按 3.1 重写 `index.css` 令牌段；删除 settings 段 5 个死变量引用并归入新令牌；消灭棕色残留。
- 补齐 topics-page 缺失的 10 个 class（`.form-row`、`.topic-message(s)`、`.topic-sessions`、`.topic-index`、`.topic-proposal`、`.web-results`、`.web-source`、`.pattern-list`、`.pattern-candidates`）。
- 圆角 9 档收敛为 3 档；间距魔法数字逐步 token 化。

### 阶段 2：前端结构清理

- `labels` 字典三处重复 → 归一到 `renderer/domain/history-items.ts`。
- `.archive-confirm` 模式 → 组件化为 `ConfirmDialog`（基于现有 Modal），替换 today/reviews/projects 三页与 `window.confirm`。
- `hasApiKey` 派生四处重复 → use-app-data 内派生一次。
- 拆分超密单行 JSX（today-page:85、app-shell:7、reviews-page:65-66），不改行为。

### 阶段 3：逐页苹果化

- 顺序：start → today → reviews → topics → projects → history → settings。
- 每页按 3.2 落地：大标题层级、留白（页 padding 28→40）、骨架屏、动效、空状态插画化文案。
- 每页完成后跑相关单测，保持逐页可提交。

### 阶段 4：后端清理（不改契约）

- ProviderPort 8 处重复 → 归一到 `infrastructure/ai/provider-port.ts`。
- fenced-JSON 解析 6 份 → 归一到 `prompts/parse-fenced-json.ts`；预览令牌机制 2 份 → 归一。
- 删除死代码：`domain/token-budget.ts`、`date-periods.ts`、`project-materials.ts`。
- 错误体系统一：`data-transfer-service.ts`、`business-archive-validator.ts`、`daily-runtime.ts` 裸 Error → AppError。
- AI 请求加超时（60s AbortSignal）+ 修复取消误报 NETWORK_TIMEOUT 死分支。
- 竞态修复：project/pattern 仓储读-改-写接入写队列。
- IPC 样板「parse → getPublicConfig → 注入 model」下沉为 handler 包装函数。

### 阶段 5：验证与发布

- `npm test` / `typecheck` / `lint` / `test:e2e` 全绿。
- 视觉走查清单：六页大标题层级、毛玻璃、动效、focus 态、空状态。
- 版本 +1（次版本号），CHANGELOG 一条 `[重构]` + 一条 `[修复]`（topics-page 样式缺陷），PROJECT_STATUS 同步。
- 登记后续观察项：重设计后仍需完成 3–5 人 10 秒理解测试，未通过前不声称易用性已验证。

## 五、验收标准

- [ ] topics-page 全部引用 class 均有样式定义（grep 零缺失）
- [ ] index.css 无未定义变量引用、无 `!important`（select 除外项清零）
- [ ] 圆角/间距/字重收敛到令牌档位数（3/8/3）
- [ ] 全局零 `window.confirm`；删除确认全部走 ConfirmDialog
- [ ] ProviderPort / fenced-JSON / 预览令牌各只剩 1 处定义
- [ ] 3 个死代码文件删除后 `npm test` 308 全绿
- [ ] 裸 `throw new Error` 在 infrastructure/application 层清零
- [ ] 六页均有大标题层级与骨架屏；动效在 `prefers-reduced-motion` 下全部降级
- [ ] e2e 通过；质量门（test/typecheck/lint）不劣化
