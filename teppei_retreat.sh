#!/bin/bash
# 🏯 multi-agent-shogun 撤退スクリプト
# 全セッションを一括終了

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  🏯 撤退！全軍帰還！                                      ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""

# セッション削除
echo "  🧹 shogun セッションを終了中..."
zellij delete-session shogun --force 2>/dev/null && echo "     ✅ 完了" || echo "     （なし）"

echo "  🧹 multiagent セッションを終了中..."
zellij delete-session multiagent --force 2>/dev/null && echo "     ✅ 完了" || echo "     （なし）"

echo ""
echo "  ════════════════════════════════════════════════════════════"
echo "   全軍撤退完了。お疲れ様でした。"
echo "  ════════════════════════════════════════════════════════════"
echo ""
