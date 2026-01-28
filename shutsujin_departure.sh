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
            echo "  zellij attach karo            # 家老セッションに接続"
            echo "  zellij attach ashigaru1       # 足軽1セッションに接続"
            echo "  zellij list-sessions          # セッション一覧"
            echo "  zellij kill-session shogun    # 将軍セッションを終了"
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
# 出陣バナー表示
# ═══════════════════════════════════════════════════════════════════════════════
show_battle_cry() {
    clear

    # タイトルバナー（色付き）
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

    # 足軽隊列
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

    # システム情報
    echo -e "\033[1;33m  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓\033[0m"
    echo -e "\033[1;33m  ┃\033[0m  \033[1;37m🏯 multi-agent-shogun\033[0m  〜 \033[1;36m戦国マルチエージェント統率システム\033[0m 〜           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m                                                                           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m    \033[1;35m将軍\033[0m: プロジェクト統括    \033[1;31m家老\033[0m: タスク管理    \033[1;34m足軽\033[0m: 実働部隊×8      \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m                                                                           \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┃\033[0m    \033[1;32m[Zellij版 for macOS]\033[0m                                               \033[1;33m┃\033[0m"
    echo -e "\033[1;33m  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m"
    echo ""
}

# バナー表示実行
show_battle_cry

echo -e "  \033[1;33m天下布武！陣立てを開始いたす\033[0m (Setting up the battlefield)"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 1: 既存セッションクリーンアップ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🧹 既存の陣を撤収中..."

# Zellijセッション削除（エラーを無視）
SESSIONS=("shogun" "karo" "ashigaru1" "ashigaru2" "ashigaru3" "ashigaru4" "ashigaru5" "ashigaru6" "ashigaru7" "ashigaru8")
for session in "${SESSIONS[@]}"; do
    zellij delete-session "$session" --force 2>/dev/null && log_info "  └─ ${session}陣、撤収完了" || true
done

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

# キューファイルリセット
cat > ./queue/shogun_to_karo.yaml << 'EOF'
queue: []
EOF

cat > ./queue/karo_to_ashigaru.yaml << 'EOF'
assignments:
  ashigaru1:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru2:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru3:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru4:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru5:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru6:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru7:
    task_id: null
    description: null
    target_path: null
    status: idle
  ashigaru8:
    task_id: null
    description: null
    target_path: null
    status: idle
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
# STEP 4: Zellijセッション作成
# ═══════════════════════════════════════════════════════════════════════════════
log_war "⚔️ Zellijセッションを構築中..."

# セッション作成関数（PTY問題を回避）
create_zellij_session() {
    local session_name="$1"
    # script コマンドで仮想TTYを提供
    script -q /dev/null zellij -s "$session_name" &
    disown
}

# 将軍セッション
log_info "  └─ 将軍の本陣を構築中..."
create_zellij_session "shogun"
sleep 1

# 家老セッション
log_info "  └─ 家老の陣を構築中..."
create_zellij_session "karo"
sleep 0.5

# 足軽セッション（8名）
log_info "  └─ 足軽の陣を構築中..."
for i in {1..8}; do
    create_zellij_session "ashigaru${i}"
    sleep 0.3
done

sleep 2
log_success "✅ 全Zellijセッション構築完了"
echo ""

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 5: Claude Code 起動（--setup-only でスキップ）
# ═══════════════════════════════════════════════════════════════════════════════
if [ "$SETUP_ONLY" = false ]; then
    log_war "👑 全軍に Claude Code を召喚中..."

    # 将軍（Opusモデル、思考なし）
    log_info "  └─ 将軍、召喚中..."
    zellij --session shogun action write-chars "MAX_THINKING_TOKENS=0 claude --model opus --dangerously-skip-permissions"
    sleep 0.3
    zellij --session shogun action write 13  # Enter
    sleep 1

    # 家老
    log_info "  └─ 家老、召喚中..."
    zellij --session karo action write-chars "claude --dangerously-skip-permissions"
    sleep 0.3
    zellij --session karo action write 13  # Enter
    sleep 0.5

    # 足軽（8名）
    log_info "  └─ 足軽、召喚中..."
    for i in {1..8}; do
        zellij --session "ashigaru${i}" action write-chars "claude --dangerously-skip-permissions"
        sleep 0.2
        zellij --session "ashigaru${i}" action write 13  # Enter
        sleep 0.3
    done

    log_success "✅ 全軍 Claude Code 起動完了"
    echo ""

    # ═══════════════════════════════════════════════════════════════════════════
    # STEP 6: 各エージェントに指示書を読み込ませる
    # ═══════════════════════════════════════════════════════════════════════════
    log_war "📜 各エージェントに指示書を読み込ませ中..."
    echo ""
    echo "  Claude Code の起動を待機中（15秒）..."
    sleep 15

    # 将軍に指示書を読み込ませる
    log_info "  └─ 将軍に指示書を伝達中..."
    zellij --session shogun action write-chars "instructions/shogun.md を読んで役割を理解せよ。"
    sleep 0.3
    zellij --session shogun action write 13

    # 家老に指示書を読み込ませる
    sleep 2
    log_info "  └─ 家老に指示書を伝達中..."
    zellij --session karo action write-chars "instructions/karo.md を読んで役割を理解せよ。"
    sleep 0.3
    zellij --session karo action write 13

    # 足軽に指示書を読み込ませる（1-8）
    sleep 2
    log_info "  └─ 足軽に指示書を伝達中..."
    for i in {1..8}; do
        zellij --session "ashigaru${i}" action write-chars "instructions/ashigaru.md を読んで役割を理解せよ。汝は足軽${i}号である。"
        sleep 0.2
        zellij --session "ashigaru${i}" action write 13
        sleep 0.3
    done

    log_success "✅ 全軍に指示書伝達完了"
    echo ""
fi

# ═══════════════════════════════════════════════════════════════════════════════
# STEP 7: 環境確認・完了メッセージ
# ═══════════════════════════════════════════════════════════════════════════════
log_info "🔍 陣容を確認中..."
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📺 Zellij陣容 (Sessions)                                │"
echo "  └──────────────────────────────────────────────────────────┘"
zellij list-sessions 2>/dev/null | sed 's/^/     /' || echo "     (セッション取得中...)"
echo ""
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  📋 布陣図 (Formation)                                   │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "     【shogunセッション】将軍の本陣"
echo "     ┌─────────────────────────────┐"
echo "     │  shogun (将軍)              │  ← 総大将・プロジェクト統括"
echo "     └─────────────────────────────┘"
echo ""
echo "     【家老・足軽セッション】各独立セッション"
echo "     ┌─────────┬─────────┬─────────┐"
echo "     │  karo   │ashigaru1│ashigaru2│"
echo "     │  (家老) │ (足軽1) │ (足軽2) │"
echo "     ├─────────┼─────────┼─────────┤"
echo "     │ashigaru3│ashigaru4│ashigaru5│"
echo "     │ (足軽3) │ (足軽4) │ (足軽5) │"
echo "     ├─────────┼─────────┼─────────┤"
echo "     │ashigaru6│ashigaru7│ashigaru8│"
echo "     │ (足軽6) │ (足軽7) │ (足軽8) │"
echo "     └─────────┴─────────┴─────────┘"
echo ""

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo "  ║  🏯 出陣準備完了！天下布武！                              ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""

if [ "$SETUP_ONLY" = true ]; then
    echo "  ⚠️  セットアップのみモード: Claude Codeは未起動です"
    echo ""
    echo "  手動でClaude Codeを起動するには:"
    echo "  ┌──────────────────────────────────────────────────────────┐"
    echo "  │  zellij attach shogun                                    │"
    echo "  │  # 接続後、claude --dangerously-skip-permissions を実行  │"
    echo "  └──────────────────────────────────────────────────────────┘"
    echo ""
fi

echo "  次のステップ:"
echo "  ┌──────────────────────────────────────────────────────────┐"
echo "  │  将軍の本陣にアタッチして命令を開始:                      │"
echo "  │     zellij attach shogun                                 │"
echo "  │                                                          │"
echo "  │  家老の陣を確認する:                                      │"
echo "  │     zellij attach karo                                   │"
echo "  │                                                          │"
echo "  │  足軽の陣を確認する:                                      │"
echo "  │     zellij attach ashigaru1                              │"
echo "  │                                                          │"
echo "  │  全セッション一覧:                                        │"
echo "  │     zellij list-sessions                                 │"
echo "  │                                                          │"
echo "  │  セッション切り替え（接続中）:                            │"
echo "  │     Ctrl+O, w でセッション選択                            │"
echo "  │                                                          │"
echo "  │  ※ 各エージェントは指示書を読み込み済み。                 │"
echo "  │    すぐに命令を開始できます。                             │"
echo "  └──────────────────────────────────────────────────────────┘"
echo ""
echo "  ════════════════════════════════════════════════════════════"
echo "   天下布武！勝利を掴め！ (Tenka Fubu! Seize victory!)"
echo "  ════════════════════════════════════════════════════════════"
echo ""
