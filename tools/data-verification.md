# データ検証戦略

## 基本原則

- **効率的な検証**: 多くのファイルを参照する場合は検証用スクリプトを作成
- **一時的なツール**: 検証用スクリプトはコミットしない
- **自動化優先**: 手動でのList/Read操作よりもスクリプト化を優先

## 検証スクリプトの適用場面（一般的なガイドライン）

### **判断基準の考慮事項**
各プロジェクトの特性に応じて以下の要素を考慮して判断：
- **ファイル数**: 対象ファイルの数量
- **複雑性**: 検証ロジックの複雑さ
- **頻度**: 検証作業の実行頻度
- **チーム規模**: 作業者数と技術レベル
- **プロジェクト期限**: 時間的制約

### 1. **ファイル数による一般的な目安**
```bash
# 一般的な指標（プロジェクトによって調整）
# 10ファイル未満: Read/LSツール推奨
# 10-50ファイル: 内容次第（複雑なチェックなら検証スクリプト）
# 50ファイル以上: 検証スクリプト推奨

# 例: 大量ファイルの整合性チェック
# ❌ 非効率: 各ファイルをReadツールで個別確認
# ✅ 効率的: 検証スクリプト作成
```

### 2. **複雑性による判断（プロジェクト固有で調整）**

#### **検証スクリプト推奨ケース**
```bash
# 以下の条件に該当する場合は検証スクリプトを検討
# - 複数の検証条件の組み合わせ
# - 構造的なパターン検証が必要
# - 相互関係のチェックが必要  
# - 時間のかかる処理（ビルド、テスト等）
# - 正規表現やログイック処理が複雑

# 例: JSONファイル群のスキーマ検証
# 例: TypeScript型定義の整合性確認
# 例: 設定ファイルの形式統一確認
```

#### **Read/LSツール推奨ケース**
```bash
# 以下の条件に該当する場合はRead/LSツールが適している
# - 単純な存在確認
# - 個別ファイルの内容確認
# - 線形的な確認作業
# - 一度限りの調査

# 例: 特定ファイルの内容確認
# 例: ディレクトリ構造の把握
# 例: 設定値の簡単な確認
```

### 3. **プロジェクト特性による考慮事項**

#### **急ぎの作業・緊急対応**
- Read/LSツールでの迅速な確認を優先
- 最小限の検証で安全性を確保

#### **継続的な品質管理**
- 検証スクリプトで自動化・再現性を重視
- 長期的な保守性を考慮

#### **チーム開発**
- 検証手順の標準化を検証スクリプトで実現
- 属人性を排除した品質チェック

### 4. **生成データの品質確認**
```bash
# 例: 自動生成されたコード/設定の検証
# 例: マイグレーション結果の確認
# 例: ビルド成果物の検証
```

## 検証スクリプトの作成パターン

### 1. **ファイル存在・形式確認**

```bash
#!/bin/bash
# verify_files.sh - 一時的な検証スクリプト

echo "🔍 ファイル検証を開始..."

# 必要なファイルの存在確認
required_files=("package.json" "tsconfig.json" ".eslintrc.js")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ 必須ファイルが見つかりません: $file"
        exit 1
    else
        echo "✅ $file 存在確認"
    fi
done

# JSONファイルの形式確認
echo "📋 JSON形式の検証..."
find . -name "*.json" -not -path "./node_modules/*" | while read -r file; do
    if ! jq empty "$file" 2>/dev/null; then
        echo "❌ JSON形式エラー: $file"
    else
        echo "✅ $file JSON形式OK"
    fi
done

echo "✅ 検証完了"
```

### 2. **データ整合性確認**

```bash
#!/bin/bash
# verify_data_consistency.sh

echo "🔍 データ整合性確認..."

# TypeScript型定義の確認
echo "📝 TypeScript型チェック..."
if ! npx tsc --noEmit; then
    echo "❌ TypeScript型エラーが検出されました"
    exit 1
fi

# package.jsonとlock fileの整合性
echo "📦 依存関係整合性確認..."
if [ -f "package-lock.json" ]; then
    if ! npm ci --dry-run > /dev/null 2>&1; then
        echo "❌ package-lock.jsonに問題があります"
        exit 1
    fi
fi

# 設定ファイルの一貫性確認
echo "⚙️ 設定ファイル確認..."
if [ -f ".eslintrc.js" ] && [ -f "package.json" ]; then
    # ESLint設定とpackage.jsonの依存関係確認
    required_eslint_deps=("eslint" "@typescript-eslint/parser")
    for dep in "${required_eslint_deps[@]}"; do
        if ! jq -e ".devDependencies[\"$dep\"]" package.json > /dev/null; then
            echo "⚠️ ESLint依存関係が不足: $dep"
        fi
    done
fi

echo "✅ データ整合性確認完了"
```

### 3. **生成結果の品質確認**

```bash
#!/bin/bash
# verify_generated_code.sh

echo "🔍 生成コードの品質確認..."

# 生成されたファイルの確認
generated_dir="./generated"
if [ -d "$generated_dir" ]; then
    echo "📁 生成ディレクトリ: $generated_dir"
    
    # ファイル数の確認
    file_count=$(find "$generated_dir" -type f | wc -l)
    echo "📄 生成ファイル数: $file_count"
    
    # TypeScriptファイルの構文確認
    ts_files=$(find "$generated_dir" -name "*.ts" -o -name "*.tsx")
    if [ -n "$ts_files" ]; then
        echo "🔍 TypeScriptファイルの構文確認..."
        echo "$ts_files" | xargs npx tsc --noEmit --skipLibCheck
    fi
    
    # コードスタイル確認
    if command -v eslint >/dev/null 2>&1; then
        echo "🎨 コードスタイル確認..."
        echo "$ts_files" | xargs npx eslint --quiet
    fi
else
    echo "⚠️ 生成ディレクトリが見つかりません: $generated_dir"
fi

echo "✅ 生成コード品質確認完了"
```

## 検証スクリプトの管理

### 1. **作成・実行・削除サイクル**

```bash
# 1. 検証スクリプト作成
cat > verify_temp.sh << 'EOF'
#!/bin/bash
# 具体的な検証ロジック
EOF

# 2. 実行権限付与・実行
chmod +x verify_temp.sh
./verify_temp.sh

# 3. 検証完了後は削除
rm verify_temp.sh
```

### 2. **.gitignoreでの除外**

```gitignore
# 検証用一時スクリプト
verify_*.sh
check_*.sh
validation_*.sh
temp_*.sh
```

### 3. **命名規則**

```bash
# 用途を明確にした命名
verify_database_migration.sh    # DB移行結果検証
check_api_endpoints.sh          # API仕様確認  
validate_config_files.sh        # 設定ファイル検証
temp_file_structure_check.sh    # ファイル構造確認
```

## プログラミング言語別の検証例

### 1. **TypeScript/JavaScript**

```bash
#!/bin/bash
# TypeScript プロジェクト検証

# 型チェック
npx tsc --noEmit

# Lint確認
npx eslint . --ext .ts,.tsx,.js,.jsx

# テスト実行
npm test

# ビルド確認
npm run build

# 依存関係の脆弱性確認
npm audit
```

### 2. **Python**

```bash
#!/bin/bash
# Python プロジェクト検証

# 構文チェック
find . -name "*.py" | xargs python -m py_compile

# 型チェック（mypy使用時）
if command -v mypy >/dev/null 2>&1; then
    mypy .
fi

# Lint確認
if command -v flake8 >/dev/null 2>&1; then
    flake8 .
fi

# テスト実行
if [ -f "pytest.ini" ] || [ -f "pyproject.toml" ]; then
    pytest
fi
```

### 3. **Go**

```bash
#!/bin/bash
# Go プロジェクト検証

# フォーマット確認
if [ "$(gofmt -l . | wc -l)" -gt 0 ]; then
    echo "❌ gofmt未適用のファイルがあります"
    gofmt -l .
    exit 1
fi

# ビルド確認
go build ./...

# テスト実行
go test ./...

# Lint確認
if command -v golangci-lint >/dev/null 2>&1; then
    golangci-lint run
fi
```

## 効率性の比較（参考）

### **プロジェクト規模による使い分け**

#### **小規模・単発作業**
```
アプローチ: Read/LSツール中心
1. LSツールでディレクトリ確認
2. 必要なファイルをReadツールで確認
3. 簡単な問題は即座に対応
→ 迅速な対応、セットアップ不要
```

#### **中〜大規模・継続的作業**
```
アプローチ: 検証スクリプト活用
1. 検証要件を整理
2. 検証スクリプトを作成
3. 一括実行で全体確認
4. 問題箇所をまとめて報告
→ 高速で確実、再現可能
```

### **判断フローの例**
```
1. ファイル数を確認（10未満/10-50/50以上）
2. 検証の複雑性を評価（単純/中程度/複雑）
3. 作業頻度を考慮（一回限り/継続的）
4. チーム要件を確認（個人/チーム/組織）
5. 適切なアプローチを選択
```

## 注意事項

### 1. **スクリプトの一時性**
- 検証完了後は必ず削除
- .gitignoreで除外設定
- コミット前の確認を怠らない

### 2. **セキュリティ配慮**
- 機密情報をスクリプトに含めない
- 実行権限の適切な管理
- 外部コマンドの安全性確認

### 3. **可読性・保守性**
- 明確なコメント記述
- エラーメッセージの充実
- 段階的な処理実行

この戦略により、大量ファイルの検証が効率化され、品質確保と作業時間の大幅短縮を両立できます。