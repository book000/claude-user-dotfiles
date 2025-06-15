# パッケージマネージャー操作指針

## 基本原則

- **プロジェクト固有確認**: 必ずそのプロジェクトで使用されているパッケージマネージャーを確認
- **一貫性の維持**: プロジェクト全体で統一されたパッケージマネージャーを使用
- **ロックファイルの尊重**: 既存のlock fileに従った操作を実行

## パッケージマネージャーの判定方法

### 1. **ロックファイルでの判定（最優先）**

```bash
# 各パッケージマネージャーのロックファイル確認
ls -la | grep -E "(package-lock\.json|yarn\.lock|pnpm-lock\.yaml|bun\.lockb)"

# 判定ロジック
if [ -f "pnpm-lock.yaml" ]; then
    PACKAGE_MANAGER="pnpm"
elif [ -f "yarn.lock" ]; then
    PACKAGE_MANAGER="yarn"  
elif [ -f "bun.lockb" ]; then
    PACKAGE_MANAGER="bun"
elif [ -f "package-lock.json" ]; then
    PACKAGE_MANAGER="npm"
else
    PACKAGE_MANAGER="npm"  # デフォルト
fi
```

### 2. **package.jsonでの確認**

```bash
# packageManagerフィールドの確認
cat package.json | jq -r '.packageManager // empty'

# engines.npmの確認
cat package.json | jq -r '.engines.npm // empty'

# scriptsでの使用パッケージマネージャー確認
cat package.json | jq -r '.scripts | to_entries[] | select(.value | contains("pnpm") or contains("yarn")) | .value'
```

### 3. **プロジェクト設定ファイルでの確認**

```bash
# .npmrc の存在確認
[ -f ".npmrc" ] && echo "npm configuration found"

# .yarnrc.yml の存在確認  
[ -f ".yarnrc.yml" ] && echo "yarn configuration found"

# .pnpmfile.cjs の存在確認
[ -f ".pnpmfile.cjs" ] && echo "pnpm configuration found"
```

## パッケージマネージャー別操作

### 1. **npm**

```bash
# 依存関係インストール
npm install

# 開発依存関係追加
npm install --save-dev <package>

# 本番依存関係追加
npm install --save <package>

# スクリプト実行
npm run <script>

# 依存関係更新
npm update

# キャッシュクリア
npm cache clean --force
```

### 2. **yarn**

```bash
# 依存関係インストール
yarn install

# 開発依存関係追加
yarn add --dev <package>

# 本番依存関係追加
yarn add <package>

# スクリプト実行
yarn <script>

# 依存関係更新
yarn upgrade

# キャッシュクリア
yarn cache clean
```

### 3. **pnpm**

```bash
# 依存関係インストール
pnpm install

# 開発依存関係追加
pnpm add --save-dev <package>

# 本番依存関係追加
pnpm add <package>

# スクリプト実行
pnpm <script>

# 依存関係更新
pnpm update

# キャッシュクリア
pnpm store prune
```

### 4. **bun**

```bash
# 依存関係インストール
bun install

# 開発依存関係追加
bun add --development <package>

# 本番依存関係追加
bun add <package>

# スクリプト実行
bun run <script>

# 依存関係更新
bun update

# キャッシュクリア
bun pm cache rm
```

## 自動判定スクリプト例

### 1. **基本的な判定スクリプト**

```bash
#!/bin/bash

detect_package_manager() {
    if [ -f "pnpm-lock.yaml" ]; then
        echo "pnpm"
    elif [ -f "yarn.lock" ]; then
        echo "yarn"
    elif [ -f "bun.lockb" ]; then
        echo "bun"
    elif [ -f "package-lock.json" ]; then
        echo "npm"
    else
        # package.jsonのpackageManagerフィールドを確認
        if [ -f "package.json" ]; then
            PM=$(cat package.json | jq -r '.packageManager // empty' | cut -d'@' -f1)
            if [ -n "$PM" ]; then
                echo "$PM"
            else
                echo "npm"
            fi
        else
            echo "npm"
        fi
    fi
}

# 使用例
PACKAGE_MANAGER=$(detect_package_manager)
echo "Detected package manager: $PACKAGE_MANAGER"
```

### 2. **完全な判定・実行スクリプト**

```bash
#!/bin/bash

run_with_package_manager() {
    local command=$1
    local args=${@:2}
    
    # パッケージマネージャー判定
    if [ -f "pnpm-lock.yaml" ]; then
        PM="pnpm"
    elif [ -f "yarn.lock" ]; then
        PM="yarn"
    elif [ -f "bun.lockb" ]; then
        PM="bun"
    elif [ -f "package-lock.json" ]; then
        PM="npm"
    else
        PM="npm"
    fi
    
    echo "Using package manager: $PM"
    
    case $command in
        "install")
            $PM install $args
            ;;
        "add")
            if [ "$PM" = "npm" ]; then
                npm install $args
            else
                $PM add $args
            fi
            ;;
        "run")
            if [ "$PM" = "npm" ]; then
                npm run $args
            else
                $PM $args
            fi
            ;;
        *)
            echo "Unknown command: $command"
            exit 1
            ;;
    esac
}

# 使用例
# run_with_package_manager install
# run_with_package_manager add --save-dev typescript
# run_with_package_manager run lint
```

## 品質チェック時の注意点

### 1. **lint/test実行**

```bash
# パッケージマネージャーを判定してから実行
PACKAGE_MANAGER=$(detect_package_manager)

case $PACKAGE_MANAGER in
    "npm")
        npm run lint && npm run test
        ;;
    "yarn")
        yarn lint && yarn test
        ;;
    "pnpm")
        pnpm lint && pnpm test
        ;;
    "bun")
        bun run lint && bun run test
        ;;
esac
```

### 2. **依存関係の追加・更新**

```bash
# 開発依存関係の追加例
case $PACKAGE_MANAGER in
    "npm")
        npm install --save-dev eslint
        ;;
    "yarn")
        yarn add --dev eslint
        ;;
    "pnpm")
        pnpm add --save-dev eslint
        ;;
    "bun")
        bun add --development eslint
        ;;
esac
```

## トラブルシューティング

### 1. **ロックファイルの競合**

```bash
# 複数のロックファイルが存在する場合
if [ -f "package-lock.json" ] && [ -f "yarn.lock" ]; then
    echo "Warning: Multiple lock files detected"
    echo "Please remove unnecessary lock file"
    ls -la package-lock.json yarn.lock pnpm-lock.yaml bun.lockb 2>/dev/null
fi
```

### 2. **パッケージマネージャーの不一致**

```bash
# CI/CD環境での確認
echo "Lock files present:"
ls -la *lock* 2>/dev/null || echo "No lock files found"

echo "Package manager in package.json:"
cat package.json | jq -r '.packageManager // "not specified"'
```

### 3. **Node.js/パッケージマネージャーバージョン確認**

```bash
# 環境情報の確認
echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"

# 利用可能なパッケージマネージャー確認
command -v yarn >/dev/null 2>&1 && echo "yarn version: $(yarn --version)"
command -v pnpm >/dev/null 2>&1 && echo "pnpm version: $(pnpm --version)"
command -v bun >/dev/null 2>&1 && echo "bun version: $(bun --version)"
```

## プロジェクト固有設定での記録

### CLAUDE.mdでの記載例

```markdown
## パッケージマネージャー
- 使用: pnpm
- バージョン: 8.x
- 理由: ワークスペース機能、高速インストール

## 重要なコマンド
- install: `pnpm install`
- dev: `pnpm dev`
- build: `pnpm build`  
- lint: `pnpm lint`
- test: `pnpm test`

## 注意事項
- npm/yarnは使用禁止
- pnpm-lock.yamlをコミット必須
```

## 最良のプラクティス

### 1. **一貫性の確保**
- プロジェクト全体で単一のパッケージマネージャーを使用
- 不要なロックファイルは削除
- CI/CDでも同じパッケージマネージャーを使用

### 2. **性能最適化**
- パッケージマネージャー固有の最適化機能を活用
- キャッシュの適切な管理
- 並列インストールの活用

### 3. **セキュリティ**
- 定期的な脆弱性チェック
- 信頼できるレジストリの使用
- ロックファイルの定期的な更新