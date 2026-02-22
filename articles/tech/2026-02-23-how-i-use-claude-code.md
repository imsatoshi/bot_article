---
layout: post
title: "How I Use Claude Code - Boris Tane 的高效工作流"
date: 2026-02-23
categories: tech
tags: [Claude Code, AI Coding, Workflow, 开发工具]
permalink: /tech/how-i-use-claude-code/
---

> 原文: [How I Use Claude Code](https://boristane.com/blog/how-i-use-claude-code/) by Boris Tane
> 
> 作者使用 Claude Code 作为主力开发工具约 9 个月，总结出一套与大多数人截然不同的工作流。

## 核心原则

**关键原则：永远不要在 Claude 写出完整计划之前让它开始编码。**

规划与执行的分离是这套工作流的核心，能避免无效劳动、保持架构控制权，并用最少的 token 获得更好的结果。

## 工作流概览

```
Research → Plan → Annotate → Todo List → Implement → Feedback
```

---

## Phase 1: 深度研究 (Research)

每个任务开始前，要求 Claude 深度阅读相关代码，并将发现写入 `research.md`。

**提示词示例：**
```
read this folder in depth, understand how it works deeply, what it does 
and all its specificities. when that's done, write a detailed report of 
your learnings and findings in research.md
```

**关键点：**
- 使用 "deeply"、"in great details"、"intricacies" 等词强调需要深入理解
- 没有这些词，Claude 只会表面浏览
- `research.md` 是审查表面，可以在计划前验证 Claude 是否真正理解了系统

---

## Phase 2: 详细规划 (Planning)

审查研究文档后，要求 Claude 编写详细的 `plan.md` 实现计划。

**提示词示例：**
```
I want to build a new feature <name> that extends the system to perform 
<outcome>. write a detailed plan.md document outlining how to implement 
this. include code snippets
```

**计划应包含：**
- 详细的方法说明
- 实际代码片段
- 要修改的文件路径
- 权衡与考量

---

## Phase 3: 批注循环 (Annotation Cycle)

**这是整个工作流最独特的部分。**

流程：
1. Claude 编写 plan.md
2. 你在编辑器中打开并添加内联批注
3. 发送给 Claude 更新文档
4. 重复 1-6 次直到满意

**批注示例：**
- `"use drizzle:generate for migrations, not raw SQL"` — 领域知识
- `"no — this should be a PATCH, not a PUT"` — 纠正错误假设
- `"remove this section entirely, we don't need caching here"` — 拒绝某方案
- `"this is wrong, restructure the schema section accordingly"` — 重构整个部分

**关键技巧：**
- 每次都要明确说 `"don't implement yet"`
- Markdown 文件是你和 Claude 之间的共享可变状态
- 三轮批注循环可以将一个通用计划转化为完美适配现有系统的方案

---

## Phase 4: Todo 清单

实施前，要求生成详细的任务清单：

```
add a detailed todo list to the plan, with all the phases and individual 
tasks necessary to complete the plan - don't implement yet
```

这作为进度跟踪器，Claude 会在完成任务时标记为已完成。

---

## Phase 5: 执行 (Implementation)

计划就绪后，使用标准提示词：

```
implement it all. when you're done with a task or phase, mark it as completed 
in the plan document. do not stop until all tasks and phases are completed. 
do not add unnecessary comments or jsdocs, do not use any or unknown types. 
continuously run typecheck to make sure you're not introducing new issues.
```

**这个提示词编码了所有重要事项：**
- `"implement it all"` — 完成计划中的所有内容
- `"mark it as completed"` — 在计划文档中标记进度
- `"do not stop until all tasks are completed"` — 不要中途停下来确认
- `"do not add unnecessary comments or jsdocs"` — 保持代码整洁
- `"do not use any or unknown types"` — 保持严格类型
- `"continuously run typecheck"` — 尽早发现问题

---

## 执行中的反馈

实施阶段，你的角色从架构师转为监督者。

**反馈风格变得极其简洁：**
- `"You didn't implement the deduplicateByTitle function."`
- `"You built the settings page in the main app when it should be in the admin app, move it."`

**前端工作最迭代：**
- `"wider"`
- `"still cropped"`
- `"there's a 2px gap"`

**参考现有代码：**
- `"this table should look exactly like the users table"`

**走偏时直接回退：**
- `"I reverted everything. Now all I want is to make the list view more minimal — nothing else."`

回退后缩小范围，几乎总是比试图逐步修复一个糟糕的方法产生更好的结果。

---

## 保持主导权

尽管将执行委托给 Claude，但永远不要让它完全自主决定构建什么。

**决策示例：**
- **挑选提案中的项目：** `"for the first one, just use Promise.all... for the third one, extract it into a separate function... ignore the fourth and fifth ones"`
- **削减范围：** `"remove the download feature from the plan, I don't want to implement this now."`
- **保护现有接口：** `"the signatures of these three functions should not change"`
- **覆盖技术选择：** `"use this model instead of that one"`

**Claude 处理机械执行，你做判断决策。**

---

## 长会话 vs 多会话

作者倾向于**单次长会话**完成研究、规划、批注和实施，而不是拆分成多个会话。

- 到说 `"implement it all"` 时，Claude 已经花了整个会话来建立理解
- 即使在上下文窗口填满后，自动压缩也能保持足够的上下文继续
- `plan.md` 作为持久化工件，在任何时间点都能完整保留

---

## 一句话总结

> **深度阅读，编写计划，批注计划直到正确，然后让 Claude 不停歇地执行整个计划，同时检查类型。**

没有魔法提示词，没有复杂的系统指令，没有巧妙的 hack。只是一个将**思考**与**打字**分离的严谨流程。

- **研究**防止 Claude 做出无知的更改
- **计划**防止它做出错误的更改
- **批注循环**注入你的判断
- **执行指令**让每个决策完成后无中断地运行

---

## 核心收获

1. **规划与执行分离** — 这是最重要的事
2. **深度研究** — 要求 "deeply"、"in great details"
3. **批注循环** — 1-6 轮迭代完善计划
4. **明确边界** — `"don't implement yet"` 是关键
5. **简洁反馈** — 执行阶段用一句话纠正
6. **保持控制** — 你做决策，Claude 执行

试试这个工作流，你会好奇没有批注计划文档是如何用 AI 编码工具交付任何项目的。
