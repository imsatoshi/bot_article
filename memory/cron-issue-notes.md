# 定时任务问题排查记录

## 问题现象
OpenClaw 定时任务状态显示 error，但实际运行正常

## 根本原因
- 任务配置了 `"delivery": {"mode": "announce"}`
- Gateway 投递消息时返回错误，但消息实际已送达
- 可能是状态检测机制的问题

## 当前任务状态

| 任务ID | 名称 | 状态 | 连续错误次数 |
|--------|------|------|-------------|
| 54de3595-a956-494c-9e64-a7167757b205 | 监控-freqtrade状态 | error | 3 |
| 5179e376-a4ce-4fa2-b202-ac13ab8056bd | 监控-claude-relay-service | ok | - |
| 1dbc4959-b239-49fd-a02e-724046d374c9 | 每小时-加密货币分析 | error | 3 |
| 302748c1-cac1-4286-8331-1640d9b389a1 | 刷推-全量 | error | 3 |
| b42a6e56-ca2b-4f88-8d03-4abcb832ba0e | 监控-mini-server健康 | error | 3 |
| 425680fa-98c7-4e6d-a228-b87031c79e67 | 每日-GitHubTrending | error | 3 |
| 40c30a1f-c99b-49ee-a165-b550f812c10e | 每日-HackerNews | error | 3 |
| 6256d6be-1fb8-4373-b4b9-656784bd8510 | 每日-AI新闻简报 | error | 3 |
| dc694baf-80a3-476e-afe3-66721240c9de | 监控-OpenClaw关键词 | ok | - |

## 修复方案

### 方案1: 忽略状态（推荐）
任务实际运行正常，消息也能收到，只是状态显示问题。

### 方案2: 修改投递配置
将 `delivery.mode` 从 `announce` 改为其他模式，或添加 `bestEffortDeliver: true`。

编辑 `~/.openclaw/cron/jobs.json` 修改：
```json
"delivery": {
  "mode": "announce",
  "bestEffort": true
}
```

### 方案3: 重启 Gateway
可能是 Gateway 的投递状态检测卡住：
```bash
openclaw gateway restart
```

## 建议
目前功能正常，建议先观察，如果后续出现消息收不到的情况再考虑修复。
