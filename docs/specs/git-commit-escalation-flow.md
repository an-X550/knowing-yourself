---
created: 2026-07-08
status: 已完成
---

# 需求目标

将 Git 提交流程从“先在沙箱内失败，再解释并提权”优化为“先完成验证，再在写 Git 前直接发起提权”。

> 作为使用 `/提交` 的用户，我想让系统在受限环境下预判 Git 元数据写入需要提权，而不是先报 `.git/index.lock` 权限错误，这样提交流程更顺滑，也不会误以为仓库异常。

# 边界约束

- 不做什么：不修改 Git 仓库结构，不改远程推送策略，不新增命令，不改日志/复盘主链路。
- 影响范围：`.claude/commands/commit.md`、`AGENTS.md`、`CLAUDE.md`、`.claude/settings.json`、`README.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`、`VERSION`。
- 技术约束：保持 `/提交` 仍然是“本地提交，推送手动执行”；受限环境下允许 Git 写入通过一次提权完成；镜像规范继续要求 `AGENTS.md` 与 `CLAUDE.md` 同步。

# 验收标准

- [x] `/提交` 文档明确区分“验证阶段可在沙箱内执行”和“Git 写入阶段在受限环境下预期需要提权”。
- [x] `AGENTS.md` 与 `CLAUDE.md` 不再把本地提交描述成无条件自动完成，而是改成“自动准备并发起提交流程；受限环境下可能等待提权批准”。
- [x] Stop 提示和 README 中的 `/提交` 描述与新流程一致，避免把 `.git/index.lock` 权限错误误解为仓库故障。

# 实施计划

1. 修改 `.claude/commands/commit.md`，把 Git 写步骤改为提权前置，并补充受限环境错误处理。
2. 同步 `AGENTS.md`、`CLAUDE.md`、`.claude/settings.json`、`README.md` 的提交语义。
3. 更新版本、状态与变更记录，并做聚焦验证后本地提交。

# 当前状态：已完成
