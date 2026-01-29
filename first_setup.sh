#!/bin/bash
# 🏯 multi-agent-shogun 初回セットアップスクリプト
# プラグイン権限付与など、初回のみ必要な手順

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo "🏯 multi-agent-shogun 初回セットアップ"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# 前提条件チェック
# ═══════════════════════════════════════════════════════════════════════════════
echo "📋 前提条件を確認中..."

# jq
if ! command -v jq &> /dev/null; then
    echo "❌ jq がインストールされていません"
    echo "   brew install jq"
    exit 1
fi
echo "  ✅ jq"

# zellij
if ! command -v zellij &> /dev/null; then
    echo "❌ zellij がインストールされていません"
    echo "   brew install zellij"
    exit 1
fi
echo "  ✅ zellij"

# claude
if ! command -v claude &> /dev/null; then
    echo "❌ claude (Claude Code CLI) がインストールされていません"
    echo "   npm install -g @anthropic-ai/claude-code"
    exit 1
fi
echo "  ✅ claude"

# ═══════════════════════════════════════════════════════════════════════════════
# プラグインインストール
# ═══════════════════════════════════════════════════════════════════════════════
PLUGIN_PATH="$HOME/.config/zellij/plugins/zellij-send-keys.wasm"

if [ ! -f "$PLUGIN_PATH" ]; then
    echo ""
    echo "📦 zellij-send-keys プラグインをインストール中..."
    mkdir -p "$HOME/.config/zellij/plugins"
    curl -sL https://github.com/atani/zellij-send-keys/releases/latest/download/zellij-send-keys.wasm \
        -o "$PLUGIN_PATH"
    echo "  ✅ プラグインインストール完了"
else
    echo "  ✅ zellij-send-keys プラグイン"
fi

# ═══════════════════════════════════════════════════════════════════════════════
# 権限付与セッション起動
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "════════════════════════════════════════════════════════════════"
echo "📝 プラグイン権限の付与が必要です（初回のみ）"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "以下の手順を実行してください："
echo ""
echo "1. このターミナルで以下を実行（テスト用セッション起動）："
echo ""
echo "   zellij -s setup_test"
echo ""
echo "2. セッション内で以下を実行："
echo ""
echo "   zellij plugin -- file:\$HOME/.config/zellij/plugins/zellij-send-keys.wasm"
echo ""
echo "3. ダイアログが表示されたら【Grant】をクリック"
echo ""
echo "4. Ctrl+q でセッションを終了"
echo ""
echo "5. 完了後、以下で日常起動できます："
echo ""
echo "   ./shutsujin_departure.sh"
echo ""
echo "════════════════════════════════════════════════════════════════"
