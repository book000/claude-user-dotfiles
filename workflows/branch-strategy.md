# ブランチ戦略

## 基本方針

- **upstream優先**: upstreamが存在する場合は、upstreamのメインブランチをベースとする
- **メインブランチ自動判定**: main/masterブランチを自動的に判定
- **no-track**: 作業ブランチは追跡しない設定で作成
- **Conventional Commits形式**: ブランチ名は`<type>/<description>`形式

## Claude Codeによる自動ブランチ作成

### **基本フロー**
Claude Codeが以下を自動実行：
1. upstream/origin判定とメインブランチ取得
2. Issueタイトルから適切なタイプを判定
3. Conventional Commits形式のブランチ名生成
4. no-track設定でブランチ作成・切り替え

### **リモート判定ロジック**
```
1. upstreamが存在するかチェック
2. 存在する場合: upstream を使用
3. 存在しない場合: origin を使用
4. メインブランチ（main/master）を自動判定
```

### **ブランチタイプ判定**

#### **基本判定ルール**
Issueタイトルから以下のパターンで自動判定：

**fix/判定（バグ修正）:**
- 英語: `bug|fix|error|crash|broken|issue|problem`
- 日本語: `修正|バグ|エラー|不具合|問題|障害|直す`
- 混在例: `fix バグ`, `error 修正`, `不具合 fix`

**feat/判定（新機能）:**
- 英語: `feature|add|implement|create|new|introduce`
- 日本語: `機能|追加|実装|作成|新規|導入|開発`
- 混在例: `add 機能`, `新機能 implementation`, `feature 追加`

**docs/判定（ドキュメント）:**
- 英語: `doc|docs|readme|documentation|guide|manual`
- 日本語: `ドキュメント|文書|説明|手順|マニュアル|README`
- 混在例: `docs 更新`, `ドキュメント update`, `README 修正`

**test/判定（テスト）:**
- 英語: `test|testing|spec|unit|integration|e2e`
- 日本語: `テスト|試験|検証|単体|結合|E2E`
- 混在例: `test 追加`, `テスト implementation`, `unit テスト`

**refactor/判定（リファクタリング）:**
- 英語: `refactor|refactoring|cleanup|reorganize|restructure`
- 日本語: `リファクタ|リファクタリング|整理|再構成|構造変更`
- 混在例: `refactor コード`, `リファクタリング cleanup`

**style/判定（スタイル）:**
- 英語: `style|format|lint|prettier|eslint|codestyle`
- 日本語: `スタイル|フォーマット|整形|コード規約|Lint`

**perf/判定（パフォーマンス）:**
- 英語: `perf|performance|optimization|optimize|speed|faster`
- 日本語: `パフォーマンス|性能|最適化|高速化|速度改善`

#### **デフォルト判定の改善**
複数パターンに一致する場合の優先順位：
1. `feat/` > `fix/` > `docs/` > `test/` > `refactor/` > `style/` > `perf/`
2. 日本語キーワードが含まれる場合は日本語を優先
3. どのパターンにも一致しない場合は `feat/`（新機能として扱う）

### **ブランチ名生成ルール**
```
形式: <type>/<description>

例:
- feat/user-authentication
- fix/password-validation
- docs/api-documentation
- refactor/database-queries
- test/user-registration
- style/eslint-rules
- perf/query-optimization
```

### **説明部分の生成**
Issueタイトルから以下の処理で生成：
1. 英数字以外をハイフンに変換
2. 連続ハイフンを単一に統一
3. 小文字に変換
4. 先頭・末尾のハイフンを除去
5. 30文字以内に制限

## ブランチ作成の実行例

### **Issue #123 "ユーザー認証機能の追加"の場合**
```
判定結果:
- タイプ: feat (「追加」から判定)
- 説明: user-authentication-function (タイトルから生成)
- ブランチ名: feat/user-authentication-function
- ベース: upstream/main (upstreamが存在する場合)

実行コマンド相当:
git checkout -b feat/user-authentication-function --no-track upstream/main
```

### **Issue #456 "ログインバグの修正"の場合**
```
判定結果:
- タイプ: fix (「バグ」「修正」から判定)
- 説明: login-bug-fix
- ブランチ名: fix/login-bug-fix
- ベース: origin/master (upstreamが存在しない場合)

実行コマンド相当:
git checkout -b fix/login-bug-fix --no-track origin/master
```

## 手動ブランチ作成が必要な場合

Claude Codeを使用せず手動でブランチを作成する特殊ケース向け：

### 手動ブランチ作成の基本コマンド

```bash
#!/bin/bash
# manual_branch_creation.sh - 手動ブランチ作成スクリプト

TYPE=${1:-"feat"}
DESCRIPTION=${2:-"example-feature"}

if [ "$DESCRIPTION" = "example-feature" ]; then
    echo "Usage: $0 <type> <description>"
    echo "Types: feat, fix, docs, refactor, test, style, perf"
    echo "Example: $0 feat user-authentication"
    exit 1
fi

# リモート判定
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
    echo "✅ upstream remote detected"
else
    REMOTE="origin"
    echo "📍 Using origin remote"
fi

# メインブランチ判定
MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)
echo "🌟 Main branch: $REMOTE/$MAIN_BRANCH"

# ブランチ作成
BRANCH_NAME="$TYPE/$DESCRIPTION"
git fetch --all
git checkout -b $BRANCH_NAME --no-track $REMOTE/$MAIN_BRANCH

echo "🚀 Created and switched to: $BRANCH_NAME (based on $REMOTE/$MAIN_BRANCH)"
git status
```

### 使用場面
- Issue以外からのブランチ作成が必要な場合
- 特殊な命名規則が必要な場合
- 複数のブランチを連続して作成する場合

## 注意事項

### **upstream優先の理由**
- フォークされたリポジトリでの最新情報取得
- 本家リポジトリとの同期維持
- 競合の早期発見・解決

### **no-track設定の理由**
- 作業ブランチの独立性確保
- プッシュ時の明示的な設定必要
- 意図しないプッシュの防止

### **命名規則の統一**
- プロジェクト全体での一貫性
- 自動化ツールでの解析容易性
- チームメンバーの理解促進

### **メインブランチ判定の重要性**
- main/masterの違いへの対応
- プロジェクト固有設定への自動適応
- 手動設定の不要化

## トラブルシューティング

### **リモートが見つからない場合**
- `git remote -v` でリモート一覧確認
- 必要に応じて `git remote add upstream <URL>` でupstream追加

### **メインブランチ判定エラーの場合**
- `git branch -r` でリモートブランチ確認
- 明示的にブランチ指定: `git checkout -b feature/my-feature --no-track upstream/main`

### **ブランチ名重複の場合**
- 既存ブランチ名に日時追加: `feature/my-feature-20250616`
- より具体的な説明に変更: `feature/user-authentication-v2`

この自動化により、Issue対応開始時に適切なブランチが自動作成され、一貫した命名規則が維持されます。