#!/bin/bash
#
# Memory Search Tool
# 语义搜索历史记忆
#

EVO_DIR="$HOME/evolution-os"

cd "$EVO_DIR"

if [ $# -eq 0 ]; then
    echo "Usage: memory-search <query>"
    echo "Example: memory-search 'freqtrade 策略'"
    exit 1
fi

QUERY="$*"

# 检查索引是否存在，如果不存在则先索引
if [ ! -f "memory/vector/vectors.npy" ]; then
    echo "[Search] Building index first..."
    python3 cron/vector_index.py index
fi

echo "[Search] Searching for: $QUERY"
echo ""

python3 cron/vector_index.py search "$QUERY"
