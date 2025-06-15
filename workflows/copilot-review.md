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

## Copilotコメントの適切性判断

### 不適切なコメントへの対応

Copilotのコメントが不適切と判断した場合：

1. **対応しない理由を返信**
2. **Resolve commentで解決**

### 不適切なコメント例と対応

#### **例1: プロジェクト固有事情を考慮していない**
```
Copilot: "この処理は非効率です。配列操作をよりパフォーマンスの良い方法に変更してください"

返信: "このプロジェクトでは可読性を優先しており、データ量も小規模のため現在の実装で十分です。パフォーマンス要件を満たしているため変更しません。"
→ Resolve comment
```

#### **例2: 既存設計思想と矛盾**
```
Copilot: "この関数は複数の責任を持っています。単一責任原則に従って分割してください"

返信: "この関数は意図的に複数の密接に関連する処理をまとめており、プロジェクトのアーキテクチャ方針に従った設計です。分割することで逆に複雑性が増すため変更しません。"
→ Resolve comment
```

#### **例3: 技術的制約を無視**
```
Copilot: "最新のES2023機能を使用してください"

返信: "このプロジェクトはNode.js 16をサポートする必要があり、ES2023機能は使用できません。互換性要件を満たすため現在の実装を維持します。"
→ Resolve comment
```

#### **例4: セキュリティ要件の誤解**
```
Copilot: "このAPI呼び出しにはレート制限を追加してください"

返信: "このAPIは内部システム専用で外部公開されておらず、レート制限は不要です。システム要件を満たしているため変更しません。"
→ Resolve comment
```

### 返信テンプレート

#### **基本テンプレート**
```
ご指摘いただきありがとうございます。

【対応しない理由】
- [具体的な理由]

【現在の実装を維持する根拠】
- [プロジェクト要件/技術制約/設計方針]

以上の理由により、現在の実装を維持します。
```

#### **プロジェクト固有事情**
```
ご指摘いただきありがとうございます。

このプロジェクトでは[特定の要件/制約]があるため、提案された変更は適用できません。

具体的には：
- [理由1]
- [理由2]

現在の実装はプロジェクト要件を満たしているため、変更は行いません。
```

#### **技術的制約**
```
ご指摘いただきありがとうございます。

技術的制約により提案された変更は実施できません：
- [環境制約/互換性要件/パフォーマンス要件]

代替案も検討しましたが、現在の実装が最適と判断しています。
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
   - 返信投稿後にResolve comment
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

この対応により、Copilotとの適切なコラボレーションを維持しながら、プロジェクト要件に合致した開発を継続できます。
