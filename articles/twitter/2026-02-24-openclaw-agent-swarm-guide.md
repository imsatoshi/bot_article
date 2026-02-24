---
layout: post
title: "OpenClaw + Codex/ClaudeCode Agent Swarm：一人开发团队实战指南"
date: 2026-02-24
categories: twitter
tags: [AI, Agent, OpenClaw, Codex, ClaudeCode, 生产力]
permalink: /twitter/openclaw-codex-agent-swarm-guide/
---

# OpenClaw + Codex/ClaudeCode Agent Swarm：一人开发团队实战指南

> 整理自 [@elvissun](https://x.com/elvissun) 的深度实践分享
> 
> 原文：[Twitter/X](https://x.com/elvissun/status/2025920521871716562)

---

## 核心观点

**作者不再直接使用 Codex 或 Claude Code，而是使用 OpenClaw 作为编排层。**

他的编排器 "Zoe" 负责：
- 生成 Agent
- 编写 Prompt
- 为每个任务选择合适模型
- 监控进度
- PR 就绪时通过 Telegram 通知

---

## 4周实战数据

| 指标 | 数据 |
|------|------|
| **单日最高提交** | 94 commits（平均 ~50 commits/天）|
| **30分钟完成** | 7 PRs |
| **成功率** | 小中型任务几乎无需干预即可一次完成 |
| **成本** | ~$100/月 Claude + $90/月 Codex（最低 $20 可起步）|

---

## 为什么需要编排层？

### 上下文是零和游戏

**单一 AI 的问题**：
- 填满代码 → 没有业务上下文空间
- 填满客户历史 → 没有代码库空间

**两层系统的优势**：
- **OpenClaw (Zoe)**：掌握所有业务上下文（客户数据、会议纪要、历史决策）
- **Codex/Claude Code**：专注代码执行

| 层级 | 掌握内容 |
|------|---------|
| **OpenClaw (Zoe)** | Obsidian 笔记库、客户数据、会议纪要、成功/失败历史 |
| **Codex/Claude** | 代码库、技术实现 |

---

## 完整8步工作流

### Step 1: 客户需求 → Zoe 梳理范围

1. **补充客户积分**（Zoe 有 admin API 访问权限）
2. **从生产数据库拉取客户配置**（只读权限，coding agents 永远不会拥有）
3. **生成 Codex Agent**（包含所有上下文的详细 prompt）

### Step 2: 生成 Agent

每个 Agent 获得：
- **独立 worktree**（隔离分支）
- **独立 tmux session**（完整终端日志）

```bash
# 创建 worktree + 生成 agent
git worktree add ../feat-custom-templates -b feat/custom-templates origin/main
cd ../feat-custom-templates && pnpm install

tmux new-session -d -s "codex-templates" \
  -c "/Users/elvis/Documents/GitHub/medialyst-worktrees/feat-custom-templates" \
  "$HOME/.codex-agent/run-agent.sh templates gpt-5.3-codex high"
```

**为什么选择 tmux？**
- Agent 跑偏了方向？不需要杀死它：`tmux send-keys -t session "补充指令" Enter`
- 可随时附加观察进度：`tmux attach -t session`

任务被记录在 `.clawdbot/active-tasks.json` 中。

### Step 3: 循环监控

每10分钟运行的 cron job（改进版 Ralph Loop）：
- 检查 tmux session 是否存活
- 检查追踪分支的开放 PR
- 通过 gh cli 检查 CI 状态
- 自动重新生成失败的 agents（最多3次尝试）
- **仅在需要人工关注时发出警报**

### Step 4: Agent 创建 PR

Agent 通过 `gh pr create --fill` 提交 PR。

**完成定义 (Definition of Done)**：
- [x] PR 已创建
- [x] 分支与 main 同步（无合并冲突）
- [x] CI 通过（lint、types、单元测试、E2E）
- [x] Codex 审查通过
- [x] Claude Code 审查通过
- [x] Gemini 审查通过
- [x] 包含截图（如有 UI 变更）

### Step 5: 自动代码审查

每个 PR 由 **三个 AI 模型** 审查：

| 审查者 | 特点 | 评价 |
|--------|------|------|
| **Codex Reviewer** | 边缘案例专家，最彻底的审查，捕获逻辑错误、竞态条件 | 误报率极低 ⭐⭐⭐⭐⭐ |
| **Gemini Code Assist** | 免费且极其有用，捕获安全问题、扩展性问题 | 建议具体修复 ⭐⭐⭐⭐ |
| **Claude Code Reviewer** | 过于保守，大量 "consider adding..." 建议 | 除非标记关键否则跳过 ⭐⭐ |

### Step 6: 自动化测试

CI 流程运行：
- Lint 和 TypeScript 检查
- 单元测试
- E2E 测试
- Playwright 测试（针对预览环境）

**新规则**：UI 变更必须在 PR 描述中包含截图，否则 CI 失败。

### Step 7: 人工审查

Telegram 通知："PR #341 ready for review."

此时：
- CI 已通过
- 三个 AI 审查者已批准
- 截图显示 UI 变更
- 所有边缘案例已在审查评论中记录

**人工审查时间：5-10分钟**

### Step 8: 合并

PR 合并后，每日 cron job 清理孤立的 worktrees 和任务注册表 json。

---

## Ralph Loop V2

这不是静态循环，而是**自适应学习系统**：

**当 Agent 失败时**：
- **上下文不足？** → "只关注这三个文件"
- **方向错误？** → "客户想要的是 X，不是 Y。这是他们在会议上说的"
- **需要澄清？** → "这是客户的邮件和他们的公司介绍"

**奖励信号**：
- CI 通过
- 三个代码审查通过
- 人工合并

任何失败都会触发循环。随着时间推移，Zoe 会写出更好的 prompt，因为她记得什么能 ship。

---

## Agent 选型指南

| Agent | 最佳用途 |
|-------|---------|
| **Codex** | 主力，后端逻辑、复杂 bug、多文件重构。慢但彻底。90% 任务用它。 |
| **Claude Code** | 前端工作更快，git 操作权限问题更少。Codex 5.3 出来后用得少了。 |
| **Gemini** | 设计感。先用 Gemini 生成 HTML/CSS 规范，再交给 Claude Code 实现。 |

**工作流示例**：
- 账单系统 bug → Codex
- 按钮样式修复 → Claude Code
- 新仪表板设计 → Gemini 设计 → Claude 构建

---

## 当前瓶颈：RAM

每个 Agent 需要：
- 自己的 worktree
- 自己的 `node_modules`
- 并行运行 builds、类型检查、测试

**5个 Agent 同时运行 = 5个并行 TypeScript 编译器 + 5个测试运行器**

作者配置：
- Mac Mini 16GB → 最多 4-5 个 Agent（会开始 swap）
- **已订购 Mac Studio M4 Max 128GB ($3,500)**，3月底到货

---

## 如何设置

**最简单的方式**：

复制整篇文章到 OpenClaw，告诉它：

> "为我的代码库实现这个 agent swarm 设置。"

它会读取架构、创建脚本、设置目录结构、配置 cron 监控。10分钟完成。

---

## 展望未来：一人百万美元公司

2026年，我们将看到大量**一人百万美元公司**。

**模式**：
- AI 编排器作为自我的延伸（Zoe 对作者的意义）
- 委托工作给专门处理不同业务功能的 agents
  - Engineering
  - Customer support
  - Ops
  - Marketing
- 保持激光聚焦和完全控制

**核心理念**：
- 保持小规模
- 快速移动
- 每日 ship
- 少炒作，多记录真实业务构建

---

*整理时间: 2026-02-24*  
*来源: Twitter/X 精选*  
*原文作者: [@elvissun](https://x.com/elvissun)*
