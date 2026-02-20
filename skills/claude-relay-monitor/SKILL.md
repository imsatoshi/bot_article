---
name: claude-relay-monitor
description: "监控 claude-relay-service 的 API Key 使用情况和费用统计。支持查询总使用量、今日用量、费用估算等。"
---

# Claude Relay 监控

监控 claude-relay-service (23.165.104.242) 的 API Key 使用情况和费用。

## 配置

在 `config/settings.yaml` 中配置：

```yaml
claude_relay:
  host: "23.165.104.242"
  port: 22
  username: "root"
  password: "NKuTMHRrHnw74Mp4"
```

## 使用方法

### 查询所有 API Key 使用情况

```bash
python {baseDir}/scripts/check_apikey_usage.py
```

### 查询费用统计

```bash
python {baseDir}/scripts/check_cost.py
```

### 查询今日实时用量

```bash
python {baseDir}/scripts/check_today.py
```

## 功能

- **API Key 列表**: 显示所有 API Key 的名称、状态、Token限制
- **使用量统计**: 总Token数、今日Token数、总请求数、今日请求数
- **费用估算**: 基于 Claude 官方定价计算费用 (USD)
- **缓存统计**: 缓存创建和读取的 Token 数量

## 定价模型

使用加权平均价估算费用：
- Input: $3.0 / 1M tokens
- Output: $15.0 / 1M tokens  
- CacheRead: $0.3 / 1M tokens

## 示例输出

```
=== API Key 费用估算 (USD) ===

API Key: shenqili
  总费用: $330.32
  今日费用: ~$8.5
  
API Key: zhangjiawei
  总费用: $322.90
  今日费用: $0 (未使用)
  
API Key: zhangping
  总费用: $35.59
  今日费用: $0.1
```
