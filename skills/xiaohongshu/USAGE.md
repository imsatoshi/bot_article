# 小红书 Skill 使用指南

## ✅ 安装状态

| 组件 | 状态 |
|------|------|
| xiaohongshu-mcp | ✅ 运行中 (PID: $(cat mcp.pid 2>/dev/null || echo '未启动')) |
| 适配器 | ⚠️ 有兼容性问题 |

## 🚀 快速开始

### 方法1: 直接使用 MCP 服务器 (推荐)

MCP 服务器已在运行，你可以直接通过 HTTP 调用：

```bash
# 检查服务器状态
curl http://localhost:18060/health

# 获取登录二维码（需要保持会话）
# 注意: 需要使用支持 SSE 的客户端
```

### 方法2: 使用 Cursor/Claude Code

这个 Skill **原生支持** Cursor 和 Claude Code：

1. 安装 Cursor: https://cursor.sh/
2. 配置 MCP: 在 Cursor 中添加 `http://localhost:18060/mcp`
3. 使用命令: `/check-login`, `/publish` 等

### 方法3: 手动发布

如果你想在 OpenClaw 中使用，建议：

1. 我帮你把文章转成**小红书格式**
2. 你手动复制粘贴发布

## 🔧 故障排除

**MCP 服务器未启动**:
```bash
cd /root/.openclaw/workspace/skills/xiaohongshu
./start-all.sh
```

**查看日志**:
```bash
tail -f mcp.log      # MCP 服务器日志
tail -f adapter.log  # 适配器日志
```

## ⚠️ 重要提示

- OpenClaw 不支持 SSE 长连接，无法直接使用 MCP 工具
- 建议使用 Cursor 或 Claude Code 获得完整体验
- 小红书有风控，自动化发布可能触发限制

## 📚 相关文档

- [OpenClaw 使用指南](OPENCRAW_GUIDE.md)
- [MCP 协议说明](https://modelcontextprotocol.io/)
- [原项目文档](https://github.com/xpzouying/xiaohongshu-mcp)
