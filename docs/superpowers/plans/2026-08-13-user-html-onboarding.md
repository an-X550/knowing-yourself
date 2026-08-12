# 知己用户 HTML 上手页 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 交付离线可直接打开的 HTML 上手页，让最终用户先完成本地日反馈闭环，再按需了解飞书与滴答集成。

**Architecture:** `zhiji-user/index.html` 是唯一完整用户入口，内嵌 CSS 且没有脚本或网络依赖。根目录 `index.html` 只承担使用者/维护者分流；两份 README 只增加页面发现入口，详细事实仍维护在 Markdown。

**Tech Stack:** HTML5、内嵌 CSS、PowerShell 静态校验、Git。

## Global Constraints

- 直接通过 `file://` 打开；不得使用 CDN、外部字体、图片、JavaScript 或构建工具。
- 飞书沉淀、飞书手机入口与滴答清单均标记为“默认关闭”，并写明由用户独立授权。
- 不在页面或示例中写入真实日志、凭证、令牌、App Secret 或 API Key。
- 本地 Markdown 是权威结果；AI 输出是待验证假说。
- 公开版本从 `1.16.0` 递增为 `1.16.1`；同步 `VERSION`、README 徽章、`PROJECT_STATUS.md`、`CHANGELOG.md`。
- 不修改已有未跟踪文件 `AI agent 自动化工作流程搭建教程.md`。

---

## File Structure

| 文件 | 职责 |
|---|---|
| `zhiji-user/index.html` | 完整、离线、响应式的用户上手页。 |
| `index.html` | 根目录分流页。 |
| `README.md`、`zhiji-user/README.md` | 增加 HTML 入口链接。 |
| `VERSION`、`PROJECT_STATUS.md`、`CHANGELOG.md` | 发布事实同步。 |

### Task 1: 创建用户版离线 HTML 主入口

**Files:** Create `zhiji-user/index.html`; Test `zhiji-user/index.html` 静态内容与链接。

**Interfaces:** 消费 `zhiji-user/README.md`、`docs/result-distribution-setup.md`、`docs/local-feishu-daily-feedback-entry.md` 的已验证内容；生成相对 Markdown 链接供本地浏览器解析。

- [ ] **Step 1: 写失败断言并确认入口不存在**

运行 `if (-not (Test-Path 'zhiji-user/index.html')) { throw 'FAIL: 用户 HTML 主入口不存在' }`；预期失败。

- [ ] **Step 2: 实现单文件页面**

创建 UTF-8 HTML5 文件，采用 `<html lang="zh-CN">`、viewport、语义 `header/main/section/footer`、跳至主内容链接、内嵌 CSS。CSS 定义强对比文本、`:focus-visible`、响应式卡片网格、760px 以下单列，以及 `prefers-reduced-motion`。

页面按用户决策顺序排列：首屏价值主张与“仅本地开始”按钮；“5 分钟完成第一次闭环”（完整包、Codex/Claude Code、日志提示词、下一次实验结果）；必需软件和可选账号；六项功能卡（日反馈、日志教练、周/月/项目复盘、人生设计、主题思考、收藏库）；三项扩展卡（`飞书文档沉淀`、`飞书智能体：手机日志入口`、`滴答清单：行动分发`）；隐私边界。

每张扩展卡写用途、前提、`默认关闭`、数据边界与相对文档链接。手机入口明确 Windows 电脑、网络和监听进程须在线，通常等待 2–5 分钟；滴答明确只创建合格行动，完成判断来自后续日志。不得包含 `<script>` 或 `http://`/`https://` URL。

- [ ] **Step 3: 校验内容与离线边界**

读取 HTML，断言含“5 分钟完成第一次闭环”“飞书文档沉淀”“飞书智能体：手机日志入口”“滴答清单：行动分发”“默认关闭”“仅本地”；断言不匹配 `https?://|<script`。预期输出 `PASS: user HTML content and offline boundary`。

- [ ] **Step 4: 校验所有本地 Markdown 链接**

用正则提取 `href="…\.md"`，以 `zhiji-user/` 作为相对根目录逐个 `Test-Path`。预期输出 `PASS: user HTML local Markdown links`。

### Task 2: 创建根目录分流页并更新 README 发现入口

**Files:** Create `index.html`; Modify `README.md`, `zhiji-user/README.md`; Test 三处入口。

**Interfaces:** 消费 Task 1 的 `zhiji-user/index.html`；输出根目录到用户入口的相对链接。

- [ ] **Step 1: 写失败断言**

运行 `if (-not (Test-Path 'index.html')) { throw 'FAIL: root landing page does not exist' }`；预期失败。

- [ ] **Step 2: 实现根目录 `index.html`**

创建小型内嵌 CSS 页面，包含项目一句话说明；主按钮 `href="zhiji-user/index.html"`，文字为“我是第一次使用者”；维护者链接指向 `README.md`、`PROJECT_STATUS.md`、`AGENTS.md`。不得重复用户页的安装步骤、功能地图或三方集成细节。

- [ ] **Step 3: 为 README 增加入口**

根 README 标题后新增离线 [项目导航页](index.html) 与 [用户上手页](zhiji-user/index.html) 链接。用户 README 标题后新增离线 [用户上手页](index.html) 链接，并说明“先本地闭环、后按需扩展”。

- [ ] **Step 4: 校验分流和去重**

断言根页包含 `href="zhiji-user/index.html"`，不含“飞书文档沉淀”或“滴答清单：行动分发”；两份 README 分别包含上述页面链接。预期输出 `PASS: root routing and README discovery`。

### Task 3: 同步发布事实并验收

**Files:** Modify `VERSION`, `README.md`, `PROJECT_STATUS.md`, `CHANGELOG.md`; Test 全部页面与版本一致性。

**Interfaces:** 消费 Task 1 与 Task 2 验证通过的页面；输出统一公开版本 `1.16.1`。

- [ ] **Step 1: 更新版本与项目状态**

将 VERSION 改为 `1.16.1`；根 README 徽章改为 `v1.16.1`；PROJECT_STATUS 当前版本与 last_updated 更新为 `1.16.1` 和 `2026-08-13`，并记录“离线 HTML 用户上手入口已完成；用户版为主入口，根目录负责分流”。

- [ ] **Step 2: 写 CHANGELOG 记录**

在 YAML frontmatter 后以实际中国标准时间新增 `[文档] 增加离线用户上手页 (v1.16.0 -> v1.16.1)`，列出根/用户 HTML、两份 README、状态与版本，并说明本地闭环和按需飞书/滴答集成；更新 last_updated。不得保留时间占位符。

- [ ] **Step 3: 运行全量离线与发布验收**

断言 VERSION、README 徽章、PROJECT_STATUS 和 CHANGELOG 均为 `1.16.1` 发布事实；两份 HTML 都有 doctype 且不含脚本/网络 URL；用户页含三项集成与“默认关闭”；运行 `git diff --check` 无输出。预期输出 `PASS: release consistency and offline HTML acceptance`。

- [ ] **Step 4: 浏览器渲染检查**

直接打开 `zhiji-user/index.html`，确认首屏、锚点、扩展卡片、代码块、窄屏布局与键盘焦点；再打开根 `index.html`，确认主按钮进入用户页。

- [ ] **Step 5: 提交任务文件**

执行 `git add`，仅纳入两个 HTML、两份 README、VERSION、PROJECT_STATUS、CHANGELOG、设计与计划文档；提交信息为 `docs: add offline user onboarding pages`，不包含已有未跟踪教程文件。

## Plan Self-Review

- Spec coverage: 本地闭环、准备清单、六项功能、三项集成、隐私、根页分流、离线可用性、可访问性、移动端与版本同步均映射到 Task 1–3。
- Placeholder scan: CHANGELOG 要求使用实际写入时的北京时间；无待定实现。
- Consistency: 根入口为 `zhiji-user/index.html`，用户页内链接以 `zhiji-user/` 为相对根目录；版本目标统一为 `1.16.1`。
