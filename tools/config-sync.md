# Claude設定同期管理

## 基本原則

- **変更時自動コミット**: ~/.claude設定変更時は必ずコミット・プッシュ
- **定期的な同期**: 他環境での変更を取り込むため定期的にpull実行
- **履歴管理**: 設定変更の履歴を適切に記録

## 設定変更時のワークフロー

### 1. **変更検出・コミット**

```bash
# ~/.claude での作業後、変更があれば自動コミット
cd ~/.claude

# 変更の確認
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "🔍 Claude設定の変更を検出しました"
    
    # 変更内容の表示
    git status --porcelain
    
    # 自動コミット・プッシュ
    git add .
    git commit -m "update: Claude設定を更新

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    git push
    echo "✅ Claude設定の同期完了"
else
    echo "📋 Claude設定に変更はありません"
fi
```

### 2. **変更タイプ別コミットメッセージ**

```bash
# 新しいワークフロー追加
git commit -m "feat: 新しいワークフロー (xxx) を追加"

# 既存設定の修正
git commit -m "fix: ブランチ戦略の設定を修正"

# ツール使用指針の更新
git commit -m "update: パッケージマネージャー対応を改善"

# ドキュメント更新
git commit -m "docs: README.mdの使用方法を更新"

# 設定の削除・非推奨化
git commit -m "remove: 非推奨なワークフローを削除"
```

## 定期的な同期

### 1. **セッション開始時のpull**

```bash
# Claude Code使用開始時の自動同期
cd ~/.claude

echo "🔄 Claude設定を同期中..."

# リモートの最新を取得
if git pull --rebase origin main; then
    echo "✅ Claude設定の同期完了"
else
    echo "⚠️ 同期に問題が発生しました。手動で確認してください。"
fi
```

### 2. **定期的な同期チェック**

```bash
# 1日1回程度の自動チェック
check_claude_config_sync() {
    cd ~/.claude
    
    # 最後のpullから24時間以上経過しているかチェック
    LAST_PULL=$(git log --grep="pull" --format="%ct" -1 2>/dev/null || echo "0")
    CURRENT_TIME=$(date +%s)
    DIFF=$((CURRENT_TIME - LAST_PULL))
    
    # 24時間 = 86400秒
    if [ $DIFF -gt 86400 ]; then
        echo "🔄 24時間以上同期していません。Claude設定を同期します..."
        git pull --rebase origin main
    fi
}
```

## 自動化スクリプト

### 1. **設定変更検出・自動コミット**

```bash
#!/bin/bash
# sync_claude_config.sh - Claude設定自動同期スクリプト

CLAUDE_DIR="$HOME/.claude"

cd "$CLAUDE_DIR" || {
    echo "❌ ~/.claude ディレクトリが見つかりません"
    exit 1
}

# Gitリポジトリの確認
if [ ! -d ".git" ]; then
    echo "❌ ~/.claude はGitリポジトリではありません"
    exit 1
fi

echo "🔍 Claude設定の変更をチェック中..."

# 変更の確認
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "📝 変更が検出されました:"
    git status --short
    
    # 変更内容の簡単な分析
    ADDED_FILES=$(git status --porcelain | grep "^A" | wc -l)
    MODIFIED_FILES=$(git status --porcelain | grep "^.M" | wc -l)
    DELETED_FILES=$(git status --porcelain | grep "^.D" | wc -l)
    
    # 自動的なコミットメッセージ生成
    if [ $ADDED_FILES -gt 0 ] && [ $MODIFIED_FILES -eq 0 ] && [ $DELETED_FILES -eq 0 ]; then
        COMMIT_MSG="feat: Claude設定に新しいファイルを追加"
    elif [ $ADDED_FILES -eq 0 ] && [ $MODIFIED_FILES -gt 0 ] && [ $DELETED_FILES -eq 0 ]; then
        COMMIT_MSG="update: Claude設定を更新"
    elif [ $DELETED_FILES -gt 0 ]; then
        COMMIT_MSG="remove: Claude設定ファイルを削除"
    else
        COMMIT_MSG="update: Claude設定を変更"
    fi
    
    # ステージング・コミット
    git add .
    git commit -m "$COMMIT_MSG

Changes:
- Added: $ADDED_FILES files
- Modified: $MODIFIED_FILES files  
- Deleted: $DELETED_FILES files

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
    
    # プッシュ
    if git push; then
        echo "✅ Claude設定の同期完了"
    else
        echo "❌ プッシュに失敗しました"
        exit 1
    fi
else
    echo "📋 Claude設定に変更はありません"
fi

# リモートからのpull確認
echo "🔄 リモートの変更をチェック中..."
git fetch

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "📥 リモートに新しい変更があります。同期中..."
    if git pull --rebase; then
        echo "✅ リモート変更の同期完了"
    else
        echo "❌ リモート同期に失敗しました"
        exit 1
    fi
else
    echo "📋 リモートに新しい変更はありません"
fi

echo "🎉 Claude設定の同期処理完了"
```

### 2. **Claude Code使用時の自動同期**

```bash
#!/bin/bash
# claude_startup_sync.sh - Claude Code起動時の同期

echo "🚀 Claude Code 起動前チェック..."

# Claude設定の同期
cd ~/.claude

echo "🔄 Claude設定を同期中..."

# まずリモートをチェック
git fetch

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse @{u} 2>/dev/null)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "📥 リモートの変更を取得中..."
    if git pull --rebase; then
        echo "✅ 設定同期完了"
    else
        echo "⚠️ 同期エラー。手動確認が必要です。"
    fi
else
    echo "📋 設定は最新です"
fi

echo "🎯 Claude Code 使用準備完了"
```

## トラブルシューティング

### 1. **コンフリクト解決**

```bash
# マージコンフリクトが発生した場合
cd ~/.claude

echo "⚠️ マージコンフリクトを検出しました"

# コンフリクトファイルの確認
git status | grep "both modified"

echo "手動でコンフリクトを解決してください:"
echo "1. コンフリクトファイルを編集"
echo "2. git add <resolved-files>"
echo "3. git rebase --continue"
echo "4. git push"
```

### 2. **同期失敗時の対処**

```bash
# プッシュ失敗時の対処
recover_sync_failure() {
    cd ~/.claude
    
    echo "🔧 同期失敗の復旧を試行中..."
    
    # リモートの状態確認
    git fetch
    
    # リベースで解決を試行
    if git pull --rebase; then
        echo "✅ リベースで復旧成功"
        git push
    else
        echo "❌ 手動での解決が必要です"
        echo "以下を実行してください:"
        echo "  cd ~/.claude"
        echo "  git status"
        echo "  git rebase --abort  # 必要に応じて"
        echo "  git pull --rebase"
    fi
}
```

### 3. **設定ファイルの破損対応**

```bash
# 設定ファイルが破損した場合の復旧
restore_claude_config() {
    cd ~/.claude
    
    echo "🔧 Claude設定の復旧中..."
    
    # 直前のコミットに戻す
    git reset --hard HEAD~1
    
    # 必要に応じてリモートから強制取得
    # git reset --hard origin/main
    
    echo "✅ 設定を復旧しました"
}
```

## フック設定

### 1. **Git Hooks設定**

```bash
# ~/.claude/.git/hooks/post-commit
#!/bin/bash
echo "📤 Claude設定の変更をプッシュ中..."
git push
```

### 2. **Claude Code統合**

```bash
# Claude Code使用後の自動同期をシェル関数として設定
claude_config_auto_sync() {
    if [ -d "$HOME/.claude/.git" ]; then
        cd "$HOME/.claude"
        
        # 変更があれば自動コミット・プッシュ
        if ! git diff --quiet; then
            git add .
            git commit -m "update: Claude設定自動同期 $(date '+%Y-%m-%d %H:%M:%S')"
            git push
        fi
        
        cd - > /dev/null
    fi
}

# シェル終了時に実行
trap claude_config_auto_sync EXIT
```

## ベストプラクティス

### 1. **コミット頻度**
- 設定変更後は即座にコミット
- 小さな変更でも履歴として残す
- 定期的な同期チェック

### 2. **コミットメッセージ**
- Conventional Commits形式を使用
- 変更内容を具体的に記述
- 自動生成であることを明記

### 3. **ブランチ戦略**
- 基本的にmainブランチで直接作業
- 大きな変更時のみfeatureブランチ使用
- 複数環境での同期を優先

### 4. **セキュリティ**
- 機密情報は.gitignoreで確実に除外
- 公開リポジトリでの共有に注意
- 認証情報の漏洩防止

この設定により、Claude設定の変更が自動的に記録・同期され、複数環境での一貫性が保たれます。