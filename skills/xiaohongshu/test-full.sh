#!/bin/bash
# 小红书 MCP 完整测试（含初始化）

MCP_URL="http://localhost:18060/mcp"

echo "🧪 测试小红书 MCP 服务器..."
echo ""

# 1. 初始化 MCP 会话
echo "1️⃣ 初始化 MCP 会话..."
INIT_RESPONSE=$(curl -s -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {
        "name": "test-client",
        "version": "1.0.0"
      }
    },
    "id": 0
  }')

echo "初始化响应:"
echo "$INIT_RESPONSE" | jq . 2>/dev/null || echo "$INIT_RESPONSE"
echo ""

# 2. 获取工具列表
echo "2️⃣ 获取可用工具列表..."
curl -s -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/list",
    "id": 1
  }' | jq . 2>/dev/null || echo "获取工具列表失败"
echo ""

# 3. 检查登录状态
echo "3️⃣ 检查登录状态..."
curl -s -X POST "${MCP_URL}" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "check-login-status",
      "arguments": {}
    },
    "id": 2
  }' | jq . 2>/dev/null || echo "检查登录失败"
echo ""

echo "✅ 测试完成"
