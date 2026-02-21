#!/bin/bash
# Claude Relay Service API Key 费用快速查询

HOST="23.165.104.242"
PORT="22"
USERNAME="root"
PASSWORD="NKuTMHRrHnw74Mp4"

echo "💰 Claude Relay Service - 费用统计"
echo "===================================="
echo ""

# 定价模型 (USD per 1M tokens)
INPUT_PRICE=3.0
OUTPUT_PRICE=15.0
CACHE_PRICE=0.3

# 获取所有 API Keys
keys=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p $PORT $USERNAME@$HOST "redis-cli smembers apikey:idx:all 2>/dev/null")

total_cost=0

for key in $keys; do
    name=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p $PORT $USERNAME@$HOST "redis-cli hget apikey:$key name 2>/dev/null")
    
    # 获取使用量
    input=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p $PORT $USERNAME@$HOST "redis-cli hget usage:$key totalInputTokens 2>/dev/null || echo 0")
    output=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p $PORT $USERNAME@$HOST "redis-cli hget usage:$key totalOutputTokens 2>/dev/null || echo 0")
    cache=$(sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p $PORT $USERNAME@$HOST "redis-cli hget usage:$key totalCacheReadTokens 2>/dev/null || echo 0")
    
    # 计算费用
    in_cost=$(echo "scale=2; $input * $INPUT_PRICE / 1000000" | bc)
    out_cost=$(echo "scale=2; $output * $OUTPUT_PRICE / 1000000" | bc)
    cache_cost=$(echo "scale=2; $cache * $CACHE_PRICE / 1000000" | bc)
    key_total=$(echo "scale=2; $in_cost + $out_cost + $cache_cost" | bc)
    
    total_cost=$(echo "scale=2; $total_cost + $key_total" | bc)
    
    echo "📌 $name"
    echo "   费用: $$key_total USD"
    echo ""
done

echo "===================================="
echo "💵 总费用: $$total_cost USD"
echo "===================================="
