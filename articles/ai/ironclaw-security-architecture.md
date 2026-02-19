---
layout: post
title: "IronClaw 深度解析：NEAR AI 的安全 AI 助手架构"
date: 2026-02-18
categories: ai
tags: [AI, Agent, Security, Rust, WASM, NEAR, IronClaw, OpenClaw]
permalink: /ai/ironclaw-security-architecture/
---

# IronClaw 深度解析：NEAR AI 的安全 AI 助手架构

**项目**: IronClaw  
**官网**: https://github.com/nearai/ironclaw  
**开发**: NEAR AI  
**整理时间**: 2026-02-18

---

## 📋 项目概述

**IronClaw** 是由 **NEAR AI** 团队开发的 AI 助手系统，基于 [OpenClaw](https://github.com/openclaw/openclaw) 理念用 **Rust** 完全重写。它代表了对 AI 安全性和隐私保护的极致追求 —— **你的数据永远属于你**。

> **核心理念**: AI assistant should work for you, not against you.

与 OpenClaw 最大的区别在于：**安全优先的设计理念**和**WASM 沙箱架构**。

---

## 🎯 为什么需要 IronClaw？

### 当前 AI 助手的痛点

| 问题 | 传统方案 | IronClaw 方案 |
|------|----------|---------------|
| **数据隐私** | 数据上传云端，不透明处理 | 完全本地存储，加密保护 |
| **凭证安全** | API Key 直接暴露给工具 | 占位符 + Host 边界注入 |
| **提示词注入** | 无防护或简单过滤 | 多层防御 + 内容消毒 |
| **工具可信度** | 完全信任 | WASM 沙箱隔离 |
| **扩展性** | 等待官方更新 | 动态构建 WASM 工具 |

### IronClaw 的承诺

- ✅ **Your data stays yours** - 所有信息本地存储、加密，永不离开你的控制
- ✅ **Transparency by design** - 开源、可审计、无隐藏遥测或数据收集
- ✅ **Self-expanding capabilities** - 无需等待供应商更新，即时构建新工具
- ✅ **Defense in depth** - 多层安全保护，防止提示词注入和数据泄露

---

## 🏗️ 核心安全架构

### 1️⃣ WASM 沙箱（WASM Sandbox）

IronClaw 最大的创新：**所有不受信任的工具都在隔离的 WebAssembly 容器中运行**。

```
WASM ──► Allowlist Validator ──► Leak Scan (request) 
                                    │
                                    ▼
                           Credential Injector ──► Execute Request 
                                    │
                                    ▼
                           Leak Scan (response) ──► WASM
```

**安全特性**：

| 特性 | 说明 |
|------|------|
| **Capability-based permissions** | 显式选择 HTTP、secrets、工具调用权限 |
| **Endpoint allowlisting** | HTTP 请求只允许访问批准的主机/路径 |
| **Credential injection** | 凭证在 Host 边界注入，WASM 代码永不接触真实 secret |
| **Leak detection** | 扫描请求和响应，检测 secret 泄露尝试 |
| **Rate limiting** | 每个工具的请求限制，防止滥用 |
| **Resource limits** | 内存、CPU、执行时间约束 |

### 2️⃣ 凭证保护机制（Credential Protection）

这是 IronClaw 最精妙的设计 —— **LLM 永远接触不到真实 secret**。

**工作流程**：

1. **占位符系统**
   - 工具代码中使用占位符如 `{{API_KEY}}`
   - LLM 只看到占位符，不知道真实值

2. **Host 边界注入**
   - 请求离开 WASM 沙箱时，Host 层将占位符替换为真实凭证
   - 注入后扫描泄露

3. **双向泄露检测**
   - 请求发出前：扫描是否包含真实 secret
   - 响应返回后：扫描是否包含 secret 泄露
   - 22 条正则规则拦截泄露尝试

**应用到钱包保护**：
- AI 只表达意图（"转账 0.1 ETH 到 0x123..."）
- Host 层完成实际签名
- 私钥永不暴露给 AI

### 3️⃣ 提示词注入防御（Prompt Injection Defense）

外部内容通过多层安全验证：

```
外部输入
    ↓
Pattern Detection（模式检测）
    ↓
Content Sanitization（内容消毒）
    ↓
Policy Enforcement（策略执行）
    ↓
Safe LLM Context
```

**策略等级**：
- **Block** - 完全阻止
- **Warn** - 警告但允许
- **Review** - 标记待审核
- **Sanitize** - 消毒处理后使用

---

## 🏛️ 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                        Channels                             │
│  ┌──────┐  ┌──────┐  ┌─────────────┐  ┌─────────────┐    │
│  │ REPL │  │ HTTP │  │WASM Channels│  │ Web Gateway │    │
│  └──┬───┘  └──┬───┘  └──────┬──────┘  │ (SSE + WS)  │    │
│     │         │             │          └──────┬──────┘    │
│     └─────────┴─────────────┴─────────────────┘            │
│                         │                                   │
│              ┌──────────▼──────────┐                        │
│              │    Agent Loop       │                        │
│              │  (Intent routing)   │                        │
│              └────┬──────────┬─────┘                        │
│                   │          │                              │
│        ┌──────────▼──┐  ┌────▼──────────────┐              │
│        │ Scheduler   │  │ Routines Engine   │              │
│        │(parallel)   │  │(cron, events)     │              │
│        └──────┬──────┘  └───────┬───────────┘              │
│               │                 │                          │
│        ┌──────┴─────────────────┘                          │
│        │                                                    │
│   ┌────▼─────┐  ┌─────────────────────────┐                │
│   │  Local   │  │      Orchestrator       │                │
│   │ Workers  │  │  ┌───────────────────┐  │                │
│   │(in-proc) │  │  │  Docker Sandbox   │  │                │
│   └────┬─────┘  │  │  ┌─────────────┐  │  │                │
│        │        │  │  │Worker / CC  │  │  │                │
│        │        │  │  └─────────────┘  │  │                │
│        │        │  └───────────────────┘  │                │
│        │        └──────────┬──────────────┘                │
│        └───────────────────┤                               │
│                            │                               │
│                   ┌────────▼────────┐                      │
│                   │  Tool Registry  │                      │
│                   │Built-in/MCP/WASM│                      │
│                   └─────────────────┘                      │
└─────────────────────────────────────────────────────────────┘
```

### 核心组件

| 组件 | 功能 |
|------|------|
| **Agent Loop** | 主消息处理和任务协调 |
| **Router** | 分类用户意图（命令、查询、任务） |
| **Scheduler** | 管理并行任务执行和优先级 |
| **Worker** | 执行任务，LLM 推理和工具调用 |
| **Orchestrator** | 容器生命周期、LLM 代理、每任务认证 |
| **Web Gateway** | 浏览器 UI，实时 SSE/WebSocket |
| **Routines Engine** | 定时任务（cron）和响应式任务 |
| **Workspace** | 持久化内存，混合搜索 |
| **Safety Layer** | 提示词注入防御和内容消毒 |

---

## 🔧 技术栈对比：IronClaw vs OpenClaw

| 维度 | OpenClaw | IronClaw |
|------|----------|----------|
| **语言** | TypeScript/Node | Rust |
| **性能** | 解释型，GC 暂停 | 原生性能，内存安全 |
| **部署** | 多依赖，容器化 | 单二进制文件 |
| **沙箱** | Docker | WASM（更轻量） |
| **数据库** | SQLite | PostgreSQL + pgvector |
| **安全模型** | 基础权限 | 能力基权限 + 多层防御 |
| **凭证保护** | 基础加密 | 占位符 + 边界注入 |
| **扩展方式** | Node.js 模块 | WASM 动态构建 |

### Rust 带来的优势

> "Native performance, memory safety, single binary"

- **内存安全**: 编译时保证，无内存泄漏
- **零成本抽象**: 高性能，无运行时开销
- **单二进制**: 一个文件，无依赖，随处运行
- **WASM 原生支持**: 沙箱隔离开箱即用

---

## 🚀 核心功能

### 1. 动态工具构建（Dynamic Tool Building）

描述你需要的功能，IronClaw 自动构建为 WASM 工具：

```
用户: "我需要一个能查询 GitHub 仓库星数的工具"
AI: 生成 Rust 代码 → 编译为 WASM → 注册到 Tool Registry → 立即可用
```

### 2. MCP 协议支持

连接 Model Context Protocol 服务器，扩展能力：
- 文件系统访问
- 数据库查询
- API 集成
- 自定义工具

### 3. 持久化记忆（Persistent Memory）

- **Hybrid Search**: 全文搜索 + 向量搜索（RRF 融合）
- **Workspace Filesystem**: 灵活的路径存储
- **Identity Files**: 跨会话保持一致个性

### 4. 多通道支持

| 通道 | 说明 |
|------|------|
| **REPL** | 命令行交互 |
| **HTTP Webhooks** | 外部系统集成 |
| **WASM Channels** | Telegram、Slack 等 |
| **Web Gateway** | 浏览器 UI，实时 SSE/WebSocket |

### 5. 心跳系统（Heartbeat System）

主动后台执行监控和维护任务，无需人工触发。

---

## 📦 安装与配置

### 环境要求

- Rust 1.85+
- PostgreSQL 15+（带 pgvector 扩展）
- NEAR AI 账户

### 快速安装

```bash
# macOS / Linux
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/nearai/ironclaw/releases/latest/download/ironclaw-installer.sh | sh

# Windows
irm https://github.com/nearai/ironclaw/releases/latest/download/ironclaw-installer.ps1 | iex
```

### 数据库设置

```bash
createdb ironclaw
psql ironclaw -c "CREATE EXTENSION IF NOT EXISTS vector;"
```

### 首次配置

```bash
ironclaw onboard
```

配置向导处理：
- 数据库连接
- NEAR AI 认证（浏览器 OAuth）
- Secrets 加密（系统密钥链）

---

## 💡 使用场景

### 场景 1：安全的钱包操作

```
用户: "转账 0.5 ETH 给 Alice"
AI意图: 识别转账意图，构造交易
Host层: 使用私钥签名，提交区块链
AI: 永远接触不到私钥
```

### 场景 2：企业级 API 调用

```
工具代码: curl -H "Authorization: {{API_KEY}}" https://api.company.com/data
实际执行: Host 将 {{API_KEY}} 替换为真实密钥
泄露检测: 扫描响应是否包含密钥
```

### 场景 3：不受信任的工具

```
未知来源工具 → WASM 沙箱 → 能力限制（仅允许特定域名）
              → 资源限制（内存/CPU/时间）
              → 泄露检测
              → 安全执行
```

---

## 🔐 安全最佳实践

### 1. 最小权限原则

每个工具只授予最小必要权限：
```yaml
capabilities:
  http: ["api.github.com", "api.openai.com"]
  secrets: ["GITHUB_TOKEN"]
  filesystem: ["/tmp/workspace"]
```

### 2. 端点白名单

严格控制工具可访问的 API：
```yaml
allowlist:
  - github.com/api/v3/**
  - api.openai.com/v1/chat/**
```

### 3. 审计日志

所有工具执行记录完整日志：
```json
{
  "tool": "github_search",
  "timestamp": "2026-02-18T10:30:00Z",
  "request": "...",
  "response_hash": "sha256:...",
  "leak_scan": "passed"
}
```

---

## 🌟 与 OpenClaw 的关系

IronClaw 是 OpenClaw 的 **Rust 重实现**，灵感来源于 OpenClaw，但在以下方面超越：

| 方面 | 改进 |
|------|------|
| **性能** | Rust 原生性能 vs Node.js 解释型 |
| **安全** | WASM 沙箱 + 多层防御 vs 基础 Docker 隔离 |
| **部署** | 单二进制 vs 复杂依赖 |
| **数据库** | PostgreSQL 生产级 vs SQLite 轻量级 |
| **凭证保护** | 占位符 + 边界注入 vs 基础加密 |

**FEATURE_PARITY.md** 详细追踪了功能对比矩阵。

---

## 🎯 适用人群

- **隐私敏感用户**: 数据不想上传云端
- **开发者**: 需要构建自定义 AI 工具
- **企业**: 需要安全可控的 AI 自动化
- **加密用户**: 需要保护私钥的 AI 助手

---

## 🔗 相关资源

- **GitHub**: https://github.com/nearai/ironclaw
- **Releases**: https://github.com/nearai/ironclaw/releases
- **文档**: 内联在 README 中
- **License**: Apache 2.0 / MIT 双许可

---

## 🏷️ 标签

`#AI` `#Agent` `#Security` `#Rust` `#WASM` `#NEAR` `#Privacy` `#IronClaw` `#OpenClaw` `#WASM沙箱` `#凭证保护` `#提示词注入防御`