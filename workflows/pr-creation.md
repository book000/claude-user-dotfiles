# プルリクエスト作成指針

## 基本原則

- **Issue連携**: 関連するIssueを自動クローズするキーワードを使用
- **日本語本文**: PR本文は日本語で記述
- **Conventional Commits**: タイトルはマージ時のコミットメッセージとして適切な形式
- **継続的更新**: PR本文は実装内容の変更に応じて適宜更新

## PR作成時の必須要素

### 1. **タイトル設定**

Conventional Commits形式でタイトルを設定：

```
# 形式
<type>(<scope>): <description>

# 例
feat: ユーザー認証機能を追加
fix: パスワードバリデーションのバグを修正
docs: README.mdのセットアップ手順を更新
refactor: API通信処理をリファクタリング
test: ユーザー登録のテストケースを追加
style: ESLintルール違反を修正
perf: データベースクエリのパフォーマンスを改善
```

### 2. **Issue連携キーワード**

PR本文に以下のキーワードを含めて、マージ時の自動クローズを設定：

```markdown
# 単一Issue
Closes #123

# 複数Issue
Closes #123
Closes #456

# その他のキーワード
Fixes #123        # バグ修正
Resolves #123     # 課題解決
Closes #123       # 一般的なクローズ
```

### 3. **PR本文構造（日本語）**

```markdown
## 概要
この変更の目的と背景を日本語で説明

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

Closes #123
```

## ghコマンドでのPR作成

### 1. **基本的なPR作成**

```bash
# Conventional Commits形式のタイトルで作成
gh pr create \
  --title "feat: ユーザー認証機能を追加" \
  --body "$(cat <<'EOF'
## 概要
ユーザーがログイン・ログアウトできる認証機能を実装しました。

## 変更内容
- JWT認証の実装
- ログイン・ログアウトAPI
- 認証ミドルウェアの追加
- フロントエンドの認証フォーム

## テスト内容
- 単体テスト: 認証ロジック
- 統合テスト: APIエンドポイント
- E2Eテスト: ログインフロー

## チェックリスト
- [x] ローカルでlint/testが通ることを確認
- [x] 既存機能に影響がないことを確認
- [x] APIドキュメントを更新

Closes #42
EOF
)"
```

### 2. **複数Issue対応の場合**

```bash
gh pr create \
  --title "fix: ユーザー管理の複数バグを修正" \
  --body "$(cat <<'EOF'
## 概要
ユーザー管理機能で報告されていた複数のバグを修正しました。

## 変更内容
- パスワードバリデーションロジックの修正
- ユーザー削除時のエラーハンドリング改善
- プロファイル更新時の型チェック強化

## テスト内容
- 各バグケースの回帰テスト
- 関連機能の動作確認

Closes #123
Closes #124
Closes #125
EOF
)"
```

### 3. **作業中PR（Draft）の作成**

```bash
gh pr create \
  --draft \
  --title "feat: データ可視化機能を実装（WIP）" \
  --body "$(cat <<'EOF'
## 概要
データの可視化機能を実装中です。

## 変更内容（予定）
- [ ] Chart.jsの統合
- [ ] データAPIの実装
- [ ] ダッシュボードUI

## 進捗
- [x] 基本的なチャート表示
- [ ] データフィルタリング
- [ ] レスポンシブ対応

関連 #78
EOF
)"
```

## Conventional Commits タイプ一覧

### 1. **主要タイプ**
- **feat**: 新機能追加
- **fix**: バグ修正
- **docs**: ドキュメント変更
- **style**: コードスタイル修正（機能変更なし）
- **refactor**: リファクタリング（機能変更なし）
- **test**: テスト追加・修正
- **chore**: ビルド・設定変更

### 2. **追加タイプ**
- **perf**: パフォーマンス改善
- **ci**: CI/CD設定変更
- **build**: ビルドシステム変更
- **revert**: 変更の取り消し

### 3. **スコープ例**
```
feat(auth): ログイン機能を追加
fix(api): ユーザー取得APIのエラーを修正
docs(readme): インストール手順を更新
test(user): ユーザー作成のテストを追加
```

## 自動化スクリプト例

### 1. **PR作成ヘルパースクリプト**

```bash
#!/bin/bash
# create_pr.sh - PR作成支援スクリプト（説明用）
# 注意: このスクリプトは概念説明用です

echo "🚀 PR作成ヘルパー"

# Issue番号の取得（コマンドライン引数推奨）
ISSUES=${1:-"123"}  # 例: ./create_pr.sh "123 124"
if [ "$ISSUES" = "123" ]; then
    echo "Usage: $0 'issue_numbers'"
    echo "Example: $0 '123 124 125'"
    exit 1
fi

# PRタイプの判定（自動化推奨）
# 実装例: Issue内容から自動判定
TYPE=${2:-"feat"}  # デフォルトまたはコマンドライン引数

# 概要の生成（Issue情報から自動生成）
DESCRIPTION=${3:-"Issue対応"}  # 実際にはIssueタイトルを使用

# タイトル生成
TITLE="$TYPE: $description"

# Issue連携の生成
CLOSES_SECTION=""
if [ -n "$issues" ]; then
    for issue in $issues; do
        CLOSES_SECTION="$CLOSES_SECTION\nCloses #$issue"
    done
fi

# PR本文テンプレート生成
BODY="## 概要
$description

## 変更内容
- 

## テスト内容
- 

## チェックリスト
- [ ] ローカルでlint/testが通ることを確認
- [ ] 既存機能に影響がないことを確認
- [ ] ドキュメントの更新（必要に応じて）
$CLOSES_SECTION"

# PR作成
echo "📝 以下の内容でPRを作成します:"
echo "タイトル: $TITLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

gh pr create --title "$TITLE" --body "$BODY"

echo "✅ PR作成完了！"
```

### 2. **Issue確認付きPR作成**

```bash
#!/bin/bash
# create_pr_with_issue_check.sh

# 現在のブランチから関連Issueを推測
BRANCH_NAME=$(git branch --show-current)
if [[ $BRANCH_NAME =~ issue-([0-9]+) ]]; then
    ISSUE_NUM="${BASH_REMATCH[1]}"
    echo "ブランチ名から Issue #$ISSUE_NUM を検出しました"
    
    # Issueの存在確認
    if gh issue view "$ISSUE_NUM" >/dev/null 2>&1; then
        echo "✅ Issue #$ISSUE_NUM 確認完了"
        ISSUE_TITLE=$(gh issue view "$ISSUE_NUM" --json title -q '.title')
        echo "Issue: $ISSUE_TITLE"
        
        # PR作成
        gh pr create \
            --title "fix: $ISSUE_TITLE" \
            --body "$(cat <<EOF
## 概要
Issue #$ISSUE_NUM の対応

## 変更内容
- 

## テスト内容
- 

Closes #$ISSUE_NUM
EOF
)"
    else
        echo "❌ Issue #$ISSUE_NUM が見つかりません"
        exit 1
    fi
else
    echo "ブランチ名からIssue番号を検出できませんでした"
    echo "手動でPR作成を続行してください"
fi
```

## PR本文・タイトルの継続的更新

### 1. **更新が必要なタイミング**

- **新しいコミット追加時**: 実装内容の変更を反映
- **レビュー指摘対応時**: 修正内容を本文に追記
- **テスト結果に応じた修正時**: テスト内容・結果の更新
- **スコープ変更時**: 変更範囲の拡大・縮小の反映
- **設計変更時**: アプローチ変更を概要に反映

### 2. **PR本文の更新方法**

```bash
# PR本文の更新
gh pr edit {PR_NUMBER} --body "$(cat <<'EOF'
## 概要
[更新された概要]

## 変更内容
- [新しい変更内容を追記]
- [既存の変更内容を修正]

## テスト内容
- [追加されたテスト]
- [修正されたテスト結果]

## レビュー対応履歴
- レビュー指摘事項A: 対応完了
- レビュー指摘事項B: 設計変更で対応

## チェックリスト
- [x] ローカルでlint/testが通ることを確認
- [x] 既存機能に影響がないことを確認
- [x] レビュー指摘事項への対応完了

Closes #123
EOF
)"
```

### 3. **PRタイトルの更新**

```bash
# スコープが大幅に変更された場合
gh pr edit {PR_NUMBER} --title "feat: ユーザー認証とアクセス制御機能を追加"

# 修正レベルの変更の場合
gh pr edit {PR_NUMBER} --title "fix: ユーザー認証の重大なセキュリティ問題を修正"
```

### 4. **更新タイミングの判断基準**

#### **必須更新ケース**
- [ ] 実装方針の大幅変更
- [ ] 新しい機能・修正の追加
- [ ] 重要なバグ修正の追加
- [ ] セキュリティ関連の変更
- [ ] パフォーマンス影響の変更

#### **推奨更新ケース**
- [ ] レビュー指摘事項の対応
- [ ] テストケースの追加・修正
- [ ] ドキュメント更新の追加
- [ ] リファクタリングの追加
- [ ] コードスタイル修正

#### **更新不要ケース**
- [ ] 軽微なタイポ修正
- [ ] コメントの追加・修正のみ
- [ ] インデント・フォーマット修正のみ
- [ ] 変数名の軽微な変更

### 5. **効率的な更新戦略**

#### **段階的更新**
```bash
# 初期PR作成時: 基本的な内容
# レビュー後: 指摘事項と対応を追記
# 追加実装後: 新機能・修正内容を追記
# 最終レビュー後: 完成版として整理
```

#### **履歴の保持**
```markdown
## 変更履歴
- 2025-01-15: 初期実装完了
- 2025-01-16: レビュー指摘事項A, B対応
- 2025-01-17: パフォーマンス改善追加
- 2025-01-18: セキュリティ修正追加
```

#### **実装の説明強化**
```markdown
## 技術的な詳細
### 当初の実装
- JWT認証のみ

### レビュー後の改善
- JWT + リフレッシュトークン方式
- セッション管理の強化
- CSRF対策の追加

### 最終実装
- 多要素認証対応
- ロールベースアクセス制御
- 監査ログ機能
```

## 自動化スクリプト（更新対応版）

### 1. **PR本文自動更新スクリプト**

```bash
#!/bin/bash
# update_pr_body.sh - PR本文自動更新

PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
if [ -z "$PR_NUMBER" ]; then
    echo "❌ 現在のブランチにPRが見つかりません"
    exit 1
fi

echo "📝 PR #$PR_NUMBER の本文を更新します"

# 現在のPR情報を取得
CURRENT_TITLE=$(gh pr view $PR_NUMBER --json title -q '.title')
CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q '.body')

echo "現在のタイトル: $CURRENT_TITLE"
echo "現在の本文の一部: $(echo "$CURRENT_BODY" | head -3)"
echo ""

# 更新理由の判定（自動化推奨）
REASON_TYPE=${1:-"1"}  # コマンドライン引数または自動判定

case $REASON_TYPE in
    1) REASON="レビュー指摘事項の対応";;
    2) REASON="新機能・修正の追加";;
    3) REASON="テスト内容の更新";;
    4) REASON="設計変更";;
    *) REASON="その他の変更";;
esac

# 変更内容の取得（コミットメッセージから自動生成推奨）
NEW_CHANGES=${2:-"最新のコミット内容を反映"}  # 実際にはgit logから取得

# 既存の本文に追記
UPDATED_BODY="$CURRENT_BODY

## 更新履歴
$(date '+%Y-%m-%d'): $REASON
- $new_changes"

# PR本文更新
gh pr edit $PR_NUMBER --body "$UPDATED_BODY"

echo "✅ PR本文を更新しました"
```

### 2. **コミット時PR自動更新スクリプト**

```bash
#!/bin/bash
# auto_update_pr_on_commit.sh - コミット時PR自動更新

# Gitフック（post-commit）として使用
# .git/hooks/post-commit に配置

PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null)
if [ -n "$PR_NUMBER" ]; then
    echo "📝 PR #$PR_NUMBER の本文を自動更新中..."
    
    # 最新のコミットメッセージを取得
    LATEST_COMMIT=$(git log -1 --pretty=format:"%s")
    
    # 現在のPR本文を取得
    CURRENT_BODY=$(gh pr view $PR_NUMBER --json body -q '.body')
    
    # 更新履歴セクションがあるかチェック
    if [[ "$CURRENT_BODY" == *"## 更新履歴"* ]]; then
        # 既存の更新履歴に追記
        UPDATED_BODY=$(echo "$CURRENT_BODY" | sed "/## 更新履歴/a\\
$(date '+%Y-%m-%d'): $LATEST_COMMIT")
    else
        # 新しく更新履歴セクションを追加
        UPDATED_BODY="$CURRENT_BODY

## 更新履歴
$(date '+%Y-%m-%d'): $LATEST_COMMIT"
    fi
    
    # PR本文更新
    gh pr edit $PR_NUMBER --body "$UPDATED_BODY"
    
    echo "✅ PR本文を自動更新しました"
fi
```

## 注意事項

### 1. **タイトルの重要性**
- マージ時のコミットメッセージになる
- プロジェクト履歴の可読性に影響
- 自動化ツールでの解析に使用
- **重要**: スコープが大幅に変更された場合は必ずタイトルも更新

### 2. **Issue連携の効果**
- Issue自動クローズ
- 変更履歴の追跡性向上
- プロジェクト管理の効率化

### 3. **日本語使用の理由**
- チーム内コミュニケーションの統一
- レビュー効率の向上
- 意図の正確な伝達

### 4. **品質確保**
- PR作成前の必須チェック項目確認
- CI通過の確認
- コンフリクト解決の完了
- **追加**: PR本文の実装内容との整合性確認

### 5. **継続的更新の重要性**
- レビュアーが最新の実装内容を正確に把握
- 将来の参照時に実際の実装と一致した情報
- プロジェクト管理の精度向上
- ドキュメントとしての価値向上