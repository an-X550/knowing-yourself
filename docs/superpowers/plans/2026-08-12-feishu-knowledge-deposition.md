# 知己飞书沉淀最小实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 复用现有 `lark-cli`，让知己新生成的白名单产物按固定目录沉淀到专用飞书账号，且不上传其他本地文件。

**Architecture:** 本地文件继续是唯一权威结果；现有结果分发契约只增加允许来源、目录路由和收藏调用约定。飞书写入继续由官方 `lark-cli drive +create-folder`、`drive +import` 和 `drive +upload` 完成，不新增上传器、后台监听或双向同步服务。

**Tech Stack:** Markdown 运行契约、JSON 运行配置、PowerShell 契约测试、飞书官方 `lark-cli`。

## Global Constraints

- 自动来源仅限日/周/月/项目/年度复盘、人生设计、已确认主题思考、明确收录的收藏条目及其受控附件。
- 固定目标为专用账号中唯一绑定的“知己”根目录及其后代目录。
- 原始日志、画像、中间分析、配置、状态、缓存和项目代码不得上传。
- 本地是唯一权威来源；本轮不实现自动覆盖、改名/移动同步、远端删除或双向同步。
- 历史文件只生成候选清单；未经用户确认不得批量同步。
- 不修改滴答提取和分发边界。

---

### Task 1: 用测试锁定白名单与飞书目录路由

**Files:**
- Modify: `tests/result-distribution-contract.tests.ps1`
- Modify: `tests/result-distribution-routing.tests.ps1`
- Modify: `tests/collection-contract.tests.ps1`

**Interfaces:**
- Consumes: `.claude/shared/paths.md` 中既有输出 key 与收藏路径。
- Produces: 对收藏来源、固定目录映射、非 Markdown 附件和 `local_only` 排除规则的回归断言。

- [x] **Step 1: 写入失败断言**

在三项现有测试中断言：契约允许 `context.collection_topic` 与 `context.collection_attachment`；飞书目标按“知己/复盘/类型”和“知己/关于我/类型”路由；收藏写入成功后调用分发；附件必须先进入受控收藏目录；`distribution: local_only` 跳过飞书。

- [x] **Step 2: 运行聚焦测试确认 RED**

Run: `powershell -NoProfile -ExecutionPolicy Bypass -File tests/result-distribution-contract.tests.ps1`，再运行 routing 与 collection 两项。

Expected: 至少一项因缺少新白名单或目录路由而 FAIL，且不是语法错误。

### Task 2: 最小扩展现有运行契约

**Files:**
- Modify: `.claude/shared/paths.md`
- Modify: `.claude/shared/contracts/result-distribution.md`
- Modify: `.claude/skills/collection.md`
- Modify: `.claude/shared/result-distribution-config.example.json`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/paths.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/contracts/result-distribution.md`
- Modify: `packaging/zhiji-user-overlay/.claude/skills/collection.md`
- Modify: `packaging/zhiji-user-overlay/.claude/shared/result-distribution-config.example.json`

**Interfaces:**
- Consumes: `distribute <path-key> <resolved-local-path>`、`lark-cli drive +import`、`lark-cli drive +upload`。
- Produces: `context.collection_attachment`；确定的飞书目录 key；收藏写入后的分发 handoff。

- [x] **Step 1: 写最小契约**

只增加来源白名单、路径真实性校验、固定目标目录映射、Markdown 在线文档导入、普通附件原格式上传和 `local_only` 跳过规则；明确更新内容仍返回 `changed_after_delivery`，不静默覆盖。

- [x] **Step 2: 接通收藏调用点**

收藏 Markdown 或附件完成新写入并复读后，分别调用 `distribute context.collection_topic <resolved-local-path>` 或 `distribute context.collection_attachment <resolved-local-path>`；缓存、冲突、仅本地或写入失败不调用。

- [x] **Step 3: 同步用户版镜像并运行 GREEN**

Run: Task 1 的三项测试。

Expected: 三项均 PASS。

### Task 3: 配置并创建固定飞书目录

**Files:**
- Modify: `复盘/.result-distribution-config.json`
- Modify: `复盘/.result-distribution-state.json`（仅在真实写入产生状态时）

**Interfaces:**
- Consumes: 已绑定的根 `folder_token` 和 bot 身份。
- Produces: “知己/复盘/{每日反馈,每周复盘,每月复盘,项目复盘,年度回顾,人生设计}”及“知己/关于我/{思考,收藏吃灰库}”目录 token。

- [x] **Step 1: 只读核验根目录和身份**

Run: `lark-cli auth status --json --verify`，并读取已绑定根目录。

Expected: bot ready，专用用户可访问，根目录唯一且名称为“知己”。

- [x] **Step 2: 串行创建缺失目录**

使用 `lark-cli drive +create-folder --folder-token <parent> --name <name> --as bot`，只创建上述固定目录；已存在则复用，不创建同名副本。

- [x] **Step 3: 写入运行配置并复读**

开启全部已确认白名单类型的飞书开关，保留滴答现有开关；记录各固定目录 token，配置中不写凭证。

### Task 4: 生成历史候选并做新写入验收

**Files:**
- Create: `复盘/飞书历史同步候选-2026-08-12.md`
- Modify: `PROGRESS.md`
- Modify: `BLOCKED.md`

**Interfaces:**
- Consumes: 白名单目录、`local_only` 排除、测试日期排除规则和现有分发状态。
- Produces: 等待用户确认的历史清单；一条非历史的新写入真实验收证据。

- [x] **Step 1: 生成候选清单**

列出白名单内真实文件的相对路径、类型和 SHA-256；排除 2099 测试材料、`local_only`、配置、状态及中间产物，不执行批量上传。

- [x] **Step 2: 用受控失败样本补发做真实工具落位验证**

不制造新的个人内容；复用此前飞书失败且无远端对象的受控样本 `2099-12-28`，只补发飞书到“每日反馈”分类目录。验证返回 URL、专用用户 `full_access`、目录 parent token 正确，重复处理命中幂等且两个分发器调用数均为 0；该样本不计作日常真实使用。

- [x] **Step 3: 更新进度和阻塞事实**

删除已经被真实证据推翻的 `cli_missing`；记录目录 token、测试返回、仍待确认的历史同步门。

### Task 5: 发布同步与最终验证

**Files:**
- Modify: `VERSION`
- Modify: `PROJECT_STATUS.md`
- Modify: `CHANGELOG.md`
- Modify: `README.md`
- Modify: `zhiji-user/README.md`

**Interfaces:**
- Consumes: Task 1–4 的测试与真实飞书证据。
- Produces: 与当前行为一致的版本和使用说明。

- [x] **Step 1: 同步用户可见事实**

说明默认上传白名单、固定根目录、本地权威、历史确认门和不支持的自动覆盖/改名/删除；按向后兼容功能递增次版本。

- [x] **Step 2: 运行完整验证**

Run: `Get-ChildItem tests -Filter '*.tests.ps1' | Sort-Object Name | ForEach-Object { powershell -NoProfile -ExecutionPolicy Bypass -File $_.FullName }`

Expected: 13/13 测试文件 PASS。

- [x] **Step 3: 范围审计并提交**

只暂存本计划涉及的跟踪文件，不暂存既有教程文件；提交信息从 CHANGELOG 生成，不推送。

## Self-Review

- 需求覆盖：多端查看、固定目录、白名单、收藏附件、历史确认和失败隔离均有对应任务。
- YAGNI：没有上传器、监听器、队列、自动覆盖、双向同步、删除或权限治理。
- 安全：外部附件必须先成为收藏目录内的受控副本，飞书目标只能使用已绑定目录 token。
