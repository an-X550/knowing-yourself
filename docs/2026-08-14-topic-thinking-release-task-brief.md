# 主题思考发布验证任务书

> 日期：2026-08-14
>
> 用途：在**另一个对话窗口**直接执行的完整规格。执行前先读本任务书与 `docs/2026-08-14-desktop-skill-output-quality-audit.md`，不需要其他上下文。
>
> 结论前提（已审计确认，不要重新立项）：桌面端「主题思考」功能完整存在于 main（提交 `7908a4c`：导航第 4 项、topics-page、`topics:*` IPC、TopicThinkingService、`topic-thinking-v1` 提示词、会话 checkpoint、受控联网）。用户看不到的根因是运行的打包构建（`apps/zhiji-desktop/out/`，2026-08-14 00:36）早于功能合入（同日 15:40）。

## 范围边界

- 不改任何代码与提示词；`.claude/` 只读。
- 不新增功能、不新增测试（`app-shell.test.tsx` 已覆盖六页导航）。
- 只做三件事：①治理同步并提交既有文档修正；②重新打包；③人工验收主题思考链路。
- 任一步失败：停下报告，不扩展范围。

## 待提交存量（上一轮对话遗留，未提交）

| 文件 | 性质 |
|---|---|
| `README.md` | 入口描述修正：五个→六个（含主题思考） |
| `apps/zhiji-desktop/README.md` | 同上 |
| `docs/2026-08-14-desktop-skill-output-quality-audit.md` | 新增：产品与 Skill 差异审计报告（用户可能已手动微调，以工作区现状为准一并提交） |

## 执行步骤

### 1. 治理同步（README 属公开文档，按 development-governance 需递增版本）

1. `VERSION`：`1.24.7` → `1.24.8`。
2. `CHANGELOG.md` 顶部追加：

```markdown
## [YYYY-MM-DD] [修复] 桌面端入口描述修正与主题思考发布验证（v1.24.7 -> v1.24.8）

- **受影响文件**: `README.md`、`apps/zhiji-desktop/README.md`、`docs/2026-08-14-desktop-skill-output-quality-audit.md`（新增）、`VERSION`
- **改动摘要**: 修正两份 README 的入口描述（五个→六个，补主题思考），消除与实际导航不符的误导；附产品与 Skill 差异审计报告（输出质量、后端提示词对齐现状、主题思考缺失误判的根因分析）。无代码与提示词变化；重新打包使既有主题思考功能（提交 7908a4c）进入用户可用构建。
```

3. `PROJECT_STATUS.md`：当前版本改 `1.24.8`；「Windows 桌面客户端」进度行的能力描述若未含主题思考则补上；不改待办与决策表。

### 2. 验证门与提交

1. `cd apps/zhiji-desktop; npm test`（52 files / 268 tests）、`npm run typecheck`（0 error）、`npm run lint`（0 error，warning ≤5）。任一门失败即停。
2. 按 source-command-commit 流程提交（提交信息取 CHANGELOG 第一条标题去日期前缀）：预期消息 `[修复] 桌面端入口描述修正与主题思考发布验证`。推送由用户手动执行。

### 3. 重新打包

1. `cd apps/zhiji-desktop; npm run package`（Windows x64，产物在 `out/`）。
2. 打包失败：报告完整错误，不尝试修复代码。

### 4. 人工验收（用户执行，逐项打勾）

1. 启动 `out/知己-win32-x64/知己.exe`，侧栏出现 6 个入口：开始、日志、复盘、**主题思考**、项目、设置。
2. 进入主题思考，输入一个长期困惑问题，确认返回首稿主线（区分事实/推断/价值/未知）。
3. 继续讨论至少一轮，点「归纳」出现提案；展示与旧主题差异（若命中既有主题）。
4. 确认沉淀后主题列表出现新条目；数据目录（设置页可打开）生成主题 Markdown 文件。
5. 关闭并重启应用，未完成会话可列出并恢复。
6. （可选）受控联网：仅点击 UI 搜索按钮触发，结果显示来源域名与检索日期。

### 5. 收尾

- 全部通过：在 `PROJECT_STATUS.md`「Windows 桌面客户端」行补一句主题思考真实验收记录（日期 + 通过项）。
- 任一验收项失败：记录现象到对话，不擅自修复；按 Bug 走 systematic-debugging 另行评估。

## 明确不做

- 不修改 `topic-thinking-v1` 提示词（已在契约对照表登记同源，无漂移）。
- 不在开始页新增主题思考建议卡（`resolveNextStep` 现有链路不含它，新增需过必要性闸门）。
- 不补齐 life-design standard/full/odyssey 与 yearly 13 节长报告（设计性差异，已登记）。
