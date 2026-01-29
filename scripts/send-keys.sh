#!/bin/bash
# ============================================================
# multi-agent-shogun ヘルパースクリプト
# Zellijペインへのキー送信機能を提供
# ============================================================

# プラグインパス
export ZELLIJ_PLUGIN="file:$HOME/.config/zellij/plugins/zellij-send-keys.wasm"

# ペインIDマッピング（multiagentセッション内）
# レイアウトに応じて調整が必要
declare -A PANE_IDS
PANE_IDS=(
    ["karo"]=0
    ["ashigaru1"]=1
    ["ashigaru2"]=2
    ["ashigaru3"]=3
    ["ashigaru4"]=4
    ["ashigaru5"]=5
    ["ashigaru6"]=6
    ["ashigaru7"]=7
    ["ashigaru8"]=8
)

# ============================================================
# send-to-pane: ペインIDを指定してキー送信
# ============================================================
# 使い方: send-to-pane <pane_id> "message" [send_enter]
# 例: send-to-pane 0 "echo hello"
# 例: send-to-pane 1 "partial text" false
send-to-pane() {
    local pane_id="$1"
    local text="$2"
    local send_enter="${3:-true}"
    local session="${ZELLIJ_SESSION_NAME:-multiagent}"

    local json_payload
    json_payload=$(jq -cn --argjson pane_id "$pane_id" --arg text "$text" --argjson send_enter "$send_enter" \
        '{pane_id: $pane_id, text: $text, send_enter: $send_enter}')

    ZELLIJ_SESSION_NAME="$session" zellij action pipe \
        --plugin "$ZELLIJ_PLUGIN" \
        --name send_keys \
        -- "$json_payload"
}

# ============================================================
# send-to-agent: エージェント名を指定してキー送信
# ============================================================
# 使い方: send-to-agent <agent_name> "message" [send_enter]
# 例: send-to-agent karo "queue/shogun_to_karo.yaml を確認せよ"
# 例: send-to-agent ashigaru1 "queue/tasks/ashigaru1.yaml を確認せよ"
send-to-agent() {
    local agent_name="$1"
    local text="$2"
    local send_enter="${3:-true}"

    local pane_id="${PANE_IDS[$agent_name]}"

    if [ -z "$pane_id" ]; then
        echo "エラー: 不明なエージェント名: $agent_name"
        echo "利用可能: karo, ashigaru1-8"
        return 1
    fi

    send-to-pane "$pane_id" "$text" "$send_enter"
}

# ============================================================
# send-to-shogun: 将軍セッションにキー送信
# ============================================================
# 使い方: send-to-shogun "message" [send_enter]
send-to-shogun() {
    local text="$1"
    local send_enter="${2:-true}"

    local json_payload
    json_payload=$(jq -cn --argjson pane_id 0 --arg text "$text" --argjson send_enter "$send_enter" \
        '{pane_id: $pane_id, text: $text, send_enter: $send_enter}')

    ZELLIJ_SESSION_NAME="shogun" zellij action pipe \
        --plugin "$ZELLIJ_PLUGIN" \
        --name send_keys \
        -- "$json_payload"
}

# ============================================================
# 読み込み確認メッセージ
# ============================================================
if [ -n "$SHOGUN_SCRIPT_LOADED" ]; then
    : # 既に読み込み済み
else
    export SHOGUN_SCRIPT_LOADED=1
    echo "🏯 send-keys ヘルパー読み込み完了"
    echo "   send-to-agent karo \"メッセージ\""
    echo "   send-to-agent ashigaru1 \"メッセージ\""
    echo "   send-to-pane <id> \"メッセージ\""
fi
