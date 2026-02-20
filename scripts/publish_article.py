#!/usr/bin/env python3
"""
发布文章到 GitHub Pages
自动同步到公开目录并推送
"""

import argparse
import json
import os
import re
import subprocess
from datetime import datetime
from pathlib import Path

# 配置
WORKSPACE = Path("/root/.openclaw/workspace")
PUBLIC_DIR = Path.home() / "bot_article_public"  # 公开目录
ARTICLES_DIR = WORKSPACE / "articles"

def slugify(text):
    """将中文转换为拼音或 slug"""
    text = re.sub(r'[^\w\s-]', '', text.lower())
    text = re.sub(r'[-\s]+', '-', text).strip('-')
    if not text:
        text = "article"
    return text[:50]

def generate_front_matter(title, category, tags, permalink=None):
    """生成 Jekyll front matter"""
    date_str = datetime.now().strftime('%Y-%m-%d')
    
    if not permalink:
        slug = slugify(title)
        permalink = f"/{category}/{slug}/"
    
    front_matter = f"""---
layout: post
title: "{title}"
date: {date_str}
categories: {category}
tags: {json.dumps(tags, ensure_ascii=False)}
permalink: {permalink}
---

"""
    return front_matter

def save_article(title, category, content, permalink=None):
    """保存文章到本地 workspace"""
    date_str = datetime.now().strftime('%Y-%m-%d')
    slug = slugify(title)
    
    # 确保目录存在
    category_dir = ARTICLES_DIR / category
    category_dir.mkdir(parents=True, exist_ok=True)
    
    # 文件名
    filename = f"{slug}.md"
    filepath = category_dir / filename
    
    # 如果文件已存在，添加数字后缀
    counter = 1
    while filepath.exists():
        filename = f"{slug}-{counter}.md"
        filepath = category_dir / filename
        counter += 1
    
    # 写入文件
    filepath.write_text(content, encoding='utf-8')
    
    return filepath, permalink

def sync_to_public(filepath, category):
    """同步文章到公开目录"""
    # 目标路径
    public_category_dir = PUBLIC_DIR / "articles" / category
    public_category_dir.mkdir(parents=True, exist_ok=True)
    
    # 复制文件
    public_filepath = public_category_dir / filepath.name
    public_filepath.write_text(filepath.read_text(encoding='utf-8'), encoding='utf-8')
    
    print(f"📤 已同步到公开目录: {public_filepath}")
    return public_filepath

def update_public_index(title, category, permalink):
    """更新公开目录的 index.md"""
    public_index = PUBLIC_DIR / "index.md"
    
    if not public_index.exists():
        print("⚠️ 公开目录 index.md 不存在")
        return
    
    content = public_index.read_text(encoding='utf-8')
    
    # 如果 permalink 为 None，生成默认的
    if not permalink:
        slug = slugify(title)
        permalink = f"/{category}/{slug}/"
    
    # 查找对应分类的列表
    category_pattern = rf"(### .*{category}.*\n)(.*?)(\n### |\n---|$)"
    match = re.search(category_pattern, content, re.DOTALL | re.IGNORECASE)
    
    if match:
        # 在分类下添加新链接
        new_link = f'- [{title}]({permalink}) 🆕\n'
        
        # 检查是否已存在
        if permalink in match.group(2):
            print("📝 索引中已存在该链接")
            return
        
        # 插入新链接
        updated_section = match.group(1) + match.group(2).rstrip() + '\n' + new_link + '\n'
        content = content[:match.start()] + updated_section + content[match.end():]
        
        public_index.write_text(content, encoding='utf-8')
        print(f"✅ 已更新公开目录 index.md")

def git_push_public():
    """推送到 GitHub"""
    try:
        # 检查是否有变更
        result = subprocess.run(
            ["git", "-C", str(PUBLIC_DIR), "status", "--porcelain"],
            capture_output=True, text=True
        )
        
        if not result.stdout.strip():
            print("📝 公开目录没有变更需要提交")
            return True
        
        # git add
        subprocess.run(
            ["git", "-C", str(PUBLIC_DIR), "add", "."],
            check=True
        )
        
        # git commit
        date_str = datetime.now().strftime('%Y-%m-%d %H:%M')
        subprocess.run(
            ["git", "-C", str(PUBLIC_DIR), "commit", "-m", f"📝 添加文章 - {date_str}"],
            check=True
        )
        
        # git push
        subprocess.run(
            ["git", "-C", str(PUBLIC_DIR), "push", "origin", "master"],
            check=True
        )
        
        print(f"✅ GitHub 推送成功!")
        return True
        
    except subprocess.CalledProcessError as e:
        print(f"❌ Git 操作失败: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description='发布文章到 GitHub Pages')
    parser.add_argument('--title', required=True, help='文章标题')
    parser.add_argument('--category', required=True, help='分类目录')
    parser.add_argument('--tags', default='[]', help='标签 JSON 数组')
    parser.add_argument('--content', required=True, help='文章内容 (Markdown)')
    parser.add_argument('--permalink', help='自定义 permalink (可选)')
    parser.add_argument('--no-push', action='store_true', help='不同步到 GitHub')
    
    args = parser.parse_args()
    
    # 解析 tags
    try:
        tags = json.loads(args.tags)
    except json.JSONDecodeError:
        tags = args.tags.strip('[]').split(',')
        tags = [t.strip().strip('"\'') for t in tags if t.strip()]
    
    print(f"📝 正在发布: {args.title}")
    print(f"   分类: {args.category}")
    print(f"   标签: {tags}")
    
    # 生成 front matter
    front_matter = generate_front_matter(
        args.title, args.category, tags, args.permalink
    )
    
    # 完整内容
    full_content = front_matter + args.content
    
    # 1. 保存到本地 workspace
    filepath, permalink = save_article(
        args.title, args.category, full_content, args.permalink
    )
    print(f"✅ 文章已保存到 workspace: {filepath}")
    
    # 2. 同步到公开目录
    public_filepath = sync_to_public(filepath, args.category)
    
    # 3. 更新公开目录索引
    update_public_index(args.title, args.category, permalink)
    
    # 4. 推送到 GitHub（除非指定 --no-push）
    if not args.no_push:
        git_push_public()
    else:
        print("⏸️ 已跳过 GitHub 推送（使用 --no-push）")
    
    print(f"\n🎉 发布完成!")
    print(f"   本地: {filepath}")
    print(f"   公开: {public_filepath}")
    print(f"   链接: https://imsatoshi.github.io/bot_article{permalink}")

if __name__ == '__main__':
    main()
