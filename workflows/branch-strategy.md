# ブランチ戦略

## 基本方針

- **upstream優先**: upstreamが存在する場合は、upstreamのメインブランチをベースとする
- **メインブランチ自動判定**: main/masterブランチを自動的に判定
- **no-track**: 作業ブランチは追跡しない設定で作成

## 実装手順

### 1. メインブランチの判定

```bash
# upstreamが存在するかチェック
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
else
    REMOTE="origin"
fi

# メインブランチを自動判定
MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)
echo "Using $REMOTE/$MAIN_BRANCH as base branch"
```

### 2. ブランチ作成

```bash
# 作業ブランチを作成（no-track）- Conventional Commits形式
git checkout -b <type>/<description> --no-track $REMOTE/$MAIN_BRANCH

# 例:
# feat/user-authentication
# fix/password-validation
# docs/api-documentation
# refactor/database-queries
```

### 3. 完全なワークフロー例

```bash
#!/bin/bash

# リモート情報の更新
git fetch --all

# upstreamが存在するかチェック
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
    echo "✅ upstream remote detected"
else
    REMOTE="origin"
    echo "📍 Using origin remote"
fi

# メインブランチを自動判定
MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)
echo "🌟 Main branch: $REMOTE/$MAIN_BRANCH"

# ブランチタイプの選択
echo "変更タイプを選択してください:"
echo "1) feat - 新機能"
echo "2) fix - バグ修正"
echo "3) docs - ドキュメント"
echo "4) refactor - リファクタリング"
echo "5) test - テスト"
echo "6) style - スタイル修正"
echo "7) perf - パフォーマンス改善"
read -r type_choice

case $type_choice in
    1) TYPE="feat";;
    2) TYPE="fix";;
    3) TYPE="docs";;
    4) TYPE="refactor";;
    5) TYPE="test";;
    6) TYPE="style";;
    7) TYPE="perf";;
    *) echo "Type manually:"; read -r TYPE;;
esac

# ブランチ説明の入力
echo "Enter branch description (e.g., user-authentication):"
read DESCRIPTION

# ブランチ名生成
BRANCH_NAME="$TYPE/$DESCRIPTION"

# ブランチ作成と切り替え
git checkout -b $BRANCH_NAME --no-track $REMOTE/$MAIN_BRANCH
echo "🚀 Created and switched to: $BRANCH_NAME (based on $REMOTE/$MAIN_BRANCH)"

# 現在のブランチ状態を確認
git status
```

## 注意事項

- **upstream優先**: フォークされたリポジトリでは、必ずupstreamから最新を取得する
- **no-track設定**: 作業ブランチは意図的に追跡しない設定で作成
- **命名規則**: `<type>/<description>` 形式（Conventional Commits準拠）
- **定期同期**: 長期間の作業では定期的にメインブランチと同期

## トラブルシューティング

### リモートが見つからない場合

```bash
# リモート一覧確認
git remote -v

# upstream追加
git remote add upstream https://github.com/original-owner/repo.git
```

### メインブランチ判定エラーの場合

```bash
# 手動でメインブランチを確認
git branch -r

# 明示的にブランチ指定
git checkout -b feature/my-feature --no-track upstream/main
```
