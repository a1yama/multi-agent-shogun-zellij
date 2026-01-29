#!/bin/bash
# 🏯 multi-agent-shogun 出陣スクリプト（Zellij版 - Mac用）
# Daily Deployment Script for Multi-Agent Orchestration System
#
# 使用方法:
#   ./shutsujin_departure.sh           # 全エージェント起動（通常）
#   ./shutsujin_departure.sh -s        # セットアップのみ（Claude起動なし）
#   ./shutsujin_departure.sh -h        # ヘルプ表示

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 言語設定を読み取り（デフォルト: ja）
LANG_SETTING="ja"
if [ -f "./config/settings.yaml" ]; then
    LANG_SETTING=$(grep "^language:" ./config/settings.yaml 2>/dev/null | awk '{print $2}' || echo "ja")
fi

# 色付きログ関数（戦国風）
log_info() {
    echo -e "\033[1;33m【報】\033[0m $1"
}

log_success() {
    echo -e "\033[1;32m【成】\033[0m $1"
}

log_war() {
    echo -e "\033[1;31m【戦】\033[0m $1"
}

log_error() {
    echo -e "\033[1;31m【誤】\033[0m $1"
}

# ═══════════════════════════════════════════════════════════════════════════════
# オプション解析
# ═══════════════════════════════════════════════════════════════════════════════
SETUP_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--setup-only)
            SETUP_ONLY=true
            shift
            ;;
        -h|--help)
            echo ""
            echo "🏯 multi-agent-shogun 出陣スクリプト（Zellij版）"
            echo ""
            echo "使用方法: ./shutsujin_departure.sh [オプション]"
            echo ""
            echo "オプション:"
            echo "  -s, --setup-only  Zellijセッションのセットアップのみ（Claude起動なし）"
            echo "  -h, --help        このヘルプを表示"
            echo ""
            echo "例:"
            echo "  ./shutsujin_departure.sh      # 全エージェント起動（通常の出陣）"
            echo "  ./shutsujin_departure.sh -s   # セットアップのみ（手動でClaude起動）"
            echo ""
            echo "セッション操作:"
            echo "  zellij attach shogun          # 将軍セッションに接続"
            echo "  zellij attach multiagent      # 家老・足軽セッションに接続"
            echo "  zellij list-sessions          # セッション一覧"
            echo ""
            exit 0
            ;;
        *)
            echo "不明なオプション: $1"
            echo "./shutsujin_departure.sh -h でヘルプを表示"
            exit 1
            ;;
    esac
done

# ═══════════════════════════════════════════════════════════════════════════════
# 前提条件チェック
# ═══════════════════════════════════════════════════════════════════════════════
check_prerequisites() {
    log_info "🔍 前提条件を確認中..."

    # jq
    if ! command -v jq &> /dev/null; then
        log_error "jq がインストールされていません"
        echo "  brew install jq"
        exit 1
    fi

    # zellij
    if ! command -v zellij &> /dev/null; then
        log_error "zellij がインストールされていません"
        echo "  brew install zellij"
        exit 1
    fi

    # プラグイン
    PLUGIN_PATH="$HOME/.config/zellij/plugins/zellij-send-keys.wasm"
    if [ ! -f "$PLUGIN_PATH" ]; then
        log_info "📦 zellij-send-keys プラグインをインストール中..."
        mkdir -p "$HOME/.config/zellij/plugins"
        curl -sL https://github.com/atani/zellij-send-keys/releases/latest/download/zellij-send-keys.wasm \
            -o "$PLUGIN_PATH"
        log_success "  └─ プラグインインストール完了"
    fi

    log_success "✅ 前提条件OK"
}

check_prerequisites

# ═══════════════════════════════════════════════════════════════════════════════
# 出陣バナー表示
# ═══════════════════════════════════════════════════════════════════════════════
show_battle_cry() {
    clear

    echo ""
    echo -e "\033[1;31m╔══════════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m███████╗██╗  ██╗██╗   ██╗████████╗███████╗██╗   ██╗     ██╗██╗███╗   ██╗\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m██╔════╝██║  ██║██║   ██║╚══██╔══╝██╔════╝██║   ██║     ██║██║████╗  ██║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m███████╗███████║██║   ██║   ██║   ███████╗██║   ██║     ██║██║██╔██╗ ██║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m╚════██║██╔══██║██║   ██║   ██║   ╚════██║██║   ██║██   ██║██║██║╚██╗██║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m███████║██║  ██║╚██████╔╝   ██║   ███████║╚██████╔╝╚█████╔╝██║██║ ╚████║\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m║\033[0m \033[1;33m╚══════╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚══════╝ ╚═════╝  ╚════╝ ╚═╝╚═╝  ╚═══╝\033[0m \033[1;31m║\033[0m"
    echo -e "\033[1;31m╠══════════════════════════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;31m║\033[0m       \033[1;37m出陣じゃーーー！！！\033[0m    \033[1;36m⚔\033[0m    \033[1;35m天下布武！\033[0m                          \033[1;31m║\033[0m"
    echo -e "\033[1;31m╚══════════════════════════════════════════════════════════════════════════════════╝\033[0m"
    echo ""

    echo -e "\033[1;34m  ╔═════════════════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;34m  ║\033[0m                    \033[1;37m【 足 軽 隊 列 ・ 八 名 配 備 】\033[0m                      \033[1;34m║\033[0m"
    echo -e "\033[1;34m  ╚═════════════════════════════════════════════════════════════════════════════╝\033[0m"

    cat << 'ASHIGARU_EOF'

       /\      /\      /\      /\      /\      /\      /\      /\
      /||\    /||\    /||\    /||\    /||\    /||\    /||\    /||\
     /_||\   /_||\   /_||\   /_||\   /_||\   /_||\   /_||\   /_||\
       ||      ||      ||      ||      ||      ||      ||      ||
      /||\    /||\    /||\    /||\    /||\    /||\    /||\    /||\
      /  \    /  \    /  \    /  \    /  \    /  \    /  \    /  \
     [足1]   [足2]   [足3]   [足4]   [足5]   [足6]   [足7]   [足8]

ASHIGARU_EOF

    echo -e "                    \033[1;36m「「「 はっ！！ 出陣いたす！！ 」」」\033[0m"
    echo ""

    echo -e "\033[1;33m  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\033[0m"
    echo -e "\033[1;33m  ┃\033[0m  \033[1;37m🏯 multi-agent-shogun\033[0m  〜 \033[1;36m戦国マルチエージェント統率システム\033[0m 〜           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m                                                                           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m    \033[1;35m将軍\033[0m: プロジェクト統括    \033[1;31m家老\033[0m: タスク管理    \033[1;34m足軽\033[0m: 実働部隊×8      \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m                                                                           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m    \033[1;32m[Zellij版 for macOS]\033[0m                                               \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m"
    echo ""
}

show_battle_cry

echo -e "  \033[1;33m天下布武！陣立てを開始いたす\033[0m (Setting up the battlefield)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: 既存セッションクリーンアップ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🧹 既存の陣を撤収中..."

zellij delete-session shogun --force 2>/dev/null && log_info "  └─ shogun陣、撤収完了" || true
zellij delete-session multiagent --force 2>/dev/null && log_info "  └─ multiagent陣、撤収完了" || true

log_success "✅ 陣払い完了"

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 2: 報告ファイルリセット
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📜 前回の軍議記録を破棄中..."
for i in {1..8}; do
    cat > ./queue/reports/ashigaru${i}_report.yaml << EOF
worker_id: ashigaru${i}
task_id: null
timestamp: ""
status: idle
result: null
EOF
done

cat > ./queue/shogun_to_karo.yaml << 'EOF'
queue: []
EOF

log_success "✅ 軍議記録、破棄完了"

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 3: ダッシュボード初期化
# ═══════════════════════════════════════════════════════════════════════════════
log_info "📊 戦況報告板を初期化中..."
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

cat > ./dashboard.md << EOF
# 📊 戦況報告
最終更新: ${TIMESTAMP}

## 🚨 要対応 - 殿のご判断をお待ちしております
なし

## 🔄 進行中 - 只今、戦闘中でござる
なし

## ✅ 本日の戦果
| 時刻 | 戦場 | 任務 | 結果 |
|------|------|------|------|

## 🎯 スキル化候補 - 承認待ち
なし

## 🛠️ 生成されたスキル
なし

## ⏸️ 待機中
なし

## ❓ 伺い事項
なし
EOF

log_success "  └─ ダッシュボード初期化完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 4: Zellijレイアウト作成
# ═══════════════════════════════════════════════════════════════════════════════
log_war "⚔️ Zellijレイアウトを準備中..."

# multiagentセッション用レイアウト（3x3グリッド: karo + ashigaru1-8）
cat > /tmp/multiagent_layout.kdl << 'EOF'
layout {
    pane split_direction="vertical" {
        pane split_direction="horizontal" size="33%" {
            pane name="karo"
            pane name="ashigaru1"
            pane name="ashigaru2"
        }
        pane split_direction="horizontal" size="33%" {
            pane name="ashigaru3"
            pane name="ashigaru4"
            pane name="ashigaru5"
        }
        pane split_direction="horizontal" size="34%" {
            pane name="ashigaru6"
            pane name="ashigaru7"
            pane name="ashigaru8"
        }
    }
}
EOF

# shogunセッション用レイアウト
cat > /tmp/shogun_layout.kdl << 'EOF'
layout {
    pane name="shogun"
}
EOF

log_success "  └─ レイアウト準備完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: セッション起動案内
# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  🏯 陣立て準備完了！                                      ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""
echo "  次のステップ（手動で実行してください）:"
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  1. 家老・足軽セッションを起動（ターミナル1）:            │"
echo "  │     zellij -s multiagent --layout /tmp/multiagent_layout.kdl │"
echo "  │                                                          │"
echo "  │  2. プラグイン権限を付与（multiagentセッション内で）:     │"
echo "  │     zellij plugin -- file:\$HOME/.config/zellij/plugins/zellij-send-keys.wasm │"
echo "  │     → ダイアログで Grant をクリック                      │"
echo "  │                                                          │"
echo "  │  3. 将軍セッションを起動（ターミナル2）:                  │"
echo "  │     zellij -s shogun --layout /tmp/shogun_layout.kdl     │"
echo "  │                                                          │"
echo "  │  4. プラグイン権限を付与（shogunセッション内で）:         │"
echo "  │     zellij plugin -- file:\$HOME/.config/zellij/plugins/zellij-send-keys.wasm │"
echo "  │     → ダイアログで Grant をクリック                      │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""

if [ "$SETUP_ONLY" = false ]; then
    echo "  ┌──────────────────────────────────────────────────────────┐"
    echo "  │  5. 各ペインでClaude Codeを起動:                         │"
    echo "  │                                                          │"
    echo "  │     【将軍ペイン】                                       │"
    echo "  │     MAX_THINKING_TOKENS=0 claude --model opus --dangerously-skip-permissions │"
    echo "  │                                                          │"
    echo "  │     【家老・足軽ペイン（各ペインで）】                    │"
    echo "  │     claude --dangerously-skip-permissions                │"
    echo "  │                                                          │"
    echo "  │  6. ヘルパースクリプトを読み込み（各ペインで）:          │"
    echo "  │     source ~/multi-agent-shogun/scripts/send-keys.sh     │"
    echo "  │                                                          │"
    echo "  │  7. 指示書を読み込ませる:                                │"
    echo "  │     【将軍】instructions/shogun.md を読んで役割を理解せよ │"
    echo "  │     【家老】instructions/karo.md を読んで役割を理解せよ   │"
    echo "  │     【足軽】instructions/ashigaru.md を読んで役割を理解せよ。汝は足軽N号である │"
    echo "  └──────────────────────────────────────────────────────────┘"
fi

echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📋 ペインID対応表（multiagentセッション）               │"
echo "  ├──────────────────────────────────────────────────────────┤"
echo "  │  ID: 0 = karo (家老)                                     │"
echo "  │  ID: 1 = ashigaru1                                       │"
echo "  │  ID: 2 = ashigaru2                                       │"
echo "  │  ID: 3 = ashigaru3                                       │"
echo "  │  ID: 4 = ashigaru4                                       │"
echo "  │  ID: 5 = ashigaru5                                       │"
echo "  │  ID: 6 = ashigaru6                                       │"
echo "  │  ID: 7 = ashigaru7                                       │"
echo "  │  ID: 8 = ashigaru8                                       │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📡 キー送信コマンド（ヘルパー読み込み後）               │"
echo "  ├──────────────────────────────────────────────────────────┤"
echo "  │  send-to-agent karo \"メッセージ\"                        │"
echo "  │  send-to-agent ashigaru1 \"メッセージ\"                   │"
echo "  │  send-to-pane 0 \"メッセージ\"                            │"
echo "  │  send-to-shogun \"メッセージ\"                            │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "  ════════════════════════════════════════════════════════════"
echo "   天下布武！勝利を掴め！ (Tenka Fubu! Seize victory!)"
echo "  ════════════════════════════════════════════════════════════"
echo ""
