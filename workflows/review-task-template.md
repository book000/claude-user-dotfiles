# レビュー対応タスクテンプレート

## 基本テンプレート（必須実行）

「レビューに対応してください」指示を受けたら、**最初に**以下をTodoWriteで実行：

### 標準7ステップタスク

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

## 実行ルール

### 1. タスク開始時
- タスクに取り掛かる際は `status: "in_progress"` に変更
- 同時にin_progressにできるのは1つのタスクのみ

### 2. タスク完了時
- 手順完了後、**即座に** `status: "completed"` に変更
- 次のタスクに進む前に必ずTodoWrite実行

### 3. 特別注意項目
- **タスク5（コミット・プッシュ）**: 最も忘れやすい手順のため要注意
- **タスク3（book000対応）**: 全指摘事項への対応必須、漏れ厳禁

## 拡張テンプレート（複雑なケース）

多数のコメントがある場合は、タスク2・3を細分化：

### Copilotコメント個別対応
```json
{"id": "2-1", "content": "Copilotコメント1対応（line 13 - キー表記）", "status": "pending", "priority": "medium"},
{"id": "2-2", "content": "Copilotコメント2対応（line 25 - キー表記）", "status": "pending", "priority": "medium"}
```

### book000コメント個別対応
```json
{"id": "3-1", "content": "book000コメント対応：バージョン情報調査・記載", "status": "pending", "priority": "high"},
{"id": "3-2", "content": "book000サジェスト対応：記述修正（複数箇所）", "status": "pending", "priority": "high"}
```

## 失敗例と対策

### ❌ よくある失敗
1. タスク作成せずに作業開始 → 手順漏れ発生
2. コミット・プッシュを忘れる → 修正が反映されない
3. Todo更新せずに複数作業 → 進捗不明、二重作業

### ✅ 正しい実行例
1. 指示受信 → 即座にTodoWrite実行
2. タスク1開始 → in_progress設定 → 完了 → completed設定
3. タスク2開始 → in_progress設定 → 完了 → completed設定
4. （繰り返し）
5. 全タスク完了確認

## 品質保証

### 完了前チェック
- [ ] 全7ステップのタスクが "completed" 状態
- [ ] `git status` でコミット漏れなし
- [ ] PR画面でreview thread全解決確認
- [ ] 完了報告コメントが投稿済み

この完全タスク管理により、レビュー対応の手順漏れを根絶します。