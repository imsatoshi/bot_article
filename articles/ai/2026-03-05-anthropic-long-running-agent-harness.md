---
layout: post
title: "Anthropic 长运行 Agent Harness 实践：让 AI 跨越多个会话持续工作"
date: 2026-03-05
categories: ai
tags: [Claude, Agent, Anthropic, Long-Running, Harness, Multi-Session]
permalink: /ai/anthropic-long-running-agent-harness/
---

> **原文**: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)  
> **作者**: Justin Young (Anthropic)  
> **代码**: [Claude Quickstarts - Autonomous Coding](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding)

---

## 核心问题

随着 AI Agent 能力增强，开发者希望它们能处理需要**数小时甚至数天**的复杂任务。但让 Agent 在多个上下文窗口间保持一致进展仍是一个开放问题。

**核心挑战**：Agent 必须在离散的会话中工作，每个新会话开始时都**没有之前的记忆**。

类比：就像一个软件项目由轮班工程师负责，每个新工程师上岗时都不知道上一轮发生了什么。

---

## Claude Agent SDK 的失败模式

即使使用 Claude Agent SDK（具备 compaction 能力），直接让它"克隆 claude.ai" 也会失败，表现为两种模式：

### 失败模式 1：试图一次性完成

Agent 倾向于一次性做完所有事情，结果：
- 在实现中途耗尽上下文
- 下一个会话接手时功能做了一半且没有文档
- 新 Agent 不得不猜测发生了什么，花时间让基本功能重新工作

### 失败模式 2：过早宣布完成

项目进行到一定阶段后，Agent 看到已有进展，就宣布工作完成。

---

## 解决方案：双 Agent 架构

Anthropic 开发了**两部分解决方案**：

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Initializer    │────>│  Session 1      │────>│  Session 2      │
│  Agent          │     │  Coding Agent   │     │  Coding Agent   │
│  (初始化环境)    │     │  (增量开发)      │────>│  (增量开发)      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
       │                        │                       │
       ▼                        ▼                       ▼
   init.sh              claude-progress.txt      claude-progress.txt
   feature_list.json    git commits              git commits
   initial git commit   (clean state)            (clean state)
```

### 1. Initializer Agent（初始化代理）

**第一次会话**，专门负责搭建环境：

| 产出物 | 用途 |
|--------|------|
| `init.sh` | 启动开发服务器的脚本 |
| `claude-progress.txt` | 工作进度日志 |
| `feature_list.json` | 功能需求清单（初始全部标记为 failing）|
| 初始 git commit | 记录初始文件状态 |

**feature_list.json 示例**：
```json
{
  "category": "functional",
  "description": "New chat button creates a fresh conversation",
  "steps": [
    "Navigate to main interface",
    "Click the 'New Chat' button",
    "Verify a new conversation is created",
    "Check that chat area shows welcome state",
    "Verify conversation appears in sidebar"
  ],
  "passes": false
}
```

**关键设计**：使用 JSON 而非 Markdown，因为模型更少会不当修改 JSON 文件。

### 2. Coding Agent（编码代理）

**后续每个会话**，负责：
1. 理解当前状态（通过 progress 文件和 git 历史）
2. **一次只做一个功能**
3. 完成后将环境保持在"干净状态"
4. 更新 progress 文件和 git commit

**"干净状态"定义**：
- 没有重大 bug
- 代码整洁且有文档
- 开发者可以立即开始新功能，无需先清理混乱

---

## 关键技术细节

### 增量进展 (Incremental Progress)

**为什么一次一个功能很重要**：
- 防止 Agent 试图一次性完成所有事情
- 每个会话都有明确、可完成的目标
- 即使会话中断，也不会留下半吊子功能

### 测试策略

**发现的问题**：Claude 倾向于在没有充分测试的情况下标记功能完成。

**解决方案**：
- 明确要求使用浏览器自动化工具（Puppeteer MCP）
- 像真实用户一样进行端到端测试
- 截图验证功能是否正常工作

**工具示例**：
```
[Tool Use] <browser - navigate to localhost:3000>
[Tool Use] <browser - click "New Chat" button>
[Tool Use] <browser - type "Hello" and press enter>
[Tool Use] <browser - screenshot>
```

**限制**：
- Claude 的 vision 能力有限
- 无法看到浏览器原生 alert 弹窗
- 依赖这些弹窗的功能更容易有 bug

### 会话启动流程

每个 Coding Agent 会话开始时的标准流程：

1. **`pwd`** - 确认工作目录
2. **读取 `claude-progress.txt`** - 了解最近做了什么
3. **读取 `feature_list.json`** - 选择最高优先级的未完成功能
4. **`git log --oneline -20`** - 查看最近的提交历史
5. **运行 `init.sh`** - 启动开发服务器
6. **基础功能测试** - 验证核心功能仍然正常工作
7. **开始新功能开发**

---

## 失败模式与解决方案总结

| 问题 | Initializer Agent 解决 | Coding Agent 解决 |
|------|------------------------|-------------------|
| **过早宣布整个项目完成** | 设置 feature_list.json 文件，所有功能初始标记为 failing | 每次会话读取 feature_list，选择单个功能开发 |
| **留下有 bug 或未记录的环境** | 创建初始 git repo 和 progress notes 文件 | 启动时读取 progress 和 git log，运行基础测试；结束时提交 git 和更新 progress |
| **功能未充分测试就标记完成** | 设置 feature_list.json | 自验证所有功能，仔细测试后才标记为 passing |
| **花时间弄清楚如何运行应用** | 编写 init.sh 脚本 | 会话开始时读取并运行 init.sh |

---

## 实际会话示例

```
[Assistant] I'll start by getting my bearings and understanding 
the current state of the project.

[Tool Use] <bash - pwd>
[Tool Use] <read - claude-progress.txt>
[Tool Use] <read - feature_list.json>

[Assistant] Let me check the git log to see recent work.
[Tool Use] <bash - git log --oneline -20>

[Assistant] Now let me check if there's an init.sh script 
to restart the servers.
<Starts the development server>

[Assistant] Excellent! Now let me navigate to the application 
and verify that some fundamental features are still working.
<Tests basic functionality with Puppeteer>

[Assistant] Based on my verification testing, I can see that 
the fundamental functionality is working well. Now let me 
review the tests.json file to understand what needs to be 
implemented next.
<Starts work on a new feature>
```

---

## 未来工作

### 多 Agent 架构

目前尚不清楚：**单个通用编码 Agent** vs **多 Agent 架构** 哪种更好。

潜在的专业化 Agent：
- **测试 Agent** - 专门负责测试
- **QA Agent** - 质量保证审查
- **代码清理 Agent** - 代码重构和优化

### 泛化到其他领域

当前演示针对全栈 Web 应用开发优化。未来方向：
- 科学研究
- 金融建模
- 其他需要长时程 Agent 任务的领域

---

## 关键启示

### 对于构建长运行 Agent 的开发者

1. **环境即记忆** - 用文件系统和 git 替代上下文记忆
2. **功能清单驱动** - 明确的目标防止过早完成
3. **一次只做一件事** - 增量进展降低风险
4. **干净状态约定** - 每个会话结束时要像能合并到主分支一样
5. **自动化测试** - 端到端测试确保功能真正工作

### 类比人类工程实践

这些实践的灵感来自**高效软件工程师的日常行为**：
- 写清晰的提交信息
- 保持主分支可部署
- 一个 PR 只做一件事
- 充分测试后才标记完成

---

## 相关资源

- [Claude 4 Prompting Guide - 多上下文窗口工作流](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices#multi-context-window-workflows)
- [Claude Quickstarts - Autonomous Coding](https://github.com/anthropics/claude-quickstarts/tree/main/autonomous-coding)
- [Claude Agent SDK Documentation](https://platform.claude.com/docs/en/agent-sdk/overview)

---

*"让 Agent 跨越多个会话工作的关键是：让它们像优秀的软件工程师一样工作。"*
