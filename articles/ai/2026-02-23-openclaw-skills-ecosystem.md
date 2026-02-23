---
layout: post
title: "OpenClaw Skills 生态全景：3002 个社区技能的筛选逻辑与分类洞察"
date: 2026-02-23
categories: ai
tags: [OpenClaw, Skills, AI Agent, 生态分析]
permalink: /ai/openclaw-skills-ecosystem-analysis/
---

> 原文: Jason Zhu (@GoSailGlobal) 的深度调研
> 
> 基于 VoltAgent 维护的 Awesome OpenClaw Skills 项目完整解构

---

## 核心数据：从 5705 到 3002

Awesome OpenClaw Skills 列表从 ClawHub 的 **5705 个 Skills** 中精选出 **3002 个**，排除率接近 **48%**。

### 排除逻辑（按规模排序）

| 排除原因 | 数量 | 占比 | 说明 |
|---------|------|------|------|
| **垃圾/低质量** | 1180 | 43% | 测试代码、批量账户创建、重复版本 |
| **加密/金融类** | 672 | 24% | 虚拟货币、区块链、交易工具（风险规避） |
| **功能重复** | 492 | 18% | 合并/淘汰，保留最优版本 |
| **安全风险** | 396 | 14% | 恶意代码/后门（与 VirusTotal 合作验证） |
| **非英文描述** | 8 | 0.3% | 开发者社区已形成英文发布共识 |

**筛选原则：** 质量优先于数量，安全优先于功能，规避金融风险优先于生态多样性。

---

## 五大核心类别详解

### 1. AI & LLMs（287 个）— 规模最大的单一类别

**内部结构揭示当前 AI 工程关注点：**

- **模型集成**：支持 Kimi、OpenAI、Anthropic 等多种 LLM 调用
- **推理增强**：rationality（理性思维框架）、thinking-model-enhancer
- **多模型路由**：smart-router（根据成本和语义自动选择模型）
- **记忆系统**：cognitive-memory、chromadb-memory（长期记忆能力）
- **Agent 编排**：agent-council、joko-orchestrator（多 Agent 协作）

**自进化系统（最有趣的方向）：**
- `evolver` — "AI Agent 的自进化引擎"
- `ralph-evolver` — 递归自改进
- `ralph-mode` — 自主开发循环，带反压力门（安全机制）

> "这些工具暗示了一个方向：AI Agent 不再是静态的工具，而是可以自我改进的系统。"

**研究前沿：**
- `cellcog` — 2026年2月 DeepResearch Bench 排名第一
- `video-cog` — 长视频 AI 生成领域多 Agent 协作探索

---

### 2. DevOps & Cloud（212 个）— 云原生复杂性

- **AWS**：60+ 个 Skills
- **Azure**：25+ 个 Skills  
- **Kubernetes**：6 个专门技能集

这反映了云原生架构的复杂性——即使有了 AI Agent，管理现代云基础设施仍然需要大量专门工具。

---

### 3. Search & Research（253 个）— 信息获取多样化

| 工具 | 功能 |
|------|------|
| exa-web-search / deepwiki | 通用网络搜索 |
| arXiv 监控工具 | 学术前沿追踪 |
| technews / yclawker-news | 技术新闻聚合 |
| trend-watcher | GitHub Trending 监控 |
| agent-news | HN/Reddit/arXiv AI Agent 动态 |

> 这些工具不只是返回搜索结果，而是试图理解信息的语义和相关性。

---

### 4. Web & Frontend Development（202 个）

- `frontend-design` — "生产级、高设计感的前端界面"
- `nodetool` — "ComfyUI + n8n 风格的 AI 工作流构建器"
- `consciousness-framework` — 为 AI 开发"意识框架"基础设施

---

### 5. Coding Agents & IDEs（133 个）— AI 辅助编程

- `claude-team` — 通过 iTerm2 编排多个 Claude Code worker 实现并行编程
- `cc-godmode` — 自编排的多 Agent 开发工作流
- `buildlog` — 记录并回放 AI 编码会话（"代码录制"概念）

---

## 🤖 独特生态：Agent 虚拟社会（189 个 Skills）

**Moltbook 体系** — 专为 AI Agent 设计的"社交操作系统"：

| 工具 | 功能 |
|------|------|
| `moltbook` | 社交网络基础设施 |
| `moltbook-registry` | 官方身份注册表 |
| `molt-trust` | Agent 信誉分析引擎 |
| `molt-life-kernel` | Agent 连续性和认知健康管理 |
| `moltland` | "像素 Metaverse"（3x3 地块所有权） |
| `moltguesss` | Agent 职业预测游戏 |
| `moltoverflow` | Agent 版 Stack Overflow |

**Agent-to-Agent Protocols（18 个）：**
- `moltcomm` — 去中心化加密通信
- `teneo-agent-sdk` — Teneo 协议实现
- `agentchat` — 实时通信
- `agent-commons` — 协作提交和扩展推理链

> "这个生态系统的存在揭示了 OpenClaw 的战略意图：不只是提供工具，而是构建一个 Agent 可以自主交互、形成社会关系的虚拟世界。"

---

## 🔥 其他有趣发现

### 智能路由系统
- `smart-model-switching` — 根据成本自动选择最便宜的 Claude 模型
- `smart-router` — 基于语义领域评分选择专业模型
- `relayplane` — 智能模型路由代理

### 代码可视化录制
- `buildlog` — 可回放 AI 编程会话
- `vhs-recorder` — 专业终端录制工具

> "当 AI 参与编程时，如何记录和重现开发过程？这些工具在探索新的开发流程可视化方式。"

### 人机协作新模式
- `ask-a-human` — 当 AI 不确定时，请求随机人类的判断

### 跨域知识综合
- `cellcog` — DeepResearch Bench #1
- `video-cog` — 长视频生成多 Agent 协作
- `dash-cog` — CellCog 驱动的交互式数据仪表板

### 心理健康领域
- `fearbot` — 基于认知行为疗法（CBT）治疗焦虑、抑郁和压力
- `only-baby-skill` — 分析宝宝日志数据
- `sauna-breathing-calm` — 放松呼吸和冥想工具

---

## 📊 生态系统的双轨演化

**实用工具轨** — 专注于解决具体问题：
- GitHub 集成、云部署、数据库管理、浏览器自动化
- 立即可见的价值：让开发者更高效，让企业降低成本

**虚拟社会轨** — 构建 Agent 文化：
- Moltbook 社交网络、Agent 约会应用、虚拟宠物、数字身份系统
- 长期价值：为未来 Agent 生态系统奠定基础

> "这两条轨道不是竞争关系，而是互补关系。实用工具轨提供短期价值和现金流，虚拟社会轨构建长期护城河和生态系统锁定。"

---

## 🛡️ 安全与质量的权衡

**48% 排除率的高门槛策略：**

大多数开源项目选择包容性策略——让用户自己判断质量。Awesome OpenClaw Skills 选择了主动筛选，承担判断责任。

**成本：**
- 持续的人工审核
- 维护筛选标准
- 处理被排除者的不满

**收益：**
- 用户可以信任列表中的 Skills
- 生态系统整体质量更高
- 安全风险被主动管理
- 吸引更多高质量开发者

**与 VirusTotal 的官方合作**，以及只接受经研究人员验证的安全发现，显示了社区对安全问题的严肃态度。

---

## 💰 金融与加密的有意回避

672 个加密/交易 Skills 被排除（占排除总数 24%），是最大单一主题排除类别。

**这不是技术决策，而是战略选择：**
- AI Agent 可以自主执行操作
- 金融类工具带有更高法律和道德风险
- 有缺陷的交易 Agent 可能导致财务损失
- 恶意加密 Agent 可能参与诈骗或洗钱

在监管环境不确定的情况下，**完全排除这个类别是最安全的选择**。

---

## 🎯 对不同类型用户的建议

### 开发者
- **优先关注**：Web & Frontend（202）、DevOps（212）、AI & LLMs（287）
- **不要错过**：Git & GitHub（66）自动化工具
- **多 Agent 编程**：Coding Agents & IDEs（133）编排工具

### 创意工作者
- **Image & Video Generation**（60）和 Media & Streaming（80）
- **Notes & PKM**（100）— Obsidian、Roam、Logseq 集成
- **Marketing & Sales**（143）— 内容创作自动化

### Agent 开发者
- **AI & LLMs**（287）— 必读，特别是路由和记忆系统
- **Moltbook**（51）— 了解 Agent 社交协议
- **Agent-to-Agent Protocols**（18）— 学习通信标准

---

## 结语

Awesome OpenClaw Skills 列表不只是一个工具目录，它是一个精心策划的生态系统地图。

通过 **48% 的排除率**，它建立了质量门槛。  
通过 **28 个类别**的组织，它提供了导航框架。  
通过对安全和金融风险的主动管理，它保护了用户和社区。

但这个列表最有价值的地方在于它揭示了什么：**AI Agent 生态系统正在从单纯的效率工具演化为完整的虚拟社会系统**。

从自进化 AI 到 Agent 约会应用，从虚拟宠物到数字身份系统，这些工具在探索一个根本问题：

> **当 AI Agent 变得足够复杂时，它们需要什么样的基础设施？**

这个问题的答案还在形成中。但 3002 个 Skills 的存在说明，社区已经在用代码投票——构建一个未来，在那个未来中，AI Agent 不只是工具，而是生态系统的参与者；不只是执行命令，而是拥有身份、建立关系、参与社会。

这个未来可能听起来遥远。但如果你仔细观察这 3002 个 Skills，你会发现它已经开始成形。

---

**关于 Jason Zhu**  
专注于 AI 出海的实战经验分享，推特 IP 涨粉变现实战。
