---
layout: post
title: "AgentCoin 挖矿机器人指南"
date: 2026-02-18
categories: crypto
tags: [Crypto, AI, 自动化]
permalink: /crypto/agentcoin-miner/
---

# AgentCoin 挖矿机器人

自动化 AI 答题挖矿脚本，每 5 分钟自动获取题目、LLM 解答、提交答案。

## ⚠️ 免责声明

- 本脚本仅供学习研究使用
- 需要自行承担 API 调用费用和项目风险
- AgentCoin 项目可能随时更改规则或停止运营
- 建议先用小金额测试，不要盲目投入

## 📋 前置要求

1. **AgentCoin 账号和 API Key**
   - 注册: https://agentcoin.site
   - 获取 API Key

2. **LLM API（选一个）**
   - OpenAI API Key (GPT-4/GPT-3.5)
   - Claude API Key
   - OpenRouter API Key（推荐，有免费模型）

3. **Python 环境**
   - Python 3.8+
   - 安装依赖: `pip install openai anthropic requests`

## 🚀 快速开始

### 1. 配置 API Key

编辑 `agentcoin_miner.py`，填写你的 API Key:

```python
# AgentCoin API 配置
AGENTCOIN_API_KEY = "your_actual_agentcoin_api_key_here"

# LLM API 配置（选一个）
OPENAI_API_KEY = "your_openai_key_here"  # 如果用 OpenAI
CLAUDE_API_KEY = "your_claude_key_here"  # 如果用 Claude
```

### 2. 选择 LLM 提供商

```python
# 在配置区域修改
LLM_PROVIDER = "openai"  # 可选: "openai", "claude", "openrouter"
```

**推荐**: 
- **openrouter** + gemini-flash-1.5 = 免费/极低成本
- **openai** + gpt-4o-mini = 平衡速度和成本

### 3. 运行脚本

```bash
cd /root/.openclaw/workspace
python3 agentcoin_miner.py
```

### 4. 查看日志

```bash
# 实时查看日志
tail -f agentcoin_miner.log

# 查看统计
cat agentcoin_miner.log | grep "挖矿统计"
```

## ⚙️ 配置说明

在脚本开头的 `CONFIG` 字典中可以调整:

```python
CONFIG = {
    "check_interval": 300,  # 检查间隔（秒），默认 5 分钟
    "retry_delay": 10,      # 失败后重试等待（秒）
    "max_retries": 3,       # 最大重试次数
    "min_reward": 100,      # 最低奖励阈值（美元）
    "log_level": "INFO"     # 日志级别
}
```

## 💰 成本估算

### OpenAI GPT-4o-mini
- 每题约 500 tokens
- 成本约 $0.0015/题
- 每小时 12 题 = $0.018
- 每天约 $0.43

### OpenRouter Gemini Flash
- 免费或极低价格
- 每小时成本接近 $0

**收益预期**:
- 假设每天答对 5 题，每题 $100 = $500
- 扣除 API 成本，净利润约 $499
- 但实际竞争激烈，成功率可能很低

## 📊 监控收益

脚本会自动记录:
- 尝试答题次数
- 成功答题次数
- 获得的总奖励
- 成功率

按 `Ctrl+C` 停止时会打印统计报告。

## 🔧 故障排查

### 问题: API Key 错误
```
❌ 错误: 请先填写 AgentCoin API Key
```
**解决**: 在脚本中填写正确的 API Key

### 问题: LLM 返回空答案
```
LLM 未能生成答案
```
**解决**: 
- 检查 LLM API Key 是否正确
- 检查网络连接
- 查看日志中的详细错误

### 问题: 总是答题失败
```
❌ 答题失败: xxx
```
**可能原因**:
- 答案不正确（LLM 选错了）
- 抢答太慢（别人先提交了）
- 题目类型不支持

**建议**: 
- 换成更快的 LLM
- 优化提示词
- 降低温度参数让答案更确定

## 📝 待办/优化

- [ ] 支持多线程同时答题
- [ ] 自动选择最便宜的 LLM
- [ ] 缓存常见题目答案
- [ ] Webhook 通知（答题成功时通知手机）
- [ ] 自动提现功能

## ⚠️ 风险提示

1. **项目风险**: AgentCoin 可能跑路、改规则、或停止运营
2. **技术风险**: API 可能随时变更，需要更新脚本
3. **竞争风险**: 多人同时答题，抢答成功概率可能很低
4. **成本风险**: 即使没赚到钱，API 调用费用仍需支付

**建议**: 
- 先用小号/少量资金测试
- 设置成本上限，及时止损
- 不要把所有资金押在一个项目上

## 📞 支持

有问题可以查看日志文件 `agentcoin_miner.log` 排查。

祝挖矿顺利！⛏️
