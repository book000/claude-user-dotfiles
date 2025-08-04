#!/bin/bash
set -e # エラー時に即座に終了する設定を有効にする

# 引数の解析
LOOP=true # デフォルトでループを有効にする
DEBUG=false
TIMEOUT=3600 # デフォルトタイムアウト（1時間）
INTERVAL=30 # チェック間隔（秒）

print_help() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "  --no-loop     一度だけチェックして終了"
  echo "  --debug       デバッグ出力を有効化"
  echo "  --timeout N   タイムアウト時間（秒、デフォルト: 3600）"
  echo "  --interval N  チェック間隔（秒、デフォルト: 30）"
  echo "  --help        このヘルプを表示"
  echo ""
  echo "例:"
  echo "  $0                    通常の監視モード"
  echo "  $0 --no-loop         現在の状態をチェックして終了"
  echo "  $0 --debug           デバッグ出力付きで監視"
  echo "  $0 --timeout 1800    30分でタイムアウト"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --no-loop)
      LOOP=false
      shift
      ;;
    --debug)
      DEBUG=true
      shift
      ;;
    --timeout)
      TIMEOUT="$2"
      shift 2
      ;;
    --interval)
      INTERVAL="$2"
      shift 2
      ;;
    --help|-h)
      print_help
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

if [ "$DEBUG" = true ]; then
  set -x # デバッグ出力を有効にする
fi

# PRの情報を取得（エラーハンドリング付き）
if ! PR_INFO=$(gh pr view --json number,headRefName 2>/dev/null); then
  echo "Error: Could not get PR information. Are you in a repository with an active PR?"
  exit 1
fi

PR_NUMBER=$(echo "$PR_INFO" | jq -r '.number')
PR_HEAD_REF=$(echo "$PR_INFO" | jq -r '.headRefName')

echo "Monitoring CI for PR #$PR_NUMBER (branch: $PR_HEAD_REF)"
echo "Timeout: ${TIMEOUT}s, Check interval: ${INTERVAL}s"

if [ "$LOOP" = false ]; then
  echo "One-time check mode enabled"
fi

START_TIME=$(date +%s)

while true; do
  CURRENT_TIME=$(date +%s)
  ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

  # タイムアウトチェック
  if [ "$LOOP" = true ] && [ $ELAPSED_TIME -gt $TIMEOUT ]; then
    echo "Timeout reached (${TIMEOUT}s). CI monitoring stopped."
    exit 1
  fi

  # 最新のワークフロー実行を取得
  RUN_INFO=$(gh run list --limit 10 --json headBranch,databaseId,status,conclusion,createdAt,updatedAt,workflowName -q ".[] | select(.headBranch == \"$PR_HEAD_REF\")" | head -n 1)

  if [ -z "$RUN_INFO" ]; then
    echo "Monitor: ${ELAPSED_TIME}s - No workflow run found for branch $PR_HEAD_REF. Waiting..."
    if [ "$LOOP" = false ]; then
      echo "No CI run found for this branch."
      exit 0
    fi
    sleep $INTERVAL
    continue
  fi

  RUN_ID=$(echo "$RUN_INFO" | jq -r '.databaseId')
  RUN_STATUS=$(echo "$RUN_INFO" | jq -r '.status')
  RUN_CONCLUSION=$(echo "$RUN_INFO" | jq -r '.conclusion')
  RUN_CREATED=$(echo "$RUN_INFO" | jq -r '.createdAt')
  RUN_UPDATED=$(echo "$RUN_INFO" | jq -r '.updatedAt')
  WORKFLOW_NAME=$(echo "$RUN_INFO" | jq -r '.workflowName')

  # GitHub Actionsの実際の経過時間を計算
  RUN_CREATED_EPOCH=$(date -d "$RUN_CREATED" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$RUN_CREATED" +%s 2>/dev/null || echo "$START_TIME")
  
  if [ "$RUN_STATUS" = "completed" ]; then
    RUN_UPDATED_EPOCH=$(date -d "$RUN_UPDATED" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$RUN_UPDATED" +%s 2>/dev/null || echo "$CURRENT_TIME")
    RUN_DURATION=$((RUN_UPDATED_EPOCH - RUN_CREATED_EPOCH))
  else
    RUN_DURATION=$((CURRENT_TIME - RUN_CREATED_EPOCH))
  fi

  # 平均実行時間を計算（過去20回の成功した実行から、同じワークフローのみ）
  if [ -z "$AVERAGE_CALCULATED" ]; then
    AVERAGE_TIME=$(gh run list --limit 50 --json status,conclusion,createdAt,updatedAt,workflowName -q ".[] | select(.status == \"completed\" and .conclusion == \"success\" and .workflowName == \"$WORKFLOW_NAME\") | {created: .createdAt, updated: .updatedAt}" 2>/dev/null | jq -r '.created + " " + .updated' 2>/dev/null | head -20 | while read created updated; do
      if [ -n "$created" ] && [ -n "$updated" ]; then
        created_epoch=$(date -d "$created" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$created" +%s 2>/dev/null || echo "0")
        updated_epoch=$(date -d "$updated" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated" +%s 2>/dev/null || echo "0")
        if [ "$created_epoch" -gt 0 ] && [ "$updated_epoch" -gt 0 ]; then
          echo $((updated_epoch - created_epoch))
        fi
      fi
    done | awk '{sum+=$1; count++} END {if(count>0) print int(sum/count); else print 0}')
    
    AVERAGE_CALCULATED=true
    if [ "$AVERAGE_TIME" -gt 0 ]; then
      AVERAGE_MIN=$((AVERAGE_TIME / 60))
      AVERAGE_SEC=$((AVERAGE_TIME % 60))
      echo "📊 Average CI duration for '$WORKFLOW_NAME': ${AVERAGE_MIN}m ${AVERAGE_SEC}s (based on recent successful runs)"
    fi
  fi

  # 実行時間の表示用フォーマット
  RUN_MIN=$((RUN_DURATION / 60))
  RUN_SEC=$((RUN_DURATION % 60))
  
  if [ "$DEBUG" = true ]; then
    echo "DEBUG: Run ID: $RUN_ID"
    echo "DEBUG: Workflow Name: $WORKFLOW_NAME"
    echo "DEBUG: Created: $RUN_CREATED"
    echo "DEBUG: Updated: $RUN_UPDATED"
    echo "DEBUG: Run Duration: ${RUN_DURATION}s"
  fi

  # 進捗表示（推定残り時間付き）
  case $RUN_STATUS in
    "queued")
      echo "Monitor: ${ELAPSED_TIME}s | Workflow: queued - ⏳ Waiting to start..."
      ;;
    "in_progress")
      PROGRESS_INFO="Monitor: ${ELAPSED_TIME}s | Workflow: ${RUN_MIN}m ${RUN_SEC}s"
      if [ "$AVERAGE_TIME" -gt 0 ] && [ "$RUN_DURATION" -gt 0 ]; then
        REMAINING_TIME=$((AVERAGE_TIME - RUN_DURATION))
        if [ "$REMAINING_TIME" -gt 0 ]; then
          REMAINING_MIN=$((REMAINING_TIME / 60))
          REMAINING_SEC=$((REMAINING_TIME % 60))
          PROGRESS_PERCENT=$((RUN_DURATION * 100 / AVERAGE_TIME))
          if [ "$PROGRESS_PERCENT" -gt 100 ]; then PROGRESS_PERCENT=100; fi
          echo "$PROGRESS_INFO - 🏃 Running... (${PROGRESS_PERCENT}%, ~${REMAINING_MIN}m ${REMAINING_SEC}s remaining)"
        else
          echo "$PROGRESS_INFO - 🏃 Running... (taking longer than average)"
        fi
      else
        echo "$PROGRESS_INFO - 🏃 Running..."
      fi
      ;;
    "completed")
      case $RUN_CONCLUSION in
        "success")
          echo "✅ All CI checks completed successfully! (Workflow: ${RUN_MIN}m ${RUN_SEC}s | Monitor: ${ELAPSED_TIME}s)"
          if [ "$AVERAGE_TIME" -gt 0 ]; then
            if [ "$RUN_DURATION" -lt "$AVERAGE_TIME" ]; then
              DIFF_TIME=$((AVERAGE_TIME - RUN_DURATION))
              DIFF_MIN=$((DIFF_TIME / 60))
              DIFF_SEC=$((DIFF_TIME % 60))
              echo "🚀 Completed ${DIFF_MIN}m ${DIFF_SEC}s faster than average!"
            elif [ "$RUN_DURATION" -gt "$AVERAGE_TIME" ]; then
              DIFF_TIME=$((RUN_DURATION - AVERAGE_TIME))
              DIFF_MIN=$((DIFF_TIME / 60))
              DIFF_SEC=$((DIFF_TIME % 60))
              echo "⏰ Took ${DIFF_MIN}m ${DIFF_SEC}s longer than average"
            else
              echo "⏱️  Completed in average time"
            fi
          fi
          gh run view "$RUN_ID" --json jobs -q '.jobs[] | select(.conclusion != "success") | {name: .name, conclusion: .conclusion}' 2>/dev/null || true
          exit 0
          ;;
        "failure")
          echo "❌ CI checks failed! (Workflow: ${RUN_MIN}m ${RUN_SEC}s | Monitor: ${ELAPSED_TIME}s)"
          echo "Failed jobs:"
          gh run view "$RUN_ID" --json jobs -q '.jobs[] | select(.conclusion == "failure") | "  - " + .name' 2>/dev/null || true
          gh run view "$RUN_ID"
          exit 1
          ;;
        "cancelled")
          echo "🚫 Workflow was cancelled (Workflow: ${RUN_MIN}m ${RUN_SEC}s | Monitor: ${ELAPSED_TIME}s)"
          gh run view "$RUN_ID"
          exit 1
          ;;
        "skipped")
          echo "⏭️  Workflow was skipped (Workflow: ${RUN_MIN}m ${RUN_SEC}s | Monitor: ${ELAPSED_TIME}s)"
          gh run view "$RUN_ID"
          exit 0
          ;;
        *)
          echo "🤔 Workflow completed with unknown conclusion: $RUN_CONCLUSION (Workflow: ${RUN_MIN}m ${RUN_SEC}s | Monitor: ${ELAPSED_TIME}s)"
          gh run view "$RUN_ID"
          exit 0
          ;;
      esac
      ;;
    *)
      echo "Monitor: ${ELAPSED_TIME}s | Workflow: ${RUN_MIN}m ${RUN_SEC}s - Unknown status: $RUN_STATUS"
      ;;
  esac

  if [ "$LOOP" = false ]; then
    echo "One-time check completed. Current status: $RUN_STATUS"
    exit 0
  fi

  sleep $INTERVAL
done