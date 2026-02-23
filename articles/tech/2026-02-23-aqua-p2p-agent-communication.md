---
layout: post
title: "Aqua 深度解析：AI Agent 的 P2P 安全通信协议与实现"
date: 2026-02-23
categories: tech
tags: [Aqua, P2P, AI Agent, libp2p, 安全通信, 开源项目]
permalink: /tech/aqua-p2p-agent-communication-protocol/
---

> 项目地址: https://github.com/quailyquaily/aqua  
> Aqua = **AQUA Queries & Unifies Agents**

---

## 项目概述

**Aqua** 是一个专为 **AI Agent** 设计的点对点（P2P）消息通信工具与协议。它使 AI Agent 能够：
- 建立可信的端到端加密通信
- 无需中心服务器直接交换消息
- 通过中继节点跨越网络边界连接
- 持久化存储消息（收件箱/发件箱）

该项目源自 [mistermorph](https://mistermorph.com)，现已成为独立的开源项目。

---

## 核心特性

| 特性 | 说明 |
|------|------|
| **P2P 通信** | 基于 libp2p 的直接点对点连接，无单点故障 |
| **身份验证** | Ed25519 加密密钥对，UUIDv7 节点标识 |
| **端到端加密** | 所有消息传输均加密 |
| **持久存储** | 本地 inbox/outbox，支持离线消息 |
| **中继支持** | Circuit Relay v2，穿透 NAT/防火墙 |
| **简单 CLI** | 直观的命令行界面，支持 JSON 输出 |

---

## 技术架构

### 1. 整体架构

```
┌─────────────────────────────────────────────────────────────┐
│                        Aqua Node                             │
├─────────────────────────────────────────────────────────────┤
│  CLI Layer (cobra)                                          │
│    ├── init, id                                             │
│    ├── contacts (add/list/verify)                           │
│    ├── serve (node runtime)                                 │
│    ├── send, inbox, outbox                                  │
│    └── relay serve                                          │
├─────────────────────────────────────────────────────────────┤
│  Service Layer                                               │
│    ├── Identity Management                                  │
│    ├── Contact Card (签名验证)                               │
│    ├── Message Routing                                      │
│    └── Trust State (TOFU/Verified/Conflicted/Revoked)       │
├─────────────────────────────────────────────────────────────┤
│  Node Layer (libp2p)                                         │
│    ├── host.Host (P2P 网络主机)                              │
│    ├── Protocol Handlers                                     │
│    │   ├── /aqua/hello/1.0.0                                │
│    │   └── /aqua/rpc/1.0.0                                  │
│    ├── Circuit Relay Client                                  │
│    └── Session Management                                    │
├─────────────────────────────────────────────────────────────┤
│  Storage Layer (fsstore)                                     │
│    ├── identity.json                                        │
│    ├── contacts.json                                        │
│    ├── inbox_messages.jsonl                                 │
│    ├── outbox_messages.jsonl                                │
│    └── dedupe_records.json                                  │
└─────────────────────────────────────────────────────────────┘
```

### 2. 核心组件

#### 2.1 Identity（身份系统）

```go
// 核心数据结构
type Identity struct {
    NodeUUID            string    // UUIDv7
    PeerID              string    // libp2p Peer ID
    NodeID              string    // aqua:前缀的节点ID
    Nickname            string    // 可选昵称
    IdentityPubEd25519  string    // Base64URL编码的公钥
    IdentityPrivEd25519 string    // Base64URL编码的私钥
    CreatedAt           time.Time
    UpdatedAt           time.Time
}
```

**生成流程：**
1. 生成 UUIDv7（时间排序 UUID）
2. 生成 Ed25519 密钥对
3. 从公钥派生 libp2p Peer ID
4. 生成 NodeID（`aqua:` + PeerID）

#### 2.2 Contact Card（联系人名片）

```go
type ContactCardPayload struct {
    Version              int        // 版本号 (当前 v1)
    NodeUUID             string     // 节点 UUID
    PeerID               string     // Peer ID
    NodeID               string     // 节点 ID
    Nickname             string     // 昵称
    IdentityPubEd25519   string     // 身份公钥
    Addresses            []string   // 多地址列表
    MinSupportedProtocol int        // 最小协议版本
    MaxSupportedProtocol int        // 最大协议版本
    IssuedAt             time.Time  // 签发时间
    ExpiresAt            *time.Time // 过期时间（可选）
    KeyRotationOf        string     // 密钥轮换记录（可选）
}

type ContactCard struct {
    Payload   ContactCardPayload // 名片内容
    SigAlg    string             // 签名算法 (ed25519)
    SigFormat string             // 签名格式 (jcs-rfc8785-detached)
    Sig       string             // Base64URL 签名
}
```

**安全特性：**
- 使用 JCS (JSON Canonicalization Scheme) 确保签名一致性
- Ed25519 签名验证身份真实性
- 支持过期时间和密钥轮换

#### 2.3 Trust State（信任状态）

```go
type TrustState string

const (
    TrustStateTOFU       TrustState = "tofu"       // 首次使用信任
    TrustStateVerified   TrustState = "verified"   // 已验证
    TrustStateConflicted TrustState = "conflicted" // 冲突（密钥变更）
    TrustStateRevoked    TrustState = "revoked"    // 已撤销
)
```

**信任建立流程：**
1. **TOFU** (Trust On First Use)：首次添加联系人时默认状态
2. **Verify**：通过带外方式确认指纹后标记为已验证
3. **Conflicted**：检测到公钥与之前记录不符
4. **Revoked**：手动撤销信任

#### 2.4 Message（消息系统）

**收件箱消息：**
```go
type InboxMessage struct {
    MessageID      string     // 消息唯一ID
    FromPeerID     string     // 发送方 Peer ID
    Topic          string     // 主题 (默认 chat.message)
    ContentType    string     // 内容类型 (text/plain, application/json)
    PayloadBase64  string     // Base64 编码的消息内容
    IdempotencyKey string     // 幂等键（防重复）
    SessionID      string     // 会话ID (UUIDv7)
    ReplyTo        string     // 回复目标消息ID
    Read           bool       // 是否已读
    ReadAt         *time.Time // 阅读时间
    ReceivedAt     time.Time  // 接收时间
}
```

**发件箱消息：**
```go
type OutboxMessage struct {
    MessageID      string    // 消息唯一ID
    ToPeerID       string    // 接收方 Peer ID
    Topic          string    // 主题
    ContentType    string    // 内容类型
    PayloadBase64  string    // Base64 编码内容
    IdempotencyKey string    // 幂等键
    SessionID      string    // 会话ID
    ReplyTo        string    // 回复目标
    SentAt         time.Time // 发送时间
}
```

### 3. 网络协议

#### 3.1 协议标识

```go
const (
    ProtocolHelloIDV1    = "/aqua/hello/1.0.0"      // 握手协议
    ProtocolRPCIDV1      = "/aqua/rpc/1.0.0"        // RPC 协议
    CapabilityDataPushV1 = "rpc.data.push.v1"       // 数据推送能力
)
```

#### 3.2 Hello 握手

```go
type helloMessage struct {
    Type         string   `json:"type"`          // "hello"
    ProtocolMin  int      `json:"protocol_min"`  // 最小协议版本
    ProtocolMax  int      `json:"protocol_max"`  // 最大协议版本
    Capabilities []string `json:"capabilities"`  // 支持的能力列表
}
```

**握手流程：**
1. 建立 libp2p 连接
2. 发送 hello 消息交换协议版本和能力
3. 协商共同支持的协议版本
4. 后续通信使用协商后的协议

#### 3.3 JSON-RPC 通信

基于 libp2p 流的 JSON-RPC 2.0 协议：

```json
// 请求
{
  "jsonrpc": "2.0",
  "method": "agent.data.push",
  "params": {
    "topic": "chat.message",
    "content_type": "text/plain",
    "payload_base64": "SGVsbG8gV29ybGQh",
    "idempotency_key": "uuid",
    "session_id": "uuid",
    "reply_to": "message_id"
  },
  "id": 1
}

// 响应
{
  "jsonrpc": "2.0",
  "result": {
    "accepted": true,
    "deduped": false
  },
  "id": 1
}
```

### 4. Circuit Relay V2

Aqua 支持 libp2p Circuit Relay v2，实现跨网络通信：

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│  Edge Node A │ ◄─────► │  Relay Node R │ ◄─────► │  Edge Node B │
│  (内网)       │  中继   │  (公网)        │  中继   │  (内网)       │
└─────────────┘         └──────────────┘         └─────────────┘
```

**中继地址格式：**
```
/dns4/aqua-relay.mistermorph.com/tcp/6372/p2p/12D3KooW.../p2p-circuit/p2p/<TARGET_PEER_ID>
```

**中继模式：**
- `auto` (默认)：先尝试直连，失败后使用中继
- `off`：仅直连
- `required`：仅通过中继连接

**官方中继节点：**
- TCP: `/dns4/aqua-relay.mistermorph.com/tcp/6372/p2p/12D3KooWSYjt4v1exWDMeN7SA4m6tDxGVNmi3cCP3zzcW2c5pN4E`
- QUIC: `/dns4/aqua-relay.mistermorph.com/udp/6372/quic-v1/p2p/12D3KooWSYjt4v1exWDMeN7SA4m6tDxGVNmi3cCP3zzcW2c5pN4E`

---

## 数据存储

### 存储布局

```
~/.aqua/
├── identity.json           # 本地身份（包含私钥）
├── contacts.json           # 联系人列表
├── inbox_messages.jsonl    # 收件箱（JSON Lines 格式）
├── inbox_read_state.json   # 阅读状态
├── outbox_messages.jsonl   # 发件箱
├── dedupe_records.json     # 去重记录
├── protocol_history.json   # 协议协商历史
└── .fslocks/               # 文件锁目录
```

### 存储特性

- **原子写入**：使用临时文件 + 重命名确保数据完整性
- **文件锁**：防止并发写入冲突
- **JSON Lines**：消息追加写入，支持高效读取
- **去重机制**：基于 (FromPeerID, Topic, IdempotencyKey) 的去重缓存

---

## CLI 命令详解

### 身份管理

```bash
# 初始化身份
aqua init

# 设置/查看身份
aqua id [nickname] [--json]
```

### 联系人管理

```bash
# 列出联系人
aqua contacts list [--json]

# 添加联系人
aqua contacts add "<ADDRESS>" [--display-name <name>] [--verify]

# 验证联系人
aqua contacts verify <PEER_ID>

# 删除联系人
aqua contacts del <PEER_ID>

# 导出联系人名片
aqua card export [--advertise auto|direct|relay|both] [--out <file>]

# 导入联系人名片
aqua contacts import <card.json> [--display-name <name>]
```

### 节点运行

```bash
# 启动节点（前台运行）
aqua serve [--listen <multiaddr>] [--relay <multiaddr>] [--relay-mode auto|off|required]

# 仅显示地址（不启动）
aqua serve --dryrun

# 启动中继服务
aqua relay serve [--listen <multiaddr>] [--allow-peer <peer_id>]
```

### 消息通信

```bash
# 发送消息
aqua send <PEER_ID> "message content" \
  [--topic <topic>] \
  [--content-type <type>] \
  [--session-id <uuid>] \
  [--reply-to <message_id>]

# 查看收件箱
aqua inbox list [--unread] [--limit <n>] [--from-peer-id <id>] [--json]

# 标记已读
aqua inbox mark-read <message_id>...
aqua inbox mark-read --all [--from-peer-id <id>]

# 查看发件箱
aqua outbox list [--limit <n>] [--to-peer-id <id>] [--json]
```

### 连接测试

```bash
# 握手测试
aqua hello <PEER_ID> [--address <multiaddr>] [--relay-mode auto|off|required]

# Ping 测试
aqua ping <PEER_ID> [--address <multiaddr>]

# 查询能力
aqua capabilities <PEER_ID> [--address <multiaddr>]
```

---

## 快速开始示例

### 场景1：同一网络内的两个 Agent 通信

**Machine A (Alice):**
```bash
# 初始化并设置昵称
aqua init
aqua id alice

# 启动节点（记录输出的 address）
aqua serve
# 输出示例: address: /ip4/192.168.1.100/tcp/6372/p2p/12D3KooW...

# 添加 Bob 为联系人
aqua contacts add "/ip4/192.168.1.101/tcp/6372/p2p/12D3KooWB..." --verify

# 发送消息
aqua send 12D3KooWB... "Hello from Alice!"
```

**Machine B (Bob):**
```bash
aqua init
aqua id bob
aqua serve

aqua contacts add "/ip4/192.168.1.100/tcp/6372/p2p/12D3KooW..." --verify

# 查看收件箱
aqua inbox list --unread
```

### 场景2：跨网络通过中继通信

**使用官方中继节点：**

```bash
# 启动带中继支持的节点
aqua serve \
  --relay-mode auto \
  --relay /dns4/aqua-relay.mistermorph.com/tcp/6372/p2p/12D3KooWSYjt4v1exWDMeN7SA4m6tDxGVNmi3cCP3zzcW2c5pN4E \
  --relay /dns4/aqua-relay.mistermorph.com/udp/6372/quic-v1/p2p/12D3KooWSYjt4v1exWDMeN7SA4m6tDxGVNmi3cCP3zzcW2c5pN4E

# 从输出复制 relay-circuit 地址分享给 peers
# 示例: /dns4/aqua-relay.mistermorph.com/tcp/6372/p2p/12D3KooW.../p2p-circuit/p2p/YOUR_PEER_ID
```

---

## 技术依赖

```go
// go.mod 核心依赖
require (
    github.com/libp2p/go-libp2p v0.44.0        // P2P 网络
    github.com/multiformats/go-multiaddr v0.16.0  // 多地址格式
    github.com/google/uuid v1.6.0              // UUID 生成
    github.com/spf13/cobra v1.8.1              // CLI 框架
    github.com/cyberphone/json-canonicalization v0.0.0-20241213102144-19d51d7fe467  // JCS
    golang.org/x/sys v0.40.0                   // 系统调用
)
```

---

## 与 OpenClaw 集成

Aqua 提供了专门的 SKILL.md 用于与 OpenClaw 集成：

```yaml
---
name: aqua-communication
description: "Use aqua CLI to establish trusted peer communication 
  and exchange messages reliably between other agents."
---
```

**核心使用模式：**
1. 使用 `aqua id` 获取 Peer ID
2. 使用 `aqua serve` 启动节点监听
3. 使用 `aqua contacts add` 添加其他 Agent
4. 使用 `aqua send` 发送消息
5. 使用 `aqua inbox list --unread` 接收消息
6. 所有命令支持 `--json` 输出便于 Agent 解析

---

## 安全考虑

### 1. 密钥管理
- 私钥存储在 `~/.aqua/identity.json`，文件权限应设置为 600
- 支持密钥轮换（通过 `KeyRotationOf` 字段追踪）
- 首次使用时生成，丢失后无法恢复

### 2. 信任建立
- 默认使用 TOFU (Trust On First Use) 模式
- 建议通过带外方式验证联系人指纹
- 使用 `aqua contacts verify` 标记已验证联系人

### 3. 中继安全
- 中继节点只能看到加密流量，无法解密内容
- 支持中继白名单模式 (`--allow-peer`)
- 端到端加密确保即使中继被攻破也无法读取消息

### 4. 去重与重放保护
- 基于 IdempotencyKey 的消息去重
- 7 天去重缓存 TTL
- 最大 10000 条去重记录

---

## 应用场景

1. **AI Agent 协作**：多个 Agent 分布式协作，无需中心协调器
2. **边缘设备通信**：IoT 设备之间的直接安全通信
3. **隐私优先的消息**：无需信任第三方服务器的点对点聊天
4. **自动化工作流**：CI/CD Agent、监控 Agent 之间的通知与协调
5. **跨网络服务发现**：通过中继连接不同内网中的服务

---

## 总结

Aqua 是一个设计精良的 AI Agent 通信基础设施，具有以下优势：

- **去中心化**：基于 libp2p 的 P2P 架构，无单点故障
- **安全可靠**：Ed25519 身份验证 + 端到端加密 + 信任状态管理
- **易于集成**：简单的 CLI 接口，支持 JSON 输出，便于 Agent 调用
- **网络穿透**：内置 Circuit Relay v2 支持，解决 NAT 穿透问题
- **持久可靠**：本地消息存储，支持离线通信

对于构建分布式 AI Agent 系统的开发者来说，Aqua 提供了一个轻量级但功能完整的通信解决方案。

---

**参考链接：**
- GitHub: https://github.com/quailyquaily/aqua
- 官方中继: aqua-relay.mistermorph.com
