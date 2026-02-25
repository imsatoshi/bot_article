---
layout: post
title: "Steve Yegge: Welcome to Gas Town - AI Agent 编排系统的未来"
date: 2026-02-26
categories: ai
tags: [Steve Yegge, Gas Town, AI Agent, Claude Code, 编排系统, Beads]
permalink: /ai/steve-yegge-gas-town/
---

# Welcome to Gas Town

> Steve Yegge 最新力作：面向 2026 年的全新 IDE 理念，一个可同时驾驭 20-30 个 Claude Code 实例的 AI Agent 编排系统

**原文链接**: [https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04](https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04)
**作者**: Steve Yegge  
**发布时间**: 2026年1月1日  
**阅读时间**: 34 分钟

---

## Gas Town 是什么？

[Gas Town](https://github.com/steveyegge/gastown) 是 Steve Yegge 为 2026 年设计的全新 IDE 理念。它解决了同时运行大量 Claude Code 实例时的繁琐问题 —— 工作容易丢失、难以追踪谁在做什么等等。Gas Town 帮助你处理这些繁琐的 "剃牦牛毛" 工作，让你专注于 Claude Code 正在处理的核心任务。

在本文中，"Claude Code" 泛指 "Claude Code 及其所有外观相似的竞品"，包括 Codex、Gemini CLI、Amp、Amazon Q-developer CLI 等。它们本质上都是克隆品。

Yegge 在 2025 年 3 月的文章《[Revenge of the Junior Developer](https://sourcegraph.com/blog/revenge-of-the-junior-developer)》中预测了有人会 "将 Claude Code 骆驼们拴在一起组成战车"，而 Gas Town 正是这一预测的实现 —— 你可以同时高效、持续地使用 20-30 个 Claude Code 实例。

---

## 开发者进化八阶段

Yegge 提出了 AI 辅助编程的 **8 个进化阶段**：

| 阶段 | 描述 |
|------|------|
| **Stage 1** | 零或接近零 AI：可能使用代码补全，偶尔问 Chat 问题 |
| **Stage 2** | IDE 中的 Coding agent，权限开启。侧边栏的窄代理询问是否运行工具 |
| **Stage 3** | IDE 中的 Agent，YOLO 模式：信任度提升，关闭权限检查 |
| **Stage 4** | IDE 中的 Wide agent：Agent 逐渐占据整个屏幕，代码只用于看 diff |
| **Stage 5** | CLI 单代理，YOLO。Diff 滚动而过，你可能看也可能不看 |
| **Stage 6** | CLI 多代理，YOLO。你经常使用 3-5 个并行实例，速度非常快 |
| **Stage 7** | 10+ 代理，手工管理。你开始触及手工管理的极限 |
| **Stage 8** | 构建自己的编排器。你处于前沿，自动化你的工作流 |

**警告**: 如果你还未达到 Stage 7，或者 Stage 6 但非常勇敢，你将无法使用 Gas Town。

---

## Gas Town 的七大角色

Gas Town 的 worker 都是常规的 coding agent，每个被提示扮演以下七种明确定义的角色之一：

### 🏙️ **The Town (城镇)**
你的总部。Yegge 的设在 `~/gt`，所有项目 rigs 都放在下面：gastown、beads、wyvern、efrit 等。城镇（Go 二进制 `gt`）管理和编排所有 rigs 上的所有 worker。

### 🏗️ **Rigs (钻机)**
每个放入 Gas Town 管理的项目（git repo）称为一个 Rig。部分角色（Witness、Polecats、Refinery、Crew）是 per-rig，而其他（Mayor、Deacon、Dogs）是 town-level 角色。

### 👤 **The Overseer (监督者)**
这就是 **你**，人类。第八个角色。作为 Overseer，你在系统中有身份、有自己的收件箱，可以收发城镇邮件。你是老板、老大、大人物。

### 🎩 **The Mayor (市长)**
这是你最常对话的主要 agent。它是你的门房和参谋长。如果市长忙，其他 worker 也都是 Claude Code，都很聪明和乐于助人。

### 😺 **Polecats (野猫)**
Gas Town 是一个工作群涌引擎。Polecats 是按需启动的 per-rig 临时 worker。它们经常成群工作，生成 Merge Requests (MRs)，然后交给 Merge Queue (MQ)。合并后完全退役，但名字会回收。

### 🏭 **Refinery (精炼厂)**
当你开始群涌 worker 时，会遇到 Merge Queue (MQ) 问题。Refinery 是负责智能合并所有变更到 main 的工程师 agent，一次一个。工作不能丢失，但允许升级。

### 🦉 **The Witness (见证者)**
当你启动足够多的 polecats 时，你会意识到需要一个 agent 专门照看它们，帮助它们摆脱困境。Witness 巡逻帮助平滑这个过程。

### 🐺 **The Deacon (执事)**
Deacon 是 daemon beacon。它是一个巡逻 Agent：在循环中运行 "巡逻"（明确定义的工作流）。Gas Town 有一个 daemon 每几分钟 ping 一次 Deacon 说 "Do your job"。

### 🐶 **Dogs (狗群)**
受 Mick Herron 的 MI5 "Dogs" 启发，这是 Deacon 的私人团队。与 polecats 不同，Dogs 是 town-level worker。它们做维护工作（清理过期分支等）和 Deacon 的杂工工作。

### 👷 **The Crew (船员)**
尽管排在列表最后，但 Crew 是你个人使用最多的 agents（仅次于市长）。Crew 是为你（Overseer）工作的 per-Rig coding agents，不受 Witness 管理。你选择他们的名字，他们有长期身份。

---

## Gas Town 通用推进原理 (GUPP)

**GUPP** 是保持 Gas Town 运转的核心。Claude Code 最大的问题是它会结束 —— 上下文窗口满了，就没动力了，停下来。

GUPP 简单地陈述：**如果你的钩子上有工作，你必须运行它。**

所有 Gas Town worker，在所有角色中，都在 Beads 中拥有持久身份，也就是在 Git 中。

---

## 为什么你可能不应该使用 Gas Town

Yegge 非常诚实地列出了 **不应该** 使用 Gas Town 的理由：

1. **代码库不到 3 周大** —— 还在早期，需要消毒
2. **100% vibe coded** —— Yegge 从未看过代码，也不在乎
3. **你可能还没准备好** —— 如果你还没到 Stage 7，不能用
4. **需要承诺 vibe coding** —— 工作变得流动，有些会丢失
5. **贵得离谱** —— Yegge 已经需要第二个 Claude Code 账户，下周需要第三个
6. **使用 tmux 作为主要 UI** —— 你需要学习 tmux
7. **基于 Beads** —— 必须使用 Beads 才能用 Gas Town

---

## 与 Kubernetes 和 Temporal 的比较

Yegge 将 Gas Town 比作 **Kubernetes** 和 **Temporal**：
- 都具有编排工作流的特性
- 都有插件和质量门禁
- 都有 Merge Queue
- Gas Town 就像是 Kubernetes 和 Temporal 生了一个非常丑的宝宝

但它是有效的！Gas Town 可以轻松解决 [MAKER 问题](https://arxiv.org/abs/2511.09030)（20 盘汉诺塔）—— 用一百万步的 wisp 就能从公式生成解决方案。

---

## Beads：Gas Town 的数据平面

[Beads](https://github.com/steveyegge/beads) 是 Gas Town 中工作的原子单位。一个 bead 是一种特殊的问题追踪器 issue，有 ID、描述、状态、负责人等。Beads 以 JSON 存储（每行一个 issue），并与项目 repo 一起追踪在 Git 中。

Gas Town 有两层 Beads 结构：
- **Rig beads** —— 项目级别的工作
- **Town beads** —— 城镇级别的编排工作

---

## 关键洞察

1. **AI Agent 编排是下一个大事件** —— Yegge 预测并实现了这一点
2. **Claude Code 只是构建块** —— 真正的力量在于编排多个 agents
3. **vibe coding 需要接受混乱** —— 不是所有工作都能 100% 高效，但吞吐量惊人
4. **需要工业化思维** —— Gas Town 是一个由超级智能机器人黑猩猩操作的工业化编码工厂

---

## 相关链接

- **Gas Town GitHub**: https://github.com/steveyegge/gastown
- **Beads GitHub**: https://github.com/steveyegge/beads
- **原文**: https://steve-yegge.medium.com/welcome-to-gas-town-4f25ee16dd04
- **Revenge of the Junior Developer**: https://sourcegraph.com/blog/revenge-of-the-junior-developer
- **MAKER 论文**: https://arxiv.org/abs/2511.09030

---

*Gas Town 代表了 AI 辅助编程的下一个前沿 —— 从单个 agent 到工业化规模的 agent 编排系统。*
