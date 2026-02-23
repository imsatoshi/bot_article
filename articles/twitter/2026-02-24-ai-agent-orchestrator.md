---
layout: post
title: "AI Agent 编排系统精选：OpenClaw 自托管方案与 Agent Orchestrator 开源项目"
date: 2026-02-24
categories: twitter
tags: [AI, Agent, OpenClaw, Codex, ClaudeCode, Orchestrator]
permalink: /twitter/ai-agent-orchestrator-2026-02-24/
---

# AI Agent 编排系统精选

> 整理自 Twitter 两篇关于 AI Agent 编排的深度文章

---

## 文章一：OpenClaw + Codex/ClaudeCode Agent Swarm

**作者**: [@elvissun](https://x.com/elvissun)  
**来源**: [Twitter/X](https://x.com/elvissun/status/2025920521871716562)

### 核心观点

Elvis 分享了他如何使用 **OpenClaw** 作为编排层，配合 Codex 和 Claude Code 构建了一个完整的 AI Agent 工作流系统。

### 关键数据

- **94 commits in one day** - 最高产的一天，有3个客户会议，一次代码编辑器都没打开
- **7 PRs in 30 minutes** - 从想法到生产环境极快
- **平均每日 ~50 commits**
- **成本**: ~$100/月 Claude + $90/月 Codex（最低可从$20开始）

### 系统架构

```
┌─────────────────────────────────────────────┐
│              Zoe (OpenClaw)                 │
│         编排器 - 持有业务上下文              │
└─────────────┬───────────────────────────────┘
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐
│ Codex │ │Claude │ │Gemini │
│ 主力  │ │ 前端  │ │ 设计  │
└───────┘ └───────┘ └───────┘
```

### 8步工作流

1. **客户需求 → Zoe 梳理范围** - 自动拉取会议笔记，确定功能方案
2. **生成 Agent** - 每个 agent 获得独立 worktree 和 tmux session
3. **循环监控** - 每10分钟检查 agent 状态
4. **Agent 创建 PR** - 自动提交、推送、创建 PR
5. **自动代码审查** - Codex、Gemini、Claude 三重审查
6. **自动化测试** - Lint、单元测试、E2E、Playwright
7. **人工审查** - 5-10分钟，很多 PR 直接合并
8. **合并** - 自动清理 worktree

### 代码审查分工

| 审查者 | 特点 | 评价 |
|--------|------|------|
| **Codex** | 边缘案例专家 | 逻辑错误、竞态条件，误报率极低 |
| **Gemini Code Assist** | 安全/扩展性 | 免费，捕获安全问题，建议具体修复 |
| **Claude Code** | 偏保守 | 经常"考虑添加..."，除非标记为关键否则跳过 |

### 自改进循环（Ralph Loop V2）

当 agent 失败时，Zoe 不只是重新生成相同 prompt：
- **上下文不足?** → "只关注这三个文件"
- **方向错误?** → "客户想要的是 X，不是 Y"
- **需要澄清?** → "这是客户的邮件和公司背景"

### Agent 选型指南

- **Codex** - 主力，后端逻辑、复杂 bug、多文件重构（90%任务）
- **Claude Code** - 前端工作更快，git 操作权限问题少
- **Gemini** - 设计感强，先生成 HTML/CSS 规范，再交给 Claude 实现

---

## 文章二：自改进 AI 系统 Agent Orchestrator

**作者**: [@agent_wrapper](https://x.com/agent_wrapper) (prateek @ Composio)  
**来源**: [Twitter/X](https://x.com/agent_wrapper/status/2025986105485733945)  
**开源仓库**: [github.com/ComposioHQ/agent-orchestrator](https://github.com/ComposioHQ/agent-orchestrator)

### 核心观点

真正的瓶颈不是 AI 编码能力，而是**人的注意力**。作者构建了一个智能编排器 agent，代替人类管理其他 coding agents。

### 关键数据

- **40,000 行 TypeScript**
- **17 个插件**
- **3,288 个测试**
- **8 天**完成（实际专注时间约 3 天）
- **27 PRs** 单日合并记录（2月14日周六）
- **700+ 自动化代码审查评论**
- **84.6% CI 成功率**，41 次 CI 失败全部自愈

### 模型分工（通过 Git Trailers 追踪）

| 模型 | 提交数 | 角色 |
|------|--------|------|
| **Claude Opus 4.6** | 340 | 复杂架构、跨包集成 |
| **Claude Sonnet 4.5** | 311 | 插件实现、测试、文档 |
| **Claude Opus 4.5** | 60 | 复杂任务 |
| **GPT-5.3 Codex** | 11 | 后端逻辑 |

### 插件架构（8个可替换槽位）

```
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Tracker  │ │ Workspace│ │ Runtime  │ │  Agent   │
│ 任务追踪  │ │ 工作空间  │ │ 运行环境  │ │ 编码Agent│
└──────────┘ └──────────┘ └──────────┘ └──────────┘
┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐
│ Terminal │ │   SCM    │ │ Reactions│ │ Notifier │
│ 终端观察  │ │ 代码管理  │ │ 事件响应  │ │ 通知系统  │
└──────────┘ └──────────┘ └──────────┘ └──────────┘
```

### 自愈合 CI 系统

** ao-58 案例** - PR #125（仪表板重设计）：
- 经历 **12 次 CI 失败 → 修复** 循环
- **零人工干预**，最终干净发布

### 活动检测

Claude Code 在每次会话中写入结构化 JSONL 事件文件，编排器直接读取：
- 是否在生成 token？
- 是否在等待工具执行？
- 是否空闲？
- 是否完成？

### Web 仪表盘功能

- **Attention Zones** - 按需关注分组（CI失败/待审查/运行正常）
- **Live Terminal** - xterm.js 实时显示 agent 终端输出
- **Session Detail** - 当前编辑文件、最近提交、PR/CI 状态
- **Config Discovery** - 自动发现 ao.config.yaml

### 自我改进循环

```
Agents 构建功能
      ↓
编排器观察什么有效
      ↓
调整未来会话管理方式
      ↓
Agents 构建更好的功能
      ↓
（循环复利）
```

### 未来方向

1. **随时随地与 agents 对话** - Telegram/Slack 集成
2. **更紧的会话中反馈** - 在 agent 跑题20分钟前纠正
3. **自动升级** - Agent 无法解决 → 编排器 → 人类判断
4. **自动冲突解决** - 并行 agent 之间的协调
5. **云端部署** - Docker/K8s 运行时

---

## 两篇文章对比

| 维度 | OpenClaw 方案 | Agent Orchestrator |
|------|--------------|-------------------|
| **编排器** | Zoe (OpenClaw) | TypeScript 编写的 Agent Orchestrator |
| **运行环境** | 本地 Mac Mini | 本地，支持 tmux/process 运行时 |
| **代码审查** | 3个 AI + 人工 | Cursor Bugbot + 自动化 |
| **自我改进** | Zoe 根据失败调整 prompt | 完整的性能追踪和回顾系统 |
| **开源** | 配置分享 | **完全开源** |
| **硬件瓶颈** | 16GB RAM 限制 4-5 agents | 未明确 |

---

## 关键洞察

1. **上下文是零和游戏** - 单一 AI 无法同时掌握代码和业务上下文，需要分层
2. **编排器必须也是 AI** - 不是脚本或仪表盘，而是理解代码库和业务的 agent
3. **人的注意力是真正的瓶颈** - 系统应只向人类展示需要决策的事项
4. **信号不要丢弃** - 每次会话的成败数据应反馈改进未来 prompt
5. **递归自改进** - Agents 构建编排器 → 编排器让 agents 更有效 → agents 改进编排器

---

*整理时间: 2026-02-24*  
*来源: Twitter/X 精选*
