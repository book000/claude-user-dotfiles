# Claude Code ベストプラクティス集

## 🎯 効率的な開発フローの確立

### プロジェクト開始時のチェックリスト
```markdown
- [ ] プロジェクト固有の CLAUDE.md を作成
- [ ] パッケージマネージャーの確認（ロックファイル）
- [ ] 主要なスクリプトの確認（package.json）
- [ ] 品質チェックコマンドの確認（lint, test, typecheck）
- [ ] Git戦略の確認（upstream/origin, メインブランチ）
- [ ] 既存のコード規約・アーキテクチャの理解
```

### 継続的な設定改善
```bash
# 新しいパターンを学習した時
echo "## 新しい学習事項
- パターン: {具体的なパターン}
- 使用場面: {どういう時に使うか}
- 実装例: {具体的なコード例}
- 注意点: {気をつけること}

適用日: $(date '+%Y-%m-%d')" >> ~/.claude/CLAUDE.md

# 設定の自動同期
cd ~/.claude && git add . && git commit -m "learn: 新しいパターンを学習" && git push
```

## 🔧 Claude Code特有の機能活用

### 拡張思考の効果的な使い方
```bash
# 複雑な問題に直面した時
"think harder about this architecture problem"

# 設計判断が必要な時  
"think about the pros and cons of using Redux vs Context API for this use case"

# デバッグで原因が不明な時
"think step by step about what could be causing this memory leak"
```

### メモリとコンテキスト管理
```bash
# ファイル参照の効率化
"@components/UserProfile.tsx の実装を参考に、@components/AdminProfile.tsx を作成して"

# プロジェクト固有情報の活用
"@docs/architecture.md に従って、新しいAPIエンドポイントを実装して"

# 設定ファイルの参照
"@.eslintrc.js の設定に従って、新しいコンポーネントのコードスタイルを修正して"
```

### 画像・視覚的コンテンツの活用
```bash
# UI実装時
"この画面のスクリーンショットを見て、React コンポーネントを実装してください"

# エラー画面の解析
"このエラー画面のスクリーンショットから、何が問題かを分析してください"

# 設計図からの実装
"この画面設計図を元に、フロントエンドコンポーネントを作成してください"
```

## 🛡️ セキュリティとプライバシーの確保

### 機密情報の保護
```bash
# .gitignore の適切な設定
echo "# Claude Code機密情報
.credentials.json
*.env
*.env.local
api-keys.json
secrets/
private/

# プロジェクト固有の機密情報
config/production.json
deploy/
.aws/
.gcp/" >> .gitignore
```

### 安全なコード実装の原則
```typescript
// ❌ 避けるべきパターン
const apiKey = "sk-1234567890abcdef"; // ハードコード
console.log(process.env.SECRET_KEY); // ログ出力

// ✅ 推奨パターン
const apiKey = process.env.API_KEY;
if (!apiKey) {
    throw new Error("API_KEY environment variable is required");
}

// セキュアなログ出力
console.log("API key loaded:", apiKey ? "✓" : "✗");
```

## 📋 ドキュメント記述の原則

### Claude Code動作の説明を優先

#### **推奨記述パターン**
```markdown
## Issue対応フロー

Claude Codeが以下を自動実行：
1. Issue詳細の取得・分析
2. 優先度・複雑度の評価
3. Conventional Commits形式のブランチ作成
4. 実装の実行
5. 品質チェック（lint/test/typecheck）
6. コミット・プッシュ
7. PR作成
```

#### **避けるべきパターン**
- 手動実行スクリプト中心の説明
- Claude Codeで自動化される処理の詳細bash記述
- 不要な技術詳細の羅列

### 手動実行スクリプトの提供基準

#### **必須提供ケース**
- Claude Codeでは対応困難な特殊な技術要件
- 外部システム連携が必要な場合
- 緊急時のフォールバック手順

#### **提供不要ケース**
- Claude Codeで完全自動化される一般的なワークフロー
- 単純な概念説明のみが目的

## 📈 コード品質の継続的向上

### 段階的リファクタリング戦略
```bash
# 1. 理解フェーズ
"このコードベースの全体アーキテクチャを教えて"
"このファイルの役割と依存関係を説明して"

# 2. 問題特定フェーズ
"パフォーマンスのボトルネックを特定して"
"技術的負債の箇所を見つけて"

# 3. 改善計画フェーズ
"このコンポーネントをよりモダンなパターンにリファクタリングする計画を立てて"

# 4. 実装フェーズ
"段階的にリファクタリングを実行して、各ステップでテストが通ることを確認して"
```

### テスト戦略の確立
```typescript
// テスト作成の優先順位
// 1. 重要なビジネスロジック
// 2. 外部依存のあるコンポーネント
// 3. 複雑な条件分岐
// 4. エラーハンドリング

// テストファイル例
describe("UserAuthentication", () => {
  it("should authenticate valid users", () => {
    // 正常系テスト
  });
  
  it("should reject invalid credentials", () => {
    // 異常系テスト
  });
  
  it("should handle network errors gracefully", () => {
    // エラーハンドリングテスト
  });
});
```

## 🚀 効率的なワークフロー確立

### Issue駆動開発の実践
```bash
# Issue作成時のテンプレート
## 問題の概要
簡潔に問題を説明

## 再現手順
1. 
2. 
3. 

## 期待される動作
どうなるべきか

## 現在の動作
実際にはどうなっているか

## 環境情報
- OS: 
- ブラウザ: 
- Node.js version: 
- パッケージマネージャー: 

## 提案する解決策
（分かる場合）
```

### プルリクエストの品質向上
```markdown
# PRレビューのセルフチェックリスト

## コード品質
- [ ] 適切な命名規則を使用
- [ ] 不要なコメントやデバッグコードを削除
- [ ] 型安全性を確保（TypeScriptの場合）
- [ ] エラーハンドリングを適切に実装

## テスト
- [ ] 新機能には対応するテストを追加
- [ ] 既存テストが全て通過
- [ ] エッジケースをカバー

## パフォーマンス
- [ ] 不要な再レンダリングを防止
- [ ] メモリリークの可能性を確認
- [ ] バンドルサイズへの影響を考慮

## セキュリティ
- [ ] 機密情報の漏洩チェック
- [ ] XSS, CSRF対策の確認
- [ ] 入力値検証の実装

## ドキュメント
- [ ] 必要に応じてREADMEを更新
- [ ] APIの変更がある場合は文書化
- [ ] 複雑な実装にはコメントを追加
```

## 🔄 継続的改善のプロセス

### 定期的な設定レビュー
```bash
# 月次設定レビュー
echo "## $(date '+%Y年%m月') 設定レビュー

### 今月追加した改善
- 

### 使用頻度の高いパターン
- 

### 改善が必要な領域
- 

### 来月の目標
- " >> ~/.claude/reviews/$(date '+%Y-%m').md
```

### チーム知識の共有
```markdown
# チーム向けの Claude Code 活用ガイド

## よく使用するコマンドパターン
1. `"issue #xx を対応してください"` - Issue完全自動対応
2. `"レビューに対応してください"` - PR修正の自動化
3. `"think about..."` - 複雑な問題の深い分析
4. `"@ファイル名 を参考に..."` - 既存コードを参考にした実装

## 避けるべき指示
- 曖昧すぎる指示（"良い感じに修正して"）
- セキュリティリスクのある指示
- 大きすぎるスコープの変更要求

## 効果的な Claude Code 活用のコツ
- 具体的で明確な指示を心がける
- 段階的なアプローチを取る
- 適切なコンテキスト情報を提供する
```