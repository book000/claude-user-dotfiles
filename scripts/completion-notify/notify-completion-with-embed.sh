#!/bin/bash

# Claude Code Stop hook として動作するスクリプト
# Stop hookは以下の形式のJSONを標準入力から受け取る:
# {
#   "session_id": "string",
#   "hook_event_name": "Stop",
#   "stop_hook_active": boolean
# }

cd "$(dirname "$0")" || exit 1
source ./.env

# JSON入力を読み取り
INPUT_JSON=$(cat)

# jqで必要な情報を抽出
SESSION_ID=$(echo "$INPUT_JSON" | jq -r '.session_id // empty')
SESSION_PATH="${HOME}/.claude/projects/*/${SESSION_ID}.jsonl"

# 現在時刻の取得
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

# フィールドの構築
FIELDS="[]"

# フィールド: 実行ディレクトリ
FIELDS=$(echo "$FIELDS" | jq --arg name "📁 実行ディレクトリ" --arg value "$(pwd)" --arg inline "true" \
  '. + [{"name": $name, "value": $value, "inline": $inline}]')

# フィールド: セッションID
FIELDS=$(echo "$FIELDS" | jq --arg name "🆔 セッションID" --arg value "$SESSION_ID" --arg inline "true" \
  '. + [{"name": $name, "value": $value, "inline": $inline}]')

# フィールド: 入力JSON
FIELDS=$(echo "$FIELDS" | jq --arg name "📝 入力JSON" --arg value "$INPUT_JSON" --arg inline "false" \
  '. + [{"name": $name, "value": $value, "inline": $inline}]')

# フィールド: 区切り (nameは zero-width space)
FIELDS=$(echo "$FIELDS" | jq --arg name "​" --arg value "------------------------------" --arg inline "false" \
  '. + [{"name": $name, "value": $value, "inline": $inline}]')

# jq -r 'select((.type == "assistant" or .type == "user") and .message.type == "message") | .type as $t | .message.content[]? | select(.type=="text") | [$t, .text] | @tsv' 9c213bb5-37f7-40b6-a588-5afe17407064.jsonl
# 複数フィールド: 最新5件のメッセージを取得
LAST_MESSAGES=$(jq -r '
  select(
    (.type == "user" and .message.role == "user" and (.message.content | type) == "string") or
    (.type == "assistant" and .message.type == "message")
  )
  | [.type,
     (if .type == "user" then .message.content
      else ([.message.content[]? | select(.type=="text") | .text] | join(" ")) end)
    ]
  | select(.[1] != "")
  | @tsv
' $SESSION_PATH | tail -n 5)
if [[ -n "$LAST_MESSAGES" ]]; then
  IFS=$'\n' read -r -d '' -a messages_array <<< "$LAST_MESSAGES"
  for message in "${messages_array[@]}"; do
    IFS=$'\t' read -r type text <<< "$message"
    # "\\n" を本当の改行 "\n" に変換
    text=$(echo -e "${text//\\n/$'\n'}")
    if [[ "$type" == "user" ]]; then
      emoji="👤"
    else
      emoji="🤖"
    fi
    FIELDS=$(echo "$FIELDS" | jq --arg name "${emoji} 会話: $type" --arg value "$text" --arg inline "true" \
      '. + [{"name": $name, "value": $value, "inline": $inline}]')
  done
fi

# embed形式のJSONペイロードを作成
PAYLOAD=$(cat <<EOF_JSON
{
  "content": "<@${MENTION_USER_ID}> Claude Code Finished",
  "embeds": [
    {
      "title": "Claude Code セッション完了",
      "color": 5763719,
      "timestamp": "${TIMESTAMP}",
      "fields": ${FIELDS}
    }
  ]
}
EOF_JSON
)

# Discord Webhookに送信
curl -H "Content-Type: application/json" \
     -X POST \
     -d "${PAYLOAD}" \
     "${DISCORD_TOKEN}"

