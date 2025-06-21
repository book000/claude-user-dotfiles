# ワークフロー詳細ガイド

## 🎯 Issue対応の完全自動化フロー

### 基本コマンド
```bash
"issue #nn を対応してください"
```

### 実行フロー詳細
```bash
# 1. Issue情報取得
gh issue view {nn} --json title,body,labels

# 2. ブランチ戦略の実行
# upstream/origin判定
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
else
    REMOTE="origin"
fi

# メインブランチ取得
MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)

# ブランチ作成
BRANCH_DESC=$(echo "$ISSUE_TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | cut -c1-30)
git checkout -b issue-${nn}-${BRANCH_DESC} --no-track $REMOTE/$MAIN_BRANCH

# 3. 実装作業
# - Issue要件の分析と実装
# - 必要なファイルの修正・追加
# - テストの追加・修正

# 4. 品質チェック（必須）
# パッケージマネージャー判定
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn"
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

# 品質チェック実行
$PM run lint && $PM run test
if command -v "$PM run typecheck" >/dev/null 2>&1; then
    $PM run typecheck
fi

# 5. コミット
# Conventional Commits prefix判定
if [[ $ISSUE_TITLE =~ bug|fix|error|修正 ]]; then PREFIX="fix"
elif [[ $ISSUE_TITLE =~ feature|add|implement|機能|追加 ]]; then PREFIX="feat"
elif [[ $ISSUE_TITLE =~ doc|readme|ドキュメント ]]; then PREFIX="docs"
elif [[ $ISSUE_TITLE =~ test|テスト ]]; then PREFIX="test"
elif [[ $ISSUE_TITLE =~ refactor|リファクタ ]]; then PREFIX="refactor"
else PREFIX="fix"; fi

git add .
git commit -m "$PREFIX: $ISSUE_TITLE

Fixes #${nn}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 6. プッシュとPR作成
git push -u origin issue-${nn}-${BRANCH_DESC}

gh pr create \
  --title "$PREFIX: $ISSUE_TITLE" \
  --body "## 概要
Issue #${nn} の対応

$ISSUE_TITLE

## 変更内容
- Issue #${nn} で報告された問題に対応
- 必要な修正・機能追加を実装

## テスト内容
- 既存テストの実行確認
- Issue要件の動作確認

## チェックリスト
- [x] ローカルでlint/testが通ることを確認
- [x] 既存機能に影響がないことを確認
- [x] Issue要件を満たしていることを確認

Closes #${nn}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## 🔄 レビュー対応プロセス

### レビュー対応の基本コマンド
```bash
"レビューに対応してください"
```

### 必須7ステップ管理
```json
[
  {"id": "1", "content": "レビュー情報収集（PR・コメント確認）", "status": "pending", "priority": "high"},
  {"id": "2", "content": "Copilotコメント対応（適切/不適切判定・実装）", "status": "pending", "priority": "medium"},
  {"id": "3", "content": "book000コメント対応（全指摘事項への実装）", "status": "pending", "priority": "high"},
  {"id": "4", "content": "品質チェック実行（lint/test/typecheck）", "status": "pending", "priority": "medium"},
  {"id": "5", "content": "【重要】修正内容のコミット・プッシュ", "status": "pending", "priority": "high"},
  {"id": "6", "content": "Review thread解決（GraphQL API）", "status": "pending", "priority": "medium"},
  {"id": "7", "content": "完了報告コメント追加", "status": "pending", "priority": "low"}
]
```

### レビュー対応完了チェックリスト
- [ ] **1. コメント収集・確認**
  - [ ] `gh pr view [PR番号] --comments` 実行
  - [ ] `gh api repos/[owner]/[repo]/pulls/[PR番号]/comments` 実行
  - [ ] Copilot・Human両方のコメント確認

- [ ] **2. 修正実装**
  - [ ] 各指摘事項への対応実装
  - [ ] サジェストコメントの適用
  - [ ] 品質チェック（lint/test）実行

- [ ] **3. 【重要】コミット・プッシュ**
  - [ ] `git add` でファイルステージング
  - [ ] `git commit` でコミット作成
  - [ ] `git push` でリモートにプッシュ
  - [ ] **この手順を忘れやすいので要注意**

- [ ] **4. Review Thread解決**
  - [ ] GraphQL APIでreview threads取得
  - [ ] `resolveReviewThread` mutation実行
  - [ ] 全threadのresolve確認

### Copilotレビューの取得
```bash
# 1. PR情報取得
REPO_INFO=$(gh repo view --json owner,name)
OWNER=$(echo $REPO_INFO | jq -r '.owner.login')
REPO=$(echo $REPO_INFO | jq -r '.name')

# 2. Copilotレビューコメント取得
gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments | \
  jq -r '.[] | select(.user.login == "github-copilot[bot]") | 
  "File: \(.path)\nLine: \(.line // "general")\nComment: \(.body)\n---"'

# 3. 通常のレビューコメント取得
gh pr view $PR_NUMBER --json reviews | \
  jq -r '.reviews[] | select(.author.login == "github-copilot[bot]") | 
  "Review ID: \(.id)\nBody: \(.body)\n---"'
```

### Humanレビュー対応
```bash
# book000からのレビューコメント取得
gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments | \
  jq -r '.[] | select(.user.login == "book000") | 
  "File: \(.path)\nLine: \(.line)\nBody: \(.body)\n---"'

# 対応後は「Resolve conversation」で解決
```

## 📋 PR作成の標準テンプレート

### Conventional Commits タイプ一覧
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント変更
- **style**: コードスタイル修正
- **refactor**: リファクタリング
- **test**: テスト追加・修正
- **chore**: ビルド・設定変更
- **perf**: パフォーマンス改善

### PR本文テンプレート
```markdown
## 概要
変更の目的と背景を日本語で説明

## 変更内容
- 追加した機能や修正した内容
- 影響範囲の説明
- 技術的な詳細

## テスト内容
- 実施したテストの内容
- 確認した動作
- テストケースの追加有無

## チェックリスト
- [ ] ローカルでlint/testが通ることを確認
- [ ] 既存機能に影響がないことを確認
- [ ] ドキュメントの更新（必要に応じて）

Closes #{issue_number}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## ⚙️ 品質チェックの自動化

### コミット前チェックスクリプト
```bash
#!/bin/bash
# quality-check.sh

echo "🔍 品質チェックを開始..."

# パッケージマネージャー判定
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn"
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

echo "📦 使用パッケージマネージャー: $PM"

# Lint実行
echo "📝 Lintチェック..."
if ! $PM run lint; then
    echo "❌ Lintエラーが発生しました"
    exit 1
fi

# テスト実行
echo "🧪 テスト実行..."
if ! $PM run test; then
    echo "❌ テストが失敗しました"
    exit 1
fi

# 型チェック
if grep -q '"typecheck"' package.json; then
    echo "📋 型チェック..."
    if ! $PM run typecheck; then
        echo "❌ 型チェックが失敗しました"
        exit 1
    fi
fi

# ビルドチェック（必要に応じて）
if grep -q '"build"' package.json; then
    echo "🏗️ ビルドチェック..."
    if ! $PM run build; then
        echo "❌ ビルドが失敗しました"
        exit 1
    fi
fi

echo "✅ 全ての品質チェックが完了しました"
```

## 🔄 設定同期の自動化

### ~/.claude変更時の自動同期
```bash
# ~/.claude ディレクトリで変更後
cd ~/.claude

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "🔍 Claude設定の変更を検出"
    
    # 変更タイプの判定
    ADDED_FILES=$(git status --porcelain | grep "^A" | wc -l)
    MODIFIED_FILES=$(git status --porcelain | grep "^.M" | wc -l)
    DELETED_FILES=$(git status --porcelain | grep "^.D" | wc -l)
    
    # コミットメッセージ生成
    if [ $ADDED_FILES -gt 0 ] && [ $MODIFIED_FILES -eq 0 ]; then
        MSG="feat: Claude設定に新しいファイルを追加"
    elif [ $MODIFIED_FILES -gt 0 ] && [ $ADDED_FILES -eq 0 ]; then
        MSG="update: Claude設定を更新"
    elif [ $DELETED_FILES -gt 0 ]; then
        MSG="remove: Claude設定ファイルを削除"
    else
        MSG="update: Claude設定を変更"
    fi
    
    git add .
    git commit -m "$MSG

Changes:
- Added: $ADDED_FILES files
- Modified: $MODIFIED_FILES files
- Deleted: $DELETED_FILES files

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    git push
    echo "✅ Claude設定の同期完了"
fi
```

### セッション開始時の同期
```bash
# Claude Code使用開始時
cd ~/.claude

echo "🔄 Claude設定を同期中..."
git fetch

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "📥 リモートの変更を取得中..."
    git pull --rebase
    echo "✅ 設定同期完了"
else
    echo "📋 設定は最新です"
fi
```