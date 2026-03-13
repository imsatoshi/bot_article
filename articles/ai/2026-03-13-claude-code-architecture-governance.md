---
layout: post
title: "你不知道的 Claude Code：架构、治理与工程实践"
date: 2026-03-13
categories: ai
tags: [Claude Code, AI Agent, OpenClaw, Architecture, Best Practices]
permalink: /ai/claude-code-architecture-governance/
---

> **作者**: @HiTw93  
> **原文**: https://x.com/i/status/2032091246588518683  
> **字数**: 8000+ 字深度长文  
> **点赞**: 2510 | 转推: 566 | 浏览: 41万+

---

## 太长不读

今天这篇文章源于最近半年深度使用 Claude Code、两个账号每月 40 刀氪金换来的一些踩坑经验。

刚开始我也把它当 ChatBot 用，后来很快发现不对劲：**上下文越来越乱、工具越来越多但效果越来越差、规则越写越长却越不遵守**。折腾了一段时间，研究了 Claude Code 本身之后才意识到，这不是 Prompt 问题，而是这套系统的设计就是这样的。

这篇文章想和大伙聊聊这几个事：
- Claude Code 底层怎么运作
- 上下文为什么会乱以及怎么治理
- Skills 和 Hooks 应该怎么设计
- Subagents 的正确用法
- Prompt Caching 的架构影响
- 怎么写一个真正有用的 CLAUDE.md

---

## 1. 它底层是怎么运行的

Claude Code 的核心不是"回答"，而是一个**反复循环的代理过程**：

```
用户输入 → 工具选择 → 工具执行 → 结果解析 → 下一步决策 → ...
```

用了一段时间才意识到，**卡住的地方几乎从来不是模型不够聪明**，更多时候是：
- 给了它错误的上下文
- 写出来了但根本没法判断对不对
- 也没法撤回

真正要关注的**五个层面**：

| 层面 | 关注点 | 出问题时的表现 |
|------|--------|---------------|
| **上下文层** | 加载顺序、污染、压缩 | 结果不稳定，同一条指令前后不一致 |
| **控制层** | 循环、决策、安全边界 | 自动化失控，停不下来或越界操作 |
| **验证层** | 测试、lint、类型检查 | 改完代码跑不过，不知道哪里挂 |
| **工具层** | 数量、schema、返回格式 | 选错工具、传错参数、返回解析失败 |
| **持久层** | 文件读写、状态管理 | 状态漂移，文件被意外修改或覆盖 |

对着这几个面看，很多问题就好排查了。

---

## 2. 概念边界：MCP / Plugin / Tools / Skills / Hooks / Subagents

| 概念 | 核心区别 | 使用场景 |
|------|---------|---------|
| **Tool** | 单个原子能力 | 给 Claude 新动作能力 |
| **MCP** | 标准化协议下的工具集合 | 连接外部系统（GitHub、数据库等） |
| **Plugin** | 跨项目分发的打包方案 | 发布到社区共享 |
| **Skill** | 工作流 + 知识 + 约束 | 特定任务的标准化方法 |
| **Hook** | 强制拦截点 | 阻断、校验、通知 |
| **Subagent** | 隔离执行环境 | 复杂任务分解、并行处理 |

简单记：**给 Claude 新动作能力用 Tool/MCP，给它一套工作方法用 Skill，需要隔离执行环境用 Subagent，要强制约束和审计用 Hook，跨项目分发用 Plugin。**

---

## 3. 上下文工程：最重要的系统约束

很多人把上下文当"容量问题"，但卡住的地方通常**不是不够长，而是太吵了**——有用的信息被大量无关内容淹没。

### 真实的上下文成本构成

Claude Code 的 **200K 上下文并非全部可用**：

```
System Prompt:     ~2,000 tokens (固定)
Tools/MCP:         ~4,000-6,000 tokens 每 Server
CLAUDE.md:         ~500-2,500 tokens
对话历史:          动态增长
文件引用:          按需加载
```

**一个典型 MCP Server（如 GitHub）包含 20-30 个工具定义**，每个约 200 tokens，合计 4,000-6,000 tokens。接 5 个 Server，光这部分固定开销就到了 25,000 tokens（12.5%）。

### 推荐的上下文分层

```
System (固定)     → 不频繁变化的核心约束
CLAUDE.md         → 项目级通用约定
Rules (.claude/rules/) → 路径/语言特定规则
Skills (按需加载)  → 任务特定工作流
对话历史          → 当前会话状态
文件引用          → 正在处理的代码
```

**说白了：偶尔用的东西就不要每次都加载进来。**

### 上下文最佳实践

1. **保持 CLAUDE.md 短、硬、可执行**
   - 优先写命令、约束、架构边界
   - Anthropic 官方 CLAUDE.md 约 2.5K tokens，可以参考

2. **大型参考文档拆到 Skills 的 supporting files**
   - 不要塞进 SKILL.md 正文

3. **使用 .claude/rules/ 做路径/语言规则**
   - 不让根 CLAUDE.md 承担所有差异

4. **任务切换优先 /clear，同一任务进入新阶段用 /compact**

5. **把 Compact Instructions 写进 CLAUDE.md**
   - 压缩后必须保留什么由你控制，不由算法猜

### 压缩机制的陷阱

默认压缩算法按"可重新读取"判断，早期的 Tool Output 和文件内容会被优先删掉，**顺带把架构决策和约束理由也一起扔了**。两小时后再改，可能根本不记得两小时前定了什么。

**解决方案**：在 CLAUDE.md 里写明 Compact Instructions。

还有一种更主动的方案：**HANDOFF.md** —— 在开新会话前，让 Claude 写一份交接文档，把当前进度、尝试过什么、哪些走通了、哪些是死路、下一步该做什么写清楚。下一个 Claude 实例只读这个文件就能接着做。

### Plan Mode 的工程价值

Plan Mode 的核心是把**探索和执行拆开**：
- 探索阶段以只读操作为主
- Claude 可以先澄清目标和边界，再提交具体方案
- 执行成本在计划确认之后才发生

对于复杂重构、迁移、跨模块改动，这样做比"急着出代码"有用得多。

**进阶玩法**：开一个 Claude 写计划，再开一个 Codex 以"高级工程师"身份审这个计划，让 AI 审 AI，效果很好。

---

## 4. Skills 设计：不是模板库，是用的时候才加载的工作流

一个好 Skill 应该满足：
- **描述要让模型知道"何时该用我"**，而不是"我是干什么的"
- **有完整步骤、输入、输出和停止条件**，别写了个开头没有结尾
- **正文只放导航和核心约束**，大资料拆到 supporting files 里
- **有副作用的 Skill 要显式设置 `disable-model-invocation: true`**

### Skill 的三种典型类型

**类型一：检查清单型（质量门禁）**

```yaml
# release-checklist.skill
name: release-checklist
description: 在发布前执行完整检查清单，确保不遗漏关键步骤
steps:
  - 检查版本号已更新
  - 确认 CHANGELOG 已更新
  - 运行完整测试套件
  - 检查文档是否同步
  - ...
```

**类型二：工作流型（标准化操作）**

```yaml
# migration-workflow.skill
name: migration-workflow
description: 执行高风险配置迁移，包含显式回滚步骤
steps:
  - 创建备份
  - 在隔离环境测试
  - 执行迁移
  - 验证结果
  - 如失败则执行回滚
```

**类型三：领域专家型（封装决策框架）**

```yaml
# debug-framework.skill
name: debug-framework
description: 运行时出问题按固定路径收集证据，不要瞎猜
steps:
  - 收集错误日志
  - 检查环境状态
  - 定位问题范围
  - 提出修复方案
```

### Skills 反模式

- ❌ 描述过短：`description: help with backend`（任何后端工作都能触发）
- ❌ 正文过长：几百行工作手册全塞进 SKILL.md 正文
- ❌ 一个 Skill 覆盖 review、deploy、debug、docs、incident 五件事
- ❌ 有副作用的 Skill 允许模型自动调用

---

## 5. 工具设计：怎么让 Claude 少选错

给 Claude 的工具和给人写的 API 不是一回事。给人用的 API 追求功能齐全，但给 agent 用，**重点不是功能堆得多完整，而是让它更容易用对**。

### 好工具 vs 坏工具

| 好工具 | 坏工具 |
|--------|--------|
| 名称前缀按系统分层 | 命名随意，模型分不清 |
| 参数语义清晰 | 参数模糊，模型传错 |
| 错误响应教模型修正 | 只抛 opaque error code |
| 高层任务工具 | 过多底层碎片工具 |

### 从 Claude Code 内部工具演进学到的

**AskUserQuestion 工具的诞生**：
- 第一版：给已有工具加 question 参数 → Claude 经常忽略
- 第二版：要求特定 markdown 格式 → Claude 经常"忘了"写
- 第三版：**独立的 AskUserQuestion 工具** → 调用即暂停，没有歧义

**核心原则**：既然你就是要 Claude 停下来问一句，那就直接给它一个专门的工具。加个 flag 或者约定一段输出格式，很多时候它一顺手就略过去了。

---

## 6. Hooks：在 Claude 执行操作前后，强制插入你自己的逻辑

Hooks 不是"自动运行的脚本"，而是把**不能交给 Claude 临场发挥的事情，重新收回到确定性的流程里**。

### 当前支持的 Hook 点

- `SessionStart` - 会话开始时
- `BeforeToolUse` - 工具调用前
- `AfterToolUse` - 工具调用后
- `BeforeEdit` - 文件编辑前
- `AfterEdit` - 文件编辑后

### 适合 vs 不适合放到 Hooks

**适合**：
- 阻断修改受保护文件
- Edit 后自动格式化/lint/轻量校验
- SessionStart 后注入动态上下文
- 任务完成后推送通知

**不适合**：
- 需要读大量上下文的复杂语义判断
- 长时间运行的业务流程
- 需要多步推理和权衡的决策

### Hooks + Skills + CLAUDE.md 三层叠加

```
CLAUDE.md: 声明"提交前必须通过测试和 lint"
    ↓
Skill: 告诉 Claude 在什么顺序下运行测试、如何看失败、如何修复
    ↓
Hook: 对关键路径执行硬性校验，必要时阻断
```

三样少任何一层都会有漏洞。只写 CLAUDE.md 规则，Claude 经常当没看见；只靠 Hooks，细节判断又做不了。

---

## 7. Subagents：派一个独立的 Claude 去干一件具体的事

Subagent 就是从主对话派出去的一个独立 Claude 实例：
- 有自己的上下文窗口
- 只用你指定的工具
- 干完汇报结果

**核心价值不是"并行"，而是隔离** —— 扫代码库、跑测试、做审查这类会产生大量输出的事，交给 Subagent 做，主线程只拿摘要，不会被中间过程污染。

### 配置时要显式约束

```yaml
subagent:
  tools: [read, grep, bash]  # 限定能用什么工具
  disallowedTools: [edit, write]  # 禁止使用的工具
  model: claude-3-5-sonnet  # 探索任务用 Haiku，重要审查用 Opus
  maxTurns: 50  # 防止跑飞
  isolation: worktree  # 需要动文件时隔离文件系统
```

### 常见反模式

- ❌ 子代理权限和主线程一样宽，隔离没有意义
- ❌ 输出格式不固定，主线程拿到没法用
- ❌ 子任务之间强依赖，频繁要共享中间状态

---

## 8. Prompt Caching：Claude Code 内部架构的核心

**"Cache Rules Everything Around Me"** —— 对 agent 同样如此。

Claude Code 的整个架构都是围绕 Prompt 缓存构建的。高缓存命中率不只降低成本，也帮助创造更宽松的速率限制。Anthropic 甚至会对命中率运行告警，太低直接宣布 SEV。

### 为缓存设计的 Prompt Layout

Prompt 缓存是按**前缀匹配**工作的：

```
[ System Prompt - 缓存 ]
[ Tools - 缓存 ]
[ CLAUDE.md - 缓存 ]
[ 对话历史 - 动态 ]
  ↓ cache_control 断点
[ 当前消息 - 不缓存 ]
```

**破坏缓存的常见陷阱**：
- 在静态 System Prompt 中放入带时间戳的内容
- 非确定性地打乱工具定义顺序
- 会话中途增删工具

**解决方案**：动态信息（如当前时间）放到用户消息里传进去，系统 Prompt 不动，缓存就不会被打坏。

### defer_loading：工具的延迟加载

Claude Code 有数十个 MCP 工具，每次请求全量包含会很贵。解决方案是发送**轻量级 stub**，只有工具名，标记 `defer_loading: true`。模型通过 ToolSearch 工具"发现"它们，完整的工具 schema 只在模型选择后才加载。

---

## 9. 验证闭环：没有 Verifier 就没有工程上的 Agent

**「Claude 说完成了」其实没啥用**，你得能知道：
- 它做没做对
- 出了问题能退回来
- 过程还能查

这才算数。

### Verifier 的层级

```
最低层: 命令退出码、lint、typecheck、unit test
  ↓
中间层: 集成测试、截图对比、contract test
  ↓
更高层: 生产日志验证、监控指标、人工审查清单
```

### 核心原则

**假如一个任务你都说不清楚「Claude 怎么才算做对了」，那它大概率也不适合直接丢给 Claude 自动完成。**

---

## 10. 如何写一个好的 CLAUDE.md

CLAUDE.md 是**你和 Claude 之间的协作契约**，不是团队文档，也不是知识库，里面只放那些**每次会话都得成立的事**。

### 应该放什么

- ✅ 怎么 build、怎么 test、怎么跑（最核心）
- ✅ 关键目录结构与模块边界
- ✅ 代码风格和命名约束
- ✅ 那些不明显的环境坑
- ✅ 绝对不能干的事（NEVER 列表）
- ✅ 压缩时必须保留的信息（Compact Instructions）

### 不该放什么

- ❌ 大段背景介绍
- ❌ 完整 API 文档
- ❌ 空泛原则，如"写高质量代码"
- ❌ Claude 通过读仓库即可推断的显然信息
- ❌ 大量背景资料和低频任务知识（这些放到 Skills）

### 高质量模板

```markdown
# CLAUDE.md

## 构建与测试
- 构建: `make build`
- 测试: `make test`
- 运行: `make dev`

## 关键目录
- `/src/core` - 核心逻辑，禁止直接调用外部 API
- `/src/adapters` - 外部集成，必须 interface 隔离
- `/tests` - 测试文件，命名必须 `*_test.go`

## 代码风格
- 函数名用 verbNoun 格式
- 错误处理必须 wrap context
- 禁止在 core 层 import adapters

## 环境坑
- 需要 Go 1.21+
- 本地开发需要 Docker Compose 启动依赖服务
- `make setup` 会配置好一切

## NEVER
- 不要直接修改 generated 文件
- 不要在 core 层打日志（用中间件）

## Compact Instructions
压缩时必须保留：
1. 构建和测试命令
2. 目录边界规则
3. NEVER 列表
```

### 让 Claude 维护自己的 CLAUDE.md

每次纠正 Claude 的错误后，让它自己更新 CLAUDE.md：

> "Update your CLAUDE.md so you don't make that mistake again."

Claude 在给自己补这类规则时其实还挺好用，用久了确实越来越少犯同样的错。

---

## 11. 高频命令的工程意义

| 命令 | 核心作用 |
|------|---------|
| `/clear` | 清空对话历史，重新开始 |
| `/compact` | 压缩上下文，保留关键信息 |
| `/context` | 查看当前上下文消耗 |
| `/simplify` | 三维检查代码（复用、质量、效率） |
| `/rewind` | 回到某个 checkpoint 重新总结 |
| `/btw` | 快速旁路问答，不打断主任务 |
| `/insight` | 让 Claude 分析当前会话，提炼值得沉淀的内容 |
| `双击 ESC` | 回溯到上一条输入重新编辑 |

---

## 12. 配置健康检查

作者开源了一个 Skill 项目 `tw93/claude-health`，可以一键检查 Claude Code 配置状态：

```bash
npx skills add tw93/claude-health
```

装好之后在任意会话里跑 `/health`，它会自动识别项目复杂度，对 CLAUDE.md、rules、skills、hooks、allowedTools 和实际行为模式各跑一遍检查，输出一份优先级报告。

---

## 13. 结语

用 Claude Code 大概会经历三个阶段：

```
第一阶段：当 ChatBot 用，问问题、改代码
    ↓
第二阶段：意识到它是 agent，开始折腾工具、rules、skills
    ↓
第三阶段：关注点变成「怎么让 agent 在约束下自己跑起来」
```

到了第三阶段，关注点会悄悄变掉，从「这个功能怎么用」变成「怎么让 agent 在约束下自己跑起来」，两件事感觉差很多。

有一个问题挺值得想的：**假如一个任务你说不清楚「什么叫做完」，那大概率也不适合直接扔给 Claude 自主完成。** 验证标准本身都没有，Claude 再聪明也跑不出正确答案。

这些是半年折腾下来的一些总结，肯定还有很多没有挖掘到的地方，如果大伙有用得更 6 的技巧，欢迎交流。

---

**原文作者**: @HiTw93  
**整理时间**: 2026-03-13  
**原文链接**: https://x.com/i/status/2032091246588518683
