#!/bin/bash
# 快速发布文章到 GitHub Pages
# 用法: ./quick_publish.sh "标题" "分类" "内容文件"

TITLE="$1"
CATEGORY="${2:-twitter}"
CONTENT_FILE="$3"

if [ -z "$TITLE" ]; then
    echo "用法: ./quick_publish.sh \"文章标题\" [分类] [内容文件]"
    echo "示例: ./quick_publish.sh \"今日Twitter精选\" twitter ./content.md"
    exit 1
fi

# 如果没有提供内容文件，使用默认模板
if [ -z "$CONTENT_FILE" ] || [ ! -f "$CONTENT_FILE" ]; then
    CONTENT="# $TITLE\n\n文章内容..."
else
    CONTENT=$(cat "$CONTENT_FILE")
fi

# 执行发布
python3 /root/.openclaw/workspace/scripts/publish_article.py \
    --title "$TITLE" \
    --category "$CATEGORY" \
    --content "$CONTENT" \
    --tags '["Twitter", "AI"]'
