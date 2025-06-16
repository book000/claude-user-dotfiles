# レビュー対応（Copilot + Human）完全タスク管理版

## 必須：開始時TodoWrite実行

「レビューに対応してください」指示受信後、**最初に**以下をTodoWriteで作成：

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

**重要**: 各手順完了時に即座にTodoWrite実行してstatusを"completed"に変更

## Copilotレビューの種類

### 1. **通常のレビューコメント**

- PR全体の概要や一般的な指摘
- 「Pull Request Overview」から始まるコメント
- テキスト形式での説明やフィードバック

### 2. **サジェストコメント（コード提案）**

- 具体的なコード変更提案を含むコメント
- 行レベルでの改善提案
- 例: "Using includes('tex') will also match filenames like 'textfile.txt'"

## Copilotレビューコメントの取得

### 基本コマンド

```bash
# 1. PRの基本情報とレビュー一覧を取得
gh pr view {PR_NUMBER} --json reviews

# 2. 全ての行レベルコメント（サジェスト含む）を取得
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments

# 3. 特定レビューの詳細コメントを取得  
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/reviews/{REVIEW_ID}/comments
```

### 効率化されたコマンド（オプション）

```bash
# 1. 未解決Copilotスレッドの一覧表示
gh pr view $PR_NUMBER --json reviewThreads --jq '.reviewThreads[] | select(.isResolved == false and .comments[0].author.login == "github-copilot[bot]") | "Thread: \(.id) | \(.comments[0].body)"'

# 2. CopilotコメントのスレッドIDのみ取得
gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]" and .isResolved == false) | .id'

# 3. Copilot行レベルコメントの取得
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments --jq '.[] | select(.user.login == "github-copilot[bot]") | "File: \(.path):\(.line) | \(.body)"'
```

### 実用的なスクリプト例

```bash
#!/bin/bash

# PR番号を引数として受け取る
PR_NUMBER=$1
if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

# リポジトリ情報を取得
REPO_INFO=$(gh repo view --json owner,name)
OWNER=$(echo $REPO_INFO | jq -r '.owner.login')
REPO=$(echo $REPO_INFO | jq -r '.name')

echo "🔍 Fetching Copilot reviews for PR #$PR_NUMBER in $OWNER/$REPO"

# 1. レビュー一覧を取得してCopilotのレビューを抽出
echo "📋 Review Overview:"
gh pr view $PR_NUMBER --json reviews | jq -r '.reviews[] | select(.author.login == "github-copilot[bot]") | "Review ID: \(.id) - \(.body)"'

# 2. 全ての行レベルコメントを取得
echo "💬 Line-level Comments:"
gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments | jq -r '.[] | select(.user.login == "github-copilot[bot]") | "Line \(.line): \(.body)"'

# 3. Copilotレビューの統計情報
REVIEW_COUNT=$(gh api repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments | jq '[.[] | select(.user.login == "github-copilot[bot]")] | length')
echo "📊 Total Copilot comments: $REVIEW_COUNT"
```

## レビュー対応ワークフロー

### 1. **コメント確認フェーズ**

```bash
# すべてのCopilotコメントを確認
./get-copilot-reviews.sh {PR_NUMBER}

# 特定ファイルのコメントのみ抽出
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | jq -r '.[] | select(.user.login == "github-copilot[bot]" and .path == "src/file.ts") | .body'
```

### 2. **対応実施フェーズ**

```bash
# 修正作業
# - 通常コメント: 指摘事項を確認して修正
# - サジェストコメント: 具体的なコード変更提案を検討

# 修正後のlint/test実行
npm run lint && npm run test
# または
pnpm lint && pnpm test

# 修正内容をコミット
git add .
git commit -m "fix: Copilotレビュー指摘事項の修正"
```

### 3. **レビューコメント解決**

GitHub Web UI上で:

1. 修正したコメントに対して「Resolve conversation」をクリック
2. サジェストが適用された場合も同様に解決
3. すべてのコメントが解決されるまで繰り返し

## 注意事項

### **必須確認ポイント**

- [ ] 通常のテキストコメントを確認
- [ ] サジェストコメント（コード変更提案）を確認  
- [ ] 両方のタイプのコメントに適切に対応
- [ ] 修正後は必ずlint/testを実行
- [ ] 対応済みコメントは「Resolve conversation」で解決

### **よくある見落とし**

- サジェストコメントの見落とし（APIで取得が必要）
- 複数ファイルにまたがるコメントの確認漏れ
- レビューコメントの解決忘れ

### **効率的な対応のコツ**

- スクリプトを活用してコメント一覧を自動取得
- ファイル別、コメント種別での整理
- 修正→テスト→コミット→解決のサイクルを確立

## Human レビュー対応

### book000からのレビュー対応

「レビューに対応してください」と指示された場合：

1. **PRコメントの確認・対応**
   - プルリクエスト全体に対するコメント
   - 設計やアプローチに関するフィードバック
   - 全般的な改善提案

2. **サジェストコメントの確認・対応**
   - 行レベルでの具体的な修正提案
   - コード品質改善の提案
   - セキュリティ・パフォーマンス指摘

### Human レビューコメント取得

```bash
# PRのすべてのコメント（Human + Copilot）を取得
gh pr view {PR_NUMBER} --json comments | jq -r '.comments[] | "Author: \(.author.login)\nBody: \(.body)\n---"'

# レビューコメント（行レベル）を取得
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | jq -r '.[] | "Author: \(.user.login)\nFile: \(.path)\nLine: \(.line)\nBody: \(.body)\n---"'

# 特定ユーザー（book000）のコメントのみ抽出
gh api repos/{owner}/{repo}/pulls/{PR_NUMBER}/comments | jq -r '.[] | select(.user.login == "book000") | "File: \(.path)\nLine: \(.line)\nBody: \(.body)\n---"'
```

### Human レビュー対応フロー

1. **コメント収集**
   - PRコメント・レビューコメントの全取得
   - book000からの指摘事項を整理

2. **優先度判定**
   - セキュリティ関連: 最優先
   - 機能・ロジック: 高優先
   - コードスタイル: 中優先

3. **修正実装**
   - 各指摘事項に対する修正
   - 関連テストの追加・修正
   - ドキュメントの更新（必要に応じて）

4. **品質確認**
   - lint/testの実行
   - 修正内容の動作確認
   - 副作用の確認

5. **レスポンス（必須手順）**
   - **修正コミット・プッシュ**（最重要 - 忘れやすい手順）
   - コメントへの返信（必要に応じて）
   - GraphQL APIでreview threadをresolve
   - 完了報告コメント追加

### 注意事項

#### **Human レビューの特徴**
- より高次元の設計・アーキテクチャに関する指摘
- ビジネス要件との整合性確認
- 保守性・拡張性の観点からのフィードバック
- チーム規約・慣習に関する指摘

#### **対応時の心構え**
- 指摘の背景・意図を理解する
- 疑問点は積極的に質問する
- 代替案がある場合は提案する
- 学習機会として活用する

## Copilotコメントの適切性判断

### 不適切なコメントへの対応

Copilotのコメントが不適切と判断した場合：

1. **レビューコメントにReply（返信）**
2. **Resolve conversation（会話解決）**

### 不適切なコメント例と対応

#### **例1: プロジェクト固有事情を考慮していない**
```
Copilot: "この処理は非効率です。配列操作をよりパフォーマンスの良い方法に変更してください"

返信: "可読性優先のため変更しません。 (Claude Code対応)"
→ Resolve conversation
```

#### **例2: 既存設計思想と矛盾**
```
Copilot: "この関数は複数の責任を持っています。単一責任原則に従って分割してください"

返信: "アーキテクチャ方針に従った設計のため変更しません。 (Claude Code対応)"
→ Resolve conversation
```

#### **例3: 技術的制約を無視**
```
Copilot: "最新のES2023機能を使用してください"

返信: "Node.js 16互換性要件のため変更しません。 (Claude Code対応)"
→ Resolve conversation
```

#### **例4: セキュリティ要件の誤解**
```
Copilot: "このAPI呼び出しにはレート制限を追加してください"

返信: "内部API専用のため不要です。 (Claude Code対応)"
→ Resolve conversation
```

### 返信テンプレート（簡潔版）

#### **基本テンプレート**
```
[理由]のため変更しません。 (Claude Code対応)
```

#### **具体例**
```
# プロジェクト固有事情
"可読性優先のため変更しません。 (Claude Code対応)"

# 技術的制約
"Node.js 16互換性のため変更しません。 (Claude Code対応)"

# 設計方針
"既存アーキテクチャに従うため変更しません。 (Claude Code対応)"

# システム要件
"内部API専用のため不要です。 (Claude Code対応)"
```

### 判断基準

#### **対応すべきコメント**
- [ ] セキュリティ脆弱性の指摘
- [ ] 明確なバグの指摘
- [ ] パフォーマンス問題（測定可能）
- [ ] コード品質の実質的改善
- [ ] 保守性の向上

#### **対応しないコメント**
- [ ] プロジェクト要件と矛盾
- [ ] 技術的制約を無視
- [ ] 設計方針と不整合
- [ ] 過度な最適化提案
- [ ] 文脈を理解していない指摘

### 実行手順

1. **コメント内容の評価**
   - プロジェクト要件との整合性確認
   - 技術的制約の考慮
   - 設計方針との一致確認

2. **対応判断**
   - 適切 → 修正実装
   - 不適切 → 理由説明準備

3. **返信作成**
   - 丁寧な感謝表現
   - 具体的な対応しない理由
   - 根拠の明示

4. **Resolve実行**
   - 返信投稿後にResolve conversation
   - 判断記録の保持

### 注意事項

#### **返信時の配慮**
- 感謝の気持ちを表現
- 建設的なトーンを維持
- 具体的な根拠を示す
- 学習機会として活用

#### **記録の重要性**
- 判断根拠の文書化
- チーム知識の共有
- 将来の参考情報
- 品質向上への貢献

## GitHub API操作方法

### レビューコメントへの返信（Reply）

#### **REST API使用**
```bash
# レビューコメントに返信
gh api -X POST repos/{owner}/{repo}/pulls/{pull_number}/comments \
  -f body="[理由]のため変更しません。 (Claude Code対応)" \
  -f in_reply_to={comment_id}
```

#### **重要事項**
- `in_reply_to`パラメータに返信対象のコメントIDを指定
- トップレベルのレビューコメントのみ返信可能（返信への返信は不可）
- `comment_id`は返信対象のレビューコメントID

### Resolve Conversation（会話解決）

#### **GraphQL API（基本）**
```bash
# 会話を解決（単一）
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "THREAD_ID"}) {
    thread {
      id
      isResolved
    }
  }
}'

# 複数会話の一括解決
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "PRRT_kwDOGIpaB85SSRmV"}) {
    thread {
      id
      isResolved
    }
  }
}' && gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "PRRT_kwDOGIpaB85SSRmW"}) {
    thread {
      id
      isResolved
    }
  }
}'
```

#### **効率化されたワンライナー（オプション）**
```bash
# 単一スレッドの解決
gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$THREAD_ID\"}) { thread { id isResolved } } }"

# 全てのCopilotスレッドを一括解決
gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]" and .isResolved == false) | .id' | while read thread_id; do gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$thread_id\"}) { thread { id } } }"; done
```

#### **実用的なヘルパー関数（参考）**
```bash
# Copilotスレッド一括解決関数
resolve_copilot_threads() {
    local pr_number=$1
    if [ -z "$pr_number" ]; then
        echo "Usage: resolve_copilot_threads <PR_NUMBER>"
        return 1
    fi
    
    echo "🔍 未解決のCopilotスレッドを確認中..."
    local thread_ids=$(gh pr view $pr_number --json reviewThreads --jq -r '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]" and .isResolved == false) | .id')
    
    if [ -z "$thread_ids" ]; then
        echo "✅ 未解決のCopilotスレッドはありません"
        return 0
    fi
    
    echo "📝 以下のスレッドを解決します:"
    echo "$thread_ids"
    
    echo "$thread_ids" | while read thread_id; do
        echo "🔧 解決中: $thread_id"
        if gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$thread_id\"}) { thread { id isResolved } } }" >/dev/null; then
            echo "✅ 解決済み: $thread_id"
        else
            echo "❌ 解決失敗: $thread_id"
        fi
    done
}

# エラー対処付き単一スレッド解決
resolve_thread_safe() {
    local thread_id=$1
    if [ -z "$thread_id" ]; then
        echo "Usage: resolve_thread_safe <THREAD_ID>"
        return 1
    fi
    
    if ! gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$thread_id\"}) { thread { id isResolved } } }"; then
        echo "❌ 権限エラー: Contents権限とPull Requests権限を確認してください"
        echo "GitHub Settings > Developer settings > Personal access tokens で設定"
        return 1
    fi
}
```

#### **従来のGraphQL API（参考）**
```bash
# 会話を解決（単一）
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "THREAD_ID"}) {
    thread {
      id
      isResolved
    }
  }
}'

# 複数会話の一括解決
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "PRRT_kwDOGIpaB85SSRmV"}) {
    thread {
      id
      isResolved
    }
  }
}' && gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "PRRT_kwDOGIpaB85SSRmW"}) {
    thread {
      id
      isResolved
    }
  }
}'
```

#### **スレッドID取得**
```bash
# PRのレビュースレッド一覧を取得
gh api graphql -f query='
query {
  repository(owner: "book000", name: "memo") {
    pullRequest(number: 553) {
      reviewThreads(first: 20) {
        nodes {
          id
          isResolved
          comments(first: 5) {
            nodes {
              id
              author {
                login
              }
              body
            }
          }
        }
      }
    }
  }
}'
```

#### **効率化されたスレッドID取得（オプション）**
```bash
# 簡潔なスレッドID取得
gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | "\(.id) | \(.isResolved) | \(.comments[0].author.login) | \(.comments[0].body[:50])..."'

# Copilotスレッドのみ取得
gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]") | .id'

# 未解決スレッドのみ取得
gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | select(.isResolved == false) | .id'
```

### 完全な対応フロー例

```bash
#!/bin/bash
# copilot_review_workflow.sh - 簡潔なCopilotレビュー対応

PR_NUMBER=$1
if [ -z "$PR_NUMBER" ]; then
    echo "Usage: $0 <PR_NUMBER>"
    exit 1
fi

echo "🔍 PR #$PR_NUMBER のCopilotレビューを確認中..."

# 1. 未解決Copilotコメントの確認
echo "📋 未解決のCopilotスレッド一覧:"
gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]" and .isResolved == false) | "ID: \(.id) | \(.comments[0].body[:80])..."'

# 2. 全Copilotスレッドを一括解決（オプション）
echo "全てのCopilotスレッドを解決しますか？ (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🔧 Copilotスレッドを一括解決中..."
    gh pr view $PR_NUMBER --json reviewThreads --jq -r '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]" and .isResolved == false) | .id' | while read thread_id; do
        echo "解決中: $thread_id"
        gh api graphql -f query="mutation { resolveReviewThread(input: {threadId: \"$thread_id\"}) { thread { id } } }" >/dev/null && echo "✅ 完了" || echo "❌ 失敗"
    done
    echo "🎉 Copilotレビュー対応完了"
fi
```

### エラー対処法の充実

```bash
# 権限エラー時の詳細対処法
handle_permission_error() {
    echo "❌ 権限エラーが発生しました"
    echo ""
    echo "📋 確認事項:"
    echo "1. Personal Access Token の権限設定"
    echo "   - Repository > Contents: Read and Write"
    echo "   - Repository > Pull requests: Read and Write"
    echo ""
    echo "2. GitHub CLI の認証状態確認:"
    echo "   gh auth status"
    echo ""
    echo "3. リポジトリへのアクセス権確認:"
    echo "   gh repo view --json permissions"
}

# スレッドIDが見つからない場合の対処
debug_thread_issues() {
    local pr_number=$1
    echo "🔍 スレッド関連の問題をデバッグ中..."
    
    echo "📊 PR基本情報:"
    gh pr view $pr_number --json number,title,state
    
    echo "📋 全レビュースレッド一覧:"
    gh pr view $pr_number --json reviewThreads --jq '.reviewThreads[] | {id, isResolved, author: .comments[0].author.login}'
    
    echo "🤖 Copilotスレッドの詳細:"
    gh pr view $pr_number --json reviewThreads --jq '.reviewThreads[] | select(.comments[0].author.login == "github-copilot[bot]")'
}

# 一般的なトラブルシューティング
troubleshoot_review_api() {
    echo "🔧 GitHub API トラブルシューティング"
    echo ""
    echo "1. gh CLI バージョン確認:"
    gh version
    echo ""
    echo "2. 認証状態確認:"
    gh auth status
    echo ""
    echo "3. API制限確認:"
    gh api rate_limit
    echo ""
    echo "4. 最新のgh CLIへの更新推奨:"
    echo "   gh extension upgrade --all"
}
```

### 従来の詳細フロー（参考）

```bash
#!/bin/bash
# reply_and_resolve_detailed.sh - 従来の詳細対応フロー

OWNER="book000"
REPO="project-name"
PR_NUMBER=123
COMMENT_ID=456
THREAD_ID="T_kwDOBhHyPc4A..."

# 1. レビューコメントに返信
echo "📝 レビューコメントに返信中..."
gh api -X POST repos/$OWNER/$REPO/pulls/$PR_NUMBER/comments \
  -f body="プロジェクト要件のため変更しません。 (Claude Code対応)" \
  -f in_reply_to=$COMMENT_ID

# 2. 会話を解決
echo "✅ 会話を解決中..."
gh api graphql -f query='
  mutation ResolveThread($threadId: ID!) {
    resolveReviewThread(input: {threadId: $threadId}) {
      thread {
        id
        isResolved
      }
    }
  }
' -F threadId="$THREAD_ID"

echo "🎉 Copilotコメント対応完了"
```

### 必要な権限

#### **GraphQL API (resolveReviewThread)**
- Repository Permissions > Contents: Read and Write
- Repository Permissions > Pull Requests: Read and Write

#### **REST API (コメント返信)**
- Repository Permissions > Pull Requests: Write
- Repository Permissions > Issues: Write (PRはIssueの一種のため)

### トラブルシューティング

#### **"Resource not accessible by integration" エラー**
- Contents権限をRead and Writeに設定
- Pull Requests権限のみでは不十分

#### **"Review has already been submitted" エラー**
- 提出済みレビューへの返信時は新しいレビューオブジェクトが作成される
- GraphQL API使用時の正常な動作

#### **スレッドIDが見つからない**
- GraphQL queryでレビュースレッド一覧を取得
- コメントIDとスレッドIDは異なるので注意

この対応により、Copilotとの適切なコラボレーションを維持しながら、プロジェクト要件に合致した開発を継続できます。
