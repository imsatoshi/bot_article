#!/bin/bash
#
# Evening Patrol Script
# Run at 22:00 every day
# Checks pending issues, summarizes daily execution
#

set -e

EVO_DIR="$HOME/evolution-os"
HEALTH_DIR="$EVO_DIR/health"
ISSUES_DIR="$EVO_DIR/issues/pending"
LOG_FILE="$EVO_DIR/logs/patrol.log"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="$HEALTH_DIR/evening-report-${DATE}.md"

echo "=== Evening Patrol: $(date) ===" >> "$LOG_FILE"

# Initialize report
cat > "$REPORT_FILE" << EOF
# 晚间巡查报告 - ${DATE}

## 执行时间
$(date)

## 待办事项检查

EOF

# Check pending issues
echo "### 未解决问题" >> "$REPORT_FILE"
PENDING_COUNT=$(find "$ISSUES_DIR" -name "*.md" -type f 2>/dev/null | wc -l || echo "0")
echo "- 待处理问题: $PENDING_COUNT" >> "$REPORT_FILE"

if [ "$PENDING_COUNT" -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "**问题列表**:" >> "$REPORT_FILE"
    find "$ISSUES_DIR" -name "*.md" -type f -exec basename {} \; 2>/dev/null | head -10 >> "$REPORT_FILE"
fi

# Check if morning report was generated
MORNING_REPORT="$HEALTH_DIR/morning-report-${DATE}.md"
if [ -f "$MORNING_REPORT" ]; then
    echo "" >> "$REPORT_FILE"
    echo "### 早间报告回顾" >> "$REPORT_FILE"
    
    # Extract health score from morning report
    MORNING_HEALTH=$(grep "今日健康度" "$MORNING_REPORT" | grep -o "[0-9]*" | head -1 || echo "N/A")
    echo "- 早间健康度: ${MORNING_HEALTH}/100" >> "$REPORT_FILE"
    
    # Check if issues were addressed
    MORNING_TODO=$(grep "TODO/FIXME" "$MORNING_REPORT" -A1 | grep "发现" | grep -o "[0-9]*" || echo "0")
    echo "- 早间发现的TODO: ${MORNING_TODO}" >> "$REPORT_FILE"
fi

# Analyze today's diary
echo "" >> "$REPORT_FILE"
echo "## 今日工作统计" >> "$REPORT_FILE"

TODAY_DIARY="$EVO_DIR/memory/${DATE}.md"
if [ -f "$TODAY_DIARY" ]; then
    TASKS_COMPLETED=$(grep -c "^- \[x\]" "$TODAY_DIARY" 2>/dev/null || echo "0")
    TASKS_PENDING=$(grep -c "^- \[ \]" "$TODAY_DIARY" 2>/dev/null || echo "0")
    
    echo "- 完成任务: ${TASKS_COMPLETED}" >> "$REPORT_FILE"
    echo "- 待办任务: ${TASKS_PENDING}" >> "$REPORT_FILE"
    
    # Count user interactions
    INTERACTIONS=$(grep -c "用户:" "$TODAY_DIARY" 2>/dev/null || echo "0")
    echo "- 用户交互: ${INTERACTIONS}" >> "$REPORT_FILE"
    
    # Check for learning entries
    LEARNINGS=$(grep -c "学习\|掌握\|了解" "$TODAY_DIARY" 2>/dev/null || echo "0")
    echo "- 新知识点: ${LEARNINGS}" >> "$REPORT_FILE"
else
    echo "- 今日日记未创建" >> "$REPORT_FILE"
fi

# Check freqtrade status (if accessible)
echo "" >> "$REPORT_FILE"
echo "## 系统状态" >> "$REPORT_FILE"

# Check if meditation ran
MEDITATION_LOG="$EVO_DIR/logs/meditation.log"
if [ -f "$MEDITATION_LOG" ]; then
    TODAY_MEDITATION=$(grep -c "$(date +%Y-%m-%d)" "$MEDITATION_LOG" 2>/dev/null || echo "0")
    if [ "$TODAY_MEDITATION" -gt 0 ]; then
        echo "- 冥想: ✅ 完成" >> "$REPORT_FILE"
    else
        echo "- 冥想: ❌ 未完成" >> "$REPORT_FILE"
    fi
else
    echo "- 冥想: ❌ 未配置" >> "$REPORT_FILE"
fi

# Check cron jobs
CRON_ACTIVE=$(crontab -l 2>/dev/null | grep -c "evolution-os" || echo "0")
echo "- 定时任务: ${CRON_ACTIVE} 个活跃" >> "$REPORT_FILE"

# GitHub Pages check
if [ -d "$HOME/bot_article_public/.git" ]; then
    cd "$HOME/bot_article_public"
    LAST_PUSH=$(git log -1 --format=%ct 2>/dev/null || echo "0")
    HOURS_SINCE=$(( ($(date +%s) - LAST_PUSH) / 3600 ))
    
    if [ $HOURS_SINCE -lt 24 ]; then
        echo "- GitHub Pages: ✅ ${HOURS_SINCE}小时前有更新" >> "$REPORT_FILE"
    else
        echo "- GitHub Pages: ⚠️ ${HOURS_SINCE}小时未更新" >> "$REPORT_FILE"
    fi
fi

# Generate tomorrow's focus
cat >> "$REPORT_FILE" << EOF

## 明日重点

EOF

# Extract pending tasks from today
if [ -f "$TODAY_DIARY" ]; then
    PENDING_TASKS=$(grep "^- \[ \]" "$TODAY_DIARY" 2>/dev/null | head -5)
    if [ -n "$PENDING_TASKS" ]; then
        echo "**继续处理**:" >> "$REPORT_FILE"
        echo "$PENDING_TASKS" >> "$REPORT_FILE"
    else
        echo "- 今日任务全部完成 🎉" >> "$REPORT_FILE"
    fi
fi

# Add recommendations based on issues
if [ "$PENDING_COUNT" -gt 3 ]; then
    echo "" >> "$REPORT_FILE"
    echo "**建议**: 优先清理积压的 ${PENDING_COUNT} 个问题" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" << EOF

## 总结

EOF

# Calculate completion rate
if [ -f "$TODAY_DIARY" ] && [ "$TASKS_COMPLETED" -gt 0 ] || [ "$TASKS_PENDING" -gt 0 ]; then
    TOTAL_TASKS=$((TASKS_COMPLETED + TASKS_PENDING))
    if [ $TOTAL_TASKS -gt 0 ]; then
        COMPLETION_RATE=$((TASKS_COMPLETED * 100 / TOTAL_TASKS))
        echo "**任务完成率**: ${COMPLETION_RATE}%" >> "$REPORT_FILE"
        
        if [ $COMPLETION_RATE -ge 80 ]; then
            echo "状态: 🟢 高效" >> "$REPORT_FILE"
        elif [ $COMPLETION_RATE -ge 50 ]; then
            echo "状态: 🟡 良好" >> "$REPORT_FILE"
        else
            echo "状态: 🔴 需改进" >> "$REPORT_FILE"
        fi
    fi
fi

# Update daily metrics JSON
cat >> "$HEALTH_DIR/daily-metrics.jsonl" << EOF
{"date":"$DATE","tasks_completed":${TASKS_COMPLETED:-0},"tasks_pending":${TASKS_PENDING:-0},"interactions":${INTERACTIONS:-0},"pending_issues":${PENDING_COUNT},"timestamp":"$(date -Iseconds)"}
EOF

echo "Evening patrol complete. Report: $REPORT_FILE" >> "$LOG_FILE"

# Auto-resolve old issues (older than 7 days)
find "$ISSUES_DIR" -name "*.md" -mtime +7 -type f 2>/dev/null | while read -r old_issue; do
    mv "$old_issue" "$EVO_DIR/issues/archived/"
    echo "Archived old issue: $(basename "$old_issue")" >> "$LOG_FILE"
done
