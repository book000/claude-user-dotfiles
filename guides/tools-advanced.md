# ツール活用の高度なテクニック

## 🔍 検索戦略の最適化

### 検索ツールの使い分け

#### Task Tool（推奨・第一選択）
```bash
# 複雑な調査や複数ファイルにわたる検索
# コンテキスト使用量を削減
用途例:
- "どのファイルでユーザー認証が実装されているか"
- "エラーハンドリングのパターンを調べて"
- "この機能に関連するテストファイルを見つけて"
```

#### Grep Tool（高速パターン検索）
```bash
# 具体的なパターンを高速検索
Grep pattern: "function.*login|class.*Auth"
Grep pattern: "import.*from ['\"]react['\"]"
Grep pattern: "TODO|FIXME|XXX"
Grep pattern: "process\.env\.(\w+)"
include: "*.{ts,tsx,js,jsx}"
```

#### Glob Tool（ファイル構造把握）
```bash
# ファイル名パターンでの検索
Glob pattern: "**/*.{test,spec}.{ts,js}"
Glob pattern: "**/components/**/*.tsx"
Glob pattern: "**/*config*.{json,js,ts}"
Glob pattern: "**/package.json"
```

### 効率的な並行検索
```typescript
// 同時に複数の検索を実行してパフォーマンス向上
Tool calls:
- Grep: "function.*authenticate"
- Grep: "class.*UserService"  
- Glob: "**/auth/**/*.ts"
- Glob: "**/user/**/*.ts"
```

## 📁 ファイル操作の高度なテクニック

### MultiEditの効果的な活用
```typescript
// 複数箇所の一括修正
MultiEdit file_path: "/path/to/file.ts"
edits: [
  {
    old_string: "import { oldFunction } from './old-module'",
    new_string: "import { newFunction } from './new-module'"
  },
  {
    old_string: "oldFunction(param)",
    new_string: "newFunction(param)",
    replace_all: true
  },
  {
    old_string: "// TODO: implement this",
    new_string: "// DONE: implemented using newFunction"
  }
]
```

### 段階的ファイル修正戦略
```bash
# 1. 理解フェーズ
Read → ファイル全体の構造把握
Read → 関連ファイルの確認

# 2. 計画フェーズ
# 変更箇所の特定と影響範囲の評価

# 3. 実行フェーズ
Edit/MultiEdit → 具体的な修正実行

# 4. 確認フェーズ
Read → 修正結果の確認
```

## 🔬 大量データ検証の自動化

### 検証スクリプトのパターン

#### TypeScript/JavaScript プロジェクト検証
```bash
#!/bin/bash
# verify_ts_project.sh

echo "🔍 TypeScript プロジェクト検証開始..."

# 1. 型チェック
echo "📋 型チェック..."
if ! npx tsc --noEmit; then
    echo "❌ 型エラーが検出されました"
    exit 1
fi

# 2. Lint確認
echo "📝 Lintチェック..."
if ! npx eslint . --ext .ts,.tsx,.js,.jsx; then
    echo "❌ Lintエラーが検出されました"
    exit 1
fi

# 3. 依存関係の整合性確認
echo "📦 依存関係確認..."
if [ -f "package-lock.json" ] && ! npm ci --dry-run >/dev/null 2>&1; then
    echo "❌ package-lock.jsonに問題があります"
    exit 1
fi

# 4. JSON形式ファイルの検証
echo "📄 JSON形式検証..."
find . -name "*.json" -not -path "./node_modules/*" | while read file; do
    if ! jq empty "$file" 2>/dev/null; then
        echo "❌ JSON形式エラー: $file"
        exit 1
    fi
done

echo "✅ 検証完了"
```

#### 設定ファイル整合性チェック
```bash
#!/bin/bash
# verify_config_consistency.sh

echo "⚙️ 設定ファイル整合性確認..."

# ESLint設定と依存関係の確認
if [ -f ".eslintrc.js" ] && [ -f "package.json" ]; then
    required_deps=("eslint" "@typescript-eslint/parser" "@typescript-eslint/eslint-plugin")
    for dep in "${required_deps[@]}"; do
        if ! jq -e ".devDependencies[\"$dep\"]" package.json >/dev/null; then
            echo "⚠️ ESLint依存関係が不足: $dep"
        fi
    done
fi

# TypeScript設定の確認
if [ -f "tsconfig.json" ]; then
    # 基本設定の存在確認
    if ! jq -e '.compilerOptions.strict' tsconfig.json >/dev/null; then
        echo "⚠️ TypeScript strict モードが有効でない可能性"
    fi
fi

echo "✅ 設定整合性確認完了"
```

### 検証スクリプトの管理原則
```bash
# 作成 → 実行 → 削除のサイクル
cat > verify_temp.sh << 'EOF'
#!/bin/bash
# 具体的な検証ロジック
EOF

chmod +x verify_temp.sh
./verify_temp.sh
rm verify_temp.sh  # 実行後は必ず削除
```

## 🌐 インターネット検索の戦略的活用

### 検索クエリの最適化

#### 年度指定検索
```bash
# 最新情報を確実に取得
"React best practices 2025"
"TypeScript 5.0 new features"
"Node.js security checklist 2025"
"Vue 3 composition API patterns 2025"
```

#### 比較検索の活用
```bash
# 技術選定に活用
"Redux vs Zustand vs Context API 2025"
"npm vs yarn vs pnpm performance comparison"
"Jest vs Vitest testing frameworks 2025"
```

#### 具体的問題解決検索
```bash
# エラーメッセージをそのまま検索
"TypeError: Cannot read property 'map' of undefined React"

# 症状 + 技術スタック
"memory leak Node.js Express application"
"React component re-rendering performance"
```

### 信頼できる情報源の優先順位

#### 最高優先度（公式）
- React公式ドキュメント
- TypeScript Handbook  
- Node.js公式ドキュメント
- MDN Web Docs
- 各ライブラリの公式GitHub

#### 高優先度（技術記事）
- dev.to
- Medium技術記事
- Qiita（日本語）
- Zenn（日本語）
- 有名開発者のブログ

#### 中優先度（コミュニティ）
- Stack Overflow
- Reddit技術サブレディット
- GitHub Issues/Discussions

### 情報の評価基準
```markdown
✅ 信頼性チェックリスト
- [ ] 記事の公開日（1年以内が理想）
- [ ] 作者の実績・所属確認
- [ ] 実際に動作するコード例の有無
- [ ] 複数ソースでの裏付け
- [ ] コミュニティでの評価（いいね数、コメント）
- [ ] セキュリティリスクの考慮
```

## 📊 パッケージマネージャーの高度な活用

### 自動判定ロジックの詳細
```bash
detect_package_manager() {
    # 1. ロックファイルでの判定（最優先）
    if [ -f "pnpm-lock.yaml" ]; then
        echo "pnpm"
        return
    elif [ -f "yarn.lock" ]; then
        echo "yarn"
        return
    elif [ -f "bun.lockb" ]; then
        echo "bun"
        return
    elif [ -f "package-lock.json" ]; then
        echo "npm"
        return
    fi
    
    # 2. package.jsonのpackageManagerフィールド確認
    if [ -f "package.json" ]; then
        PM=$(jq -r '.packageManager // empty' package.json | cut -d'@' -f1)
        if [ -n "$PM" ]; then
            echo "$PM"
            return
        fi
    fi
    
    # 3. デフォルト
    echo "npm"
}

# 使用例
PM=$(detect_package_manager)
echo "Detected: $PM"

# パッケージマネージャー固有のコマンド実行
case $PM in
    "pnpm") pnpm install && pnpm lint && pnpm test;;
    "yarn") yarn install && yarn lint && yarn test;;
    "bun") bun install && bun run lint && bun run test;;
    *) npm install && npm run lint && npm run test;;
esac
```

### プロジェクト固有設定の記録
```markdown
# プロジェクト用 CLAUDE.md への記録例

## 開発環境設定
- パッケージマネージャー: pnpm
- Node.js バージョン: 18.x
- 重要なコマンド:
  - 開発サーバー: `pnpm dev`
  - ビルド: `pnpm build`
  - テスト: `pnpm test`
  - Lint: `pnpm lint`
  - 型チェック: `pnpm typecheck`

## 注意事項
- npm/yarnは使用しない（pnpmワークスペース使用）
- コミット前は必ず `pnpm lint && pnpm test` を実行
- pnpm-lock.yamlは必ずコミットに含める
```