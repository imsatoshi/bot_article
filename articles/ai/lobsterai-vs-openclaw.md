---
layout: post
title: "LobsterAI 深度解析：网易有道的「中国版 OpenClaw」有何不同？"
description: "深入对比 LobsterAI 与 OpenClaw 的架构差异、产品定位和适用场景，解析网易有道如何打造全场景个人助理 Agent"
date: 2026-02-19
categories: ai
tags: [lobsterai, openclaw, netease, ai-agent, desktop-agent, electron]
permalink: /ai/lobsterai-vs-openclaw/
---

# LobsterAI 深度解析：网易有道的「中国版 OpenClaw」

> **TL;DR**: LobsterAI 是网易有道开源的桌面级 AI Agent，定位「中国版 OpenClaw」。与 OpenClaw 的 Gateway 架构不同，LobsterAI 采用 Electron + React 构建 GUI 应用，内置 16 种办公技能，支持 IM 远程控制，主打「7×24 小时全场景个人助理」。

---

## 一、LobsterAI 是什么？

**LobsterAI** 是[网易有道](https://www.youdao.com/)于 2025 年底开源的桌面级 AI Agent 项目，官方定位是**「7×24 小时帮你干活的全场景个人助理」**。

### 核心定位

| 特性 | 说明 |
|------|------|
| **桌面应用** | Electron 构建的 GUI 程序，不是命令行工具 |
| **全场景办公** | 数据分析、PPT 制作、视频生成、文档撰写、Web 搜索、邮件收发 |
| **Cowork 模式** | AI 在本地或沙箱环境中自主执行任务，用户监督 |
| **IM 远程控制** | 钉钉、飞书、Telegram、Discord 远程触发 |
| **持久记忆** | 自动提取用户偏好，跨会话记住习惯 |
| **权限门控** | 敏感操作需用户明确批准 |

### 技术栈

| 层级 | 技术 |
|------|------|
| 框架 | Electron 40 |
| 前端 | React 18 + TypeScript + Vite 5 |
| 样式 | Tailwind CSS 3 |
| 状态管理 | Redux Toolkit |
| AI 引擎 | Claude Agent SDK (Anthropic) |
| 存储 | SQLite (sql.js) |
| IM 集成 | DingTalk Stream / Lark SDK / grammY / discord.js |

---

## 二、OpenClaw 是什么？（回顾）

**OpenClaw** 是一个**本地优先的 AI Gateway**：

- 运行在你自己的机器上（Mac、Linux、树莓派、服务器）
- 连接 Claude、GPT 等大模型到 Telegram、Discord、WhatsApp 等聊天工具
- 支持多个独立 Agent，每个有自己的记忆、技能和聊天窗口
- 通过 Skills 扩展功能（文件操作、浏览器控制、代码执行等）
- **以命令行/终端交互为主**，需要一定的技术背景

---

## 三、深度对比：LobsterAI vs OpenClaw

### 1. 产品形态对比

| 维度 | LobsterAI | OpenClaw |
|------|-----------|----------|
| **产品形态** | 🖥️ 桌面 GUI 应用 | 🖥️ 命令行 / Gateway |
| **技术架构** | Electron + React | Python/Node.js Gateway |
| **交互方式** | 图形界面 + IM 远程 | 终端命令 + 聊天界面 |
| **目标用户** | 普通办公用户 | 开发者、技术用户 |
| **上手门槛** | ⭐ 低（开箱即用） | ⭐⭐⭐ 高（需配置部署） |
| **开发公司** | 网易有道 | 开源社区（核心 Peter Steinberger） |

### 2. 核心能力对比

#### LobsterAI 的 16 种内置技能

| 技能 | 功能 | 场景 |
|------|------|------|
| web-search | Web 搜索 | 信息检索 |
| docx | Word 文档生成 | 报告撰写 |
| xlsx | Excel 表格生成 | 数据分析 |
| pptx | PowerPoint 制作 | 演示文稿 |
| pdf | PDF 处理 | 文档解析 |
| remotion | 视频生成 | 宣传视频 |
| playwright | Web 自动化 | 网页操作 |
| canvas-design | Canvas 绘图 | 海报设计 |
| frontend-design | 前端 UI 设计 | 原型制作 |
| develop-web-game | Web 游戏开发 | 快速原型 |
| scheduled-task | 定时任务 | 周期性工作 |
| weather | 天气查询 | 信息获取 |
| local-tools | 本地系统工具 | 文件管理 |
| create-plan | 计划编排 | 项目规划 |
| skill-creator | 自定义技能 | 扩展能力 |
| imap-smtp-email | 邮件收发 | 邮件处理 |

#### OpenClaw 的技能生态

OpenClaw 本身不提供具体技能，而是通过 **Skills 系统**让社区扩展：

- **browser** — 浏览器控制
- **exec** — 命令执行
- **file** — 文件操作
- **coding-agent** — 代码代理
- **healthcheck** — 系统健康检查
- ...（社区持续贡献）

**关键区别**: LobsterAI 是**开箱即用的办公套件**，OpenClaw 是**可扩展的底层平台**。

### 3. 架构设计对比

#### LobsterAI 的 Electron 严格隔离架构

```
┌─────────────────────────────────────────────────────────────┐
│  Renderer Process (React UI)                                │
│  ├─ 所有 UI 和业务逻辑                                       │
│  ├─ Redux Toolkit 状态管理                                  │
│  └─ 仅通过 IPC 与主进程通信                                  │
├─────────────────────────────────────────────────────────────┤
│  Preload Script (安全桥接)                                   │
│  └─ contextBridge 暴露 window.electron API                   │
├─────────────────────────────────────────────────────────────┤
│  Main Process (Electron 主进程)                              │
│  ├─ 窗口生命周期管理                                         │
│  ├─ SQLite 数据持久化                                        │
│  ├─ CoworkRunner (Claude Agent SDK 执行引擎)                │
│  ├─ IM 网关 (钉钉/飞书/Telegram/Discord)                     │
│  └─ 40+ IPC 通道处理                                         │
└─────────────────────────────────────────────────────────────┘
```

**安全设计**:
- context isolation 启用
- node integration 禁用
- sandbox 启用
- 所有敏感操作需用户审批

#### OpenClaw 的 Gateway 架构

```
┌─────────────────────────────────────────────────────────────┐
│  聊天渠道 (Telegram/Discord/WhatsApp/...)                   │
├─────────────────────────────────────────────────────────────┤
│  OpenClaw Gateway                                           │
│  ├─ 多 Agent 管理                                           │
│  ├─ 记忆系统                                                 │
│  ├─ Skill 调度                                               │
│  └─ 消息路由                                                 │
├─────────────────────────────────────────────────────────────┤
│  Skills (工具包)                                             │
│  ├─ browser (浏览器控制)                                     │
│  ├─ exec (命令执行)                                          │
│  ├─ file (文件操作)                                          │
│  └─ ...                                                      │
├─────────────────────────────────────────────────────────────┤
│  大模型 (Claude/GPT/...)                                     │
└─────────────────────────────────────────────────────────────┘
```

### 4. Cowork 模式 vs OpenClaw 模式

#### LobsterAI 的 Cowork 系统

**Cowork** 是 LobsterAI 的核心 —— 基于 Claude Agent SDK 的 AI 工作会话系统。

**执行模式**:

| 模式 | 说明 |
|------|------|
| `auto` | 自动根据上下文选择执行方式 |
| `local` | 本地直接执行，全速运行 |
| `sandbox` | 隔离的 Alpine Linux VM，安全优先 |

**流式事件**:
- `message` — 新消息加入会话
- `messageUpdate` — 流式内容增量更新
- `permissionRequest` — 工具执行需要用户审批
- `complete` — 会话执行完毕
- `error` — 执行出错

#### OpenClaw 的执行模式

OpenClaw 本身不限制执行方式，取决于具体 Skill 的实现：

- **直接执行** — Skill 直接调用系统命令
- **沙箱执行** — 部分 Skill 支持隔离环境
- **审批机制** — 依赖 Skill 自行实现（如 `healthcheck` 的 risk 分级）

### 5. 记忆系统对比

#### LobsterAI 的持久记忆

**自动提取** 用户偏好和个人信息：

| 提取类型 | 示例 | 置信度 |
|----------|------|--------|
| 个人档案 | 「我叫张三」「我是产品经理」 | 高 |
| 个人所有 | 「我养了一只猫」「我有一台 MacBook」 | 高 |
| 个人偏好 | 「我喜欢简洁的风格」 | 中高 |
| 助手偏好 | 「回复时不要用 emoji」 | 中高 |
| 主动告知 | 「记住这个」「请记下来」 | 最高 |

**工作机制**: 每轮对话结束后，记忆提取器分析内容，自动去重合并，后续会话注入 Agent 上下文。

#### OpenClaw 的记忆系统

OpenClaw 的记忆更加**灵活但也更分散**：

- **会话记忆** — 当前对话的上下文
- **AGENTS.md** — 智能体的自我定义
- **MEMORY.md** — 长期记忆的 curated 存储
- **memory/YYYY-MM-DD.md** — 每日原始日志
- **SOUL.md** — 智能体的"灵魂"定义

**关键区别**: LobsterAI 是**自动化的记忆提取**，OpenClaw 是**手动管理+自动化辅助**。

### 6. IM 集成对比

#### LobsterAI 的 IM 远程控制

| 平台 | 协议 | 说明 |
|------|------|------|
| 钉钉 | DingTalk Stream | 企业机器人双向通信 |
| 飞书 | Lark SDK | 飞书应用机器人 |
| Telegram | grammY | Bot API 接入 |
| Discord | discord.js | Discord Bot 接入 |

**使用场景**: 在手机上通过 IM 发送「帮我分析这份数据」「做一份本周工作汇报 PPT」，桌面端 Agent 自动执行并返回结果。

#### OpenClaw 的渠道集成

OpenClaw 本身是多渠道 Gateway：

- Telegram
- Discord
- WhatsApp
- Slack
- Signal
- 更多...

**关键区别**: LobsterAI 是**桌面端 + IM 远程控制**，OpenClaw 是**多渠道并行接入**。

---

## 四、适用场景对比

### 选择 LobsterAI 当...

- ✅ 你是**普通办公用户**，不想折腾命令行
- ✅ 需要**开箱即用的办公技能**（PPT、Excel、文档）
- ✅ 需要**GUI 界面**直观查看任务执行
- ✅ 需要**IM 远程控制**桌面 Agent
- ✅ 需要**定时任务**自动执行周期性工作
- ✅ 希望**自动记忆**个人偏好，无需手动配置

### 选择 OpenClaw 当...

- ✅ 你是**开发者或技术用户**
- ✅ 需要**高度定制化**的 Agent 能力
- ✅ 需要**多 Agent 架构**处理不同任务
- ✅ 需要**社区 Skill 生态**扩展功能
- ✅ 希望**完全控制**数据和执行环境
- ✅ 愿意投入时间**学习配置和部署**

---

## 五、技术实现细节对比

### 1. 执行环境

| 特性 | LobsterAI | OpenClaw |
|------|-----------|----------|
| **沙箱支持** | ✅ Alpine Linux VM | ⚠️ 依赖具体 Skill |
| **执行审批** | ✅ 内置权限门控 | ⚠️ 依赖具体 Skill |
| **工作区限制** | ✅ 限制在指定目录 | ⚠️ 依赖具体 Skill |
| **进程隔离** | ✅ Electron sandbox | ✅ 独立进程 |

### 2. 数据存储

**LobsterAI**:
- SQLite 本地存储 (`lobsterai.sqlite`)
- 表结构：kv、cowork_config、cowork_sessions、cowork_messages、scheduled_tasks

**OpenClaw**:
- Markdown 文件存储 (MEMORY.md、AGENTS.md 等)
- 可选数据库存储（依赖配置）

### 3. 扩展性

**LobsterAI**:
- 内置 `skill-creator` 创建自定义技能
- SKILLs/ 目录热加载

**OpenClaw**:
- Skills/ 目录自定义 Skill
- 社区丰富的 Skill 生态
- 更灵活的架构设计

---

## 六、生态系统与未来

### LobsterAI 生态

- **GitHub Stars**: 快速增长中（作为网易有道开源项目受到关注）
- **社区**: 中文社区为主
- **商业化**: 网易有道背书，可能有企业版规划
- **路线图**: 更多办公技能、更强大的记忆系统、企业级功能

### OpenClaw 生态

- **GitHub Stars**: 20万+（现象级开源项目）
- **社区**: 全球开发者社区
- **商业化**: 纯开源，接受 OpenAI 赞助
- **路线图**: Moltbot、Lobster(workflow shell)、更多 Skill

---

## 七、总结：两条不同的路径

### LobsterAI 的路径

> **「让 AI 办公助手像 Office 一样普及」**

- 降低使用门槛，主打普通用户
- 内置丰富的办公技能
- GUI 优先，体验友好
- 中国企业背景，本土化好

### OpenClaw 的路径

> **「让每个人都能拥有自己的 AI 基础设施」**

- 强调本地优先和隐私
- 高度可扩展的架构
- 技术用户导向
- 全球开源社区驱动

### 两者关系

**不是竞争，是互补**:

- **LobsterAI** 降低了 AI Agent 的使用门槛，让普通用户受益
- **OpenClaw** 提供了更底层、更灵活的基础设施
- **技术用户**可以同时使用两者：OpenClaw 处理复杂任务，LobsterAI 处理日常办公

---

## 八、快速开始

### LobsterAI

```bash
# 克隆仓库
git clone https://github.com/netease-youdao/LobsterAI.git
cd LobsterAI

# 安装依赖
npm install

# 启动开发环境
npm run electron:dev

# 生产构建
npm run build
npm run dist:mac  # 或 dist:win / dist:linux
```

### OpenClaw

```bash
# 安装 OpenClaw CLI
npm install -g openclaw

# 或使用 Docker
docker run -it openclaw/openclaw

# 配置和启动
openclaw configure
openclaw start
```

---

## 参考链接

- **LobsterAI GitHub**: https://github.com/netease-youdao/LobsterAI
- **OpenClaw GitHub**: https://github.com/openclaw/openclaw
- **OpenClaw 官网**: https://openclaw.ai

---

> 📝 **作者注**: 这篇文章基于 LobsterAI 的公开文档和代码仓库整理。LobsterAI 是一个快速迭代的项目，部分细节可能随版本更新而变化。

> **免责声明**: 本文仅为技术解析，不构成任何产品推荐。选择工具请根据实际需求和技术背景决定。
