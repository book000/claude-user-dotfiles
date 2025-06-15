# 品質管理・テスト戦略

## 基本原則

- **事前実行**: コミット前の必須品質チェック
- **適切な範囲**: 変更に関連するテストの確認
- **CI対応**: CIがパスするまで修正を継続
- **新機能**: 新機能には対応するテストを追加

## 品質チェックのタイミング

### 1. **開発中（継続的）**

```bash
# ファイル保存時の自動チェック（エディタ設定推奨）
# - ESLint
# - Prettier
# - TypeScript型チェック
```

### 2. **コミット前（必須）**

```bash
# プロジェクト固有のコマンドを確認・実行
npm run lint && npm run test
# または
pnpm lint && pnpm test  
# または
yarn lint && yarn test

# 型チェックがある場合
npm run typecheck
# または
tsc --noEmit
```

### 3. **プッシュ前（推奨）**

```bash
# ビルドテスト
npm run build
# または
pnpm build

# E2Eテスト（ある場合）
npm run test:e2e
```

## プロジェクト固有コマンドの確認

### 1. **package.jsonの確認**

```bash
# スクリプト一覧を確認
cat package.json | jq '.scripts'

# よくあるスクリプト名
# - lint, lint:fix
# - test, test:watch, test:coverage
# - typecheck, type-check
# - build
# - format, prettier
```

### 2. **README.mdの確認**

```bash
# 開発セクションを確認
grep -A 10 -i "development\|getting started\|scripts" README.md
```

### 3. **CI設定の確認**

```bash
# GitHub Actions
cat .github/workflows/*.yml | grep -A 5 "run:"

# 他のCI設定
ls -la | grep -E "\.(yml|yaml)$"
```

## エラー対応戦略

### 1. **Lintエラー**

```bash
# 自動修正可能なエラーを修正
npm run lint:fix
# または
eslint --fix .

# 手動修正が必要なエラーを確認
npm run lint
```

### 2. **テストエラー**

```bash
# 詳細なテスト結果を取得
npm run test -- --verbose

# 特定のテストファイルのみ実行
npm run test -- path/to/test.spec.ts

# ウォッチモードで開発
npm run test:watch
```

### 3. **型エラー**

```bash
# 型チェックの詳細確認
tsc --noEmit --pretty

# 段階的な修正
# 1. 明らかなタイポの修正
# 2. 型定義の追加・修正
# 3. any型の削除・適切な型付け
```

## テスト戦略

### 1. **新機能のテスト**

- **単体テスト**: 関数・クラスレベル
- **統合テスト**: コンポーネント・モジュール間
- **E2Eテスト**: ユーザーフロー全体（必要に応じて）

### 2. **既存機能の回帰テスト**

```bash
# 全テスト実行
npm run test

# カバレッジ確認
npm run test:coverage

# 変更に関連するテストを特定
npm run test -- --findRelatedTests src/changed-file.ts
```

### 3. **テスト品質の確認**

- **カバレッジ**: 最低限の閾値を満たす
- **テストケース**: 正常系・異常系・境界値
- **メンテナンス性**: テストコードの可読性

## プロジェクト固有設定の管理

### 1. **CLAUDE.mdでの記録**

```markdown
## 品質チェックコマンド
- lint: `npm run lint`
- test: `npm run test` 
- typecheck: `npm run typecheck`
- build: `npm run build`

## 特別な注意事項
- E2Eテストはデータベース接続が必要
- Dockerコンテナ起動後にテスト実行
```

### 2. **自動化スクリプト例**

```bash
#!/bin/bash
# pre-commit-checks.sh

echo "🔍 Running pre-commit quality checks..."

# lint
echo "📝 Running lint..."
if ! npm run lint; then
    echo "❌ Lint failed"
    exit 1
fi

# test  
echo "🧪 Running tests..."
if ! npm run test; then
    echo "❌ Tests failed"
    exit 1
fi

# typecheck
echo "📋 Running type check..."
if ! npm run typecheck; then
    echo "❌ Type check failed"
    exit 1
fi

echo "✅ All quality checks passed!"
```

## CI対応

### 1. **ローカルでCIエラーを再現**

```bash
# CIと同じ環境でテスト
docker run --rm -v $(pwd):/app -w /app node:18 npm ci && npm run test

# 依存関係の問題確認
rm -rf node_modules package-lock.json
npm install
```

### 2. **CI失敗時の対応フロー**

1. CIログの詳細確認
2. ローカルでエラー再現
3. 修正実装
4. ローカルで品質チェック実行
5. コミット・プッシュ
6. CI結果確認

### 3. **継続的改善**

- CI実行時間の最適化
- テストの並列実行
- キャッシュの活用
- 不安定なテストの修正
