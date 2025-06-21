# プロジェクト用 CLAUDE.md テンプレート 2025

## 📋 プロジェクト概要
- **プロジェクト名**: [プロジェクト名]
- **目的**: [プロジェクトの目的を簡潔に説明]
- **技術スタック**: 
  - フロントエンド: [React 18, Vue 3, etc.]
  - バックエンド: [Node.js, Python, etc.]
  - データベース: [PostgreSQL, MongoDB, etc.]
  - ツール: [Vite, Webpack, etc.]
- **アーキテクチャ**: [MVC, Clean Architecture, Microservices, etc.]

## ⚡ 効率化設定（2025年版）

### Task Tool優先使用
- **MUST**: 複雑な調査はTask Tool最優先
- **効果**: コンテキスト効率50%改善
- **適用**: ファイル検索、パターン分析、依存関係調査

### 拡張思考活用
- **設計判断**: "ultrathink about architecture decisions"
- **デバッグ**: "think step by step about this issue"
- **最適化**: "think harder about performance improvements"

## ⚙️ 開発環境
- **Node.js**: [18.x, 20.x]
- **パッケージマネージャー**: pnpm（統一）
- **推奨エディタ**: VS Code + 推奨拡張機能

### 重要なコマンド（pnpm統一）
```bash
# 開発サーバー起動
pnpm dev

# ビルド
pnpm build

# 品質チェック統合
pnpm run lint && pnpm run test && pnpm run typecheck

# 依存関係管理
pnpm install --frozen-lockfile
pnpm outdated
pnpm update

# 開発ユーティリティ
pnpm dlx [package]  # 一時実行
pnpm why [package]  # 依存関係分析
```

## 🎯 プロジェクト固有ルール

### コーディング規約
- **命名規則**: 
  - 変数・関数: camelCase
  - コンポーネント・型: PascalCase
  - ファイル: kebab-case (コンポーネントのみPascalCase)
- **インポート順序**: 
  1. React/Framework関連
  2. 外部ライブラリ  
  3. 内部modules
  4. 相対パス・アセット
- **型定義**: interfaces より types を優先
- **スタイリング**: [Tailwind CSS, styled-components, CSS Modules]

### 品質基準
- **TypeScript**: 厳格モード必須
- **ESLint**: [Airbnb, Standard] + TypeScript推奨
- **Prettier**: セミコロンあり、シングルクォート
- **テスト**: 80%以上のカバレッジ

## 📁 ディレクトリ構造
```
src/
├── components/     # 再利用可能なUIコンポーネント
├── pages/         # ページコンポーネント（Reactの場合）
├── hooks/         # カスタムHooks
├── utils/         # ユーティリティ関数
├── types/         # TypeScript型定義  
├── services/      # API通信・外部サービス
├── stores/        # 状態管理（Zustand/Redux/Context）
├── constants/     # 定数定義
├── assets/        # 静的アセット
└── __tests__/     # テストファイル
```

## 🧪 テスト戦略
- **単体テスト**: Jest + [React Testing Library, etc.]
- **統合テスト**: 重要なフロー
- **E2Eテスト**: [Playwright, Cypress] (クリティカルパスのみ)
- **テストファイル命名**: `*.test.ts`, `*.spec.ts`
- **カバレッジ目標**: 80%以上

## 🚀 CI/CD・デプロイ
- **環境**: development, staging, production
- **CI**: GitHub Actions / GitLab CI
- **デプロイ**: [Vercel, Netlify, AWS, Docker]
- **環境変数**: `.env.example` を参考に設定

### GitHub Actions設定例
```yaml
name: CI
on: [push, pull_request]
jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
        with:
          version: 8
      - uses: actions/setup-node@v4
        with:
          node-version: 18
          cache: 'pnpm'
      - run: pnpm install --frozen-lockfile
      - run: pnpm run lint
      - run: pnpm run test
      - run: pnpm run typecheck
      - run: pnpm run build
```

## ⚠️ 重要な注意事項
- **機密情報**: 絶対にコミットしない
  - API キー、トークン
  - データベース接続情報
  - 本番環境設定
- **コンソール出力**: 本番コードに `console.log` を含めない
- **TODO管理**: コメントではなくIssueで管理
- **破壊的変更**: チーム合意後に実施

## 🔗 関連リンク
- [プロジェクト仕様書]()
- [API ドキュメント]()
- [デザインシステム]()
- [デプロイ環境]()
- [監視・ログ]()

## 📦 依存関係管理
- **本番依存関係**: 必要最小限
- **開発依存関係**: 積極的活用
- **セキュリティ**: `pnpm audit` 定期実行
- **更新ポリシー**: 
  - パッチバージョン: 自動更新
  - マイナーバージョン: 積極的
  - メジャーバージョン: 慎重に評価

## 🎨 UI/UX ガイドライン（該当する場合）
- **デザインシステム**: [Material-UI, Ant Design, Custom]
- **レスポンシブ**: モバイルファースト
- **アクセシビリティ**: WCAG 2.1 AA準拠
- **パフォーマンス**: 
  - Core Web Vitals最適化
  - バンドルサイズ監視
  - 画像最適化

## 🔧 開発ツール設定

### VS Code推奨拡張機能
```json
{
  "recommendations": [
    "ms-vscode.vscode-typescript-next",
    "esbenp.prettier-vscode", 
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-json"
  ]
}
```

### Husky + lint-staged設定
```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  }
}
```

## 📈 パフォーマンス指標
- **ビルド時間**: 目標[X]分以内
- **テスト実行時間**: 目標[X]分以内
- **バンドルサイズ**: 目標[X]MB以内
- **Core Web Vitals**: 全指標Good

## 🤝 貢献ガイドライン
1. **Issue作成**: テンプレートに従う
2. **ブランチ命名**: `feature/`, `fix/`, `docs/`
3. **コミットメッセージ**: Conventional Commits
4. **PR作成**: テンプレートとチェックリスト
5. **コードレビュー**: 建設的なフィードバック