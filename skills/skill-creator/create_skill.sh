#!/bin/bash
# スキル自動生成スクリプト
# 使い方: ./create_skill.sh <skill_name> <description> <worker_id>

SKILL_NAME="$1"
DESCRIPTION="$2"
WORKER_ID="${3:-ashigaru}"
TIMESTAMP=$(date "+%Y-%m-%dT%H:%M:%S")

TEMPLATE_FILE="$(dirname "$0")/../../templates/skill_template.md"
OUTPUT_FILE="$(dirname "$0")/../${SKILL_NAME}.md"

if [ -z "$SKILL_NAME" ] || [ -z "$DESCRIPTION" ]; then
    echo "使い方: ./create_skill.sh <skill_name> <description> [worker_id]"
    exit 1
fi

if [ -f "$OUTPUT_FILE" ]; then
    echo "エラー: スキル '$SKILL_NAME' は既に存在します"
    exit 1
fi

# テンプレートからスキルファイルを生成
sed -e "s/{{SKILL_NAME}}/$SKILL_NAME/g" \
    -e "s/{{DESCRIPTION}}/$DESCRIPTION/g" \
    -e "s/{{TIMESTAMP}}/$TIMESTAMP/g" \
    -e "s/{{WORKER_ID}}/$WORKER_ID/g" \
    -e "s/{{USE_CASE}}/TODO: 使用場面を記載/g" \
    -e "s/{{STEP_1}}/TODO: 手順1/g" \
    -e "s/{{STEP_2}}/TODO: 手順2/g" \
    -e "s/{{STEP_3}}/TODO: 手順3/g" \
    -e "s/{{PARAM_NAME}}/input/g" \
    -e "s/{{PARAM_TYPE}}/string/g" \
    -e "s/{{REQUIRED}}/Yes/g" \
    -e "s/{{PARAM_DESC}}/入力値/g" \
    -e "s/{{OUTPUT_DESCRIPTION}}/TODO: 出力の説明/g" \
    -e "s/{{EXAMPLE_INPUT}}/TODO: 入力例/g" \
    -e "s/{{EXAMPLE_OUTPUT}}/TODO: 出力例/g" \
    -e "s/{{NOTE_1}}/TODO: 注意事項/g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

echo "スキル '$SKILL_NAME' を作成しました: $OUTPUT_FILE"
