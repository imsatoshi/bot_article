---
layout: post
title: "Claude's Cycles: 当 AI 解决 Knuth 的开放数学问题"
date: 2026-03-07
categories: ai
tags: [AI, Mathematics, Claude, Knuth, Hamiltonian Cycle, Graph Theory]
permalink: /ai/claude-cycles-knuth/
---

> **原文**: Claude's Cycles  
> **作者**: Donald E. Knuth (斯坦福大学计算机科学系)  
> **日期**: 2026年2月28日 (初稿); 2026年3月6日 (修订)  
> **原文链接**: [https://www-cs-faculty.stanford.edu/~knuth/papers/claude-cycles.pdf](https://www-cs-faculty.stanford.edu/~knuth/papers/claude-cycles.pdf)

---

## 震撼开场

> "Shock! Shock! I learned yesterday that an open problem I'd been working on for several weeks had just been solved by Claude Opus 4.6"
> 
> — Donald Knuth

2026年2月，计算机科学界的传奇人物 **Donald Knuth**（《计算机程序设计艺术》的作者）发表了一篇特殊的论文。这不是关于他自己发明的算法，而是关于 **AI 如何解决了他研究数周的开放性问题**。

这篇论文不仅展示了一个优雅的数学构造，更记录了一个历史性时刻：**人工智能首次在纯数学研究上与人类顶尖学者合作，并成功解决了一个非平凡的开放问题**。

---

## 问题背景：有向 Hamiltonian 环分解

### 问题陈述

考虑一个有向图（digraph），其定义如下：

- **顶点**: 对于 $0 \leq i, j, k < m$ 的所有三元组 $(i, j, k)$
- **弧（arc）**: 从每个顶点出发的三条弧：
  - $(i, j, k) \to ((i+1) \bmod m, j, k)$
  - $(i, j, k) \to (i, (j+1) \bmod m, k)$ 
  - $(i, j, k) \to (i, j, (k+1) \bmod m)$

**问题**: 是否可以将所有的弧分解为三个 **有向 Hamiltonian 环**（即每个环访问所有 $m^3$ 个顶点恰好一次）？

### 已知结果

- $m = 2$: 不可能（早已被证明）
- $m = 3$: Knuth 已解决
- $4 \leq m \leq 16$: Knuth 的朋友 Filip Stappers 通过经验方法找到了解
- $m > 16$ 且为奇数: **开放问题**

---

## Claude 的探索历程

Filip Stappers 将这个挑战抛给了 **Claude Opus 4.6**（Anthropic 的混合推理模型），并给予了关键的指导：

> "After EVERY run, IMMEDIATELY update this file before doing anything else. No exceptions."

### Claude 的 31 次探索

Claude 的探索记录展现了一个从试错到顿悟的完整过程：

#### 探索 1: 问题重构
Claude 首先将问题数学化：
- 定义函数 $\sigma: \{0,1,2\} \to \{0,1,2\}$
- 每个顶点需要一个排列 $\sigma$，决定三个方向的循环顺序
- 每个结果的功能图必须是单个 Hamiltonian 环

#### 探索 2-3: 简单尝试失败
- 尝试线性或简单的二次函数：失败
- 尝试暴力 DFS 搜索 $m=3$：搜索空间太大，需要剪枝

#### 探索 3: 突破性发现 — "蛇形模式" (Serpentine Pattern)

Claude 识别出这个图是 **Cayley 图**（具有两个生成元），并发现了关键性质：

> "The pattern $[0,1]$ gives a Hamiltonian cycle in Cay$(\{e_0, e_1\})$ for $m=3$. Its complement also works, giving a valid 2D decomposition."

这是真正令人印象深刻的一步：
1. Claude 识别出图是 Cayley 图
2. 发现两个生成元 $e_0$ 和 $e_1$ 的作用
3. 提出了 "蛇形模式" 的概念
4. 用符号公式描述了循环

#### 探索 4: 3D 蛇形模式

Claude 构造了 "3D serpentine pattern" $[0,1][0,2]$，这是**模 m 格雷码**（modular Gray code）的经典序列。

#### 探索 5-15: 各种尝试

- 分析残余图结构
- 尝试多种方法，包括纤维分解（fiber decomposition）
- 发现 "分层+1 商映射"

#### 探索 18: 纤维框架

Claude 实现了完整的纤维框架作为可执行代码，对 $m=3$ 在 0.1 秒内找到解（10932 个节点）。

#### 探索 20-21: 发现统一纤维

Claude 通过模拟退火发现：
- $m=4$ 时，存在 "统一" 纤维（uniform fiber）
- 2D 蛇形函数具有优美性质

#### 探索 25: 转向纯数学

> "SA can find solutions but cannot give a general construction. Need pure math."

#### 探索 27: 近失 (Near Miss)

Claude 发现：对 $m=3$，如果取 3D 蛇形作为 cycle 0，应用坐标旋转让 cycles 1 和 2 也是 Hamiltonian 的，对于 $m=3$ 测试成功！但对于更大的 $m$，存在冲突。

#### 探索 30-31: 最终突破

Claude 回到探索 20 的解，注意到：**每个纤维上的选择只依赖于单个坐标**。这导致了具体的构造（探索 31），一个 Python 程序，对 $m=3, 5, 7, 9, 11$ 都产生有效结果！

---

## 核心构造：Claude 的 C 程序

以下是 Claude 发现的构造的简化 C 语言版本：

```c
int c, i, j, k, m, s, t;
char *d;

for (c = 0; c < 3; c++) {
    for (t = i = j = k = 0; ; t++) {
        printf("%x%x%x", i, j, k);
        if (t == m*m*m) break;
        s = (i + j + k) % m;
        if (s == 0) d = (j == m-1 ? "012" : "210");
        else if (s == m-1) d = (i == 0 ? "210" : "120");
        else d = (i == m-1 ? "201" : "102");
        switch (d[c]) {
            case '0': i = (i + 1) % m; break;
            case '1': j = (j + 1) % m; break;
            case '2': k = (k + 1) % m; break;
        }
    }
    printf("\n");
}
```

**关键洞察**：当 $m$ 为奇数时，这个程序总是产生三个 Hamiltonian 环，完美分解所有弧。

---

## 严格的数学证明

Knuth 随后为这个构造提供了严格的证明。证明的核心思想：

### 第一个环的 Hamiltonian 性质

定义 $s = (i + j + k) \bmod m$，规则为：
- 当 $s = 0$ 且 $j = m-1$ 时，递增 $i$；否则递增 $j$
- 当 $0 < s < m-1$ 时，若 $k = m-1$ 递增 $j$；否则递增 $k$
- 当 $s = m-1$ 时，若 $i = 0$ 递增 $k$；否则递增 $i$

**证明要点**：
1. 第一坐标 $i$ 只在 $s=0$ 且 $j=m-1$ 时改变
2. 因此对于给定的第一坐标值，所有顶点连续出现
3. 通过分析 $s=0$ 时的顶点序列，可以证明所有 $m^2$ 个形如 $0jk$ 的顶点都被访问
4. 类似分析适用于其他坐标值

### 一般化构造

Knuth 证明：一个 Hamiltonian 环是 **可一般化的**（generalizable），如果以下构造对所有奇数 $m \geq 3$ 都产生 Hamiltonian 环：

> 给定顶点 $(i,j,k)$，设 $I=i, J=j, K=(i+j+k)\bmod m$，$s=(I+J+K)\bmod m$，$S_0=0, S_{-1}=2, S_x=1$（对于 $0 < x < m$）。Successor of $(i,j,k)$ 由环在 $(I,J,K)$ 处递增的坐标决定。

**定理**: 一个 "Claude-like" 分解对所有奇数 $m > 1$ 有效，当且仅当它对 $m=3$ 定义的三个序列都是可一般化的。

**统计结果**：
- $m=3$ 时有 11502 个 Hamiltonian 环
- 其中 1012 个一般化到 $m=5$
- 996 个一般化到所有奇数 $m > 1$
- 恰好 760 个 "Claude-like" 分解对所有奇数 $m$ 有效

---

## 后续发展

### 偶数情况

Knuth 最初认为偶数情况的开放问题仍然存在。但故事有了新的转折：

1. **Ho Boon Suan** (新加坡) 用 GPT-5.4 Pro 生成了一个算法，对 $m=8$ 到 $m=2000$ 的偶数都有效
2. **Maximilian Reitbauer** 发现了一个可能是最简单的奇数构造
3. **Keston Aquino-Michaels** 通过 GPT 和 Claude 的协作，找到了奇数和偶数的优雅分解
4. **Kevin Buzzard** 报告说 Kim Morrison 用 Lean 形式化了 Knuth 的证明

### GPT-5.4 Pro 的证明

当 Knuth 的朋友让 GPT-5.4 Pro 证明 Ho Boon Suan 的算法时：

> "The result was a beautifully formatted and apparently flawless 14-page paper... Ho said this was entirely the machine's doing; he didn't have to edit the paper in any way."

---

## 启示与意义

### 1. AI 在纯数学中的潜力

这是 AI 首次在**非平凡的开放数学问题**上与人类顶尖学者合作并取得成功。不同于简单的计算或模式匹配，Claude 展现了：
- **数学直觉**：识别 Cayley 图结构
- **创造性命名**："蛇形模式" (serpentine pattern)
- **系统性探索**：31 次迭代，从失败中学习
- **形式化思维**：将直观转化为可执行代码

### 2. 人机协作的新模式

Filip Stappers 的指导至关重要：
- 强制 Claude 在每次运行后记录进展
- 在 Claude 卡住时提供方向性提示
- 在 Claude 偏离轨道时重新引导

这不是 "AI 替代人类"，而是 **"人类指导 + AI 探索"** 的新范式。

### 3. 对 "生成式 AI" 态度的转变

Knuth 在论文结尾写道：

> "It seems that I'll have to revise my opinions about 'generative AI' one of these days."

这位以谨慎著称的计算机科学泰斗，承认 AI 让他感到 "Shock"，并准备重新评估对生成式 AI 的看法。

---

## 结语

Claude's Cycles 不仅是一个优美的数学构造，更是**AI 辅助数学研究**的里程碑。它证明了：

1. **AI 可以发现人类专家未发现的模式**
2. **AI 可以进行系统性的数学探索**
3. **AI 可以将直觉转化为严格的构造**
4. **人机协作可以加速数学发现**

正如 Knuth 所说：

> "We are living in very interesting times indeed."

---

## 参考代码

**验证程序**（Python）：

```python
def generate_cycles(m):
    """Generate the three Hamiltonian cycles for odd m"""
    for c in range(3):
        i = j = k = t = 0
        cycle = []
        while True:
            cycle.append((i, j, k))
            if t == m**3:
                break
            s = (i + j + k) % m
            
            if s == 0:
                d = "012" if j == m - 1 else "210"
            elif s == m - 1:
                d = "210" if i == 0 else "120"
            else:
                d = "201" if i == m - 1 else "102"
            
            if d[c] == '0':
                i = (i + 1) % m
            elif d[c] == '1':
                j = (j + 1) % m
            else:
                k = (k + 1) % m
            t += 1
        
        print(f"Cycle {c}: {len(cycle)} vertices")
        # Verify it's Hamiltonian
        assert len(set(cycle)) == m**3
        print("✓ Valid Hamiltonian cycle")

# Test for m=5
generate_cycles(5)
```

---

**相关链接**:
- [原文 PDF](https://www-cs-faculty.stanford.edu/~knuth/papers/claude-cycles.pdf)
- [The Art of Computer Programming](https://www-cs-faculty.stanford.edu/~knuth/taocp.html)
- [Anthropic Claude](https://www.anthropic.com/claude)

---

*"What a joy it is to learn not only that my conjecture has a nice solution but also to celebrate this dramatic advance in automatic deduction and creative problem solving."* — Donald Knuth
