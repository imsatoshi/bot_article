#!/bin/bash
# OpenClaw 关键词监控脚本

export AUTH_TOKEN='e080f640c8c8102307733ac2871f3c8d39706e35'
export CT0='430cf3e1f7cf8425c773dfeec7d2df9d22ccf9c8cef10574ff4e3d72bb970624da3f33338b14173001b162e639c9d8603096d21709fa03716a9557987fc954fd6a4a719a71faccdfbea12defc32801ba'

# 搜索最近1小时的 OpenClaw 相关推文
bird search "openclaw" -n 15 2>/dev/null | head -100
