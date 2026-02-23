#!/bin/bash
#
# Daily Meditation Script
# Run at 02:30 every day
# Reviews today's work, analyzes patterns, generates insights
#

set -e

EVO_DIR="$HOME/evolution-os"
MEMORY_DIR="$EVO_DIR/memory"
LOG_FILE="$EVO_DIR/logs/meditation.log"
DATE=$(date +%Y-%m-%d)
YESTERDAY=$(date -d "yesterday" +%Y-%m-%d 2>/dev/null || date -v-1d +%Y-%m-%d)

echo "=== Meditation Session: $(date) ===" >> "$LOG_FILE"

# Check if today's diary exists
TODAY_DIARY="$MEMORY_DIR/${DATE}.md"
if [ ! -f "$TODAY_DIARY" ]; then
    echo "No diary found for today. Skipping meditation." >> "$LOG_FILE"
    exit 0
fi

# Count today's activities
TASK_COUNT=$(grep -c "^- \[x\]" "$TODAY_DIARY" 2>/dev/null || echo "0")
INTERACTION_COUNT=$(grep -c "用户:" "$TODAY_DIARY" 2>/dev/null || echo "0")
ERROR_COUNT=$(grep -c "❌\|错误\|失败" "$TODAY_DIARY" 2>/dev/null || echo "0")

echo "Stats: $TASK_COUNT tasks, $INTERACTION_COUNT interactions, $ERROR_COUNT errors" >> "$LOG_FILE"

# Generate meditation entry
cat >> "$EVO_DIR/evolution-log.md" << EOF

## ${DATE} 冥想记录

### 今日统计
- **完成任务**: ${TASK_COUNT}
- **用户交互**: ${INTERACTION_COUNT}
- **错误/失败**: ${ERROR_COUNT}
- **执行时间**: $(date +%H:%M)

### 工作回顾
EOF

# Extract key decisions and learnings
if grep -q "决策\|决定\|选择" "$TODAY_DIARY"; then
    echo "**关键决策**:" >> "$EVO_DIR/evolution-log.md"
    grep "决策\|决定\|选择" "$TODAY_DIARY" | head -3 >> "$EVO_DIR/evolution-log.md"
    echo "" >> "$EVO_DIR/evolution-log.md"
fi

# Analyze errors
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "**错误分析**:" >> "$EVO_DIR/evolution-log.md"
    grep "❌\|错误\|失败" "$TODAY_DIARY" | head -3 >> "$EVO_DIR/evolution-log.md"
    echo "" >> "$EVO_DIR/evolution-log.md"
fi

# Pattern recognition (simple keyword matching)
echo "**技能使用**:" >> "$EVO_DIR/evolution-log.md"
grep -o "编辑\|发布\|分析\|监控\|部署" "$TODAY_DIARY" | sort | uniq -c | sort -rn | head -5 >> "$EVO_DIR/evolution-log.md"

cat >> "$EVO_DIR/evolution-log.md" << EOF

### 进化洞察
（待AI深度分析）

### 明日行动
- [ ] 继续优化工作流

---
EOF

echo "Meditation complete. Entry added to evolution-log.md" >> "$LOG_FILE"

# Rebuild vector index after adding new content
echo "[Meditation] Rebuilding vector index..." >> "$LOG_FILE"
cd "$EVO_DIR" && python3 cron/vector_index.py index >> "$LOG_FILE" 2>&1

# Create tomorrow's diary template
cat > "$MEMORY_DIR/$(date -d "tomorrow" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d).md" << EOF
# $(date -d "tomorrow" +%Y-%m-%d 2>/dev/null || date -v+1d +%Y-%m-%d) 工作日记

## 待办任务
- [ ] 

## 工作记录

## 用户交互

## 学习记录

## 反思总结

EOF

echo "Tomorrow's diary template created." >> "$LOG_FILE"
