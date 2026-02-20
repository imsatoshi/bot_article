#!/bin/bash
# Issue 通知扫描器
# 每 5 分钟运行一次，扫描新的 Issue 并发送通知

WORKSPACE="/root/.openclaw/workspace"
ISSUES_DIR="$WORKSPACE/issues"
NOTIFIED_FILE="$WORKSPACE/.issues_notified"
LOG_FILE="$WORKSPACE/.issue_scanner.log"

# 创建已通知记录文件（如果不存在）
touch "$NOTIFIED_FILE"

# 扫描所有 open 状态的 Issue
find "$ISSUES_DIR" -maxdepth 1 -name "*.md" ! -name "TEMPLATE.md" | while read -r issue_file; do
    issue_id=$(basename "$issue_file" .md)
    
    # 检查是否已经通知过
    if grep -q "^$issue_id$" "$NOTIFIED_FILE"; then
        continue
    fi
    
    # 解析 Issue 内容
    status=$(grep "^status:" "$issue_file" | cut -d: -f2 | tr -d ' ')
    severity=$(grep "^severity:" "$issue_file" | cut -d: -f2 | tr -d ' ')
    auto_execute=$(grep "^auto_execute:" "$issue_file" | cut -d: -f2 | tr -d ' ')
    
    # 只处理 open 状态的
    if [ "$status" != "open" ]; then
        echo "$issue_id" >> "$NOTIFIED_FILE"
        continue
    fi
    
    # 读取标题（第一个 # 开头的行）
    title=$(grep "^# " "$issue_file" | head -1 | sed 's/^# //')
    
    # 确定风险图标
    case "$severity" in
        "critical") icon="🔴"; risk="高风险";;
        "warning") icon="🟡"; risk="中风险";;
        *) icon="🟢"; risk="低风险";;
    esac
    
    # 确定自动执行提示
    if [ "$auto_execute" = "true" ]; then
        auto_msg="⏰ 10分钟后自动执行"
    else
        auto_msg="⏸️ 等待人工批准"
    fi
    
    # 构建通知消息
    message="${icon} **新 Issue 创建: #$issue_id**

**${title}**

- 风险等级: ${risk}
- ${auto_msg}

文件: ${issue_file}

回复指令:
• \"批准 #${issue_id}\" - 立即执行
• \"取消 #${issue_id}\" - 阻止自动执行  
• \"查看 #${issue_id}\" - 显示详情"

    # 发送 Telegram 通知（通过 OpenClaw）
    # 这里使用 echo 记录，实际由 OpenClaw 调用
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] NOTIFY: $issue_id - $title" >> "$LOG_FILE"
    
    # 记录已通知
    echo "$issue_id" >> "$NOTIFIED_FILE"
    
    # 输出到 stdout（会被 OpenClaw 捕获发送）
    echo "$message"
done

# 检查是否有即将自动执行的 Issue（通知后 8-12 分钟）
# 这部分可以扩展为实际执行逻辑