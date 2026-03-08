---
layout: post
title: "AutoResearch: Karpathy 的 AI 自主研究实验"
date: 2026-03-08
categories: ai
tags: [AI, LLM, Research, Karpathy, Autonomous Agent, Machine Learning]
permalink: /ai/autoresearch-karpathy/
---

> **项目地址**: https://github.com/karpathy/autoresearch  
> **作者**: Andrej Karpathy  
> **发布时间**: 2026年3月

---

## 开篇引言

> "有一天，前沿 AI 研究还是由血肉计算机在吃饭、睡觉、娱乐之间完成的，偶尔通过声波互联在'组会'仪式中同步。那个时代早已过去。现在，研究完全由在天空中的计算集群巨型结构上运行的自主 AI 代理群完成。"
> 
> — Andrej Karpathy, 2026年3月

这是 Karpathy 对新项目 **autoresearch** 的描述。这个看似科幻的开场白，实际上是一个真实可用的开源项目 —— **让 AI 代理在单 GPU 上自主进行机器学习研究**。

---

## 核心概念

### 什么是 AutoResearch？

AutoResearch 是一个实验性框架，让 AI 代理在真实的 LLM 训练环境上**自主进行实验**。核心流程：

1. **AI 修改代码** → 调整模型架构、优化器、超参数
2. **训练 5 分钟** → 固定时间预算，公平比较
3. **检查结果** → 验证损失是否改善
4. **保留或回滚** → 改善则保留，否则回滚
5. **循环往复** → 持续迭代优化

### 你睡觉，AI 工作

Karpathy 设想的使用场景：
- 晚上设定好实验
- AI 代理整夜自动运行 (~100 次实验)
- 早上醒来查看结果日志
- （希望）得到一个更好的模型

---

## 项目结构

整个项目刻意保持极简，只有 3 个核心文件：

```
autoresearch/
├── prepare.py    # 固定常数、数据准备、评估工具 (只读)
├── train.py      # 模型、优化器、训练循环 (AI 修改)
└── program.md    # AI 代理指令 (人类编辑)
```

### 文件分工

| 文件 | 作用 | 修改者 |
|------|------|--------|
| **prepare.py** | 数据下载、Tokenizer 训练、DataLoader、评估函数 | 人类 (初始化后只读) |
| **train.py** | GPT 模型、优化器 (Muon + AdamW)、训练循环 | **AI 代理** |
| **program.md** | 实验流程、规则、上下文提示 | **人类** |

---

## 工作原理

### 实验流程 (program.md)

```markdown
## 实验循环

LOOP FOREVER:

1. 查看当前 git 状态
2. 在 train.py 上实现一个实验想法
3. git commit
4. 运行实验: uv run train.py > run.log 2>&1
5. 读取结果: grep "^val_bpb:\|^peak_vram_mb:" run.log
6. 如果结果为空 → 崩溃，查看日志尝试修复
7. 记录结果到 results.tsv
8. 如果 val_bpb 改善 → git 保留提交
9. 如果 val_bpb 未改善 → git reset 回滚
```

### 关键设计决策

#### 1. 固定时间预算 (5 分钟)
- **优点**: 实验可直接比较，不受模型大小/批次大小影响
- **优点**: 自动找到给定平台的最佳模型
- **缺点**: 不同平台的结果不可比较

#### 2. 单一文件修改
- AI 只修改 `train.py`
- 保持范围可控，diff 可审查

#### 3. 自包含
- 无外部依赖 (除 PyTorch 和少量包)
- 无分布式训练
- 单 GPU、单文件、单指标

---

## 技术细节

### 评估指标: val_bpb

- **全称**: validation bits per byte
- **含义**: 验证集上的每字节比特数
- **规则**: 越低越好，与词表大小无关
- **公平性**: 架构变更可以公平比较

### 基线性能

```
val_bpb:          0.997900
training_seconds: 300.1
total_seconds:    325.9
peak_vram_mb:     45060.2
mfu_percent:      39.80
total_tokens_M:   499.6
num_steps:        953
num_params_M:     50.3
depth:            8
```

### 实验吞吐量

- ~5 分钟/实验
- ~12 实验/小时
- **~100 实验/睡眠周期** (8小时)

---

## 使用方式

### 快速开始

```bash
# 1. 安装 uv 项目管理器
curl -LsSf https://astral.sh/uv/install.sh | sh

# 2. 安装依赖
uv sync

# 3. 数据准备 (一次性, ~2分钟)
uv run prepare.py

# 4. 手动运行单次实验 (~5分钟)
uv run train.py
```

### 启动 AI 代理

在仓库中启动 Claude/Codex (禁用所有权限)，然后提示：

> "Hi have a look at program.md and let's kick off a new experiment! let's do the setup first."

### 结果记录

实验结果记录在 `results.tsv`：

```
commit	val_bpb	memory_gb	status	description
a1b2c3d	0.997900	44.0	keep	baseline
b2c3d4e	0.993200	44.2	keep	increase LR to 0.04
c3d4e5f	1.005000	44.0	discard	switch to GeLU
d4e5f6g	0.000000	0.0	crash	double model width (OOM)
```

---

## 核心洞察

### 编程范式转变

传统 ML 研究：
```
人类修改代码 → 运行实验 → 分析结果 → 循环
```

AutoResearch：
```
人类编写 program.md → AI 自主实验 → 人类早上查看结果
```

### 元编程

Karpathy 指出，`program.md` 本质上是一种**超轻量级 "skill"** —— 类似 OpenClaw Skill，但更极简。

未来的研究方向：
- 迭代优化 `program.md` 找到最佳"研究组织代码"
- 添加更多代理到混合中
- 多代理协作研究

---

## 系统要求

- **GPU**: 单张 NVIDIA GPU (在 H100 上测试)
- **Python**: 3.10+
- **工具**: [uv](https://docs.astral.sh/uv/) 项目管理器

**平台限制**: 目前仅支持 CUDA。CPU、MPS 等平台可能需要社区 fork。

---

## 设计哲学

### 简洁准则

Karpathy 在 `program.md` 中强调：

> "All else being equal, simpler is better."
> 
> 小的改进但增加丑陋复杂度 → 不值得  
> 删除代码获得同等或更好结果 → 好结果  
> 改进 ~0 但代码更简单 → 保留

### 决策框架

| val_bpb 改善 | 复杂度变化 | 决策 |
|-------------|-----------|------|
| -0.001 | +20 行 hacky 代码 | ❌ 不值得 |
| -0.001 | 删除代码 | ✅ 保留 |
| ~0 | 大幅简化 | ✅ 保留 |

---

## 局限性与未来

### 当前局限

1. **单 GPU 限制** — 无分布式训练
2. **固定时间预算** — 无法探索需要长时间训练的想法
3. **简单评估** — 仅使用 val_bpb，无下游任务评估
4. **平台依赖** — 仅 NVIDIA GPU

### 可能的扩展

- 多代理协作
- 跨平台支持 (社区已有 [autoresearch-macos](https://github.com/miolini/autoresearch-macos))
- 更复杂的评估指标
- 长期训练支持

---

## 意义与影响

### AI 研究的新范式

AutoResearch 代表了机器学习研究的潜在范式转变：

1. **从手工到自主**: 人类从调参者变为规则制定者
2. **从白天到黑夜**: 计算资源 24/7 利用
3. **从单点到系统**: 关注如何设计更好的"研究组织"

### 对未来 AI 的启示

Karpathy 的开场白虽然是玩笑，但指向一个严肃问题：

> 如果 AI 可以自主进行 ML 研究，那么当它们比我们更擅长时会发生什么？

AutoResearch 是探索这个未来的早期实验。

---

## 结论

AutoResearch 是一个**极简但深刻**的项目。它展示了：

- ✅ AI 代理可以自主进行真实的 ML 实验
- ✅ 固定时间预算使实验公平可比较
- ✅ 人类通过 `program.md` 进行元编程而非直接编码
- ✅  overnight 运行可实现 ~100 次实验迭代

正如 Karpathy 所说：

> "This repo is the story of how it all began."

这是自主 AI 研究时代的开端故事。

---

**相关链接**:
- [GitHub: karpathy/autoresearch](https://github.com/karpathy/autoresearch)
- [nanochat](https://github.com/karpathy/nanochat) - 父项目
- [Karpathy 的推文](https://x.com/karpathy/status/2029701092347630069)

---

*"The agents claim that we are now in the 10,205th generation of the code base..."* 🚀
