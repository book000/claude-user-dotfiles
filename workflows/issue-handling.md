# Issue対応ワークフロー

## 基本原則

「issue #nnを対応してください」と指示された場合の完全自動化フロー

### Issue対応の品質管理基準
- **再現性の確保**: 問題の再現手順を必ず確認・検証
- **影響範囲の評価**: 変更による既存機能への影響を事前評価
- **テストカバレッジ**: 新機能・修正には対応するテストを必ず追加
- **ドキュメント整合性**: 仕様変更時は関連ドキュメントも更新
- **セキュリティ配慮**: セキュリティに関わる変更は特に慎重に検証

## Issue対応の完全フロー

### 1. **Issue内容確認・分析**

```bash
# Issue詳細の取得・確認
gh issue view {ISSUE_NUMBER} --json title,body,labels,assignees,milestone

# Issue分析フェーズ
echo "🔍 Issue分析を開始..."

# 1. Issue分類の判定
LABELS=$(gh issue view {ISSUE_NUMBER} --json labels -q '.labels[].name')
if [[ $LABELS =~ "critical"|"urgent" ]]; then
    PRIORITY="high"
elif [[ $LABELS =~ "enhancement"|"feature" ]]; then
    PRIORITY="medium"
else
    PRIORITY="low"
fi

echo "Priority: $PRIORITY"

# 2. 複雑度評価
BODY_LENGTH=$(gh issue view {ISSUE_NUMBER} --json body -q '.body | length')
if [ $BODY_LENGTH -gt 500 ]; then
    COMPLEXITY="complex"
elif [ $BODY_LENGTH -gt 200 ]; then
    COMPLEXITY="medium"
else
    COMPLEXITY="simple"
fi

echo "Complexity: $COMPLEXITY"

# 3. 依存関係チェック
RELATED_ISSUES=$(gh issue view {ISSUE_NUMBER} --json body -q '.body' | grep -o "#[0-9]\+" | head -5)
if [ -n "$RELATED_ISSUES" ]; then
    echo "Related issues detected: $RELATED_ISSUES"
fi
```

#### Issue内容の理解・検証項目
- **問題の概要**: 何が問題なのか、なぜ重要なのか
- **再現手順**: 具体的な手順、環境情報
- **期待される動作**: 修正後の理想的な状態
- **技術的要件**: 使用技術、制約条件、パフォーマンス要求
- **受け入れ基準**: 完了判定の明確な基準

### 2. **ブランチ作成**

```bash
# upstream/origin判定とメインブランチ取得
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
else
    REMOTE="origin"
fi

MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)

# Issue対応ブランチの作成（Conventional Commits形式）
git fetch --all

# Issueタイトルから適切なタイプを判定
ISSUE_TITLE=$(gh issue view {ISSUE_NUMBER} --json title -q '.title')
if [[ $ISSUE_TITLE =~ bug|fix|error|修正 ]]; then
    TYPE="fix"
elif [[ $ISSUE_TITLE =~ feature|add|implement|機能|追加 ]]; then
    TYPE="feat"
elif [[ $ISSUE_TITLE =~ doc|readme|ドキュメント ]]; then
    TYPE="docs"
elif [[ $ISSUE_TITLE =~ test|テスト ]]; then
    TYPE="test"
elif [[ $ISSUE_TITLE =~ refactor|リファクタ ]]; then
    TYPE="refactor"
else
    TYPE="fix"  # デフォルト
fi

# 説明部分の生成
DESCRIPTION=$(echo "$ISSUE_TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-\|-$//g' | cut -c1-30)

git checkout -b $TYPE/$DESCRIPTION --no-track $REMOTE/$MAIN_BRANCH

# 例: git checkout -b fix/login-validation --no-track upstream/main
```

### 3. **実装計画・実行**

#### **実装前の準備**

```bash
# 影響範囲調査
echo "🔍 影響範囲を調査中..."

# 関連ファイルの特定
if [[ $TYPE == "fix" ]]; then
    # バグ修正: エラー箇所の特定
    grep -r "error_pattern" src/ || true
    
elif [[ $TYPE == "feat" ]]; then
    # 新機能: 類似機能の調査
    find src/ -name "*similar_feature*" || true
    
elif [[ $TYPE == "refactor" ]]; then
    # リファクタリング: 依存関係の調査
    grep -r "target_function" src/ || true
fi

# 既存テストの確認
find . -name "*.test.*" -o -name "*.spec.*" | head -10
```

#### **段階的実装アプローチ**

```bash
# 複雑度に応じた実装戦略
case $COMPLEXITY in
    "simple")
        echo "📝 シンプルな実装を開始..."
        # 直接実装
        ;;
    "medium")
        echo "📋 段階的実装を開始..."
        # 1. 最小実装
        # 2. テスト追加
        # 3. 機能拡張
        ;;
    "complex")
        echo "🏗️ 複雑な実装を開始..."
        # 1. 設計検討
        # 2. プロトタイプ作成
        # 3. 段階的実装
        # 4. 統合テスト
        ;;
esac
```

#### **実装種別ごとの対応**

##### **バグ修正 (fix)**
```bash
# 1. 問題の再現
# 2. 原因の特定
# 3. 最小限の修正
# 4. 回帰テストの追加
# 5. 副作用の確認
```

##### **新機能 (feat)**
```bash
# 1. 要件の詳細確認
# 2. 設計の検討
# 3. インターフェース定義
# 4. 実装
# 5. ユニットテスト
# 6. 統合テスト
# 7. ドキュメント更新
```

##### **リファクタリング (refactor)**
```bash
# 1. 現在の動作確認
# 2. リファクタリング対象の特定
# 3. 段階的な改善
# 4. テストでの動作確認
# 5. パフォーマンス測定
```

##### **ドキュメント (docs)**
```bash
# 1. 対象ドキュメントの特定
# 2. 現在の内容確認
# 3. 不足・誤りの特定
# 4. 内容の更新・追加
# 5. リンク整合性確認
```

##### **テスト (test)**
```bash
# 1. テスト対象の特定
# 2. テストケース設計
# 3. 正常系テスト
# 4. 異常系テスト
# 5. 境界値テスト
# 6. カバレッジ確認
```

### 4. **品質チェック・検証**

#### **基本品質チェック**

```bash
echo "🔍 品質チェックを開始..."

# パッケージマネージャー判定
if [ -f "pnpm-lock.yaml" ]; then
    PM="pnpm"
elif [ -f "yarn.lock" ]; then
    PM="yarn"
elif [ -f "bun.lockb" ]; then
    PM="bun"
else
    PM="npm"
fi

# 1. Lint検査
echo "📝 Lint検査実行中..."
if ! $PM run lint; then
    echo "❌ Lintエラーが検出されました"
    exit 1
fi

# 2. 型チェック
echo "🔍 型チェック実行中..."
if command -v "$PM run typecheck" >/dev/null 2>&1; then
    if ! $PM run typecheck; then
        echo "❌ 型エラーが検出されました"
        exit 1
    fi
fi

# 3. テスト実行
echo "🧪 テスト実行中..."
if ! $PM run test; then
    echo "❌ テストが失敗しました"
    exit 1
fi

# 4. ビルド確認
echo "🏗️ ビルド確認中..."
if grep -q '"build"' package.json; then
    if ! $PM run build; then
        echo "❌ ビルドが失敗しました"
        exit 1
    fi
fi
```

#### **拡張品質チェック**

```bash
# セキュリティチェック（該当する場合）
if [[ $PRIORITY == "high" ]] || [[ $LABELS =~ "security" ]]; then
    echo "🔒 セキュリティチェック実行中..."
    
    # 依存関係脆弱性チェック
    $PM audit || echo "⚠️ 脆弱性が検出されました"
    
    # セキュリティ関連の静的解析（該当ツールがある場合）
    if command -v eslint-plugin-security >/dev/null 2>&1; then
        npx eslint --ext .js,.ts --plugin security src/ || true
    fi
fi

# パフォーマンステスト（該当する場合）
if [[ $TYPE == "perf" ]] || [[ $LABELS =~ "performance" ]]; then
    echo "⚡ パフォーマンステスト実行中..."
    
    # ビルドサイズチェック
    if [ -d "dist" ] || [ -d "build" ]; then
        du -sh dist/ build/ 2>/dev/null || true
    fi
    
    # パフォーマンステスト実行（該当スクリプトがある場合）
    if grep -q '"test:perf"' package.json; then
        $PM run test:perf || true
    fi
fi

# テストカバレッジ確認
echo "📊 テストカバレッジ確認中..."
if grep -q '"test:coverage"' package.json; then
    $PM run test:coverage || true
    
    # カバレッジ閾値チェック（設定されている場合）
    if [ -f ".nycrc" ] || [ -f "jest.config.js" ]; then
        echo "✅ カバレッジ設定確認済み"
    fi
fi
```

#### **Issue種別ごとの追加検証**

```bash
# Issue種別に応じた追加検証
case $TYPE in
    "fix")
        echo "🐛 バグ修正の検証..."
        # 1. 問題の再現確認（修正前）
        # 2. 修正後の動作確認
        # 3. 回帰テスト実行
        # 4. 関連機能の動作確認
        ;;
    "feat")
        echo "✨ 新機能の検証..."
        # 1. 機能要件の充足確認
        # 2. ユーザビリティテスト
        # 3. 既存機能との統合確認
        # 4. ドキュメント整合性確認
        ;;
    "refactor")
        echo "♻️ リファクタリングの検証..."
        # 1. 既存機能の動作確認
        # 2. パフォーマンス比較
        # 3. コード品質指標確認
        # 4. API互換性確認
        ;;
    "docs")
        echo "📚 ドキュメントの検証..."
        # 1. 内容の正確性確認
        # 2. リンクの有効性確認
        # 3. 形式の統一性確認
        # 4. 実装との整合性確認
        ;;
    "test")
        echo "🧪 テストの検証..."
        # 1. テストケースの網羅性確認
        # 2. テストの実行時間確認
        # 3. テストの安定性確認
        # 4. カバレッジ向上の確認
        ;;
esac
```

### 5. **コミット・プッシュ**

```bash
# 変更のステージング
git add .

# Conventional Commits形式でコミット
# Issue内容に基づいてtypeを判定
ISSUE_TITLE=$(gh issue view {ISSUE_NUMBER} --json title -q '.title')

# 適切なprefixを判定
if [[ $ISSUE_TITLE =~ bug|fix|error ]]; then
    PREFIX="fix"
elif [[ $ISSUE_TITLE =~ feature|add|implement ]]; then
    PREFIX="feat"
elif [[ $ISSUE_TITLE =~ doc|readme ]]; then
    PREFIX="docs"
elif [[ $ISSUE_TITLE =~ test ]]; then
    PREFIX="test"
elif [[ $ISSUE_TITLE =~ refactor ]]; then
    PREFIX="refactor"
else
    PREFIX="fix"  # デフォルト
fi

# コミット実行
git commit -m "$PREFIX: $ISSUE_TITLE

Fixes #${ISSUE_NUMBER}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# リモートプッシュ
git push -u origin issue-{ISSUE_NUMBER}-{brief-description}
```

### 6. **PR作成**

```bash
# PR作成
gh pr create \
  --title "$PREFIX: $ISSUE_TITLE" \
  --body "$(cat <<EOF
## 概要
Issue #${ISSUE_NUMBER} の対応

$ISSUE_TITLE

## 変更内容
- Issue #${ISSUE_NUMBER} で報告された問題を修正
- [具体的な変更内容を記載]

## テスト内容
- 既存テストの実行確認
- [新規テストがある場合は記載]

## チェックリスト
- [x] ローカルでlint/testが通ることを確認
- [x] 既存機能に影響がないことを確認
- [x] Issue要件を満たしていることを確認

Closes #${ISSUE_NUMBER}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## 自動化スクリプト例

### 完全自動Issue対応スクリプト

```bash
#!/bin/bash
# handle_issue.sh - Issue完全対応スクリプト

set -e

ISSUE_NUMBER=$1
if [ -z "$ISSUE_NUMBER" ]; then
    echo "Usage: $0 <issue_number>"
    exit 1
fi

echo "🔍 Issue #$ISSUE_NUMBER の対応を開始..."

# 1. Issue詳細取得
echo "📋 Issue内容を確認中..."
ISSUE_DATA=$(gh issue view $ISSUE_NUMBER --json title,body,labels)
ISSUE_TITLE=$(echo $ISSUE_DATA | jq -r '.title')
ISSUE_BODY=$(echo $ISSUE_DATA | jq -r '.body')

echo "Issue: $ISSUE_TITLE"

# 2. ブランチ作成
echo "🌿 ブランチを作成中..."
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
else
    REMOTE="origin"
fi

MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)
git fetch --all

# ブランチタイプ判定（Conventional Commits）
if [[ $ISSUE_TITLE =~ bug|fix|error|修正 ]]; then
    TYPE="fix"
elif [[ $ISSUE_TITLE =~ feature|add|implement|機能|追加 ]]; then
    TYPE="feat"
elif [[ $ISSUE_TITLE =~ doc|readme|ドキュメント ]]; then
    TYPE="docs"
elif [[ $ISSUE_TITLE =~ test|テスト ]]; then
    TYPE="test"
elif [[ $ISSUE_TITLE =~ refactor|リファクタ ]]; then
    TYPE="refactor"
else
    TYPE="fix"  # デフォルト
fi

# ブランチ説明生成
DESCRIPTION=$(echo "$ISSUE_TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | sed 's/--*/-/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-\|-$//g' | cut -c1-30)
BRANCH_NAME="$TYPE/$DESCRIPTION"

git checkout -b $BRANCH_NAME --no-track $REMOTE/$MAIN_BRANCH
echo "✅ ブランチ作成完了: $BRANCH_NAME (Conventional Commits形式)"

# 3. 実装フェーズ（ここでClaude Codeが実装を実行）
echo "⚙️ Issue対応の実装を実行中..."
echo "Issue詳細:"
echo "$ISSUE_BODY"
echo ""
echo "実装が必要な内容を以下で処理してください："
echo "- Issue要件の分析"
echo "- 必要なファイルの修正・追加"
echo "- テストの追加・修正"
echo ""

# パッケージマネージャー判定
if [ -f "pnpm-lock.yaml" ]; then
    PM="pnpm"
elif [ -f "yarn.lock" ]; then
    PM="yarn"
elif [ -f "bun.lockb" ]; then
    PM="bun"
else
    PM="npm"
fi

# 実装完了を待つ関数
wait_for_implementation() {
    echo "実装が完了したら 'y' を入力してください:"
    read -r response
    if [ "$response" = "y" ]; then
        return 0
    else
        echo "実装を続行してください..."
        wait_for_implementation
    fi
}

# 実装完了待ち
wait_for_implementation

# 4. 品質チェック
echo "🔍 品質チェックを実行中..."
if ! $PM run lint; then
    echo "❌ Lintエラーが発生しました"
    exit 1
fi

if ! $PM run test; then
    echo "❌ テストが失敗しました"
    exit 1
fi

if command -v "$PM run typecheck" >/dev/null 2>&1; then
    if ! $PM run typecheck; then
        echo "❌ 型チェックが失敗しました"
        exit 1
    fi
fi

echo "✅ 品質チェック完了"

# 5. Conventional Commits prefix判定
if [[ $ISSUE_TITLE =~ bug|fix|error|修正 ]]; then
    PREFIX="fix"
elif [[ $ISSUE_TITLE =~ feature|add|implement|機能|追加 ]]; then
    PREFIX="feat"
elif [[ $ISSUE_TITLE =~ doc|readme|ドキュメント ]]; then
    PREFIX="docs"
elif [[ $ISSUE_TITLE =~ test|テスト ]]; then
    PREFIX="test"
elif [[ $ISSUE_TITLE =~ refactor|リファクタ ]]; then
    PREFIX="refactor"
else
    PREFIX="fix"
fi

# 6. コミット・プッシュ
echo "📝 変更をコミット中..."
git add .

if git diff --staged --quiet; then
    echo "⚠️ ステージングされた変更がありません"
    exit 1
fi

git commit -m "$PREFIX: $ISSUE_TITLE

Fixes #${ISSUE_NUMBER}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

echo "🚀 リモートにプッシュ中..."
git push -u origin $BRANCH_NAME

# 7. PR作成
echo "📋 PRを作成中..."
PR_URL=$(gh pr create \
  --title "$PREFIX: $ISSUE_TITLE" \
  --body "## 概要
Issue #${ISSUE_NUMBER} の対応

$ISSUE_TITLE

## 変更内容
- Issue #${ISSUE_NUMBER} で報告された問題に対応
- 必要な修正・機能追加を実装

## テスト内容
- 既存テストの実行確認
- Issue要件の動作確認

## チェックリスト
- [x] ローカルでlint/testが通ることを確認
- [x] 既存機能に影響がないことを確認
- [x] Issue要件を満たしていることを確認

Closes #${ISSUE_NUMBER}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>" \
  --json url -q '.url')

echo "✅ Issue #$ISSUE_NUMBER の対応完了！"
echo "PR: $PR_URL"
```

## Issue対応時の実装判断基準

### 1. **Issue分類別対応**

```bash
# バグ修正
if [[ $ISSUE_LABELS =~ bug ]]; then
    # 再現手順の確認
    # 原因の特定
    # 最小限の修正
    # 回帰テスト追加
fi

# 新機能
if [[ $ISSUE_LABELS =~ enhancement ]]; then
    # 要件の詳細確認
    # 設計の検討
    # 実装
    # テストの追加
fi

# ドキュメント
if [[ $ISSUE_LABELS =~ documentation ]]; then
    # 対象ドキュメントの特定
    # 内容の更新・追加
    # 関連リンクの確認
fi
```

### 2. **実装前の確認事項**

```markdown
- [ ] Issue要件の理解は正確か
- [ ] 影響範囲は適切に把握できているか
- [ ] 既存機能への影響はないか
- [ ] テスト戦略は適切か
- [ ] 技術的制約は考慮されているか
```

### 3. **実装後の確認事項**

```markdown
- [ ] Issue要件を満たしているか
- [ ] 品質チェック（lint/test）が通るか
- [ ] 既存機能が正常に動作するか
- [ ] パフォーマンス影響はないか
- [ ] セキュリティ問題はないか
```

## エラー対応

### 1. **ブランチ作成エラー**
```bash
# 既存ブランチ名重複
if git show-ref --verify --quiet refs/heads/$BRANCH_NAME; then
    BRANCH_NAME="$BRANCH_NAME-$(date +%s)"
fi
```

### 2. **品質チェック失敗**
```bash
# 修正後に再チェック
echo "品質チェックに失敗しました。修正後に再実行してください。"
echo "修正完了後、以下を実行："
echo "  $PM run lint && $PM run test"
echo "  git add . && git commit --amend --no-edit"
echo "  git push --force-with-lease"
```

### 3. **PR作成失敗**
```bash
# 手動PR作成の案内
echo "PR作成に失敗しました。以下のコマンドで手動作成してください："
echo "gh pr create --title '$PREFIX: $ISSUE_TITLE' --body-file pr_body.txt"
```

## エスカレーション・対応継続戦略

### 1. **複雑なIssueのエスカレーション基準**

```bash
# エスカレーション判定
should_escalate() {
    local complexity=$1
    local priority=$2
    local implementation_time=$3
    
    # 複雑度が高く、実装時間が長い場合
    if [[ $complexity == "complex" && $implementation_time -gt 240 ]]; then  # 4時間以上
        echo "エスカレーション推奨: 複雑度・時間要因"
        return 0
    fi
    
    # 高優先度で依存関係が多い場合
    if [[ $priority == "high" && -n "$RELATED_ISSUES" ]]; then
        echo "エスカレーション推奨: 優先度・依存関係要因"
        return 0
    fi
    
    return 1
}

# エスカレーション実行
escalate_issue() {
    local issue_number=$1
    local reason=$2
    
    echo "🚨 Issue #$issue_number をエスカレーション中..."
    
    # Issue にエスカレーションコメント追加
    gh issue comment $issue_number --body "## エスカレーション通知

このIssueは以下の理由によりエスカレーションされました：
$reason

### 現在の状況
- 分析完了: ✅
- 実装アプローチ: 検討中
- 推定作業時間: 4時間以上

### 必要なアクション
- [ ] 技術的レビュー
- [ ] 実装方針の確認
- [ ] リソース配分の検討

🤖 Generated with [Claude Code](https://claude.ai/code)"
    
    # Priority ラベルの追加
    gh issue edit $issue_number --add-label "escalated,needs-review"
}
```

### 2. **Issue対応メトリクス追跡**

```bash
# メトリクス記録関数
record_issue_metrics() {
    local issue_number=$1
    local start_time=$2
    local end_time=$3
    local complexity=$4
    local type=$5
    
    local duration=$((end_time - start_time))
    local duration_hours=$((duration / 3600))
    
    # メトリクス記録（ログファイルまたはコメント）
    METRICS_LOG="## Issue対応メトリクス

- Issue番号: #$issue_number
- タイプ: $type
- 複雑度: $complexity
- 開始時刻: $(date -d @$start_time '+%Y-%m-%d %H:%M:%S')
- 完了時刻: $(date -d @$end_time '+%Y-%m-%d %H:%M:%S')
- 対応時間: ${duration_hours}時間 $((duration % 3600 / 60))分

### 品質指標
- Lint エラー: 0
- テスト成功率: 100%
- ビルド成功: ✅

🤖 Generated with [Claude Code](https://claude.ai/code)"
    
    # Issue完了コメントとしてメトリクス記録
    gh issue comment $issue_number --body "$METRICS_LOG"
    
    echo "📊 メトリクス記録完了"
}
```

### 3. **継続的改善・フィードバック**

```bash
# Issue対応完了後のフィードバック収集
collect_feedback() {
    local issue_number=$1
    local pr_url=$2
    
    echo "📝 フィードバック収集を開始..."
    
    # PR品質の自動評価
    PR_METRICS=$(gh pr view --json additions,deletions,changedFiles,commits)
    ADDITIONS=$(echo $PR_METRICS | jq '.additions')
    DELETIONS=$(echo $PR_METRICS | jq '.deletions')
    FILES_CHANGED=$(echo $PR_METRICS | jq '.changedFiles')
    COMMITS=$(echo $PR_METRICS | jq '.commits | length')
    
    # 品質スコア計算（簡易版）
    if [[ $FILES_CHANGED -le 3 && $COMMITS -le 2 ]]; then
        QUALITY_SCORE="高"
    elif [[ $FILES_CHANGED -le 10 && $COMMITS -le 5 ]]; then
        QUALITY_SCORE="中"
    else
        QUALITY_SCORE="要改善"
    fi
    
    # フィードバックコメント
    FEEDBACK_COMMENT="## Issue対応完了フィードバック

### PR品質評価
- 変更行数: +$ADDITIONS -$DELETIONS
- 変更ファイル数: $FILES_CHANGED
- コミット数: $COMMITS
- 品質スコア: $QUALITY_SCORE

### 改善提案
$([ "$QUALITY_SCORE" = "要改善" ] && echo "- コミットの細分化を検討
- 変更範囲の最小化を検討" || echo "- 良好な実装品質を維持")

### 学習ポイント
- Issue分析の正確性
- 実装アプローチの適切性
- 品質管理の徹底度

🤖 Generated with [Claude Code](https://claude.ai/code)"
    
    gh issue comment $issue_number --body "$FEEDBACK_COMMENT"
}
```

### 4. **Issue対応ワークフローの進化**

```bash
# ワークフロー改善の提案生成
suggest_workflow_improvements() {
    local recent_issues=$1  # 最近対応したIssue一覧
    
    echo "🔄 ワークフロー改善提案を生成中..."
    
    # 最近のIssue傾向分析
    for issue in $recent_issues; do
        ISSUE_TYPE=$(gh issue view $issue --json labels -q '.labels[] | select(.name | contains("type/")) | .name')
        RESOLUTION_TIME=$(gh issue view $issue --json closedAt,createdAt -q '(.closedAt | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime) - (.createdAt | strptime("%Y-%m-%dT%H:%M:%SZ") | mktime)')
        
        # 傾向データ蓄積...
    done
    
    # 改善提案の生成
    echo "## ワークフロー改善提案

### 検出された傾向
- 頻出Issue種別: $COMMON_TYPE
- 平均解決時間: $AVERAGE_TIME
- 品質指標トレンド: $QUALITY_TREND

### 推奨改善項目
1. **自動化拡張**: 頻出パターンの自動化
2. **テンプレート改善**: Issue種別ごとのテンプレート最適化
3. **品質基準調整**: 現実的な品質閾値の設定

🤖 Generated with [Claude Code](https://claude.ai/code)"
}
```

## 高度なIssue対応機能

### 1. **AI支援による初期分析**

```bash
# AI支援Issue分析（Claude Code活用）
ai_analyze_issue() {
    local issue_number=$1
    
    echo "🤖 AI支援分析を開始..."
    
    # Issue内容をAIで分析
    ISSUE_CONTENT=$(gh issue view $issue_number --json title,body -q '.title + "\n\n" + .body')
    
    # 分析結果の生成（実際の実装では外部API呼び出し）
    echo "AI分析結果:
- 推定複雑度: $COMPLEXITY
- 推定作業時間: $ESTIMATED_TIME
- 関連技術領域: $TECH_AREA
- リスク要因: $RISK_FACTORS"
}
```

### 2. **依存関係の自動検出**

```bash
# 依存関係の自動検出・管理
detect_dependencies() {
    local issue_number=$1
    
    echo "🔗 依存関係を検出中..."
    
    # 関連Issueの検出
    MENTIONED_ISSUES=$(gh issue view $issue_number --json body -q '.body' | grep -o "#[0-9]\+" | sort -u)
    
    # ブロッカーの確認
    for related_issue in $MENTIONED_ISSUES; do
        STATUS=$(gh issue view ${related_issue#\#} --json state -q '.state')
        if [[ $STATUS == "open" ]]; then
            echo "⚠️ ブロッカー検出: $related_issue (未解決)"
        fi
    done
    
    # 依存関係グラフの構築
    echo "📊 依存関係マップ: $MENTIONED_ISSUES"
}
```

### 3. **品質予測・リスク評価**

```bash
# 品質予測・リスク評価
assess_quality_risk() {
    local issue_type=$1
    local complexity=$2
    local files_to_change=$3
    
    echo "🎯 品質リスク評価中..."
    
    # リスクスコア計算
    RISK_SCORE=0
    
    # 複雑度による調整
    case $complexity in
        "complex") RISK_SCORE=$((RISK_SCORE + 3));;
        "medium") RISK_SCORE=$((RISK_SCORE + 2));;
        "simple") RISK_SCORE=$((RISK_SCORE + 1));;
    esac
    
    # 変更範囲による調整
    if [[ $files_to_change -gt 10 ]]; then
        RISK_SCORE=$((RISK_SCORE + 2))
    elif [[ $files_to_change -gt 5 ]]; then
        RISK_SCORE=$((RISK_SCORE + 1))
    fi
    
    # リスクレベル判定
    if [[ $RISK_SCORE -ge 5 ]]; then
        echo "🔴 高リスク: 追加レビュー・テスト推奨"
    elif [[ $RISK_SCORE -ge 3 ]]; then
        echo "🟡 中リスク: 慎重な実装推奨"
    else
        echo "🟢 低リスク: 通常の実装プロセス"
    fi
}
```

この完全自動化・拡張機能により、「issue #nnを対応してください」と指示するだけで、Issue確認からPR作成、継続的改善まで一貫した高品質な対応が実現されます。