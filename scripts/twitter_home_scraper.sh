#!/bin/bash
# Twitter Home Timeline Scraper - 每小时刷推脚本
# 获取 "For You" 推荐时间线并格式化输出

set -e

# Twitter/X API Credentials
export AUTH_TOKEN="e080f640c8c8102307733ac2871f3c8d39706e35"
export CT0="430cf3e1f7cf8425c773dfeec7d2df9d22ccf9c8cef10574ff4e3d72bb970624da3f33338b14173001b162e639c9d8603096d21709fa03716a9557987fc954fd6a4a719a71faccdfbea12defc32801ba"

# 配置
BIRD_CMD="/usr/bin/bird"
LOG_FILE="/tmp/twitter_home_scraper.log"
OUTPUT_FILE="/tmp/twitter_home_output.txt"

# 检查 bird 是否可用
if [ ! -f "$BIRD_CMD" ]; then
    echo "错误: bird 命令未找到"
    exit 1
fi

# 获取当前时间
CURRENT_TIME=$(date '+%m/%d %H:%M')

# 获取时间线 (最近30条)
if ! $BIRD_CMD home --json > /tmp/home_raw.json 2>/dev/null; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 错误: 无法获取时间线" >> "$LOG_FILE"
    exit 1
fi

# 检查是否获取到数据
if [ ! -s /tmp/home_raw.json ] || [ "$(jq 'length' /tmp/home_raw.json)" -eq 0 ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] 警告: 未获取到推文" >> "$LOG_FILE"
    exit 1
fi

# 格式化输出
cat > "$OUTPUT_FILE" << EOF
📊 **刷推汇总** ($CURRENT_TIME)

---

**🤖 AI / 编程**

EOF

# 提取 AI/编程相关推文 (使用 jq -f 避免引号问题)
jq -r '.[] | select(.text | test("AI|Claude|GPT|LLM|代码|编程|coding|agent|模型|训练|OpenAI|Anthropic|OpenClaw|Cursor|Copilot|vibe.?coding|spec"; "i")) | select(.text | length > 20) | @text "• **@\(.author.username)**: \(.text[:150])\(if (.text | length) > 150 then "..." else "" end)"' /tmp/home_raw.json 2>/dev/null | head -8 >> "$OUTPUT_FILE" || true

# 如果没有内容，显示提示
if ! grep -q "@" "$OUTPUT_FILE" | head -20; then
    echo "• 暂无相关内容" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << 'EOF'

**💰 加密/DeFi**

EOF

# 提取加密相关推文
jq -r '.[] | select(.text | test("BTC|ETH|crypto|比特币|以太坊|DeFi|trading|交易|token|区块链|blockchain|binance|OKX|空投|airdrop|NVDA|英伟达|财报|收益|量化"; "i")) | select(.text | length > 20) | @text "• **@\(.author.username)**: \(.text[:150])\(if (.text | length) > 150 then "..." else "" end)"' /tmp/home_raw.json 2>/dev/null | head -6 >> "$OUTPUT_FILE" || true

if ! grep -q "加密" "$OUTPUT_FILE" >/dev/null 2>&1; then
    echo "• 暂无相关内容" >> "$OUTPUT_FILE"
fi

cat >> "$OUTPUT_FILE" << 'EOF'

**🛠️ 工具/产品**

EOF

# 提取工具/产品相关推文
jq -r '.[] | select(.text | test("工具|产品|launch|发布|更新|新品|feature|github|开源|repo|app|plugin|skill|MCP|框架"; "i")) | select(.text | length > 20) | @text "• **@\(.author.username)**: \(.text[:150])\(if (.text | length) > 150 then "..." else "" end)"' /tmp/home_raw.json 2>/dev/null | head -5 >> "$OUTPUT_FILE" || true

cat >> "$OUTPUT_FILE" << 'EOF'

**📚 其他精选**

EOF

# 提取其他高互动推文
jq -r '.[] | select(.likeCount // 0 >= 5) | select(.text | test("AI|Claude|GPT|LLM|BTC|ETH|crypto|工具|产品|github|开源"; "i") | not) | @text "• **@\(.author.username)**: \(.text[:120])\(if (.text | length) > 120 then "..." else "" end) 👍\(.likeCount)"' /tmp/home_raw.json 2>/dev/null | head -4 >> "$OUTPUT_FILE" || true

echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "有感兴趣的话题想深挖吗？" >> "$OUTPUT_FILE"

# 输出结果
cat "$OUTPUT_FILE"

# 记录日志
TWEET_COUNT=$(jq 'length' /tmp/home_raw.json)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] 刷推完成，共处理 $TWEET_COUNT 条推文" >> "$LOG_FILE"

# 清理临时文件
rm -f /tmp/home_raw.json
