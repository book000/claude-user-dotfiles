# Issue対応ワークフロー

## 基本原則

「issue #nnを対応してください」と指示された場合の完全自動化フロー

## Issue対応の完全フロー

### 1. **Issue内容確認**

```bash
# Issue詳細の取得・確認
gh issue view {ISSUE_NUMBER}

# Issue内容の理解
# - 問題の概要
# - 再現手順
# - 期待される動作
# - 技術的要件
```

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

### 3. **実装・修正実行**

```bash
# Issue内容に基づく実装
# - バグ修正
# - 新機能開発  
# - ドキュメント更新
# - テスト追加
# - リファクタリング
```

### 4. **品質チェック**

```bash
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

# 品質チェック実行
$PM run lint
$PM run test
if command -v "$PM run typecheck" >/dev/null 2>&1; then
    $PM run typecheck
fi

# ビルド確認（必要に応じて）
if grep -q '"build"' package.json; then
    $PM run build
fi
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

この完全自動化により、「issue #nnを対応してください」と指示するだけで、Issue確認からPR作成までが一貫して実行されます。