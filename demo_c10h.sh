#!/bin/bash
# C10H demo —— 一键复现 Hermes Agent 的「配置链路 / 自定义技能 / 记忆持久化 / cron 缺陷」
# 作者：宋俊毅 2025108600351　日期：2026-11-21
# 用法：bash demo_c10h.sh
# 本脚本只读，不改任何配置，不联网。

export PATH="/Users/songjunyi/.local/bin:$PATH"
HOME_DIR="$HOME/.hermes"

line() { echo "================================================================"; }
item() { echo; echo "【$1】"; }

line; echo "C10H demo · $(date '+%Y-%m-%d %H:%M:%S')"; line

item "0. 环境与版本"
hermes --version

item "1. 配置链路：provider 到底指向谁（不采信模型自述，看文件）"
echo "--- $HOME_DIR/config.yaml ---"
cat "$HOME_DIR/config.yaml"
echo "--- $HOME_DIR/.env（键名保留，值只显示是否为占位） ---"
sed 's/^\(OPENAI_API_KEY\)=.*/\1=<本机 ollama 不校验，占位串>/' "$HOME_DIR/.env"
echo "--- 本机 ollama 实际在跑的模型 ---"
curl -s http://127.0.0.1:11434/api/tags | python3 -c "import sys,json;d=json.load(sys.stdin);[print('  模型:',m['name'],'| 大小: %.1f GB'%(m['size']/1e9),'| digest:',m['digest'][:16]+'...') for m in d['models']]"

item "2. 自定义技能是否被真正识别（不是文件放了就算）"
hermes skills list

item "3. 记忆是否真的落盘（文件为准）"
echo "--- $HOME_DIR/memories/USER.md ---"
cat "$HOME_DIR/memories/USER.md" 2>/dev/null || echo "（尚无记忆文件）"
echo "--- 字节数 ---"
wc -c "$HOME_DIR/memories/USER.md" 2>/dev/null

item "4. 定时任务：配置成功 ≠ 自动化生效"
hermes cron list
echo "--- 执行历史 ---"
hermes cron runs 04646455c72f

item "5. 记忆库与人格文件体积"
ls -l "$HOME_DIR/state.db" "$HOME_DIR/SOUL.md" "$HOME_DIR/SOUL.md.default.bak" 2>/dev/null

line; echo "demo 结束"; line
