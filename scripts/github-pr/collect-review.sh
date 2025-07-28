#!/bin/bash
set -euo pipefail

PR_NUMBER=$1
if [ -z "$PR_NUMBER" ]; then
  echo "Usage: $0 <PR_NUMBER>"
  exit 1
fi

# 1. gh repo viewを1回だけ実行してOWNERとREPOを取得
REPO_INFO=$(gh repo view --json owner,name)
OWNER=$(echo "$REPO_INFO" | jq -r '.owner.login')
REPO=$(echo "$REPO_INFO" | jq -r '.name')

echo "🔍 Collecting unresolved review comments for PR #$PR_NUMBER in $OWNER/$REPO"

# 一時ファイル（クリーンアップトラップ付き）
REST_JSON=$(mktemp)
GRAPHQL_JSON=$(mktemp)
trap 'rm -f "$REST_JSON" "$GRAPHQL_JSON"' EXIT

# 1. REST APIでPRコメント取得
gh api "/repos/${OWNER}/${REPO}/pulls/${PR_NUMBER}/comments" > "$REST_JSON"

# 2. GraphQL APIでreviewThreads取得
gh api graphql -f query="
{
  repository(owner: \"${OWNER}\", name: \"${REPO}\") {
    pullRequest(number: ${PR_NUMBER}) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 50) {
            nodes {
              id
            }
          }
        }
      }
    }
  }
}" > "$GRAPHQL_JSON"

# 3. resolved=true のコメントnode_id一覧を抽出
RESOLVED_IDS=$(jq -r '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == true)
  | .comments.nodes[].id
' "$GRAPHQL_JSON")

# 4. REST API結果から resolved な node_id を除外して表示
UNRESOLVED_COMMENTS=$(jq -r --argjson resolved "$(jq -Rn --argjson arr "$(printf '%s\n' $RESOLVED_IDS | jq -R . | jq -s .)" '$arr')" '
  map(select((.node_id) as $id | ($resolved | index($id) | not)))
  | .[]
  | "\(.id)\t\(.path)\nURL: \(.html_url)\nCOMMENT: \(.body)\n---"
' "$REST_JSON")

TOTAL_COMMENTS=$(jq '. | length' "$REST_JSON")
UNRESOLVED_COUNT=$(echo "$UNRESOLVED_COMMENTS" | grep -c "^[0-9]" || echo "0")

echo "📊 Comments: $UNRESOLVED_COUNT unresolved / $TOTAL_COMMENTS total"
echo "=================================="

if [ "$UNRESOLVED_COUNT" -gt 0 ]; then
  echo "$UNRESOLVED_COMMENTS"
else
  echo "✅ All review comments have been resolved!"
fi
