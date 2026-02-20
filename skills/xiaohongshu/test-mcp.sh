#!/bin/bash
# 小红书发布测试脚本

MCP_URL="http://localhost:18060"

echo "🧪 测试小红书 MCP 服务器..."
echo ""

# 1. 测试健康检查
echo "1️⃣ 测试健康检查..."
curl -s "${MCP_URL}/health" | jq . 2>/dev/null || echo "❌ 健康检查失败"
echo ""

# 2. 测试获取二维码（用于登录）
echo "2️⃣ 测试获取登录二维码..."
curl -s -X POST "${MCP_URL}/mcp" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "get-login-qrcode"
    },
    "id": 1
  }' | jq . 2>/dev/null || echo "❌ 获取二维码失败"
echo ""

# 3. 检查登录状态
echo "3️⃣ 检查登录状态..."
curl -s -X POST "${MCP_URL}/mcp" \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "method": "tools/call",
    "params": {
      "name": "check-login-status"
    },
    "id": 2
  }' | jq . 2>/dev/null || echo "❌ 检查登录失败"
echo ""

echo "✅ 测试完成"
echo ""
echo "📋 下一步:"
echo "   如果第2步成功，保存二维码图片并用小红书APP扫描"
echo "   如果第3步显示已登录，就可以使用发布功能了"
