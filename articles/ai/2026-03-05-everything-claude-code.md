---
layout: post
title: "everything-claude-code：Claude Code 性能优化完全指南"
date: 2026-03-05
categories: ai
tags: [Claude Code, Agent, Skill, Prompt Engineering, Productivity]
permalink: /ai/everything-claude-code-guide/
---

> **GitHub**: https://github.com/affaan-m/everything-claude-code  
> **作者**: Affaan Mustafa (Anthropic Hackathon 获奖者)  
> **Stars**: 50K+ | **Forks**: 6K+ | **支持**: Claude Code / Cursor / Codex / OpenCode

---

## 项目简介

**everything-claude-code** 是一个完整的 AI Agent 性能优化系统，由 Anthropic Hackathon 获奖者开发。它不仅仅是一套配置，而是一个完整的生产级生态系统：

- 🎯 **13 个专用 Agent** - 规划、架构、代码审查、安全审计等
- 🛠️ **56 个技能 (Skills)** - TDD、安全审查、持续学习等
- ⚡ **32 个命令 (Commands)** - 一键执行复杂工作流
- 🔗 **跨平台支持** - Claude Code、Cursor、Codex CLI、OpenCode

---

## 核心组件

### 1. Agents (专用子代理)

| Agent | 用途 |
|-------|------|
| `planner` | 功能实现规划 |
| `architect` | 系统架构设计 |
| `tdd-guide` | 测试驱动开发 |
| `code-reviewer` | 代码质量审查 |
| `security-reviewer` | 漏洞分析 (AgentShield 集成) |
| `build-error-resolver` | 构建错误修复 |
| `e2e-runner` | Playwright E2E 测试 |
| `refactor-cleaner` | 死代码清理 |

**使用示例**:
```bash
/plan "Add user authentication with OAuth"  # 使用 planner agent
/tdd                                          # 使用 tdd-guide agent
/code-review                                  # 使用 code-reviewer agent
```

### 2. Skills (技能库)

按领域分类的 50+ 技能：

**开发工作流**:
- `tdd-workflow` - TDD 方法论
- `security-review` - 安全审查清单
- `verification-loop` - 持续验证
- `continuous-learning-v2` - 基于本能的持续学习

**框架特定**:
- `django-patterns` / `django-tdd` / `django-security`
- `springboot-patterns` / `springboot-tdd`
- `golang-patterns` / `golang-testing`
- `frontend-patterns` (React/Next.js)

**通用技能**:
- `api-design` - REST API 设计
- `database-migrations` - 数据库迁移
- `e2e-testing` - E2E 测试模式
- `docker-patterns` - Docker 最佳实践

### 3. Rules (规则)

分层规则架构：

```
rules/
├── common/          # 通用规则（所有项目适用）
│   ├── coding-style.md
│   ├── git-workflow.md
│   ├── testing.md      # 要求 80%+ 覆盖率
│   ├── performance.md
│   └── security.md
├── typescript/      # TypeScript 特定
├── python/          # Python 特定
└── golang/          # Go 特定
```

### 4. Hooks (钩子)

基于事件的自动化：

| Hook 事件 | 功能 |
|-----------|------|
| `PreToolUse` | 工具使用前检查 |
| `PostToolUse` | 工具使用后格式化 |
| `Stop` | 会话结束保存状态 |
| `SessionStart` | 会话开始加载上下文 |
| `SessionEnd` | 会话结束持久化 |

**示例**: 自动检测 `console.log` 并警告移除

---

## 快速开始

### 方式一：作为插件安装 (推荐)

```bash
# 添加市场
/plugin marketplace add affaan-m/everything-claude-code

# 安装插件
/plugin install everything-claude-code@everything-claude-code

# 安装规则 (手动)
git clone https://github.com/affaan-m/everything-claude-code.git
./install.sh typescript  # 或 python / golang
```

### 方式二：手动安装

```bash
git clone https://github.com/affaan-m/everything-claude-code.git

# 复制组件
cp everything-claude-code/agents/*.md ~/.claude/agents/
cp -r everything-claude-code/rules/common/* ~/.claude/rules/
cp everything-claude-code/commands/*.md ~/.claude/commands/
```

---

## Token 优化策略

### 推荐设置

添加到 `~/.claude/settings.json`:

```json
{
  "model": "sonnet",
  "env": {
    "MAX_THINKING_TOKENS": "10000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  }
}
```

| 设置 | 默认值 | 推荐值 | 效果 |
|------|--------|--------|------|
| `model` | opus | sonnet | 成本降低 ~60% |
| `MAX_THINKING_TOKENS` | 31,999 | 10,000 | thinking token 减少 ~70% |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | 95 | 50 | 更早压缩，长会话质量更好 |

### 常用命令

| 命令 | 用途 |
|------|------|
| `/model sonnet` | 默认模型 |
| `/model opus` | 复杂架构/深度推理 |
| `/clear` | 重置上下文（免费） |
| `/compact` | 手动压缩 |
| `/cost` | 监控 token 消耗 |

### MCP 管理

⚠️ **重要**: 不要同时启用所有 MCP！每个 MCP 工具描述消耗 token。

```json
{
  "disabledMcpServers": ["supabase", "railway", "vercel"]
}
```

- 每项目保持 < 10 个 MCP
- 保持 < 80 个活跃工具

---

## 跨平台支持

### Cursor IDE

```bash
./install.sh --target cursor typescript
```

- 15 种 hook 事件 (比 Claude Code 多)
- 29 条规则 (YAML frontmatter 格式)
- AGENTS.md 共享

### Codex CLI

```bash
cp .codex/config.toml ~/.codex/config.toml
codex
```

- 16 个原生技能
- 2 个 profile: `strict` (只读沙盒) / `yolo` (全自动化)
- ⚠️ 暂不支持 hooks (等待 OpenAI Issue #2109)

### OpenCode

```bash
npm install -g opencode
opencode
```

- 12 个 agents
- 24 个 commands
- 11 种 hook 事件
- 6 个原生自定义工具

---

## 生态系统工具

### 1. AgentShield - 安全审计

```bash
# 快速扫描
npx ecc-agentshield scan

# 自动修复
npx ecc-agentshield scan --fix

# 深度分析 (3 个 Opus 4.6 agents)
npx ecc-agentshield scan --opus --stream
```

- 1282 个测试，98% 覆盖率
- 102 条静态分析规则
- 红队/蓝队/审计员对抗推理

### 2. Skill Creator

```bash
# 本地分析
/skill-create
/skill-create --instincts

# GitHub App (高级功能)
# Comment on issue: /skill-creator analyze
```

从 git 历史自动生成 SKILL.md 和本能集合。

### 3. Plankton - 写时质量控制

- 每次文件编辑后自动运行 formatter 和 linter
- 20+ 种语言支持
- 三阶段架构：静默格式化 → 收集违规 → 委派修复

---

## 典型工作流

### 开发新功能

```bash
/plan "Add user authentication with OAuth"  # 规划
/tdd                                         # TDD 开发
/code-review                                 # 代码审查
/security-scan                              # 安全审计
/e2e                                         # E2E 测试
```

### 修复 Bug

```bash
/tdd      # 先写失败测试复现 bug
# 修复实现
/code-review  # 检查回归
```

### 生产准备

```bash
/security-scan   # OWASP Top 10 审计
/e2e             # 关键用户流测试
/test-coverage   # 验证 80%+ 覆盖率
```

---

## 持续学习 v2

基于本能的学习系统自动学习你的模式：

```bash
/instinct-status          # 查看学习到的本能
/instinct-export          # 导出分享
/instinct-import <file>   # 导入他人本能
/evolve                   # 聚类成本能技能
```

本能 = 带置信度分数的模式，从会话中自动提取。

---

## 总结

**everything-claude-code** 解决了 Claude Code 用户的几个核心痛点：

1. **碎片化配置** → 统一生态系统
2. **Token 成本高** → 系统化优化策略
3. **质量不稳定** → 专业化 Agent 分工
4. **学习曲线陡** → 即插即用的技能库
5. **平台锁定** → 跨工具兼容

对于每天使用 Claude Code 的开发者，这是目前最全面的生产力提升方案。

---

**资源链接**:
- [速查指南 (Twitter)](https://x.com/affaanmustafa/status/2012378465664745795)
- [完整指南 (Twitter)](https://x.com/affaanmustafa/status/2014040193557471352)
- [AgentShield](https://github.com/affaan-m/agentshield)
- [作者 Twitter](https://x.com/affaanmustafa)
