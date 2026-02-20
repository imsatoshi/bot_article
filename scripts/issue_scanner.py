#!/usr/bin/env python3
"""
Issue Scanner - 扫描并通知新的 Issue
每 5 分钟运行一次
"""

import os
import re
import json
from datetime import datetime
from pathlib import Path

WORKSPACE = Path("/root/.openclaw/workspace")
ISSUES_DIR = WORKSPACE / "issues"
NOTIFIED_FILE = WORKSPACE / ".issues_notified.json"
LOG_FILE = WORKSPACE / ".issue_scanner.log"

def load_notified():
    """加载已通知的 Issue 列表"""
    if NOTIFIED_FILE.exists():
        with open(NOTIFIED_FILE) as f:
            return json.load(f)
    return {}

def save_notified(notified):
    """保存已通知的 Issue 列表"""
    with open(NOTIFIED_FILE, 'w') as f:
        json.dump(notified, f, indent=2)

def parse_issue(filepath):
    """解析 Issue 文件"""
    with open(filepath) as f:
        content = f.read()
    
    # 解析 front matter
    front_matter = {}
    if content.startswith('---'):
        _, fm, body = content.split('---', 2)
        for line in fm.strip().split('\n'):
            if ':' in line:
                key, value = line.split(':', 1)
                front_matter[key.strip()] = value.strip()
    
    # 提取标题
    title_match = re.search(r'^# (.+)$', content, re.MULTILINE)
    title = title_match.group(1) if title_match else "无标题"
    
    return {
        'id': front_matter.get('id', 'unknown'),
        'status': front_matter.get('status', 'open'),
        'severity': front_matter.get('severity', 'info'),
        'auto_execute': front_matter.get('auto_execute', 'false') == 'true',
        'title': title,
        'filepath': str(filepath)
    }

def get_severity_info(severity):
    """获取风险等级信息"""
    mapping = {
        'critical': ('🔴', '高风险', '❌ 必须人工批准'),
        'warning': ('🟡', '中风险', '⏰ 10分钟后自动执行'),
        'info': ('🟢', '低风险', '✅ 已自动执行')
    }
    return mapping.get(severity, ('⚪', '未知', ''))

def scan_issues():
    """扫描所有 Issue"""
    notified = load_notified()
    new_issues = []
    
    for issue_file in ISSUES_DIR.glob('*.md'):
        if issue_file.name == 'TEMPLATE.md':
            continue
        
        issue_id = issue_file.stem
        
        # 检查是否已经通知过
        if issue_id in notified:
            continue
        
        # 解析 Issue
        issue = parse_issue(issue_file)
        
        # 只处理 open 状态的
        if issue['status'] != 'open':
            notified[issue_id] = {'status': 'closed', 'notified_at': datetime.now().isoformat()}
            continue
        
        # 获取风险信息
        icon, risk_level, auto_msg = get_severity_info(issue['severity'])
        
        # 构建通知消息
        message = f"""{icon} **新 Issue 创建: #{issue_id}**

**{issue['title']}**

- 风险等级: {risk_level}
- {'⏰ 10分钟后自动执行' if issue['auto_execute'] else '⏸️ 等待人工批准'}

💡 **建议操作**:
• 回复 "批准 #{issue_id}" - 立即执行
• 回复 "取消 #{issue_id}" - 阻止自动执行
• 回复 "查看 #{issue_id}" - 显示完整内容"""

        # 记录日志
        log_entry = f"[{datetime.now().isoformat()}] NOTIFY: {issue_id} - {issue['title']}\n"
        with open(LOG_FILE, 'a') as f:
            f.write(log_entry)
        
        # 标记为已通知
        notified[issue_id] = {
            'status': 'notified',
            'notified_at': datetime.now().isoformat(),
            'auto_execute': issue['auto_execute']
        }
        
        new_issues.append({
            'id': issue_id,
            'message': message,
            'auto_execute': issue['auto_execute'],
            'severity': issue['severity']
        })
    
    # 保存通知记录
    save_notified(notified)
    
    return new_issues

def check_auto_execute():
    """检查是否有 Issue 需要自动执行（通知后 10 分钟）"""
    notified = load_notified()
    to_execute = []
    
    for issue_id, info in notified.items():
        if info.get('status') == 'notified' and info.get('auto_execute'):
            notified_at = datetime.fromisoformat(info['notified_at'])
            elapsed = (datetime.now() - notified_at).total_seconds() / 60
            
            # 10-15 分钟窗口期执行
            if 10 <= elapsed <= 15:
                to_execute.append(issue_id)
    
    return to_execute

if __name__ == '__main__':
    # 扫描新 Issue
    new_issues = scan_issues()
    
    # 输出通知（OpenClaw 会捕获并发送）
    for issue in new_issues:
        print(f"===ISSUE_NOTIFICATION===")
        print(json.dumps(issue, ensure_ascii=False))
        print(f"===END_NOTIFICATION===")
    
    # 检查自动执行
    auto_issues = check_auto_execute()
    if auto_issues:
        print(f"===AUTO_EXECUTE===")
        print(json.dumps({'issues': auto_issues}))
        print(f"===END_AUTO_EXECUTE===")