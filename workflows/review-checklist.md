# レビュー対応チェックリスト

## 必須確認項目（忘れやすい手順）

### ✅ レビュー対応完了チェック

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

- [ ] **5. 完了報告**
  - [ ] `gh pr comment` で対応完了報告
  - [ ] 対応内容の要約記載

## 再発防止策

### 1. **手順の標準化**
```bash
# レビュー対応完了後の必須コマンド
git status && git add . && git commit -m "対応内容" && git push
```

### 2. **最終確認の習慣化**
レビュー対応作業後は必ず以下を確認：
- `git status` でコミット漏れチェック
- `gh pr view [PR番号]` でPR状況確認

### 3. **TodoWrite活用**
レビュー対応時はTodoWriteツールで進捗管理：
- コミット・プッシュもTodo項目として管理
- 完了チェックで漏れ防止

### 4. **自動化スクリプト作成**
よく使うコマンドの組み合わせをスクリプト化検討