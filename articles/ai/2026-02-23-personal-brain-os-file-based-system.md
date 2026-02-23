---
layout: post
title: "Personal Brain OS：为 AI Agent 构建的基于文件的个人操作系统"
date: 2026-02-23
categories: ai
tags: [Personal Brain OS, Context Engineering, AI Agent, 知识管理, 文件系统]
permalink: /ai/personal-brain-os-file-based-agent-system/
---

> 原文: Muratcan Koylan (@koylanai)  
> 链接: https://x.com/koylanai/status/2025286163641118915  
> 
> Muratcan 是  [Context Engineer](https://context.ai)，专注于上下文工程系统设计。

---

## 问题：每次对话都要重新开始

每次与 AI 对话都在重复：
- 解释自己是谁
- 粘贴风格指南
- 重新描述目标
- 提供同样的上下文

然后，40 分钟后，模型忘了你的声音，开始写得像新闻稿。

**解决方案：Personal Brain OS** —— 一个基于文件的 Git 仓库形式的个人操作系统。

---

## 核心架构：11 个隔离模块

> "不是写一个大系统提示，而是将系统拆分为 11 个隔离模块。"

当要求 AI 写博客时，它加载声音指南和品牌文件。当要求准备会议时，它加载联系人数据库和交互历史。模型在内容任务期间从不会看到网络数据，在网络任务期间从不会看到内容模板。

### 模块设计原则

**注意力预算（Attention Budget）：**
- 语言模型有有限的上下文窗口，不是所有 token 都同等重要
-  dumping 所有内容到系统提示不仅是浪费，还会降低性能
- 每个 token 都在竞争模型的注意力

**U 形注意力曲线：**
- 就像人类记忆一样——记住别人说的第一件事和最后一件事，中间模糊
- Token 位置影响回忆概率
- 了解这一点会改变你为 AI 系统设计信息架构的方式

---

## Progressive Disclosure（渐进式披露）

这是让整个系统工作的架构模式。

### 三层结构

```
Level 1: 轻量级路由文件 (always loaded)
    └── 告诉 AI 哪个模块相关
    
Level 2: 模块特定指令 (loaded when needed)
    └── 40-100 行，包含文件清单、工作流序列、行为规则
    
Level 3: 实际数据 (loaded only when required)
    └── JSONL 日志、YAML 配置、研究文档
```

这模仿专家的操作方式。三层创建一个漏斗：广泛路由 → 模块上下文 → 具体数据。每一步，模型都有它需要的，没有更多。

**路由文件示例：**
```markdown
# router.md
- 内容任务 → 加载 brand 模块
- 网络任务 → 加载 contacts 模块
```

**模块指令文件：**
```markdown
# content/skills.md
文件清单、工作流序列、<instructions> 行为规则

数据文件最后加载，AI 逐行读取 JSONL 而不是解析整个文件。
最多两次跳转到达任何信息。
```

---

## Agent Instruction Hierarchy（三层指令层级）

解决大型 AI 项目中的"冲突指令"问题。

| 层级 | 文件 | 作用 |
|------|------|------|
| **Repository** | `AGENTS.md` | 入职文档，每个 AI 工具首先读取 |
| **Brain** | `CLAUDE.md` | 七条核心规则 + 决策表，映射请求到行动序列 |
| **Module** | `module/skills.md` | 领域特定的行为约束 |

**决策表示例：**
```
用户说"发送邮件给 Z"
→ Step 1: 在 HubSpot 查找联系人
→ Step 2: 验证邮箱地址
→ Step 3: 通过 Gmail 发送
```

**优先级系统：**
- P0: 今天做
- P1: 本周
- P2: 本月
- P3:  backlog

代理遵循与作者相同的优先级系统，因为系统是编码的，不是暗示的。

---

## 无数据库架构

> "没有数据库。没有向量存储。没有检索系统，除了 Cursor 或 Claude Code 的功能。只是磁盘上的文件，用 Git 版本控制。"

### Format-Function Mapping（格式功能映射）

| 格式 | 用途 | 原因 |
|------|------|------|
| **JSONL** | 日志 | 追加式设计，流友好，每行自包含有效 JSON |
| **YAML** | 配置 | 层次数据清晰，支持注释，人机可读 |
| **Markdown** | 叙述 | LLM 原生读取，到处渲染，Git diff 干净 |

**JSONL 的追加式特性：**
- 防止一类 bug：代理意外覆盖历史数据
- 作者曾见过 JSON 文件写入导致丢失三个月联系人历史
- JSONL 中代理只能添加行，删除通过标记 `"status": "archived"`

**YAML 的注释支持：**
- 可以注释目标文件，提供上下文给代理阅读，但不污染数据结构

**Markdown 的通用渲染：**
- 声音指南在 Cursor、GitHub、浏览器中看起来一样

---

## 文件结构

```
personal-brain-os/
├── AGENTS.md              # 仓库级入职文档
├── CLAUDE.md              # 大脑级核心规则
├── router.md              # 路由文件
├── memory/
│   ├── experiences.jsonl  # 关键 moments + 情感权重 (1-10)
│   ├── decisions.jsonl    # 关键决策 + 推理、替代方案、结果
│   └── failures.jsonl     # 出错内容 + 根本原因 + 预防措施
├── identity/
│   ├── brand.md           # 品牌定位
│   ├── tone-of-voice.md   # 声音指南（前100行最关键）
│   └── values.yaml        # 价值观
├── content/
│   ├── skills.md          # 内容模块指令
│   ├── templates/         # 内容模板
│   └── anti-patterns.md   # 禁止模式
├── network/
│   ├── contacts.jsonl     # 联系人
│   ├── interactions.jsonl # 交互记录
│   └── circles.yaml       # 圈子定义
├── knowledge/
│   └── research/          # 研究文档
├── posts.jsonl            # 发布内容日志
├── ideas.jsonl            # 想法（带评分系统）
├── bookmarks.jsonl        # 书签
├── goals.yaml             # 目标
├── learning.yaml          # 学习计划
└── rhythms.yaml           # 节奏/习惯
```

**11 个 JSONL 文件：**
posts, contacts, interactions, bookmarks, ideas, metrics, experiences, decisions, failures, engagement, meetings

**6 个 YAML 文件：**
goals, values, learning, circles, rhythms, heuristics

**50+ Markdown 文件：**
voice guides, research, templates, drafts, todos

**每个 JSONL 文件以 schema 行开头：**
```json
{"_schema": "contact", "_version": "1.0", "_description": "..."}
```

---

## Episodic Memory（情景记忆）

> "大多数'第二大脑'系统存储事实。我的存储判断。"

**三种追加式日志：**

1. **experiences.jsonl** - 关键 moments + 情感权重评分 (1-10)
2. **decisions.jsonl** - 关键决策 + 推理、考虑的替代方案、追踪的结果
3. **failures.jsonl** - 出错内容 + 根本原因 + 预防步骤

**事实 vs 判断：**
- 事实告诉代理发生了什么
- 情景记忆告诉代理什么重要、什么会做得不同、如何思考权衡

**案例：**
> "当我决定是否接受 Antler Canada 的 $250K 投资还是加入 [公司] 担任 Context Engineer 时，决策日志捕获了两个选项、每个选项的推理和结果。如果出现类似的职业权衡，代理不会给我通用职业建议。它引用我实际如何思考这些决策的方式。"

作者的优先级顺序：**Learning > Impact > Revenue > Growth**

加入公司框架：
- Can I touch everything?
- Will I learn at the edge of my capability?
- Do I respect the founders?

---

## Cross-Module References（跨模块引用）

使用扁平文件关系模型。

**引用链示例：**
```
interactions.jsonl 中的 contact_id 
    → 指向 contacts.jsonl 中的条目

ideas.jsonl 中的 pillar
    → 映射到 identity/brand.md 中定义的内容支柱

书签 → 喂养内容想法
帖子指标 → 喂养周回顾
```

**会议准备链：**
```
contacts.jsonl (他们是谁)
    + interactions.jsonl (按 contact_id 过滤历史)
    + todos (待处理事项)
    = 一页简报：关系上下文 + 上次对话摘要 + 开放跟进
```

---

## Agent Skills 设计

### 两种类型

| 类型 | 设置 | 用途 |
|------|------|------|
| **Reference Skills** | `user-invocable: false` | 自动加载，如 voice-guide、writing-anti-patterns |
| **Task Skills** | `disable-model-invocation: true` | 手动调用，如 /write-blog、/topic-research |

**自动加载解决一致性问题：**
- 不需要每次都说"用我的声音"
- 系统为作者记住

**手动调用解决精确性问题：**
- 研究任务与博客文章有不同的质量门槛
- 保持分离防止代理混淆两个工作流

**Slash 命令示例：**
```
/write-blog context engineering for marketing teams
```
自动触发五件事：
1. 声音指南加载（如何写）
2. 反模式加载（从不写什么）
3. 博客模板加载（7 节结构 + 字数目标）
4. 检查 persona 文件夹
5. 检查研究文件夹

**Skill 文件引用源模块，从不复制内容。** 单一事实来源。

---

## Voice System（声音系统）

声音编码为结构化数据 + vibe。

**声音档案评分（1-10 量表）：**
- Formal/Casual: **6**
- Serious/Playful: **4**
- Technical/Simple: **7**
- Reserved/Expressive: **6**
- Humble/Confident: **7**

**反模式文件：**
- 50+ 禁用词，分三层
- 禁止的开头
- 结构陷阱（强迫的三法则、系动词避免、过度对冲）
- 每段最多一个 em-dash 的硬限制

**质量检查点：**
每 500 字：
- "我是否以洞察领先？"
- "我是否用数字具体化？"
- "我实际会发布这个吗？"

**4 遍编辑流程：**
1. 结构编辑（钩子吸引人吗？）
2. 声音编辑（禁用词扫描、句子节奏检查）
3. 证据编辑（声明有来源吗？）
4. 朗读测试

---

## Content Pipeline（内容流水线）

**7 个阶段：**
Idea → Research → Outline → Draft → Edit → Publish → Promote

**想法评分系统（1-5 分）：**
- 与定位的一致性
- 独特洞察
- 受众需求
- 时效性
- 努力 vs 影响

**总分 15+ 才继续**

**研究输出格式：**
```markdown
# knowledge/research/[topic].md
- Executive Summary
- Landscape Map
- Core Concepts
- Evidence Bank（统计、引用、案例研究、论文，带来源和日期）
- Failure Modes
- Content Opportunities
- Sources List（HIGH/MEDIUM/LOW 可靠性评分）
```

**内容日历：**
- 周日批量创作：3-4 小时，目标 3-4 篇草稿 + 大纲
- 每天映射到平台和内容类型

---

## Personal CRM（个人 CRM）

**四个圈子，不同维护频率：**

| 圈子 | 频率 | 说明 |
|------|------|------|
| inner | 每周 | 核心关系 |
| active | 每两周 | 活跃关系 |
| network | 每月 | 网络关系 |
| dormant | 每季度 | 休眠重新激活 |

**联系人记录字段：**
- `can_help_with` - 他们能在什么方面帮忙
- `you_can_help_with` - 你能在什么方面帮忙
- 交叉引用这些字段实现匹配介绍

**交互记录：**
- 情感追踪（positive, neutral, needs_attention）
- 关系健康一目了然

**stale_contacts 脚本：**
- 交叉引用 contacts（他们是谁）
- interactions（上次对话时间）
- circles（应该多久聊一次）
- 浮出水面需要 outreach 的关系

**专业圈子策略：**
- AI builders: 分享有用内容、开源协作、提供工具反馈、放大他们的工作
- Mentors: 带具体问题、更新之前建议的进展、寻找回馈价值的方式

---

## Automation Chains（自动化链）

**周日周回顾链：**
```
metrics_snapshot.py → stale_contacts.py → weekly_review.py
```

输出：完成 vs 计划、指标趋势、下周优先级

**内容构思链：**
```
最近书签 → 检查未开发想法 → 生成新建议 → 交叉引用内容日历找排期空缺
```

**Agent 可读格式：**
- 脚本输出到 stdout
- 引用目标并识别哪些关键结果在正轨、落后、下周优先什么

**反馈循环：**
Goals → Content → Metrics → Reviews → Goals

---

## 关键教训

### 1. 模式过度工程
- 初始 JSONL 模式有 15+ 字段，大多数为空
- 代理 struggle 稀疏数据——试图填充字段或评论缺失
- 削减到 8-10 个基本字段，只在有数据时添加可选字段

### 2. 声音指南太长
- 第一版 `tone-of-voice.md` 1,200 行
- 代理开始强，但到第四段漂移，因为声音指令落入 lost-in-middle 区域
- 重构为前 100 行放最关键模式（签名短语、禁用词、开头模式）
- **关键规则需要在顶部，不是中间**

### 3. 模块边界比你想象的更重要
- 最初将 identity 和 brand 放在一个模块
- 代理会在只需要禁用词列表时加载整个 bio
- 拆分为两个模块，纯声音任务 token 使用减少 40%
- 每个模块边界都是加载决策

### 4. Append-only 是不可协商的
- 早期丢失三个月帖子参与数据，因为代理重写了 `posts.jsonl` 而不是追加
- JSONL 的追加式模式不仅是约定——是安全机制
- 代理可以添加数据，不能销毁数据
- **这是系统中最重要的架构决策**

---

## 核心理念：Context Engineering

> "这是上下文工程，不是提示工程。"

**提示工程问：** "如何更好地措辞这个问题？"

**上下文工程问：** "这个 AI 需要什么信息才能做出正确决策，我如何结构化这些信息让模型实际使用它？"

转变是从优化单个交互到设计信息架构。

**区别：**
- 写一封好邮件 vs 建立一个好归档系统
- 一个帮你一次
- 另一个每次都帮你

---

## 成果

打开 Cursor 或 Claude Code，开始对话，AI 已经知道：
- 作者是谁
- 如何写作
- 在做什么
- 在乎什么

它用作者的声音写作，因为声音编码为结构化数据。它遵循作者的优先级，因为目标在它建议做什么之前读取的 YAML 文件中。它管理作者的关系，因为联系人和交互在它可以查询的文件中。

---

## 完整可移植性

整个系统适合一个 Git 仓库。

**Clone 到任何机器，指向任何 AI 工具，操作系统就运行了。**

- 零依赖
- 完全可移植
- 每个变更都版本化
- 每个决策都可追溯
- 没有什么真正丢失

---

## 相关资源

- **Framework:** [Agent Skills for Context Engineering](https://github.com/muratcankoylan/context-engineering)
- **作者:** Muratcan Koylan, Context Engineer at [Context.ai](https://context.ai)
- **GitHub Stars:** 8,000+
- **引用:** 学术研究（与 Anthropic 并列）

---

**核心原则：**

Take what fits, ignore what doesn't, and ship something that makes your AI actually useful instead of generically helpful.
