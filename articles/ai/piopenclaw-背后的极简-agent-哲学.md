---
layout: post
title: "Pi：OpenClaw 背后的极简 Agent 哲学"
date: 2026-02-21
categories: ai
tags: ["AI", "Agent", "OpenClaw", "Pi", "极简主义"]
permalink: /ai/pi-minimal-agent/
---

# Pi：OpenClaw 背后的极简 Agent 哲学

**原文**: [Pi: The Minimal Agent Within OpenClaw](https://lucumr.pocoo.org/2026/1/31/pi/)  
**作者**: Armin Ronacher (Flask 创始人)  
**翻译整理**: 2026-02-21

---

## 什么是 Pi？

Pi 是 **OpenClaw 的核心 coding agent**，由 [Mario Zechner](https://mariozechner.at/) 开发。如果说 OpenClaw（由 Peter Steinberger 创建）追求的是"科幻般的疯狂"，那 Pi 则完全相反——它极其**克制和极简**。

但两者核心理念一致：**LLM 擅长写代码和运行代码，那就拥抱这一点**。

---

## Pi 的极简设计哲学

### 核心特点

| 特性 | Pi 的做法 | 其他 Agent |
|------|----------|-----------|
| **系统提示词** | 最短 | 通常很长 |
| **内置工具** | 只有 4 个 | 几十个甚至上百 |
| **扩展方式** | 让 Agent 自己写扩展 | 下载安装扩展 |
| **状态管理** | Session 树形结构，可分支回溯 | 线性对话 |

### 四大核心工具

Pi 只提供最基础的 4 个工具：

1. **Read** - 读取文件
2. **Write** - 写入文件
3. **Edit** - 编辑文件
4. **Bash** - 执行命令

> "如果你需要 Agent 做它还没做的事情，不要下载扩展，**让 Agent 自己扩展自己**。"

---

## 为什么不用 MCP？

Pi **不支持 MCP**（Model Context Protocol），这不是懒惰的 omission，而是有意的设计选择。

MCP 的问题是：工具需要在会话开始时加载到系统上下文中，这使得**热重载**变得非常困难——如果不清空缓存或让 AI 困惑，就无法完全重新加载工具的功能。

Pi 的解决方案：**Session 树形结构**。

---

## Session 树：Pi 的秘密武器

Pi 的会话不是线性的，而是**树形结构**：

```
主分支: 开发功能 A
    ↓
分支 1: 修复工具 bug
    ↓
回到主分支: 继续开发功能 A（带修复）
```

**好处**:
- 可以在**不浪费主会话上下文**的情况下，分支出去修复工具
- 修复完成后，**回溯到之前的时间点**
- Pi 会自动总结分支上发生的事情

---

## 扩展系统：Agent 为自己写扩展

Pi 的扩展系统允许：
1. 扩展可以**在 Session 中持久化状态**
2. 支持**热重载**——Agent 可以写代码、重载、测试，循环直到扩展可用
3. 扩展可以注册**自定义 TUI 组件**（旋转器、进度条、文件选择器、数据表格等）

### Armin 的扩展示例

#### 1. `/answer` - 优雅回答问题

Armin 不喜欢结构化的问答对话框，他更喜欢 Agent 自然的散文式回答（带解释和图表）。

问题：内联回答问题会变得很乱。  
解决：`/answer` 读取 Agent 的最后回复，提取所有问题，重新格式化为漂亮的输入框。

#### 2. `/todos` - Agent 待办清单

虽然 Armin 批评 Beads 的实现方式，但他确实认为给 Agent 一个待办清单很有用。

`/todos` 将所有项目存储在 `.pi/todos` 目录下的 markdown 文件中。Agent 和人类都可以操作它们，会话可以认领任务将其标记为进行中。

#### 3. `/review` - Agent 代码审查

随着更多代码由 Agent 编写，在丢给人类之前先让 Agent 审查更有意义。

利用 Pi 的 Session 树，可以**分支到一个全新的审查上下文**，获取发现的问题，然后将修复带回主会话。

UI 参考了 Codex，提供易于审查的 commits、diffs、未提交更改或远程 PR。

#### 4. `/control` - 多 Agent 实验

一个实验性扩展，让一个 Pi Agent 可以向另一个发送提示。这是一个简单的多 Agent 系统，没有复杂的编排，适合实验。

#### 5. `/files` - 文件管理

列出会话中更改或引用的所有文件。可以在 Finder 中显示、在 VS Code 中 diff、快速查看，或在提示中引用。

`shift+ctrl+r` 快速查看最近提到的文件，当 Agent 生成 PDF 时很方便。

---

## 软件构建软件

这些扩展都不是 Armin 自己写的，而是**他告诉 Pi 做一个扩展，Pi 就做了**。

> "没有 MCP，没有社区技能，什么都没有。我用了很多技能，但它们都是由我的'小铁匠'（Agent）手工打造的，而不是从任何地方下载的。"

### Armin 的技能示例

- **浏览器自动化技能**: 完全替代了 CLIs 或 MCPs，使用 CDP（Chrome DevTools Protocol）
- **Pi 会话读取技能**: 帮助 Agent 读取其他工程师分享的 Pi 会话，有助于代码审查
- **提交信息技能**: 帮助 Agent 按 Armin 想要的方式编写提交信息和更新变更日志
- **uv 迁移技能**: 帮助 Pi 使用 uv 而不是 pip

---

## Pi vs OpenClaw

| | Pi | OpenClaw |
|--|-----|----------|
| **定位** | 核心 coding agent | 完整的 AI Gateway |
| **界面** | 终端 TUI | 多平台（Telegram/Discord/等） |
| **使用场景** | 开发者本地编码 | 24/7 自动化助手 |
| **关系** | OpenClaw 构建在 Pi 之上 | 包含 Pi |

Pi 是 OpenClaw 的引擎，OpenClaw 是 Pi 的"去 UI 化"版本——移除界面和输出，连接到聊天应用。

---

## 核心启示

1. **极简主义获胜**: 4 个工具足够完成大多数任务
2. **让 Agent 自扩展**: 不要下载扩展，让 Agent 写扩展
3. **Session 树形结构**: 分支和回溯是处理复杂工作流的关键
4. **热重载**: Agent 应该能写代码、测试、修复，循环迭代
5. **软件构建软件**: 这是未来的编程方式

正如 Armin 所说：

> "使用像 Pi 这样的极简 Agent 工作让我真正体验到'用软件构建更多软件'的理念。将其推向极致就是移除 UI 和输出，将其连接到你的聊天应用。这就是 OpenClaw 所做的，考虑到它的巨大增长，我真的越来越觉得这将以某种方式成为我们的未来。"

---

## 相关链接

- **Pi 源码**: https://github.com/badlogic/pi-mono/
- **Mario Zechner**: https://mariozechner.at/
- **Armin 的扩展**: https://github.com/mitsuhiko/agent-stuff/
- **原文**: https://lucumr.pocoo.org/2026/1/31/pi/