# pnpm最適化設定

## 📦 分析結果に基づくpnpm中心の最適化

### 検出された現状
- **パッケージマネージャー使用状況**: pnpm が主要
- **よく使われるコマンド**: `pnpm run lint`, `pnpm test`, `pnpm install`
- **課題**: npm/yarnとの混在による非効率性

## 🎯 pnpm優先化戦略

### 改良された自動判定アルゴリズム
```bash
#!/bin/bash
# pnpm優先の確実な判定
detect_package_manager() {
    # 1. pnpm-lock.yaml が最優先（確実性重視）
    if [ -f "pnpm-lock.yaml" ]; then 
        echo "pnpm"
        return 0
    fi
    
    # 2. package.json の packageManager フィールド確認
    if [ -f "package.json" ]; then
        PM=$(jq -r '.packageManager // empty' package.json 2>/dev/null | cut -d'@' -f1)
        if [ "$PM" = "pnpm" ]; then 
            echo "pnpm"
            return 0
        fi
    fi
    
    # 3. 他のロックファイル確認
    if [ -f "yarn.lock" ]; then 
        echo "yarn"
    elif [ -f "bun.lockb" ]; then 
        echo "bun"
    elif [ -f "package-lock.json" ]; then
        echo "npm"
    else 
        echo "npm"  # フォールバック
    fi
}

# 使用例
PM=$(detect_package_manager)
echo "検出されたパッケージマネージャー: $PM"
```

### pnpm特化品質チェック統合
```bash
#!/bin/bash
# pnpm環境での統一品質チェック
pnpm_quality_check() {
    local PM=$(detect_package_manager)
    
    if [ "$PM" = "pnpm" ]; then
        echo "🚀 pnpm統一品質チェック開始..."
        
        # 依存関係確認
        echo "📦 依存関係確認..."
        pnpm install --frozen-lockfile
        
        # Lint実行
        echo "📝 Lintチェック..."
        if pnpm run lint; then
            echo "✅ Lint成功"
        else
            echo "❌ Lintエラー"
            return 1
        fi
        
        # テスト実行
        echo "🧪 テスト実行..."
        if pnpm run test; then
            echo "✅ テスト成功"
        else
            echo "❌ テスト失敗"
            return 1
        fi
        
        # TypeScript型チェック
        if pnpm run typecheck 2>/dev/null; then
            echo "📋 型チェック..."
            if pnpm run typecheck; then
                echo "✅ 型チェック成功"
            else
                echo "❌ 型チェック失敗"
                return 1
            fi
        fi
        
        echo "🎉 全ての品質チェックが完了しました"
    else
        echo "⚠️ pnpm以外のパッケージマネージャー($PM)を検出"
        $PM run lint && $PM run test
    fi
}
```

## ⚡ pnpm高速化テクニック

### 並行実行による効率化
```bash
# 並行実行でさらに高速化
pnpm_parallel_check() {
    echo "🔄 並行品質チェック開始..."
    
    # バックグラウンドで並行実行
    pnpm run lint &
    LINT_PID=$!
    
    pnpm run test &
    TEST_PID=$!
    
    if command -v "pnpm run typecheck" >/dev/null 2>&1; then
        pnpm run typecheck &
        TYPE_PID=$!
    fi
    
    # 結果待機
    wait $LINT_PID
    LINT_RESULT=$?
    
    wait $TEST_PID  
    TEST_RESULT=$?
    
    if [ -n "$TYPE_PID" ]; then
        wait $TYPE_PID
        TYPE_RESULT=$?
    else
        TYPE_RESULT=0
    fi
    
    # 結果判定
    if [ $LINT_RESULT -eq 0 ] && [ $TEST_RESULT -eq 0 ] && [ $TYPE_RESULT -eq 0 ]; then
        echo "🎉 並行品質チェック完了"
        return 0
    else
        echo "❌ 品質チェック失敗"
        return 1
    fi
}
```

### pnpm特化コマンド活用
```bash
# 開発効率向上のpnpm活用
pnpm_dev_utils() {
    local action="$1"
    
    case $action in
        "outdated")
            echo "📋 依存関係の更新チェック..."
            pnpm outdated
            ;;
        "why")
            echo "🔍 依存関係の分析..."
            pnpm why "$2"
            ;;
        "dlx")
            echo "⚡ 一時実行..."
            pnpm dlx "$2"
            ;;
        "update")
            echo "📦 依存関係更新..."
            pnpm update
            ;;
        "audit")
            echo "🔒 セキュリティ監査..."
            pnpm audit
            ;;
        *)
            echo "利用可能なコマンド: outdated, why, dlx, update, audit"
            ;;
    esac
}

# 使用例
# pnpm_dev_utils outdated
# pnpm_dev_utils why react
# pnpm_dev_utils dlx create-react-app my-app
```

## 🏗️ プロジェクト設定最適化

### package.json テンプレート
```json
{
  "name": "project-name",
  "packageManager": "pnpm@8.15.0",
  "scripts": {
    "dev": "pnpm run start:dev",
    "build": "pnpm run build:prod",
    "lint": "eslint . --ext .ts,.tsx,.js,.jsx",
    "lint:fix": "pnpm run lint -- --fix",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage",
    "typecheck": "tsc --noEmit",
    "quality": "pnpm run lint && pnpm run test && pnpm run typecheck",
    "quality:parallel": "run-p lint test typecheck"
  },
  "devDependencies": {
    "npm-run-all": "^4.1.5"
  }
}
```

### .npmrc 最適化設定
```ini
# pnpm最適化設定
auto-install-peers=true
strict-peer-dependencies=false
shamefully-hoist=false
prefer-frozen-lockfile=true
enable-pre-post-scripts=true

# 高速化設定
fetch-retries=3
fetch-retry-factor=2
fetch-retry-mintimeout=10000
fetch-retry-maxtimeout=60000

# セキュリティ設定
audit-level=moderate
```

## 🔧 統合ワークフロー

### Issue対応での活用
```bash
# Issue対応時のpnpm統合フロー
issue_workflow_pnpm() {
    local issue_number="$1"
    
    echo "🎯 Issue #$issue_number 対応開始（pnpm統合）"
    
    # 1. 依存関係確認
    pnpm install --frozen-lockfile
    
    # 2. 開発開始
    echo "💻 開発環境準備完了"
    
    # 3. 実装後の品質チェック
    echo "🔍 品質チェック実行..."
    if pnpm_quality_check; then
        echo "✅ 品質チェック合格"
    else
        echo "❌ 品質チェック失敗 - 修正が必要です"
        return 1
    fi
    
    # 4. コミット前最終確認
    echo "📋 最終確認..."
    pnpm run quality
    
    echo "🎉 Issue #$issue_number 対応完了"
}
```

### PR作成での活用
```bash
# PR作成時のpnpm最適化
pr_creation_pnpm() {
    echo "📤 PR作成準備（pnpm統合）"
    
    # 最新依存関係で確認
    pnpm install
    
    # 並行品質チェック
    pnpm_parallel_check
    
    # 依存関係監査
    pnpm audit --audit-level moderate
    
    echo "✅ PR作成準備完了"
}
```

## 📊 効果測定

### 期待される改善効果
- **インストール速度**: npm比で2-3倍高速
- **ディスク使用量**: シンボリックリンクによる効率化
- **品質保証**: 統一されたコマンド体系
- **開発体験**: 一貫したワークフロー

### 移行のメリット
- 既存プロジェクトとの互換性維持
- より厳密な依存関係管理
- モノレポ対応の優位性
- Node.js最新版との親和性