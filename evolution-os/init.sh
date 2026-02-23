#!/bin/bash
#
# Evolution OS 初始化脚本
# 一键设置向量索引和依赖
#

set -e

EVO_DIR="$HOME/evolution-os"
cd "$EVO_DIR"

echo "=== Evolution OS 初始化 ==="
echo ""

# 检查 Python
echo "[1/4] 检查 Python 环境..."
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 未安装"
    exit 1
fi

# 检查 numpy
echo "[2/4] 安装依赖 (numpy)..."
python3 -c "import numpy" 2>/dev/null || pip3 install numpy -q

# 设置脚本权限
echo "[3/4] 设置脚本权限..."
chmod +x cron/*.sh
echo "✅ 脚本权限已设置"

# 首次索引
echo "[4/4] 构建初始向量索引..."
python3 cron/vector_index.py index
echo "✅ 向量索引已构建"

# 创建快捷方式
echo ""
echo "=== 创建快捷方式 ==="

# memory-search 命令
if ! grep -q "memory-search" ~/.bashrc 2>/dev/null; then
    echo "alias memory-search='$EVO_DIR/cron/memory-search.sh'" >> ~/.bashrc
    echo "✅ 已添加 'memory-search' 命令到 .bashrc"
fi

echo ""
echo "=== 初始化完成 ==="
echo ""
echo "使用方法:"
echo "  memory-search '<查询内容>'  - 语义搜索历史记忆"
echo "  cd $EVO_DIR && python3 cron/vector_index.py stats  - 查看索引统计"
echo ""
echo "定时任务已设置:"
echo "  02:30 - 每日冥想 (自动更新向量索引)"
echo "  06:30 - 早间巡查"
echo "  22:00 - 晚间巡查"
