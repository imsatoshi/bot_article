---
layout: post
title: "Skill Graphs > SKILL.md：从单文件到知识图谱的进化"
date: 2026-02-18
categories: ai
tags: [AI, Agent, SkillGraph, KnowledgeBase, Zettelkasten, ClaudeCode, arscontexta]
permalink: /ai/skill-graphs-vs-skill-md/
---

# Skill Graphs > SKILL.md：从单文件到知识图谱的进化

**作者**: Heinrich (@arscontexta)  
**来源**: https://x.com/i/status/2023957499183829467  
**整理时间**: 2026-02-18

---

## 📖 核心观点

**人们低估了结构化知识的力量。** 它启发了全新的应用类型。

现在的技能文件（SKILL.md）往往只捕捉单一功能：
- 一个技能用于总结
- 一个技能用于代码审查
- ...

**问题**：单一文件无法承载真正的深度。

---

## 🎯 什么是 Skill Graph？

**Skill Graph（技能图谱）** 是一个**由多个技能文件组成的网络**，通过 **wikilinks** 相互连接。

### 核心概念

| 传统 SKILL.md | Skill Graph |
|--------------|-------------|
| 单一大文件 | 多个小型可组合片段 |
| 单一功能 | 深度知识网络 |
| 线性阅读 | 图谱遍历 |
| 静态注入 | 动态上下文发现 |

### 示例：治疗技能图谱

想象一下治疗技能图谱，包含：
- 认知行为模式
- 依恋理论
- 积极倾听技巧
- 情绪调节框架
- ...

**单一文件无法容纳这些**，但技能图谱可以。

---

## 🏗️ Skill Graph 架构

### 文件结构

```
skill-graph/
├── index.md          # 索引：入口点，指向 attention
├── MOCs/             # Maps of Content：组织子主题
│   ├── cognitive-patterns.md
│   ├── therapy-techniques.md
│   └── ...
├── nodes/            # 独立技能节点
│   ├── cbt-basics.md
│   ├── active-listening.md
│   ├── attachment-theory.md
│   └── ...
└── assets/           # 图片、附件
```

### 渐进式披露 (Progressive Disclosure)

```
index → descriptions → links → sections → full content
```

**大部分决策发生在阅读完整文件之前**。

---

## 🔗 Wikilinks 的力量

### 文本中的有意义的链接

Wikilinks 不只是引用，它们**编织在散文中**，携带意义：

```markdown
当患者表现出 [[cognitive-distortions|cognitive distortion patterns]] 时，
治疗师应使用 [[socratic-questioning]] 技巧引导其重新审视...
```

**效果**：
- Agent 理解**何时**跟随链接
- Agent 理解**为什么**跟随链接
- 跳过不相关的内容

### YAML Frontmatter

每个节点都有 YAML 描述，Agent 可以扫描而无需阅读完整文件：

```yaml
---
title: "Cognitive Behavioral Therapy Basics"
description: "Core principles of CBT including thought records and behavioral activation"
tags: [therapy, cbt, cognitive]
---
```

---

## 🧠 递归发现模式

**Skill Graph 在图谱内部递归应用相同的技能发现模式**。

### 遍历示例

1. **入口**：Index 文件描述整体景观
2. **导航**：Agent 读取 Index，理解有哪些子主题
3. **选择**：根据当前对话，跟随相关链接
4. **深入**：进入 MOC 或具体技能节点
5. **组合**：从多个节点拉取上下文

---

## 💡 实际应用场景

### 1. 交易技能图谱

```
trading/
├── index.md
├── risk-management/
│   ├── position-sizing.md
│   ├── stop-loss-strategies.md
│   └── [[portfolio-diversification]]
├── market-psychology/
│   ├── fear-and-greed.md
│   ├── sentiment-analysis.md
│   └── [[behavioral-finance|behavioral patterns]]
└── technical-analysis/
    ├── chart-patterns.md
    └── [[indicators|indicator interpretation]]
```

### 2. 法律技能图谱

```
legal/
├── contract-patterns/
├── compliance-requirements/
├── jurisdiction-specifics/
└── precedent-chains/
```

### 3. 公司知识图谱

```
company/
├── org-structure/
├── product-knowledge/
├── processes/
├── onboarding-context/
├── culture/
└── competitive-landscape/
```

**共同点**：
- 单一文件无法容纳
- 但都能作为图谱工作

---

## 🛠️ 构建方法

### 方法 A：使用 arscontexta 插件（推荐）

**arscontexta** 是一个 Claude Code 插件，教你构建知识系统。

```bash
# 安装插件
# 选择研究预设
# 指向任何主题
```

它会为你设置 Markdown 文件夹结构，然后你用 `/learn` 和 `/reduce` 填充。

### 方法 B：手动构建（比你想象的简单）

**关键**：一个 **Index 文件** 告诉 Agent 什么存在以及如何遍历。

#### Index 文件示例

```markdown
# Knowledge Work Skill Graph

## Core Methodologies
- [[zettelkasten]] — Connected note-taking for idea development
- [[evergreen-notes]] — Writing that compounds over time
- [[progressive-summarization]] — Layered knowledge extraction

## Cognitive Tools
- [[mental-models]] — Thinking frameworks for better decisions
- [[first-principles]] — Deconstructing problems to fundamentals
- [[systems-thinking]] — Understanding interconnections

## Implementation
- [[spaced-repetition]] — Long-term memory retention
- [[incremental-reading]] — Processing large volumes efficiently
```

**注意**：Index 不是查找表，而是**指向 attention 的入口点**。

#### 节点文件示例

```markdown
---
title: "Zettelkasten"
description: "A method of note-taking and knowledge management that emphasizes connections between ideas"
---

# Zettelkasten

The Zettelkasten method, developed by Niklas Luhmann, is a [[knowledge-management]] system based on:

1. **Atomic notes** — One idea per note
2. **Unique identifiers** — Each note has a permanent address
3. **Linking** — Notes reference each other forming a [[knowledge-graph]]

When implementing Zettelkasten, consider:
- [[note-taking-best-practices]] for capture
- [[linking-conventions]] for navigation
- [[periodic-reviews]] for maintenance

## Related Concepts
- [[evergreen-notes]] — Similar emphasis on lasting value
- [[digital-garden]] — Public sharing of connected notes
```

---

## 📊 arscontexta 示例

**arscontexta** 本身就是一个技能图谱：
- **~250 个** 连接的 Markdown 文件
- 教 Agent 如何构建技能图谱
- （实际上是关于构建知识库，但原理相同）

涵盖：
- 认知科学
- Zettelkasten
- 图谱理论
- Agent 架构

每个片段链接到其他片段，可组合，整个图谱可遍历。

---

## 🎓 关键洞察

### 上下文工程的本质

> **Skills are context engineering**, basically curated knowledge injected where it matters.

**Skill Graphs 是下一步**：
- 不是单一注入
- Agent **导航知识结构**
- 拉取当前情况**恰好需要**的内容

### 智能的区别

这是 **遵循指令的 Agent** 与 **理解领域的 Agent** 之间的区别。

---

## 🔮 未来方向

### 可能的演进

1. **自动图谱构建**：AI 自动从对话中发现并组织知识节点
2. **动态权重**：根据使用频率和效果调整节点重要性
3. **跨图谱链接**：不同领域的 Skill Graphs 相互引用
4. **可视化界面**：图形化展示和编辑知识网络

---

## 🏷️ 相关概念

| 概念 | 说明 |
|------|------|
| **Zettelkasten** | 德国社会学家卢曼的卡片盒笔记法 |
| **MOC (Map of Content)** | 内容地图，组织相关主题的入口 |
| **Wikilinks** | `[[page-name|display-text]]` 格式链接 |
| **Progressive Disclosure** | 渐进式披露，按需展示信息 |
| **Atomic Notes** | 原子笔记，一个想法一个笔记 |
| **Knowledge Graph** | 知识图谱，实体和关系网络 |

---

## 🔗 资源

- **原文**: https://x.com/i/status/2023957499183829467
- **作者**: Heinrich (@arscontexta)
- **工具**: arscontexta Claude Code 插件
- **理念**: Zettelkasten + Agent 架构 + 知识图谱

---

## 💭 总结

**Skill Graphs 代表了从单文件到知识网络的进化**。

不是让你的 Agent 记住更多，而是让它：
- 🧭 **导航** 知识景观
- 🎯 **发现** 相关上下文
- 🔗 **组合** 多个技能
- 📚 **理解** 整个领域

**这就是下一代 Agent 能力的基础**。

---

## 🏷️ 标签

`#AI` `#Agent` `#SkillGraph` `#KnowledgeBase` `#Zettelkasten` `#ClaudeCode` `#arscontexta` `#Wikilinks` `#知识图谱` `#上下文工程`