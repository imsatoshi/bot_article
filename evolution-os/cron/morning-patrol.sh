#!/bin/bash
#
# Morning Patrol Script
# Run at 06:30 every day
# Checks code health, doc freshness, generates daily report
#

set -e

EVO_DIR="$HOME/evolution-os"
HEALTH_DIR="$EVO_DIR/health"
LOG_FILE="$EVO_DIR/logs/patrol.log"
DATE=$(date +%Y-%m-%d)
REPORT_FILE="$HEALTH_DIR/morning-report-${DATE}.md"

echo "=== Morning Patrol: $(date) ===" >> "$LOG_FILE"

# Initialize report
cat > "$REPORT_FILE" << EOF
# 早间巡查报告 - ${DATE}

## 执行时间
$(date)

## 代码健康检查

EOF

# Check for TODO/FIXME markers in workspace
echo "### TODO/FIXME 标记" >> "$REPORT_FILE"
WORKSPACE_DIR="$HOME/.openclaw/workspace"
if [ -d "$WORKSPACE_DIR" ]; then
    TODO_COUNT=$(grep -r "TODO\|FIXME" "$WORKSPACE_DIR" --include="*.md" --include="*.sh" --include="*.py" 2>/dev/null | wc -l || echo "0")
    echo "- 发现 $TODO_COUNT 个待办标记" >> "$REPORT_FILE"
    
    if [ "$TODO_COUNT" -gt 0 ]; then
        echo "" >> "$REPORT_FILE"
        echo "**待办列表**:" >> "$REPORT_FILE"
        grep -r "TODO\|FIXME" "$WORKSPACE_DIR" --include="*.md" --include="*.sh" --include="*.py" 2>/dev/null | head -10 >> "$REPORT_FILE"
    fi
else
    echo "- 工作目录不存在" >> "$REPORT_FILE"
fi

# Check for empty/hollow code
echo "" >> "$REPORT_FILE"
echo "### 空壳代码检测" >> "$REPORT_FILE"

# Check for empty functions in scripts
EMPTY_FUNCS=$(grep -r "function.*{.*}" "$WORKSPACE_DIR" --include="*.sh" 2>/dev/null | grep -v "#" | wc -l || echo "0")
echo "- 潜在空函数: $EMPTY_FUNCS" >> "$REPORT_FILE"

# Check shell script syntax
SYNTAX_ERRORS=0
if [ -d "$WORKSPACE_DIR/scripts" ]; then
    for script in "$WORKSPACE_DIR/scripts"/*.sh; do
        if [ -f "$script" ]; then
            if ! bash -n "$script" 2>/dev/null; then
                ((SYNTAX_ERRORS++))
            fi
        fi
    done
fi
echo "- 语法错误: $SYNTAX_ERRORS" >> "$REPORT_FILE"

# Check documentation freshness
echo "" >> "$REPORT_FILE"
echo "### 文档新鲜度" >> "$REPORT_FILE"

# Check key docs
docs=("AGENTS.md" "MEMORY.md" "SYSTEM.md")
for doc in "${docs[@]}"; do
    if [ -f "$EVO_DIR/$doc" ]; then
        DAYS_OLD=$(( ($(date +%s) - $(stat -c %Y "$EVO_DIR/$doc" 2>/dev/null || stat -f %m "$EVO_DIR/$doc")) / 86400 ))
        if [ $DAYS_OLD -gt 7 ]; then
            echo "- ⚠️ $doc: ${DAYS_OLD}天未更新" >> "$REPORT_FILE"
        else
            echo "- ✅ $doc: ${DAYS_OLD}天前更新" >> "$REPORT_FILE"
        fi
    fi
done

# Check GitHub Pages articles
ARTICLES_DIR="$HOME/bot_article_public/articles"
if [ -d "$ARTICLES_DIR" ]; then
    OLD_ARTICLES=$(find "$ARTICLES_DIR" -name "*.md" -mtime +30 2>/dev/null | wc -l || echo "0")
    echo "- ${OLD_ARTICLES} 篇文章超过30天未更新" >> "$REPORT_FILE"
fi

# Check cron job status
echo "" >> "$REPORT_FILE"
echo "### 定时任务状态" >> "$REPORT_FILE"

CRON_COUNT=$(crontab -l 2>/dev/null | grep -c "evolution-os" || echo "0")
echo "- Evolution OS 任务数: $CRON_COUNT" >> "$REPORT_FILE"

# Check yesterday's log
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)
if [ -f "$EVO_DIR/logs/meditation-${YESTERDAY}.log" ]; then
    echo "- 昨日冥想: ✅ 完成" >> "$REPORT_FILE"
else
    echo "- 昨日冥想: ❌ 未执行" >> "$REPORT_FILE"
fi

# Generate today's action items
cat >> "$REPORT_FILE" << EOF

## 今日建议

### 优先处理
1. 检查上述 TODO/FIXME 标记
2. 更新超过7天未动的文档

### 可选优化
- [ ] 审查并清理空壳代码
- [ ] 优化脚本性能

## 健康度评分

EOF

# Calculate simple health score
HEALTH_SCORE=100
if [ "$TODO_COUNT" -gt 10 ]; then
    HEALTH_SCORE=$((HEALTH_SCORE - 10))
fi
if [ "$SYNTAX_ERRORS" -gt 0 ]; then
    HEALTH_SCORE=$((HEALTH_SCORE - 20))
fi
if [ -f "$EVO_DIR/evolution-log.md" ]; then
    LAST_MEDITATION_DAYS=$(( ($(date +%s) - $(stat -c %Y "$EVO_DIR/evolution-log.md" 2>/dev/null || stat -f %m "$EVO_DIR/evolution-log.md")) / 86400 ))
    if [ $LAST_MEDITATION_DAYS -gt 2 ]; then
        HEALTH_SCORE=$((HEALTH_SCORE - 15))
    fi
fi

echo "**今日健康度**: ${HEALTH_SCORE}/100" >> "$REPORT_FILE"

if [ $HEALTH_SCORE -ge 90 ]; then
    echo "状态: 🟢 优秀" >> "$REPORT_FILE"
elif [ $HEALTH_SCORE -ge 70 ]; then
    echo "状态: 🟡 良好" >> "$REPORT_FILE"
else
    echo "状态: 🔴 需要关注" >> "$REPORT_FILE"
fi

# Update health metrics JSON
cat > "$HEALTH_DIR/latest-metrics.json" << EOF
{
  "date": "$DATE",
  "health_score": $HEALTH_SCORE,
  "todo_count": $TODO_COUNT,
  "syntax_errors": $SYNTAX_ERRORS,
  "timestamp": "$(date -Iseconds)"
}
EOF

echo "Morning patrol complete. Report: $REPORT_FILE" >> "$LOG_FILE"

# If health score is low, create an issue
if [ $HEALTH_SCORE -lt 70 ]; then
    ISSUE_FILE="$EVO_DIR/issues/pending/low-health-${DATE}.md"
    cat > "$ISSUE_FILE" << EOF
# 健康度偏低 - ${DATE}

**健康度**: ${HEALTH_SCORE}/100

**问题**:
- TODO数量: $TODO_COUNT
- 语法错误: $SYNTAX_ERRORS

**建议行动**:
1. 清理待办事项
2. 修复语法错误
3. 恢复冥想习惯

**截止**: $(date -d "+3 days" +%Y-%m-%d 2>/dev/null || date -v+3d +%Y-%m-%d)
EOF
    echo "⚠️ Created issue: $ISSUE_FILE" >> "$LOG_FILE"
fi
