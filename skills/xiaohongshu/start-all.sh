#!/bin/bash
# 启动小红书完整服务

cd /root/.openclaw/workspace/skills/xiaohongshu

echo "🚀 启动小红书服务..."

# 1. 启动 MCP 服务器
echo "📡 启动 xiaohongshu-mcp 服务器..."
nohup ./xiaohongshu-mcp -headless > mcp.log 2>&1 &
echo $! > mcp.pid
sleep 5

# 2. 检查 MCP 是否启动
if curl -s http://localhost:18060/health > /dev/null 2>&1; then
    echo "✅ MCP 服务器启动成功"
else
    echo "⚠️ MCP 服务器可能未完全启动，查看日志: tail -f mcp.log"
fi

# 3. 启动适配器
echo "🔗 启动 OpenClaw 适配器..."
nohup node adapter-server.js > adapter.log 2>&1 &
echo $! > adapter.pid
sleep 3

# 4. 检查适配器
if curl -s http://localhost:3000/api/health > /dev/null 2>&1; then
    echo "✅ 适配器启动成功"
    echo ""
    echo "🎉 服务已启动！"
    echo "   MCP: http://localhost:18060"
    echo "   适配器: http://localhost:3000"
    echo ""
    echo "📱 现在需要:"
    echo "   1. 访问 http://localhost:18060 查看二维码"
    echo "   2. 用小红书 APP 扫码登录"
    echo "   3. 然后就可以使用 /check-login /publish 命令了"
else
    echo "⚠️ 适配器启动失败，查看日志: tail -f adapter.log"
fi
