#!/bin/bash
# freqtrade 交易监控脚本 - 静默版

HOST="175.24.206.10"
PORT="3340"
USER="zhangjiawei"
PASS="cbb123"
STATE_FILE="/root/.openclaw/workspace/.freqtrade_last_check"

# SSH 执行命令函数
run_remote() {
    sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p "$PORT" "$USER@$HOST" "$1" 2>/dev/null
}

# 获取最新交易ID
LATEST_TRADE=$(run_remote "cd ~/freqtrade && echo 'SELECT MAX(id) FROM trades;' | sqlite3 tradesv3.sqlite")

if [ -z "$LATEST_TRADE" ]; then
    echo "⚠️ ALERT: 无法获取交易数据，请检查 freqtrade 状态"
    exit 1
fi

# 读取上次检查的状态
LAST_TRADE_ID=0
if [ -f "$STATE_FILE" ]; then
    LAST_TRADE_ID=$(head -1 "$STATE_FILE")
fi

# 获取当前持仓情况
OPEN_POSITIONS=$(run_remote "cd ~/freqtrade && echo 'SELECT COUNT(*) FROM trades WHERE is_open=1;' | sqlite3 tradesv3.sqlite")

# 检查是否有异常
HAS_ALERT=0

# 1. 检查进程是否存在
PROCESS=$(run_remote "pgrep -f 'freqtrade trade' | head -1")
if [ -z "$PROCESS" ]; then
    echo "❌ ALERT: freqtrade 进程不存在！"
    HAS_ALERT=1
fi

# 2. 如果有新交易或持仓变化，输出详情
if [ "$LATEST_TRADE" -gt "$LAST_TRADE_ID" ] || [ ! -f "$STATE_FILE" ]; then
    echo "🤖 Freqtrade 交易更新"
    echo ""
    
    if [ "$LATEST_TRADE" -gt "$LAST_TRADE_ID" ]; then
        NEW_TRADES_COUNT=$((LATEST_TRADE - LAST_TRADE_ID))
        echo "📈 新增 $NEW_TRADES_COUNT 笔交易"
        echo ""
        
        run_remote "cd ~/freqtrade && echo '.mode column
.headers on
SELECT pair, datetime(open_date) as time, open_rate, close_rate, round(close_profit_abs, 2) as profit, exit_reason FROM trades WHERE id > $LAST_TRADE_ID ORDER BY id DESC;' | sqlite3 tradesv3.sqlite"
        echo ""
    fi
    
    if [ "$OPEN_POSITIONS" -gt "0" ]; then
        echo "💼 当前持仓 ($OPEN_POSITIONS):"
        run_remote "cd ~/freqtrade && echo '.mode column
.headers on
SELECT pair, datetime(open_date) as open_time, open_rate, amount, round((open_rate * amount), 2) as value FROM trades WHERE is_open=1 ORDER BY open_date DESC;' | sqlite3 tradesv3.sqlite"
    else
        echo "💤 当前无持仓"
    fi
    
    TODAY=$(date +%Y-%m-%d)
    TODAY_PROFIT=$(run_remote "cd ~/freqtrade && echo \"SELECT round(COALESCE(SUM(close_profit_abs), 0), 2) FROM trades WHERE date(close_date) = '$TODAY';\" | sqlite3 tradesv3.sqlite")
    
    echo ""
    echo "📊 今日盈亏: $TODAY_PROFIT USDT"
    
    # 保存状态
    echo "$LATEST_TRADE" > "$STATE_FILE"
    echo "$OPEN_POSITIONS" >> "$STATE_FILE"
    
    HAS_ALERT=1
else
    # 检查持仓状态是否变化
    if [ -f "$STATE_FILE" ]; then
        LAST_OPEN_COUNT=$(tail -1 "$STATE_FILE")
        if [ "$OPEN_POSITIONS" != "$LAST_OPEN_COUNT" ]; then
            echo "🤖 Freqtrade 持仓变化"
            echo ""
            if [ "$OPEN_POSITIONS" -gt "0" ]; then
                echo "💼 当前持仓 ($OPEN_POSITIONS):"
                run_remote "cd ~/freqtrade && echo '.mode column
.headers on
SELECT pair, datetime(open_date) as open_time, open_rate, amount, round((open_rate * amount), 2) as value FROM trades WHERE is_open=1 ORDER BY open_date DESC;' | sqlite3 tradesv3.sqlite"
            else
                echo "💤 当前无持仓"
                echo ""
                echo "📊 最近平仓:"
                run_remote "cd ~/freqtrade && echo '.mode column
.headers on
SELECT pair, datetime(close_date) as close_time, round(close_profit_abs, 2) as profit FROM trades WHERE is_open=0 ORDER BY close_date DESC LIMIT 3;' | sqlite3 tradesv3.sqlite"
            fi
            echo "$LATEST_TRADE" > "$STATE_FILE"
            echo "$OPEN_POSITIONS" >> "$STATE_FILE"
            HAS_ALERT=1
        fi
    fi
fi

# 如果一切正常（无交易变化、无持仓变化、进程正常），则无输出
if [ "$HAS_ALERT" -eq 0 ]; then
    # 完全静默，无输出
    exit 0
fi

exit 0
