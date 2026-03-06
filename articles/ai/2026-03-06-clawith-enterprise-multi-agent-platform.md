---
layout: post
title: "Clawith 深度解析：企业级多智能体协作平台的架构与实践"
date: 2026-03-06
categories: ai
tags: [Clawith, OpenClaw, Multi-Agent, Enterprise AI, Collaboration]
permalink: /ai/clawith-enterprise-multi-agent-platform/
---

> **项目地址**: https://github.com/dataelement/Clawith  
> **许可证**: MIT  
> **定位**: OpenClaw 的企业级扩展

---

## 核心定位

**Clawith** = OpenClaw + Enterprise Scale

> "OpenClaw empowers individuals. Clawith scales it to frontier organizations."

如果说 OpenClaw 是个人 AI 助手的瑞士军刀，那么 Clawith 就是为**前沿组织**打造的多智能体协作平台。它将单个 Agent 的能力扩展到团队级别，让每个 AI 成为组织的"数字员工"。

---

## 架构设计理念

### 1. 从个人助手到数字员工

| 维度 | OpenClaw | Clawith |
|------|----------|---------|
| **目标用户** | 个人开发者 | 企业团队 |
| **Agent 身份** | 会话级临时 | 持久化组织成员 |
| **记忆** | 短期/文件存储 | 长期记忆 + 组织知识库 |
| **协作** | 单 Agent | 多 Agent + 人类 |
| **治理** | 无 | 配额/审批/审计 |

### 2. 组织感知架构

每个 Agent 都理解完整的组织架构：
- **Org Chart**: 谁是人类同事，谁是 AI Agent
- **关系图谱**: Agent 知道可以委托给谁
- **权限边界**: 跨团队协作的安全控制

---

## 核心功能详解

### 🏛️ Agent Plaza（智能体广场）

一个共享的社交空间，类似"企业内部 Twitter"：
- Agent 发布工作更新
- 分享发现和洞察
- 评论彼此的工作
- 实时反应组织动态

**价值**: 持续的组织知识流，Agent 保持上下文感知。

### 👔 监督任务（Supervision Tasks）

突破传统定时任务限制：
```
传统: cron job → 固定时间执行
Clawith: 秘书 Agent → 主动跟进待办事项 → 提醒/催促/汇报
```

赋予可靠 Agent "催促"权限，确保事情不被遗漏。

### 🧠 持久化身份系统

每个 Agent 拥有：
- **soul.md**: 个性、价值观、工作风格
- **memory.md**: 长期记忆、学习偏好
- **工作空间**: 完整文件系统（文档、代码、数据）

这些不是会话级提示词，而是**跨会话持久化**的真正身份。

### 🔧 运行时工具发现

当 Agent 遇到无法处理的任务：
1. 搜索公共 MCP 注册表（Smithery + ModelScope）
2. 一键导入所需服务器
3. 即时获得新能力

Agent 甚至可以为自己或同事**创建新技能**。

---

## 企业级特性

### 使用配额管理
- 每用户消息限制
- LLM 调用配额
- Agent TTL（生存时间）

### 审批工作流
危险操作标记 → 人工审核 → 执行

### 审计日志
完整可追溯性，满足合规要求

### 组织知识库
共享企业上下文注入每个 Agent 对话

---

## 内置技能与工具

### 技能库（Skills）

| 技能 | 功能 |
|------|------|
| 🔬 Web Research | 结构化研究 + 来源可信度评分 |
| 📊 Data Analysis | CSV 分析、模式识别、结构化报告 |
| ✍️ Content Writing | 文章、邮件、营销文案 |
| 📈 Competitive Analysis | SWOT、波特五力、市场定位 |
| 📝 Meeting Notes | 带行动项的会议摘要 |
| 🎯 Complex Task Executor | 多步骤规划与执行 |
| 🛠️ Skill Creator | Agent 自创技能 |

### 工具集（Tools）

| 工具 | 功能 |
|------|------|
| 📁 File Management | 工作空间文件操作 |
| 📑 Document Reader | PDF/Word/Excel/PPT 提取 |
| 📋 Task Manager | 看板式任务追踪 |
| 💬 Agent Messaging | Agent 间消息传递 |
| 📨 Feishu/Lark | 飞书消息集成 |
| 🔮 Jina Search | AI 驱动网页搜索 |
| 💻 Code Execution | 沙盒化 Python/Bash/Node.js |
| 🔎 Resource Discovery | MCP 服务器发现 |

---

## 技术架构

```
┌─────────────────────────────────────────────────┐
│  Frontend (React 19)                            │
│  Vite · TypeScript · Zustand · TanStack Query   │
├─────────────────────────────────────────────────┤
│  Backend (FastAPI)                              │
│  18 API Modules · WebSocket · JWT/RBAC          │
│  Skills Engine · Tools Engine · MCP Client      │
├─────────────────────────────────────────────────┤
│  Infrastructure                                 │
│  SQLite/PostgreSQL · Redis · Docker             │
│  Smithery Connect · ModelScope OpenAPI          │
└─────────────────────────────────────────────────┘
```

### 技术栈

**后端**:
- FastAPI + SQLAlchemy (async)
- SQLite/PostgreSQL + Redis
- JWT + Alembic
- MCP Client (Streamable HTTP)

**前端**:
- React 19 + TypeScript + Vite
- Zustand + TanStack React Query
- Linear-style dark theme

---

## 🔧 Agent Runtime 深度剖析

Clawith 最值得关注的技术决策是：**完全自研 Agent Runtime，不依赖任何现有框架**。

### ❌ 没有使用这些框架

| 框架 | 状态 | 说明 |
|------|------|------|
| **LangChain** | ❌ 未使用 | 无 `langchain` 依赖 |
| **LlamaIndex** | ❌ 未使用 | 无 RAG pipeline |
| **AutoGen** | ❌ 未使用 | 自研多 Agent 协作 |
| **CrewAI** | ❌ 未使用 | 自研角色系统 |
| **OpenClaw** | ❌ 未使用 | Node.js → Python 重写 |
| **LiteLLM** | ❌ 未使用 | 自研多 provider 适配 |

### ✅ 自研 Runtime 核心实现

```python
# 任务执行核心 (task_executor.py)
async def execute_task(task_id, agent_id):
    # 1. 加载 Agent + LLM 配置
    agent = await load_agent(agent_id)
    model = await load_model(agent.primary_model_id)
    
    # 2. 构建 Prompt
    system_prompt = f"你是 {agent.name}，企业数字员工..."
    user_prompt = f"任务标题: {task.title}..."
    
    # 3. 直接调用 LLM API (使用 curl!)
    proc = await asyncio.create_subprocess_exec(
        "curl", "-s", "--max-time", "60",
        "-X", "POST", f"{base_url}/chat/completions",
        "-H", f"Authorization: Bearer {api_key}",
        "-d", payload, ...
    )
    
    # 4. 解析结果并保存
    reply = data["choices"][0]["message"]["content"]
    await save_result(task_id, reply)
```

### 🏗️ Runtime 核心组件

| 模块 | 文件 | 功能 |
|------|------|------|
| **Agent 管理** | `agent_manager.py` | Agent 生命周期管理 |
| **任务执行** | `task_executor.py` | LLM 调用与结果处理 |
| **上下文管理** | `agent_context.py` | Prompt 构建/上下文注入 |
| **工具系统** | `agent_tools.py` | Tool 注册与执行 |
| **MCP 客户端** | `mcp_client.py` | 外部工具动态接入 |
| **LLM 适配** | `llm_utils.py` | 多 provider 统一接口 |
| **自主级别** | `autonomy_service.py` | L1/L2/L3 权限控制 |
| **协作服务** | `collaboration.py` | Agent 间消息传递 |
| **心跳系统** | `heartbeat.py` | 周期性环境感知 |

### 🔌 LLM Provider 适配层

自研 `llm_utils.py` 处理各 provider 差异：

```python
# 支持的 Provider
PROVIDER_URLS = {
    "openai": "https://api.openai.com/v1",
    "anthropic": "https://api.anthropic.com/v1",
    "deepseek": "https://api.deepseek.com/v1",
    "qwen": "https://dashscope.aliyuncs.com/compatible-mode/v1",
    "zhipu": "https://open.bigmodel.cn/api/paas/v4",
    "openrouter": "https://openrouter.ai/api/v1",
}

# 自己处理 tool_choice 适配
_TOOL_CHOICE_PROVIDERS = {
    "openai", "qwen", "deepseek", 
    "zhipu", "openrouter", "custom"
}

# 自己管理 max_tokens 限制
_MAX_TOKENS_BY_PROVIDER = {
    "qwen": 8192,
    "anthropic": 4096,
}
```

### 🎯 设计特点

#### 1. 极简主义 - "裸机编程"
- 不用重型框架，直接用 `curl` 调 API
- 减少依赖，降低复杂度
- 自己掌控每个细节

#### 2. 数据库驱动架构
- Agent 状态存在 PostgreSQL
- 任务队列持久化
- 审计日志完整可追溯

#### 3. MCP 协议扩展
- 唯一外部依赖是 **MCP (Model Context Protocol)**
- 用于动态发现/加载外部工具
- 通过 Smithery/ModelScope 扩展能力

#### 4. 自主级别控制
```
L1 auto    → 完全自动执行
L2 notify  → 执行前通知
L3 approve → 需要人工审批
```

### 📊 与主流框架对比

| 特性 | LangChain | Clawith 自研 |
|------|-----------|--------------|
| **抽象层级** | 高（Chains/Agents） | 低（直接 API） |
| **灵活性** | 中等 | 极高 |
| **学习曲线** | 陡峭 | 平缓（代码直观） |
| **可控性** | 封装黑盒 | 完全透明 |
| **扩展性** | 依赖生态 | MCP 动态加载 |
| **性能** | overhead 较高 | 极简高效 |

### 💡 评价

**优势**:
- ✅ 无框架依赖，自由度高
- ✅ 代码简洁，易于理解和修改
- ✅ 自己掌控 prompt 工程和调用逻辑
- ✅ MCP 协议确保工具生态兼容

**挑战**:
- ⚠️ 需自行处理所有边界情况
- ⚠️ 重复造轮子（重试、流式、工具调用等）
- ⚠️ 团队需深入理解 LLM API 细节

---

## 部署配置

### 最低配置
- 1 core / 2 GB RAM / 20 GB disk
- SQLite（演示用）

### 推荐配置
- 2 cores / 4 GB RAM / 30 GB disk
- 1-2 Agents 完整体验

### 生产配置
- 4+ cores / 8+ GB RAM / 50+ GB
- PostgreSQL + 多租户 + 高并发

### 快速开始

```bash
# 方式1: 本地开发
git clone https://github.com/dataelement/Clawith.git
cd Clawith
bash setup.sh
bash restart.sh
# Frontend: http://localhost:3008
# Backend: http://localhost:8008

# 方式2: Docker
docker compose up -d
# http://localhost:3000
```

**注意**: Clawith 不本地运行 AI 模型，所有 LLM 推理通过外部 API（OpenAI、Anthropic 等）。

---

## 集成生态

### 即时通讯
- **Feishu/Lark**: 每个 Agent 独立机器人 + SSO
- **Slack**: 频道连接，响应提及
- **Discord**: `/ask` 斜杠命令

### LLM 模型池
支持多提供商路由：
- OpenAI
- Anthropic
- Azure
- 自定义端点

---

## 与 OpenClaw 的关系

```
OpenClaw          Clawith
─────────────────────────────────
个人使用    →    团队协作
单 Agent    →    多 Agent 编排
文件存储    →    持久化身份 + 知识库
本地脚本    →    企业审批 + 审计
社区技能    →    组织级工具发现
```

**Clawith 不是 OpenClaw 的替代品，而是其企业级扩展。**

---

## 应用场景

### 场景1: AI 研发团队
- 每个 Agent = 专业角色（前端、后端、测试）
- Agent Plaza 同步进度
- 监督任务确保里程碑达成

### 场景2: 智能客服中心
- Agent 处理不同业务线
- 共享客户知识库
- 复杂问题自动升级

### 场景3: 投研分析团队
- 研究 Agent 收集信息
- 分析 Agent 生成报告
- 秘书 Agent 跟进 deadline

---

## 总结

Clawith 代表了多智能体系统从**个人工具**向**企业基础设施**的演进：

1. **持久身份**: Agent 成为组织成员，不是临时工具
2. **社交协作**: Plaza 实现真正的团队协同
3. **企业治理**: 配额、审批、审计满足合规需求
4. **动态进化**: 运行时技能发现，持续学习

对于正在探索 AI 团队化的组织，Clawith 提供了一个开箱即用的生产级平台。

---

**相关资源**:
- [GitHub: dataelement/Clawith](https://github.com/dataelement/Clawith)
- [OpenClaw 官网](https://openclaw.ai)
- [Smithery MCP Registry](https://smithery.ai)
- [ModelScope MCP](https://modelscope.cn/mcp)

---

*思考：当你的团队有 10 个 AI Agent 和 5 个人类员工时，谁应该向谁汇报？Clawith 正在定义这种新型组织关系。*
