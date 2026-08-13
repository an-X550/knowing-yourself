# Desktop Skill Runtime Release Gate Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 为已完成的桌面端日反馈 Skill Runtime 补齐隔离回归证明、用户可见的运行边界说明和 Windows 封装验收，不新增业务功能。

**Architecture:** 只增加测试和文档，不改变日反馈图、LLM 提示词、业务数据结构或 `.claude/`。隔离测试在源码级阻止 `skill-runtime` 重新出现 `.claude` 依赖；README 向使用者说明桌面端与 Codex Skill 独立；封装使用项目既有 Electron Forge 脚本。

**Tech Stack:** Electron Forge、Vite、Vitest、TypeScript、Node.js `fs/promises`。

## Global Constraints

- 从 `codex/desktop-daily-skill-runtime` 创建新的隔离工作树；只改 `apps/zhiji-desktop/`。
- 不读取、执行、修改 `.claude/`，不更改原 Skill 系统，也不合并工作树到 `main`。
- 不新增运行时依赖、数据库、常驻进程、云服务、飞书、滴答清单、MCP、shell 或任意文件工具。
- 不为下载失败添加镜像脚本；先检查本机 Electron 缓存。若无缓存且官方网络失败，只记录失败证据。
- 所有生产行为都保持已有测试绿灯；本计划不改变用户数据格式。

---

### Task 1: 用源码级回归测试证明 Runtime 不依赖 `.claude`

**Files:**

- Modify: `apps/zhiji-desktop/tests/unit/daily-runtime.test.ts`
- Read: `apps/zhiji-desktop/src/main-process/skill-runtime/**/*.ts`

**Interfaces:**

```ts
// Test-only helper. It must scan only the desktop source tree.
async function runtimeSources(): Promise<string[]>;
```

- [ ] **Step 1: 写失败测试**

在 `daily-runtime.test.ts` 加入 Node `readdir`/`readFile` 辅助函数，递归收集 `src/main-process/skill-runtime` 下的 `.ts` 文件。新增断言：每个源码文本都不包含字符串 `.claude`，并断言至少扫描到一个文件。

```ts
it('keeps the desktop runtime independent from the Codex Skill directory', async () => {
  const sources = await runtimeSources();
  expect(sources.length).toBeGreaterThan(0);
  expect(sources).not.toContainEqual(expect.stringContaining('.claude'));
});
```

- [ ] **Step 2: 运行并确认测试基线**

Run: `npm test -- tests/unit/daily-runtime.test.ts`

Expected: PASS（当前实现已经没有 `.claude` 字符串）。若失败，停止，列出精确文件和引用；不得用忽略规则掩盖依赖。

- [ ] **Step 3: 检查测试边界**

确认测试根路径由 `import.meta.url` 推导或使用明确的相对测试路径，且只扫描 `apps/zhiji-desktop/src/main-process/skill-runtime`，不会扫描用户数据、`.claude` 或整个磁盘。

- [ ] **Step 4: 再次运行测试**

Run: `npm test -- tests/unit/daily-runtime.test.ts`

Expected: PASS。

- [ ] **Step 5: 提交**

```powershell
git add apps/zhiji-desktop/tests/unit/daily-runtime.test.ts
git commit -m "test: guard desktop runtime isolation"
```

### Task 2: 在桌面端 README 说明独立运行边界

**Files:**

- Modify: `apps/zhiji-desktop/README.md`
- Read: `apps/zhiji-desktop/docs/skill-compatibility-matrix.md`

**Interfaces:** 无代码接口；用户文档必须与兼容矩阵一致。

- [ ] **Step 1: 写文档验收清单**

在 README 的架构或数据说明附近加入 `## Skill Runtime 边界`，准确表达以下四项：

1. 桌面端仅支持 Windows 本地单用户、应用打开时运行；
2. 日反馈使用版本化兼容快照和 LangGraph JS；
3. 不读取、执行或修改 Codex + `.claude` Skill 系统；
4. 审计日志保存在桌面端数据目录的 `runtime/daily-feedback-audit.jsonl`，不含 API Key 或日记全文。

- [ ] **Step 2: 编辑最小文档**

不得声称支持未完成的 verified-pattern 持久化、主题思考、联网搜索、恢复运行或外部集成。链接到 `docs/skill-compatibility-matrix.md`。

- [ ] **Step 3: 手动核对事实**

Run: `Select-String -Path README.md -Pattern 'Skill Runtime|\.claude|daily-feedback-audit'`

Expected: 能定位上述边界；不得出现“会执行 Skill Markdown”“完全功能对齐”等不实表述。

- [ ] **Step 4: 提交**

```powershell
git add apps/zhiji-desktop/README.md
git commit -m "docs: clarify desktop runtime boundary"
```

### Task 3: 完成实际可用的发布门验证

**Files:** 不修改文件，除非 Task 1 或 Task 2 产生必要变更。

- [ ] **Step 1: 校验依赖和测试**

Run:

```powershell
npm ci
npm test
npm run typecheck
npm run lint
git diff --check
```

Expected: 测试、类型检查和 diff 检查 exit 0；lint 不得出现 error。历史 warning 单独列出，不得以关闭规则处理。

- [ ] **Step 2: 检查本机 Electron 缓存（只读）**

Run:

```powershell
Get-ChildItem -Force "$env:LOCALAPPDATA\electron\Cache" -ErrorAction SilentlyContinue
Get-ChildItem -Force "$env:USERPROFILE\.cache\electron" -ErrorAction SilentlyContinue
```

Expected: 仅报告缓存是否存在；不删除缓存、不修改 npm 配置。

- [ ] **Step 3: 封装验证**

Run: `npm run package`

Expected: Electron Forge exit 0，生成 Windows x64 package。若失败是 `ECONNRESET`、下载超时或上游不可用，记录完整错误类别、日期和已通过的 Vite 构建阶段；不改业务代码，不把网络问题写成产品失败。

- [ ] **Step 4: 交接状态**

在 `docs/desktop-skill-runtime-handoff.md` 的“已完成验证”添加最新事实：成功的命令、测试数量、lint warnings 和封装结果。只有封装成功后，才把 P0 标为完成；否则保留“网络阻塞、可安全重试”。

- [ ] **Step 5: 最终提交**

```powershell
git add docs/desktop-skill-runtime-handoff.md apps/zhiji-desktop/
git commit -m "docs: record desktop runtime release gate"
git status --porcelain
git log -1 --oneline
```

Expected: 工作树干净；输出精确提交哈希。不要推送，除非用户另行明确授权。

## 计划自检

- 覆盖隔离、防回归、用户文档和 Windows 封装四个 P0 目标。
- 没有引入任何新业务能力或未验证架构。
- 每项代码变更有明确测试和命令；没有“以后再补”的隐含实现。
- 完成后下一项候选只能是经过必要性闸门的 P1 验证模式沉淀，而不是扩张到通用 Agent。

