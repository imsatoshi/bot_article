#!/bin/bash
# mini-server 健康监控脚本

HOST="175.24.206.10"
PORT="3340"
USER="zhangjiawei"
PASS="cbb123"
STATE_FILE="/root/.openclaw/workspace/.server_last_state"

# SSH 执行命令
run_remote() {
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$PORT" "$USER@$HOST" "$1" 2>/dev/null
}

# 检查系统状态
echo "=== 系统状态检查 ==="

# 1. 负载检查
LOAD=$(run_remote "uptime | awk '{print \$(NF-2)}' | tr -d ','")
LOAD_INT=$(echo "$LOAD" | cut -d. -f1)

if [ "$LOAD_INT" -gt 5 ]; then
    echo "⚠️ 高负载警告: $LOAD (正常<5)"
fi

# 2. 内存检查
MEM_INFO=$(run_remote "vm_stat | head -5")
FREE_PAGES=$(echo "$MEM_INFO" | grep "free:" | awk '{print $3}' | tr -d '.')
if [ -n "$FREE_PAGES" ] && [ "$FREE_PAGES" -lt 10000 ]; then
    echo "⚠️ 内存不足: 空闲页面 $FREE_PAGES"
fi

# 3. 磁盘检查
DISK_USAGE=$(run_remote "df -h / | tail -1 | awk '{print \$5}' | tr -d '%'")
if [ -n "$DISK_USAGE" ] && [ "$DISK_USAGE" -gt 85 ]; then
    echo "⚠️ 磁盘空间不足: ${DISK_USAGE}%"
fi

# 4. 关键进程检查
echo ""
echo "=== 关键服务状态 ==="

# 检查 freqtrade
FREQTRADE_PID=$(run_remote "pgrep -f 'freqtrade trade' | head -1")
if [ -z "$FREQTRADE_PID" ]; then
    echo "❌ freqtrade 未运行"
else
    echo "✅ freqtrade 运行中 (PID: $FREQTRADE_PID)"
fi

# 检查 ClashX
CLASH_PID=$(run_remote "pgrep -f 'ClashX Pro'")
if [ -z "$CLASH_PID" ]; then
    echo "⚠️ ClashX Pro 未运行"
else
    echo "✅ ClashX Pro 运行中"
fi

# OpenClaw 已在该服务器上永久删除

# 5. 网络连接检查
echo ""
echo "=== 网络端口状态 ==="
PORTS=$(run_remote "netstat -an | grep LISTEN | wc -l")
echo "监听端口数: $PORTS"

# 6. 系统运行时间
UPTIME=$(run_remote "uptime | awk '{print \$3, \$4}' | tr -d ','")
echo ""
echo "=== 系统信息 ==="
echo "运行时间: $UPTIME"
echo "当前负载: $LOAD"
echo "磁盘使用: ${DISK_USAGE}%"

echo ""
echo "📊 数据时间: $(date '+%Y-%m-%d %H:%M')"
