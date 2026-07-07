---
description: 提交并推送代码到GitHub（自动从CHANGELOG提取提交信息）
allowed-tools:
  - Bash
  - Read
---

# /提交

将当前改动提交并推送到 GitHub。提交信息自动从 CHANGELOG.md 最新条目提取。

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

#### 死链验证

- Bash: 提取所有 `.md` 文件中的相对链接，逐一检查目标文件是否存在
- 有死链 → 列出、提示修复

#### 验证结果

- ✅ 全部通过 → 进入步骤 3
- ❌ 任一失败 → 报告具体差异，停止提交流程，提示用户修复后重试

### 3. 执行 Git 操作

依次运行（前一步失败则停止）：

```bash
git add .
git commit -m "<提取的提交信息>"
git push
```

### 4. 报告结果

运行 `git log -1 --oneline` 确认提交，向用户报告：
- 短 commit hash
- 提交信息
- 推送结果（成功/失败）

## 错误处理

| 情况 | 处理 |
|------|------|
| 无改动（工作区干净） | "✅ 没有需要提交的改动。" |
| CHANGELOG 无条目 | 使用默认信息 `chore: 项目更新` 继续提交 |
| git add 失败 | 报错并停止，不执行后续步骤 |
| git commit 失败 | 报错，提示可能原因（冲突/无改动等） |
| git push 失败（网络问题） | "❌ 推送失败。可能是网络问题。改动已在本地提交，网络恢复后运行 `git push` 即可。" |
| 不在 Git 仓库 | "❌ 当前目录不是 Git 仓库。" |
