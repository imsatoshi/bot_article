---
layout: post
title: "epro-memory 深度解析：LLM Agent 的六级分类记忆系统"
date: 2026-02-18
categories: ai
tags: [AI, Agent, Memory, LanceDB, OpenViking, epro-memory, VectorDB]
permalink: /ai/epro-memory-agent-memory/
---

# epro-memory 深度解析：LLM Agent 的六级分类记忆系统

**项目**: epro-memory  
**作者**: Toby Bridges  
**GitHub**: https://github.com/toby-bridges/epro-memory  
**整理时间**: 2026-02-18

---

## 📋 项目概述

**epro-memory** 是一个 **LLM-powered Agent 记忆插件**，基于 **LanceDB** 向量存储和 OpenAI-compatible API 构建。

**核心特性**：
- ✅ **6级分类记忆系统**（6-category classification）
- ✅ **L0/L1/L2 三层结构**（tiered structure）
- ✅ **自动记忆提取**（LLM-powered extraction）
- ✅ **向量去重**（embedding similarity + LLM dedup）
- ✅ **智能召回**（vector search with relevance threshold）

**技术栈**：
- **向量存储**: LanceDB（嵌入式、无服务器）
- **嵌入模型**: OpenAI-compatible API（text-embedding-3-small）
- **提取模型**: OpenAI-compatible API（gpt-4o-mini）
- **配置验证**: TypeBox（JSON Schema-compatible）

---

## 🏗️ 六级记忆分类系统

| 分类 | 类型 | 合并行为 | 描述 |
|------|------|----------|------|
| **profile** | User | Always merge | 用户身份和静态属性 |
| **preferences** | User | Merge by topic | 用户倾向、习惯和偏好 |
| **entities** | User | Merge supported | 项目、人员、组织 |
| **events** | User | Append only | 决策、里程碑、发生的事情 |
| **cases** | Agent | Append only | 问题+解决方案对 |
| **patterns** | Agent | Merge supported | 可复用的流程和方法 |

### 分类设计哲学

**User vs Agent**：
- **User 类型**（profile, preferences, entities, events）：关于用户的信息
- **Agent 类型**（cases, patterns）：Agent 自身积累的经验

**合并策略**：
- **Always merge**（profile）：用户身份始终更新
- **Merge by topic**（preferences）：按主题合并偏好
- **Merge supported**（entities, patterns）：支持合并但不强制
- **Append only**（events, cases）：只追加不修改历史

---

## 📊 L0/L1/L2 三层结构

**灵感来源**: [OpenViking](https://github.com/toby-bridges/OpenViking) 项目

| 层级 | 名称 | 内容 | 用途 |
|------|------|------|------|
| **L0** | Abstract | 一句话摘要 | 快速召回、索引扫描 |
| **L1** | Summary | 结构化摘要 | 中等详细度查询 |
| **L2** | Narrative | 完整叙述 | 详细上下文需求 |

### 渐进式披露（Progressive Disclosure）

```
Query → L0 扫描 → 匹配则深入 L1 → 需要细节则读取 L2
```

**优势**：
- 大部分决策在读取完整内容前完成
- 按需加载，节省 token
- 快速过滤不相关记忆

---

## 🔄 提取与召回流程

### 提取流程（Extraction Pipeline）

```
Conversation
    ↓
LLM Extraction（提取候选记忆）
    ↓
Vector Similarity Search（向量相似性搜索）
    ↓
Dedup Decision（去重决策：CREATE / MERGE / SKIP）
    ↓
Persist to LanceDB（持久化到 LanceDB）
```

**去重策略**：
1. **Vector pre-filter**：嵌入相似度预筛选
2. **LLM decision**：LLM 决定 CREATE / MERGE / SKIP
3. **Category-aware merge**：根据分类执行不同合并逻辑

### 召回流程（Recall Pipeline）

```
User Prompt
    ↓
Embed（向量化）
    ↓
Vector Search（向量搜索）
    ↓
Filter by Score（按相似度分数过滤）
    ↓
Group by Category（按分类分组）
    ↓
Inject as <agent-experience> context（注入上下文）
```

---

## 🛠️ 快速开始

### 安装

```bash
pnpm add @moltbot/epro-memory
```

### 配置

```json
{
  "embedding": {
    "apiKey": "${OPENAI_API_KEY}",
    "model": "text-embedding-3-small"
  },
  "llm": {
    "apiKey": "${OPENAI_API_KEY}",
    "model": "gpt-4o-mini"
  }
}
```

**⚠️ 安全提示**: 永远不要硬编码 API Key，使用环境变量或密钥管理器。

### 配置选项

| 选项 | 类型 | 默认 | 描述 |
|------|------|------|------|
| `embedding.apiKey` | string | required | 嵌入服务 API Key |
| `embedding.model` | string | text-embedding-3-small | 嵌入模型 |
| `embedding.baseUrl` | string | — | 自定义 API 端点 |
| `llm.apiKey` | string | required | LLM 提取 API Key |
| `llm.model` | string | gpt-4o-mini | LLM 模型 |
| `llm.baseUrl` | string | — | 自定义 API 端点 |
| `dbPath` | string | ~/.clawdbot/memory/epro-lancedb | LanceDB 存储路径 |
| `autoCapture` | boolean | true | 自动从对话提取记忆 |
| `autoRecall` | boolean | true | 自动注入相关记忆 |
| `recallLimit` | number | 5 | 每次查询最大召回记忆数 |
| `recallMinScore` | number | 0.3 | 召回最小相似度分数 |
| `extractMinMessages` | number | 4 | 提取前最小对话消息数 |
| `extractMaxChars` | number | 8000 | 最大处理字符数 |

---

## 🧪 测试覆盖

**106 个单元测试**，7 个测试套件：

| 套件 | 测试数 | 覆盖范围 |
|------|--------|----------|
| config | 23 | 模式验证、类型强制、范围检查、默认值 |
| validators | 19 | UUID 格式、分类白名单、SQL 注入拒绝 |
| llm-parser | 22 | 从 LLM 响应提取 JSON、边界情况 |
| conversation | 17 | 消息提取、截断、内容块格式 |
| extractor | 13 | 记忆提取管道、候选解析 |
| deduplicator | 12 | 向量去重、合并决策、分类感知逻辑 |
| db.integration | 7 | LanceDB CRUD、向量搜索、并发写入 |

**运行测试**：
```bash
pnpm test         # 单元测试
pnpm test:all     # 单元 + 集成测试
```

---

## 🔍 技术选型

| 组件 | 选择 | 原因 |
|------|------|------|
| **Vector storage** | LanceDB | 嵌入式、无服务器、无需外部 DB 进程 |
| **Config validation** | TypeBox | JSON Schema 兼容的运行时类型安全验证 |
| **Embedding & LLM** | OpenAI-compatible API | 通过 baseUrl 覆盖支持多种提供商 |
| **Memory classification** | 6-category system | 从 [OpenViking](https://github.com/toby-bridges/OpenViking) 移植，平衡粒度和合并语义 |
| **Tiered structure** | L0/L1/L2 | 按需注入：召回用一句话，需要时用完整叙述 |
| **Dedup strategy** | Vector pre-filter + LLM decision | 消除重复但不丢失细微差别 |

---

## 🎯 与 OpenViking 的关系

**epro-memory** 的 **6级分类记忆系统**、**L0/L1/L2 三层结构**、以及提示模板（提取、去重、合并）都是从 **[OpenViking](https://github.com/toby-bridges/OpenViking)** 项目移植而来。

**OpenViking** 是一个开源的 LLM Agent 框架，具有持久记忆功能。

---

## 💡 核心洞察

### 1. 记忆分类的粒度

6级分类平衡了：
- **粒度**：足够细致以支持不同合并策略
- **实用性**：不过于复杂导致难以维护

### 2. 渐进式披露的价值

L0/L1/L2 三层结构实现了：
- **快速扫描**：L0 一句话摘要用于索引
- **按需深入**：只有需要时才读取 L2 完整内容
- **Token 效率**：避免不必要的长文本加载

### 3. 去重 vs 保真

**Vector pre-filter + LLM decision** 策略：
- **向量预筛选**：快速找出潜在重复
- **LLM 决策**：保留细微差别，避免粗暴合并
- **分类感知**：不同分类有不同合并语义

---

## 🚀 应用场景

### 场景 1：个人助手记忆

```
User: "我喜欢喝美式咖啡，不加糖"
→ 提取: preference("咖啡偏好", "美式, 无糖")
→ 合并: 更新 preferences 分类

User: "上周三我参加了张三的婚礼"
→ 提取: event("参加婚礼", "2026-02-10", "张三的婚礼")
→ 追加: events 分类（append only）
```

### 场景 2：编程 Agent 经验积累

```
Agent 解决: "React useEffect 无限循环问题"
→ 提取: case("useEffect 无限循环", "解决方案...")
→ 提取: pattern("useEffect 依赖检查", "检查依赖数组...")
→ 追加/合并: cases 和 patterns 分类

下次遇到类似问题：
→ 召回相关 cases 和 patterns
→ 注入上下文帮助解决
```

---

## 🔗 相关资源

- **GitHub**: https://github.com/toby-bridges/epro-memory
- **中文 README**: https://github.com/toby-bridges/epro-memory/blob/main/README.zh-CN.md
- **灵感来源**: [OpenViking](https://github.com/toby-bridges/OpenViking)
- **License**: Apache License 2.0

---

## 🏷️ 标签

`#AI` `#Agent` `#Memory` `#LanceDB` `#VectorDB` `#OpenViking` `#epro-memory` `#六级分类` `#渐进式披露` `#记忆系统`