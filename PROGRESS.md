# 桌面端 Skill Runtime P1-P4 交付进度

目标：完成受控 Skill Runtime（周期复盘、验证模式、主题思考/受控联网、意图路由），可测试、可打包、可维护。
顺序：任务0 基线 -> P0/P2 周期复盘完善 -> P1 验证模式 -> P3 主题思考/联网 -> P4 意图路由 -> 全量验证+聚焦提交。
最大风险：新增 IPC/UI 面破坏既有日反馈闭环；模型输出不合 Schema；打包链受网络影响。

- [x] 任务0：npm test 38/158 通过；typecheck 通过；lint 0 error/5 既有 warning；package x64 成功。基线 HEAD a695b20 + 未提交 P2 探索。
- [ ] P0/P2 周期复盘：下游沉淀优先材料组装、compat snapshot、隔离测试、端到端 UI/API 测试。
- [ ] P1 验证模式：候选-确认/拒绝、JSON 快照原子写入+复读。
- [ ] P3 主题思考/受控联网：讨论-差异-确认-沉淀、文件型 checkpoint、sourceId 校验。
- [ ] P4 意图路由：确定性匹配 -> 固定枚举 -> Zod 失败回退澄清。
- [ ] 最终：全量验证 + 聚焦提交 + handoff/PROJECT_STATUS/CHANGELOG 更新。
