# レビュー対応（Copilot + Human）

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

5. **レスポンス**
   - 修正コミット・プッシュ
   - コメントへの返信（必要に応じて）
   - 「Resolve conversation」での解決

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
