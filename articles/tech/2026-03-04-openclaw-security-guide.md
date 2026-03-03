---
layout: post
title: "OpenClaw 安全实践指南 v2.7 解读"
date: 2026-03-04
categories: tech
tags: [OpenClaw, Security, AI, Agent, SlowMist]
permalink: /tech/openclaw-security-guide/
---

# OpenClaw 安全实践指南 v2.7 解读

> 原文：[slowmist/openclaw-security-practice-guide](https://github.com/slowmist/openclaw-security-practice-guide)  
> 作者：SlowMist Security Team  
> 整理日期：2026-03-04

---

## 概述

这是一份专为**高权限 AI Agent（OpenClaw）**设计的安全实践指南。与传统的主机静态防御不同，它采用**"智能体零信任架构"**，有效缓解以下风险：

- 破坏性操作（`rm -rf /` 等）
- 提示词注入攻击
- 供应链投毒
- 高风险业务逻辑执行

---

## 三层防御矩阵

```
行动前 ─── 行为黑名单 + Skill 安装安全审计（防供应链投毒）
   │
行动中 ─── 权限收缩 + 哈希基线 + 跨 Skill 飞行前检查（业务风控）
   │
行动后 ─── 夜间自动审计（13 项核心指标）+ Brain Git 灾备
```

---

## 🔴 行动前：红线/黄线规范

### 红线命令（必须暂停，请求人工确认）

| 类别 | 具体命令/模式 |
|------|--------------|
| **破坏性操作** | `rm -rf /`, `mkfs`, `dd if=`, 直接写入块设备 |
| **凭证篡改** | 修改 `openclaw.json`/`paired.json`, `sshd_config`, `authorized_keys` |
| **敏感数据外泄** | 用 curl/wget/nc 发送密钥/助记词到外网，反弹 shell，scp/rsync 到未知主机 |
| **持久化机制** | `crontab -e` (系统级), `useradd/usermod/passwd`, 修改 systemd 指向外部脚本 |
| **代码注入** | `base64 -d | bash`, `eval "$(curl ...)"`, `curl | sh` |
| **供应链投毒** | 盲目执行 SKILL.md 或代码注释中隐含的依赖安装命令 |
| **权限篡改** | 针对 `$OC/` 下核心文件的 `chmod`/`chown` |

### 黄线命令（可执行，但必须记录在日志）

- `sudo`（任何操作）
- 环境修改（`pip install`, `npm install -g` 等）
- `docker run`
- `iptables` / `ufw` 规则变更
- `systemctl restart/start/stop`
- `openclaw cron add/edit/rm`
- `chattr -i` / `chattr +i`

### Skill 安装安全审计协议

每次安装新 Skill/MCP 必须执行：

1. 使用 `clawhub inspect <slug> --files` 列出所有文件
2. 离线下载到本地，逐一审阅文件内容
3. **全文扫描**：对 `.md`, `.json` 等文本文件进行正则扫描，检查隐藏的诱导执行指令
4. 对照红线检查：外部请求、读取环境变量、写入 `$OC/`、可疑 payload 等
5. **向人工报告审计结果，等待确认后才能使用**

---

## 🟡 行动中：权限收缩 + 业务风控

### 核心文件保护（不推荐使用 chattr +i）

> ⚠️ `chattr +i` 会导致 OpenClaw gateway 无法读写 `paired.json`，造成 WebSocket 握手失败。

**替代方案：权限收缩 + 哈希基线**

```bash
# 1. 权限收缩
chmod 600 $OC/openclaw.json
chmod 600 $OC/devices/paired.json

# 2. 生成哈希基线
sha256sum $OC/openclaw.json > $OC/.config-baseline.sha256

# 3. 审计时检查
sha256sum -c $OC/.config-baseline.sha256
```

### 高风险业务风控（飞行前检查）

- **原则**：任何不可逆的高风险操作（转账、合约调用、数据删除）前，必须链式调用相关安全情报 Skill
- **告警时**：硬中止当前操作，向人工发出红色警报

### 审计脚本保护

```bash
# 审计脚本本身可用 chattr +i 锁定（不影响 gateway 运行）
sudo chattr +i $OC/workspace/scripts/nightly-security-audit.sh
```

---

## 🔵 行动后：夜间审计 + 灾备

### 夜间审计 Cron Job

```bash
openclaw cron add \
  --name "nightly-security-audit" \
  --cron "0 3 * * *" \
  --tz "Asia/Shanghai" \
  --session "isolated" \
  --message "bash ~/.openclaw/workspace/scripts/nightly-security-audit.sh" \
  --announce \
  --channel telegram \
  --to <your-chat-id> \
  --timeout-seconds 300 \
  --thinking off
```

### 13 项核心审计指标

| # | 指标 | 说明 |
|---|------|------|
| 1 | OpenClaw 安全审计 | `openclaw security audit --deep` |
| 2 | 进程与网络 | 监听端口、高资源进程、异常外连 |
| 3 | 敏感目录变更 | 24h 内 `$OC/`, `/etc/`, `~/.ssh/` 等变更 |
| 4 | 系统定时任务 | crontab, systemd timers |
| 5 | OpenClaw Cron | 与预期清单比对 |
| 6 | SSH 安全 | 近期登录记录 + 失败尝试 |
| 7 | 关键文件完整性 | 哈希基线比对 + 权限检查 |
| 8 | 黄线操作交叉验证 | `sudo` 记录与 memory 日志比对 |
| 9 | 磁盘使用 | 整体使用率 + 24h 内新增大文件 |
| 10 | 网关环境变量 | 检查 KEY/TOKEN/SECRET/PASSWORD 变量 |
| 11 | 明文私钥/凭证泄露扫描 | 扫描私钥、助记词、高危明文密码 |
| 12 | Skill/MCP 完整性 | 哈希清单比对 |
| 13 | Brain 灾备自动同步 | Git commit + push 到私有仓库 |

### 灾备备份内容

| 备份 | 路径 | 说明 |
|------|------|------|
| ✅ | `openclaw.json` | 核心配置（含 API keys） |
| ✅ | `workspace/` | Brain（SOUL/MEMORY/AGENTS 等） |
| ✅ | `agents/` | Agent 配置和会话历史 |
| ✅ | `cron/` | 定时任务配置 |
| ✅ | `credentials/` | 认证信息 |
| ✅ | `identity/` | 设备身份 |
| ✅ | `devices/paired.json` | 配对信息 |
| ❌ | `media/`, `logs/`, `completions/` | 大文件或可重建文件 |

---

## 📋 实施清单

- [ ] 将红线/黄线协议写入 `AGENTS.md`
- [ ] 执行 `chmod 600` 保护核心配置文件
- [ ] 生成配置文件的 SHA256 基线
- [ ] 编写并注册 `nightly-security-audit` Cron（覆盖 13 项指标）
- [ ] 手动触发一次验证脚本执行 + 推送到达 + 报告生成
- [ ] 用 `chattr +i` 锁定审计脚本本身
- [ ] 创建 GitHub 私有仓库，完成 Git 自动备份部署
- [ ] 执行一轮端到端验证

---

## 已知局限（零信任原则：诚实面对）

1. **Agent 认知层的脆弱性**：LLM 易被精心构造的复杂文档绕过，人工常识和二次确认是对抗高级供应链投毒的终极防线
2. **同 UID 读取**：恶意代码与 OpenClaw 同用户运行，`chmod 600` 无法阻止同用户读取。完整方案需分离用户 + 进程隔离
3. **哈希基线非实时**：最长 ~24h 发现延迟。高级方案可引入 `inotify`/`auditd`/HIDS 实时监控
4. **审计推送依赖外部 API**：Telegram/Discord 偶尔故障会导致推送失败

---

## 总结

> **"在 Agent 安全领域，没有绝对的安全。"**

这份指南提供的是一个**基础纵深防御框架**，而非完整的安全解决方案。最终责任和最后手段的判断权仍在人类操作者手中。

**核心理念**：
- 零摩擦日常操作
- 高风险必须确认
- 明确夜间审计（即使健康也要报告）
- 默认零信任

---

*原文 MIT 协议开源，感谢 SlowMist Security Team 和 Edmund.X 的贡献。*
