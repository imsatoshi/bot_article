#!/usr/bin/env python3
"""
将 Markdown 文章转换为小红书格式
用法: python3 convert_to_xiaohongshu.py <文章文件>
"""

import sys
import re
from pathlib import Path

def convert_to_xiaohongshu(filepath):
    """转换文章为小红书格式"""
    content = Path(filepath).read_text(encoding='utf-8')
    
    # 提取标题
    title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else "无标题"
    
    # 提取正文（去掉 front matter 和标题）
    # 去掉 front matter
    content = re.sub(r'^---[\s\S]*?---\n', '', content)
    # 去掉一级标题
    content = re.sub(r'^# .+\n', '', content)
    
    # 转换为小红书格式
    lines = content.strip().split('\n')
    xhs_lines = []
    
    for line in lines:
        # 跳过空行
        if not line.strip():
            continue
        
        # 处理二级标题
        if line.startswith('##'):
            line = line.replace('##', '').strip()
            xhs_lines.append(f"📌 {line}")
            xhs_lines.append("")
        # 处理列表
        elif line.startswith('- ') or line.startswith('* '):
            line = line[2:].strip()
            xhs_lines.append(f"• {line}")
        # 处理引用
        elif line.startswith('>'):
            line = line[1:].strip()
            xhs_lines.append(f"💬 {line}")
        # 普通段落
        else:
            # 加粗转换为小红书表情
            line = re.sub(r'\*\*(.+?)\*\*', r'👉 \1', line)
            xhs_lines.append(line)
    
    # 生成小红书文案
    xhs_content = '\n'.join(xhs_lines)
    
    # 生成封面标题
    xhs_title = f"🔥{title[:20]} | AI干货分享"
    
    # 生成标签
    tags = "#AI #Agent #技术干货 #人工智能 #学习笔记"
    
    # 生成完整文案
    final_content = f"""{xhs_title}

{xhs_content}

💡 觉得有用的话点赞收藏～
有问题评论区见！

{tags}
"""
    
    return xhs_title, final_content

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("用法: python3 convert_to_xiaohongshu.py <文章文件.md>")
        sys.exit(1)
    
    filepath = sys.argv[1]
    title, content = convert_to_xiaohongshu(filepath)
    
    # 保存到文件
    output_file = filepath.replace('.md', '-xiaohongshu.txt')
    Path(output_file).write_text(content, encoding='utf-8')
    
    print(f"✅ 转换完成!")
    print(f"📄 标题: {title}")
    print(f"📝 内容已保存到: {output_file}")
    print(f"📋 内容预览:\n")
    print("=" * 50)
    print(content)
    print("=" * 50)
    print(f"\n💡 使用说明:")
    print(f"   1. 打开小红书 APP")
    print(f"   2. 复制上面内容到发布页面")
    print(f"   3. 配图可以用 AI 生成相关图片")
    print(f"   4. 发布!")
