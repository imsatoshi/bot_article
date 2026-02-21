#!/bin/bash
# freqtrade 监控脚本

HOST="175.24.206.10"
PORT="3340"
USER="zhangjiawei"
PASS="cbb123"

# 检查进程
PROCESS=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$PORT" "$USER@$HOST" 'ps aux | grep freqtrade | grep -v grep' 2>/dev/null)

if [ -z "$PROCESS" ]; then
    echo "❌ ALERT: freqtrade 进程不存在！"
    exit 1
fi

# 检查最近日志是否有错误
ERRORS=$(sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$PORT" "$USER@$HOST" 'tail -n 5 ~/freqtrade/logs/freqtrade.error.log | grep -E "ERROR|CRITICAL"' 2>/dev/null)

if [ -n "$ERRORS" ]; then
    echo "❌ ALERT: freqtrade 发现错误日志："
    echo "$ERRORS"
    exit 1
fi

# 正常
exit 0
