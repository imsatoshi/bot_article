---
layout: post
title: "pi-mono × OpenViking：给 AI Agent 装上持久记忆"
description: "深度解析 pi-mono 与 OpenViking 的结合方案，探索工具优先的记忆架构设计"
date: 2026-02-19
categories: ai
tags: [pi-mono, openviking, memory, ai-agent, persistent-memory]
permalink: /ai/pi-mono-openviking-memory/
---

# pi-mono × OpenViking：给 AI Agent 装上持久记忆

> 原文作者: roger (@lbq110)  
> 原文链接: https://x.com/i/status/2024402486639952220  
> 项目地址: https://github.com/lbq110/pi-mono/tree/feat/pi-viking-memory  
> 整理时间: 2026-02-19

---

## 引言：记忆是 Agent 的刚需

很多朋友抱怨 [OpenViking](https://github.com/lbq110/OpenViking) 不知道怎么用。最近，开发者 roger 将其与 [pi-mono](https://github.com/badlogic/pi-mono) 结合起来，提供了一个优雅的解决方案。

**核心洞察**: LLM 是大脑，pi-mono 是身体，OpenViking 是海马体。

---

## 一、三者关系定位

| 组件 | 角色 | 职责 |
|------|------|------|
| **LLM** | 大脑 | 推理和决策，但天生无记忆——每次对话都是失忆状态 |
| **pi-mono** | 身体 | AI Agent 框架，给 LLM 装上工具调用、任务执行等能力，让它能真正干活 |
| **OpenViking** | 海马体 | 专门解决记忆问题，负责跨 session 的持久化存储与语义检索 |

**三者组合**，才构成一个"用过就记住、下次还认识你"的完整 Agent。

---

## 二、核心设计思想：工具优先，记忆为辅

### 与主流 RAG 方案的区别

**主流做法（被动注入）**:
```
每次对话开始前 → 系统自动检索历史记忆 → 塞进上下文 → LLM 被动接收
```

**问题很明显**:
- LLM 不知道这些记忆从哪来、是否可信
- 当前场景是否真的用得上
- 记忆变成了噪音，上下文窗口被无效信息占满
- 反而干扰推理

**pi-mono 的选择（主动工具）**:
```
记忆以工具形式存在 → 召回这个动作交给 LLM 来决策
```

Agent 在推理过程中自己判断：
- "我现在需要回忆什么吗？"
- "这件事值得记下来吗？"

**记忆从被动注入变成主动行为**，和搜索网页、执行代码在逻辑上完全对等。

### 好处与代价

| 方面 | 说明 |
|------|------|
| **好处** | 召回有明确意图，保存有明确判断，记忆的质量和相关性都更高 |
| **代价** | Agent 需要足够"聪明"才能知道什么时候该用记忆工具——但这正是现代 LLM 擅长的事 |

---

## 三、架构设计：两层分离

### 架构概览

```
Pi-mono Agent
     │
     ├── 主动工具（LLM 决定何时调用）
     │     ├── recall_memory(query, scope?)  → 语义搜索历史记忆
     │     ├── save_memory(content)          → 显式保存关键信息
     │     ├── explore_memory(uri)           → 浏览记忆文件系统
     │     └── add_knowledge(path)           → 索引本地文件/目录
     │
     └── 被动钩子（透明自动执行，LLM 无感知）
           ├── before_agent_start  → 创建 OV session，注入记忆系统提示
           ├── session_compact     → 同步消息 + 提交（提取记忆）
           └── session_shutdown    → 同步消息 + 提交（提取记忆）
                                           │
                                   OpenViking HTTP API (localhost:1933)
                                   独立 Python 进程
```

### 主动工具（Active Tools）

Agent 自行决策调用，四个核心工具：

| 工具 | 功能 | 使用场景 |
|------|------|----------|
| `recall_memory` | 语义搜索历史记忆 | "我现在需要回忆什么吗？" |
| `save_memory` | 显式保存关键信息 | "这件事值得记下来吗？" |
| `explore_memory` | 浏览记忆文件系统 | 查看有哪些记忆 |
| `add_knowledge` | 索引本地文件/目录 | 将项目文档纳入知识库 |

#### recall_memory 详解

```typescript
recall_memory(query: string, scope?: "preferences"|"entities"|"cases"|"all", limit?: number)
```

Scopes 对应 Viking URI 前缀：

| scope | 搜索范围 |
|-------|----------|
| `preferences` | `viking://user/memories/preferences/` |
| `entities` | `viking://user/memories/entities/` |
| `cases` | `viking://user/memories/cases/` |
| `all` (默认) | `viking://user/memories/` |

### 被动钩子（Passive Hooks）

透明自动执行，LLM 无感知：

| 钩子 | 触发时机 | 功能 |
|------|----------|------|
| `before_agent_start` | Agent 启动前 | 建立 OV session，注入记忆能力系统提示 |
| `session_compact` | 会话压缩时 | 增量同步消息 + 触发记忆提取 |
| `session_shutdown` | 会话关闭时 | 同步消息 + 提交会话（提取记忆） |

**底层实现**: 跑在 `localhost:1933` 的独立 Python 进程，通过 HTTP API 通信。

---

## 四、三层存储模型

| 层级 | 决策者 | 执行时机 | 说明 |
|------|--------|----------|------|
| **消息同步** | 自动钩子 | compact/shutdown 时静默追加对话 | 对话内容自动同步到 OV session |
| **记忆提取** | OV 内部 LLM pipeline | commit 时自动执行 | 提取 preferences / entities / cases |
| **主动召回/保存** | Agent LLM | 调用工具时 | Agent 自己决定何时使用记忆 |

---

## 五、实际效果演示

### Session 1：保存记忆

```
用户: "我喜欢用 anyhow 做 Rust 错误处理"

Agent: 调用 save_memory 保存

关闭 pi → OV 自动提取 → 写入 viking://user/memories/preferences/
```

### Session 2：全新进程，零上下文

```
用户: "帮我写个 Rust 工具"

Agent: 调用 recall_memory("Rust preferences")

→ 搜到上次的偏好，自动用 anyhow，不过度抽象
```

**关键**: 即使全新进程、零上下文，Agent 也能记住用户的偏好。

---

## 六、容错设计：记忆是增强，不是依赖

**设计原则**: OV 挂了，pi 照跑。

| 场景 | 处理方式 |
|------|----------|
| `health()` 检测失败 | 静默跳过，不注入系统提示 |
| 工具调用失败 | 返回描述性文本，不抛异常 |
| 所有钩子 | try/catch 吞错误，主流程不受影响 |

**核心思想**: 记忆是增强功能，不是系统依赖。即使记忆服务不可用，Agent 依然能正常工作。

---

## 七、快速开始

### 1. 安装并启动 OpenViking

```bash
git clone https://github.com/lbq110/OpenViking
cd openviking

uv venv .venv
uv pip install setuptools pybind11 cmake
uv pip install -e "."
```

创建配置文件 `~/.openviking/ov.conf`（示例使用 Gemini）：

```json
{
  "storage": {
    "vectordb": { "backend": "local", "path": "~/.openviking/data" },
    "agfs":     { "backend": "local", "path": "~/.openviking/data", "port": 1833 }
  },
  "embedding": {
    "dense": {
      "provider": "openai",
      "model": "models/gemini-embedding-001",
      "api_key": "<your-gemini-api-key>",
      "api_base": "https://generativelanguage.googleapis.com/v1beta/openai/",
      "dimension": 3072
    }
  },
  "vlm": {
    "model": "gemini-2.0-flash",
    "provider": "gemini",
    "providers": {
      "gemini": { "api_key": "<your-gemini-api-key>" }
    }
  }
}
```

启动服务：

```bash
.venv/bin/openviking serve --config ~/.openviking/ov.conf &
```

### 2. 配置扩展

```bash
mkdir -p ~/.pi
cp packages/pi-viking-memory/config-templates/viking-memory.json ~/.pi/viking-memory.json
```

### 3. 安装扩展

```bash
mkdir -p ~/.pi/agent/extensions
ln -sfn /path/to/pi-mono/packages/pi-viking-memory \
        ~/.pi/agent/extensions/viking-memory
```

验证安装：

```bash
pi --print "list all available tools"
# 应该显示: recall_memory, save_memory, explore_memory, add_knowledge
```

---

## 八、技术亮点

### 1. 完全测试覆盖

- 42 个单元测试
- 覆盖 OVClient、SessionManager 和所有四个工具
- 使用 vitest + mocked fetch

### 2. 技术栈

| 组件 | 技术 |
|------|------|
| 构建 | Go + CMake |
| Vector DB | 本地存储 |
| Embedding | Gemini (models/gemini-embedding-001, 3072-dim) |
| VLM | Gemini 2.0 Flash |
| 测试 | Vitest |

### 3. 优雅的降级

所有工具在 OpenViking 不可用时都能优雅降级，不影响主流程。

---

## 九、总结：一种新的记忆范式

pi-mono × OpenViking 的整合展示了一种新的 AI Agent 记忆范式：

**不是**把记忆塞进上下文让 LLM 被动接受，  
**而是**把记忆变成工具让 LLM 主动决策。

这种"工具优先，记忆为辅"的设计：
- 更符合 LLM 的能力模型
- 记忆质量更高（有明确意图）
- 系统更健壮（优雅降级）
- 用户体验更好（跨 session 持久）

---

## 参考链接

- **Twitter 原文**: https://x.com/i/status/2024402486639952220
- **GitHub 仓库**: https://github.com/lbq110/pi-mono/tree/feat/pi-viking-memory
- **OpenViking**: https://github.com/lbq110/OpenViking
- **pi-mono**: https://github.com/badlogic/pi-mono

---

> 📝 **作者注**: 本文基于 roger 的 Twitter 分享和开源仓库整理。pi-viking-memory 是一个快速迭代的实验性项目，部分细节可能随版本更新而变化。
