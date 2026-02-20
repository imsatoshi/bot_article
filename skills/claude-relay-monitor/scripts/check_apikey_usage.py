#!/usr/bin/env python3
"""
Claude Relay Service API Key 使用情况监控脚本
"""

import subprocess
import json
import sys

# 服务器配置
HOST = "23.165.104.242"
PORT = 22
USERNAME = "root"
PASSWORD = "NKuTMHRrHnw74Mp4"

def run_ssh_command(command):
    """执行 SSH 命令"""
    ssh_cmd = f'sshpass -p "{PASSWORD}" ssh -o StrictHostKeyChecking=no -o ConnectTimeout=10 -p {PORT} {USERNAME}@{HOST} "{command}"'
    result = subprocess.run(ssh_cmd, shell=True, capture_output=True, text=True)
    return result.stdout.strip(), result.stderr.strip(), result.returncode

def get_apikey_list():
    """获取 API Key 列表"""
    cmd = "redis-cli smembers apikey:idx:all 2>/dev/null"
    stdout, _, _ = run_ssh_command(cmd)
    return [k.strip() for k in stdout.split('\n') if k.strip()]

def get_apikey_info(key_id):
    """获取 API Key 详细信息"""
    cmd = f"redis-cli hgetall apikey:{key_id} 2>/dev/null"
    stdout, _, _ = run_ssh_command(cmd)
    data = {}
    lines = stdout.split('\n')
    for i in range(0, len(lines)-1, 2):
        if i+1 < len(lines):
            data[lines[i]] = lines[i+1]
    return data

def get_usage_stats(key_id):
    """获取使用量统计"""
    # 总使用量
    cmd = f"redis-cli hgetall usage:{key_id} 2>/dev/null"
    stdout, _, _ = run_ssh_command(cmd)
    total = {}
    lines = stdout.split('\n')
    for i in range(0, len(lines)-1, 2):
        if i+1 < len(lines):
            total[lines[i]] = lines[i+1]
    
    # 今日使用量
    import datetime
    today = datetime.datetime.now().strftime('%Y-%m-%d')
    cmd = f"redis-cli hgetall usage:daily:{key_id}:{today} 2>/dev/null"
    stdout, _, _ = run_ssh_command(cmd)
    daily = {}
    lines = stdout.split('\n')
    for i in range(0, len(lines)-1, 2):
        if i+1 < len(lines):
            daily[lines[i]] = lines[i+1]
    
    return total, daily

def calculate_cost(input_tokens, output_tokens, cache_tokens):
    """计算费用 (USD)"""
    # 定价 (per 1M tokens)
    INPUT_PRICE = 3.0
    OUTPUT_PRICE = 15.0
    CACHE_READ_PRICE = 0.3
    
    input_t = int(input_tokens) if input_tokens else 0
    output_t = int(output_tokens) if output_tokens else 0
    cache_t = int(cache_tokens) if cache_tokens else 0
    
    input_cost = input_t * INPUT_PRICE / 1000000
    output_cost = output_t * OUTPUT_PRICE / 1000000
    cache_cost = cache_t * CACHE_READ_PRICE / 1000000
    total = input_cost + output_cost + cache_cost
    
    return input_cost, output_cost, cache_cost, total

def format_number(num):
    """格式化数字"""
    try:
        n = int(num)
        if n >= 1000000:
            return f"{n/1000000:.2f}M"
        elif n >= 1000:
            return f"{n/1000:.1f}K"
        return str(n)
    except:
        return str(num)

def main():
    print("=" * 60)
    print("🤖 Claude Relay Service - API Key 使用情况")
    print("=" * 60)
    print()
    
    # 获取 API Key 列表
    keys = get_apikey_list()
    
    total_cost_all = 0
    
    for key_id in keys[:10]:  # 限制显示数量
        info = get_apikey_info(key_id)
        if not info:
            continue
        
        name = info.get('name', 'Unknown')
        is_active = info.get('isActive', 'false') == 'true'
        
        total, daily = get_usage_stats(key_id)
        
        # 提取数据
        total_input = int(total.get('totalInputTokens', 0))
        total_output = int(total.get('totalOutputTokens', 0))
        total_cache = int(total.get('totalCacheReadTokens', 0))
        total_requests = int(total.get('totalRequests', 0))
        
        daily_tokens = int(daily.get('tokens', 0))
        daily_requests = int(daily.get('requests', 0))
        
        # 计算费用
        in_cost, out_cost, cache_cost, total_cost = calculate_cost(
            total_input, total_output, total_cache
        )
        total_cost_all += total_cost
        
        # 显示
        status = "🟢 活跃" if is_active else "🔴 停用"
        print(f"📌 API Key: {name} ({status})")
        print(f"   总Tokens: {format_number(total_input + total_output)}")
        print(f"   总请求数: {format_number(total_requests)}")
        print(f"   今日Tokens: {format_number(daily_tokens)}")
        print(f"   今日请求数: {format_number(daily_requests)}")
        print(f"   累计费用: ${total_cost:.2f} USD")
        print(f"     - Input: ${in_cost:.2f}")
        print(f"     - Output: ${out_cost:.2f}")
        print(f"     - Cache: ${cache_cost:.2f}")
        print()
    
    print("-" * 60)
    print(f"💰 总费用估算: ${total_cost_all:.2f} USD")
    print("-" * 60)

if __name__ == "__main__":
    main()
