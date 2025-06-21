# プロジェクト固有設定テンプレート

## 🏗️ 新規プロジェクト用 CLAUDE.md テンプレート

```markdown
# プロジェクト名

## 📋 プロジェクト概要
- **目的**: プロジェクトの目的を簡潔に説明
- **技術スタック**: 
  - フロントエンド: React 18, TypeScript, Tailwind CSS
  - バックエンド: Node.js, Express, PostgreSQL
  - ツール: Vite, ESLint, Prettier, Jest
- **アーキテクチャ**: MVC, Clean Architecture, etc.

## ⚙️ 開発環境
- **Node.js**: 18.x以上
- **パッケージマネージャー**: pnpm
- **推奨エディタ**: VS Code + TypeScript拡張

### 重要なコマンド
```bash
# 開発サーバー起動
pnpm dev

# ビルド
pnpm build

# テスト実行
pnpm test

# Lint + 型チェック
pnpm lint && pnpm typecheck

# 依存関係更新
pnpm update
```

## 🎯 コーディング規約
- **命名規則**: camelCase (変数・関数), PascalCase (コンポーネント・型)
- **ファイル命名**: kebab-case, コンポーネントはPascalCase
- **インポート順序**: 
  1. React関連
  2. 外部ライブラリ
  3. 内部modules
  4. 相対パス
- **型定義**: interfaces より types を優先
- **スタイリング**: Tailwind CSS クラス使用、カスタムCSSは最小限

## 📁 ディレクトリ構造
```
src/
├── components/     # 再利用可能なUIコンポーネント
├── pages/         # ページコンポーネント
├── hooks/         # カスタムHooks
├── utils/         # ユーティリティ関数
├── types/         # TypeScript型定義
├── services/      # API通信・外部サービス
├── stores/        # 状態管理（Zustand/Redux）
└── constants/     # 定数定義
```

## 🧪 テスト戦略
- **単体テスト**: Jest + React Testing Library
- **E2Eテスト**: Playwright (重要フローのみ)
- **カバレッジ目標**: 80%以上
- **テストファイル命名**: `*.test.ts`, `*.spec.ts`

## 📦 依存関係管理
- **本番依存関係**: 必要最小限に留める
- **開発依存関係**: 積極的に活用
- **脆弱性チェック**: `pnpm audit` 定期実行
- **更新ポリシー**: マイナーバージョンは積極的、メジャーは慎重に

## 🔧 開発ツール設定
- **ESLint**: Airbnb base + TypeScript recommended
- **Prettier**: セミコロンあり、シングルクォート
- **Husky**: pre-commit フックでlint + test
- **lint-staged**: 変更ファイルのみlint実行

## 🚀 デプロイ・CI/CD
- **環境**: development, staging, production
- **CI**: GitHub Actions
- **デプロイ**: Vercel / Netlify / AWS
- **環境変数**: `.env.example` を参考に設定

## ⚠️ 注意事項
- **API キー**: 絶対にコミットしない
- **console.log**: 本番コードには含めない
- **TODO コメント**: Issue として管理
- **破壊的変更**: 必ずチームに事前相談

## 🔗 関連リンク
- [プロジェクト仕様書](link-to-specs)
- [API ドキュメント](link-to-api-docs)
- [デザインシステム](link-to-design-system)
- [デプロイ環境](link-to-deployment)
```

## ⚙️ プロジェクト固有設定ファイル

### .claude/settings.local.json
```json
{
  "permissions": {
    "bash": true,
    "edit": true,
    "webFetch": true
  },
  "env": {
    "NODE_ENV": "development"
  },
  "cleanupPeriodDays": 30,
  "includeCoAuthoredBy": true
}
```

### .claude/.gitignore
```gitignore
# Claude Code 固有
settings.local.json
temp/
cache/
*.log

# プロジェクト固有の機密情報
.env.local
.env.production
api-keys.json
```

## 🚦 プロジェクト開始時チェックリスト

### 初期設定
- [ ] `./CLAUDE.md` をプロジェクトルートに作成
- [ ] `.claude/` ディレクトリを作成
- [ ] パッケージマネージャーの確認・統一
- [ ] 品質チェックコマンドの動作確認
- [ ] Git戦略の確認（upstream/origin）

### 開発環境確認
- [ ] Node.js バージョンの確認
- [ ] 必要な拡張機能のインストール
- [ ] 環境変数の設定
- [ ] データベース接続確認（該当する場合）

### チーム設定
- [ ] コーディング規約の共有
- [ ] ブランチ戦略の合意
- [ ] レビュープロセスの確立
- [ ] CI/CD パイプラインの設定

## 🎨 プロジェクトタイプ別カスタマイズ

### React + TypeScript プロジェクト
```markdown
## React 固有の規約
- **Hooks規則**: ESLint rules-of-hooks 必須
- **コンポーネント設計**: Single Responsibility Principle
- **Props命名**: boolean は is/has プレフィックス
- **状態管理**: useState → useReducer → Zustand → Redux の順で検討
```

### Node.js API プロジェクト
```markdown
## API 固有の規約
- **エラーハンドリング**: 統一されたエラーレスポンス形式
- **ログ出力**: 構造化ログ（JSON）
- **セキュリティ**: helmet, cors, rate-limiting 必須
- **データベース**: トランザクション境界の明確化
```

### フルスタック プロジェクト
```markdown
## フルスタック固有の設定
- **モノレポ**: pnpm workspace 活用
- **型共有**: 共通型定義パッケージ
- **API契約**: OpenAPI/Swagger による文書化
- **E2Eテスト**: フロント・バック連携テスト
```

## 🔧 設定メンテナンス

### 定期レビュー項目
```markdown
## 月次レビュー（プロジェクトチーム）
- [ ] 依存関係の脆弱性チェック
- [ ] 使用していない依存関係の削除
- [ ] コーディング規約の遵守状況確認
- [ ] パフォーマンス指標の確認

## 四半期レビュー（アーキテクチャ）
- [ ] 技術スタックの見直し
- [ ] アーキテクチャの妥当性評価
- [ ] 新しいベストプラクティスの適用検討
- [ ] チーム開発効率の改善点洗い出し
```

### 設定更新のフロー
```bash
# 1. 変更提案
# プロジェクトチームでの議論

# 2. 更新実施
# CLAUDE.md の更新

# 3. チーム共有
# 変更内容の周知

# 4. 効果測定
# 開発効率・品質指標での評価
```