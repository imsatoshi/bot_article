---
name: github-pages-publisher
description: Automatically publish articles to GitHub Pages with Jekyll support. Handles git add/commit/push, README updates, and category indexing.
---

# GitHub Pages Publisher Skill

自动将整理的文章推送到 GitHub Pages，支持 Jekyll 主题、分类索引和 README 自动更新。

## 功能

- ✅ 自动 `git add + commit + push`
- ✅ Jekyll 兼容的 front matter
- ✅ 分类目录管理（ai/crypto/tech/twitter 等）
- ✅ README 自动更新索引
- ✅ 英文 permalink 支持（避免中文 URL 问题）

## 使用方法

### 1. 初始化（首次使用）

```bash
# 在 workspace 根目录运行
python3 {baseDir}/scripts/init_github_pages.py \
  --repo https://github.com/username/repo.git \
  --categories "ai,crypto,tech,twitter"
```

### 2. 发布文章

```python
# 在你的 Agent 代码中使用
import subprocess
import json

# 定义文章
article = {
    "title": "文章标题",
    "category": "ai",
    "tags": ["AI", "Agent"],
    "content": "# Markdown 内容",
    "permalink": "ai/article-slug/"  # 可选，自动生成
}

# 调用发布脚本
subprocess.run([
    "python3", "{baseDir}/scripts/publish_article.py",
    "--title", article["title"],
    "--category", article["category"],
    "--tags", json.dumps(article["tags"]),
    "--content", article["content"]
])
```

### 3. 更新索引

```bash
python3 {baseDir}/scripts/update_index.py
```

## 配置

编辑 `{baseDir}/config/settings.yaml`:

```yaml
github:
  repo_url: "https://github.com/username/repo.git"
  branch: "master"
  
articles:
  base_path: "articles"
  categories:
    - ai
    - crypto
    - tech
    - twitter
  
jekyll:
  theme: "minima"
  layout: "post"
  
permalink:
  auto_generate: true  # 自动生成英文 permalink
  fallback: "pinyin"   # 拼音或 "hash"
```

## 文章格式

生成的文章自动包含 Jekyll front matter:

```markdown
---
layout: post
title: "文章标题"
date: 2026-02-18
categories: ai
tags: [AI, Agent]
permalink: /ai/article-slug/
---

# 文章内容...
```

## 目录结构

```
workspace/
├── articles/
│   ├── ai/
│   ├── crypto/
│   ├── tech/
│   └── twitter/
├── _config.yml          # Jekyll 配置
├── index.md             # 首页
├── README.md            # GitHub 首页
└── .git/               # Git 仓库
```

## 依赖

- Python 3.8+
- Git
- 已配置 GitHub SSH 密钥或 token

## 示例

### 完整工作流

```python
#!/usr/bin/env python3
"""示例：自动整理推特并发布到 GitHub Pages"""

import subprocess
import json
from datetime import datetime

# 1. 获取内容（示例：整理推特）
tweets = [
    {"author": "@xxx", "content": "推文内容", "url": "https://x.com/..."}
]

# 2. 生成文章
content = f"""# Twitter 精选 - {datetime.now().strftime('%Y-%m-%d')}

"""
for t in tweets:
    content += f"- **{t['author']}**: {t['content']}\n"

# 3. 发布
subprocess.run([
    "python3", "skills/github-pages-publisher/scripts/publish_article.py",
    "--title", f"Twitter 精选 - {datetime.now().strftime('%Y-%m-%d')}",
    "--category", "twitter",
    "--tags", json.dumps(["Twitter", "AI"]),
    "--content", content
], check=True)

print("✅ 已发布到 GitHub Pages!")
```

## 注意事项

1. **首次使用**需要先配置 GitHub 仓库权限（SSH 或 token）
2. **中文标题**会自动转换为拼音 permalink（避免 URL 编码问题）
3. **README** 会自动更新，但保留手动编辑的灵活性
4. **冲突处理**：如果远程有更新，脚本会先 pull 再 push

## License

MIT
