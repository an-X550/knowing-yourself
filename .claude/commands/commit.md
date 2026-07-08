---
description: 本地提交代码（自动从CHANGELOG提取提交信息）。推送需用户手动执行
allowed-tools:
  - Bash
  - Read
---

# /提交

将当前改动提交到本地 Git。推送由用户手动执行。

> 默认工作流：代码或文档改动完成、CHANGELOG 已记录且验证通过后，AI 应自动执行本命令对应流程准备并发起本地提交。受限环境下，`git add` / `git commit` 这类 Git 元数据写入可能需要一次提权批准；用户只需要手动运行 `git push` 推送。

## 执行步骤

### 1. 检查是否有改动

运行 `git status --porcelain`。

若无输出，回复"✅ 没有需要提交的改动。"并停止。

### 2. 提取提交信息

Read CHANGELOG.md，找到第一条匹配 `## [YYYY-MM-DD` 的标题行，去掉日期前缀 `## [...] ` 后作为提交信息。

日期前缀格式：`## [YYYY-MM-DD] ` 或 `## [YYYY-MM-DD HH:MM] `，用正则 `^## \[[^]]*\] ` 去除。

若 CHANGELOG.md 中无条目，回退为 `chore: 项目更新`。

### 2.5 提交前同步验证

在 `git add` 之前执行自动验证，确保跨文件一致性。

#### 版本号验证

如果 CHANGELOG 最新条目涉及版本号变更：
- Bash: `grep -oP '当前版本[：:]\s*\K[\d.]+' PROJECT_STATUS.md` 与 `cat VERSION` 比较
- Bash: `grep -oP '版本-v[\d.]+' README.md | grep -oP '[\d.]+'` 与 `cat VERSION` 比较
- 不一致 → 报告差异、提示修复后再提交

#### 路径验证

- Bash: `grep -L "paths.md" .claude/agents/*.md` — 检查是否有 agent 未引用共享路径文件（`review-readiness-checker.md` 可豁免）
- 如有输出 → 提示哪些 agent 尚未迁移到 paths.md

#### 禁用词验证

- 对比 `.claude/shared/banned-phrases.json` 的 `common` / `yearly_extra` 与 `.claude/shared/runtime-contracts.js` 的 `BANNED_PHRASE_GROUPS`
- 确认 3 个 workflow 入口没有重新声明 `bannedPhrases`，而是导入 `validateChatSummary`
- 不一致 → 报告漂移文件，提示同步后再提交

#### 死链验证

- Bash: 提取所有 `.md` 文件中的相对链接，逐一检查目标文件是否存在
- 有死链 → 列出、提示修复

#### 验证结果

- ✅ 全部通过 → 进入步骤 3
- ❌ 任一失败 → 报告具体差异，停止提交流程，提示用户修复后重试

### 3. 执行 Git 操作（提权前置）

先区分两段流程：

- **验证阶段**：步骤 1、2、2.5 可在当前工作区内直接执行。
- **Git 写入阶段**：`git add` 与 `git commit` 会写 `.git/index.lock`、objects、refs 等 Git 元数据；在受限环境下，这一步应直接发起提权请求，而不是先在沙箱内尝试一次再失败。

受限环境下，AI 在进入下列命令前应直接请求提权；若环境允许 `.git` 写入，则按正常流程执行。

依次运行（前一步失败则停止）：

```bash
git add .
git commit -m "<提取的提交信息>"
```

### 4. 报告结果

运行 `git log -1 --oneline` 确认提交，向用户报告：
- 短 commit hash
- 提交信息
- 提醒用户手动推送：💡 提交已在本地。运行 `git push` 推送到远程。

## 错误处理

| 情况 | 处理 |
|------|------|
| 无改动（工作区干净） | "✅ 没有需要提交的改动。" |
| CHANGELOG 无条目 | 使用默认信息 `chore: 项目更新` 继续提交 |
| `git add` / `git commit` 在受限环境下报 `.git/index.lock` / Permission denied | 视为 `.git` 写权限受限，直接发起提权请求继续完成 Git 写入；不要把它描述为仓库损坏或锁文件异常 |
| git add 失败（非权限限制） | 报错并停止，不执行后续步骤 |
| git commit 失败 | 报错，提示可能原因（冲突/无改动等） |
| 不在 Git 仓库 | "❌ 当前目录不是 Git 仓库。" |
