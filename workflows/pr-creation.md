# プルリクエスト作成指針

## 基本原則

- **Issue連携**: 関連するIssueを自動クローズするキーワードを使用
- **日本語本文**: PR本文は日本語で記述
- **Conventional Commits**: タイトルはマージ時のコミットメッセージとして適切な形式

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
# create_pr.sh

echo "🚀 PR作成ヘルパー"

# Issue番号の入力
echo "関連するIssue番号を入力してください（複数可、スペース区切り）:"
read -r issues

# PRタイプの選択
echo "変更タイプを選択してください:"
echo "1) feat - 新機能"
echo "2) fix - バグ修正"
echo "3) docs - ドキュメント"
echo "4) refactor - リファクタリング"
echo "5) その他"
read -r type_choice

case $type_choice in
    1) TYPE="feat";;
    2) TYPE="fix";;
    3) TYPE="docs";;
    4) TYPE="refactor";;
    5) echo "タイプを入力してください:"; read -r TYPE;;
esac

# 概要の入力
echo "変更の概要を入力してください:"
read -r description

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

## 注意事項

### 1. **タイトルの重要性**
- マージ時のコミットメッセージになる
- プロジェクト履歴の可読性に影響
- 自動化ツールでの解析に使用

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