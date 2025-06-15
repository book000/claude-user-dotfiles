# 検索戦略

## ツール使い分け

### 1. **Task Tool（推奨）**

- **用途**: 複数ファイルにわたる複雑な検索
- **メリット**: コンテキスト使用量の削減
- **適用場面**:
  - 「どのファイルでXXXが定義されているか」
  - 「YYY機能の実装場所を調べたい」
  - 複数回の検索が必要な調査

### 2. **Grep Tool**

- **用途**: 特定パターンのコンテンツ検索
- **メリット**: 高速な正規表現検索
- **適用場面**:
  - 関数/クラス名の使用箇所検索
  - エラーメッセージの出現箇所
  - 特定文字列の一括検索

### 3. **Glob Tool**  

- **用途**: ファイル名パターンでの検索
- **メリット**: ファイル構造の把握
- **適用場面**:
  - 特定拡張子のファイル一覧
  - 命名規則に従うファイル検索
  - ディレクトリ構造の調査

## 検索パターン別戦略

### 1. **機能実装場所の特定**

```
ステップ1: Task Tool
→ 「XXX機能はどこで実装されていますか？」

代替案: 段階的検索
1. Glob "**/*.{ts,js}" → ファイル一覧取得
2. Grep "functionName|className" → 候補絞り込み
3. Read → 詳細確認
```

### 2. **エラー・問題箇所の調査**

```
ステップ1: Grep でエラーメッセージ検索
pattern: "error message"
include: "*.{ts,js,log}"

ステップ2: 関連ファイルの確認
Glob で関連ファイル取得
Read で詳細コード確認
```

### 3. **依存関係の調査**

```
ステップ1: import/require文の検索
Grep pattern: "import.*from ['\"]target['\"]|require\(['\"]target['\"]\)"

ステップ2: 使用箇所の特定
Grep pattern: "targetFunction|targetClass"

ステップ3: 影響範囲の確認
関連ファイルをReadで詳細確認
```

## 効率的な検索テクニック

### 1. **並行検索の活用**

```typescript
// 同時に複数の検索を実行
Tool calls:
- Grep: "function.*login"
- Grep: "class.*Auth"  
- Glob: "**/auth/**/*.ts"
```

### 2. **正規表現パターン**

```regex
# 関数定義の検索
function\s+(\w+)\s*\(

# クラス定義の検索  
class\s+(\w+)

# import文の検索
import.*from\s+['"](.*?)['"]

# 型定義の検索
interface\s+(\w+)|type\s+(\w+)\s*=

# コメント内のTODO/FIXME
(TODO|FIXME|XXX).*

# 環境変数の使用
process\.env\.(\w+)
```

### 3. **ファイル種別別検索**

```typescript
// TypeScript/JavaScript
include: "*.{ts,tsx,js,jsx}"

// 設定ファイル
include: "*.{json,yml,yaml,env}"

// ドキュメント
include: "*.{md,txt,rst}"

// テストファイル
include: "*.{test,spec}.{ts,js}"
```

## プロジェクト構造の理解

### 1. **ディレクトリ構造の把握**

```bash
# 主要ディレクトリ確認
LS: /project-root

# 深い階層の確認
Glob: "**/package.json" → サブプロジェクト発見
Glob: "**/src/**" → ソースコード構造
Glob: "**/test/**" → テスト構造
```

### 2. **プロジェクト固有パターンの学習**

```typescript
// よくあるパターン
components/ → UIコンポーネント
utils/ → ユーティリティ関数
services/ → API通信、外部サービス
types/ → TypeScript型定義
__tests__/ → テストファイル
docs/ → ドキュメント
```

### 3. **設定ファイルの確認**

```typescript
// 重要な設定ファイル
package.json → 依存関係、スクリプト
tsconfig.json → TypeScript設定
.eslintrc.* → Lint設定
.gitignore → Git除外設定
README.md → プロジェクト概要
```

## 検索結果の活用

### 1. **段階的詳細化**

```
1. 概要把握 → Task Tool で全体像
2. 候補絞り込み → Grep で具体的箇所  
3. 詳細確認 → Read で正確な内容
```

### 2. **関連性の調査**

```
1. 中心となるファイル/関数を特定
2. そこから参照されるもの/参照するものを調査
3. 依存関係グラフの構築
```

### 3. **変更影響範囲の評価**

```
1. 変更対象の特定
2. 影響を受ける可能性のあるコード検索
3. テストコードの存在確認
4. ドキュメントの更新要否確認
```

## トラブルシューティング

### 1. **検索結果が多すぎる場合**

```
対策:
- より具体的なパターンを使用
- ファイル種別を限定（include parameter）
- 除外パターンの活用（.git/, node_modules/）
```

### 2. **検索結果が見つからない場合**

```
対策:  
- パターンを緩く（大文字小文字無視）
- 部分マッチでの検索
- 類似名称での検索
- Globでファイル存在確認
```

### 3. **パフォーマンス問題**

```
対策:
- Task Toolの積極活用
- 検索範囲の限定
- 段階的な絞り込み
- 並行検索での効率化
```
