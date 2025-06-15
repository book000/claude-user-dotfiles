# ファイル操作指針

## 基本優先順位

1. **Read優先**: ファイル操作前の内容確認
2. **Edit活用**: 既存ファイルの部分修正
3. **Write慎重**: 新規ファイル作成は必要時のみ

## 操作パターン

### 1. **既存ファイルの確認・修正**

```
1. Read → ファイル内容の確認
2. Edit → 部分的な修正
3. Read → 修正結果の確認（必要に応じて）
```

**推奨フロー:**

- 必ずReadツールで現在の内容を確認
- Editツールで最小限の変更を実施
- 大幅な変更の場合は、MultiEditを検討

### 2. **新規ファイル作成**

```
1. 必要性の確認 → 既存ファイルで対応できないか検討
2. Write → 新規ファイル作成（最後の手段）
```

**作成前チェックリスト:**

- [ ] 既存ファイルでの対応が不可能
- [ ] ファイル作成が明示的に要求されている
- [ ] 適切なディレクトリ構造を確認済み

### 3. **ファイル検索・探索**

```
1. Glob → ファイル名パターンでの検索
2. Grep → ファイル内容での検索
3. LS → ディレクトリ構造の確認
```

## Edit操作のベストプラクティス

### 1. **正確な文字列マッチング**

```typescript
// ❌ 不正確（インデントや改行が不一致）
old_string: "function getData() {
return data;
}"

// ✅ 正確（Readツールの出力から正確にコピー）
old_string: "    function getData() {\n        return data;\n    }"
```

### 2. **コンテキストの活用**

```typescript
// ❌ 曖昧（複数箇所にマッチする可能性）
old_string: "const data = [];"

// ✅ 一意（周辺コードを含める）
old_string: "// ユーザーデータ初期化\nconst data = [];\nconst users = new Map();"
```

### 3. **段階的修正**

```typescript
// 大きな変更は複数のEdit操作に分割
// 1. 関数名の変更
// 2. 引数の追加
// 3. 処理ロジックの修正
```

## MultiEdit操作の活用

### 適用ケース

- 同一ファイル内の複数箇所修正
- 変数名の一括リネーム
- インポート文の整理

### 注意点

```typescript
// ❌ 順序依存の問題
edits: [
  { old_string: "oldName", new_string: "newName" },
  { old_string: "function oldName()", new_string: "function newName()" }
]

// ✅ 具体的な文字列での指定
edits: [
  { old_string: "function oldName()", new_string: "function newName()" },
  { old_string: "return oldName;", new_string: "return newName;" }
]
```

## ファイル操作の効率化

### 1. **並行読み取り**

```typescript
// 複数ファイルを同時に読み取り
Read tool calls:
- file1.ts
- file2.ts  
- file3.ts
```

### 2. **事前調査**

```typescript
// ファイル構造の把握
1. LS → ディレクトリ構造確認
2. Glob → 関連ファイル抽出
3. Read → 主要ファイル内容確認
```

### 3. **変更影響範囲の確認**

```typescript
// 変更前の影響調査
1. Grep → 関数/変数の使用箇所検索
2. Read → 関連ファイルの確認
3. Edit → 安全な修正の実施
```

## エラー対応

### 1. **Editエラーの対処**

```
Error: old_string not found
→ Readツールで正確な文字列を再確認
→ 改行・インデント・スペースを正確に合わせる

Error: old_string matches multiple locations  
→ より具体的なコンテキストを含める
→ replace_all=true の検討
```

### 2. **ファイル権限エラー**

```bash
# ファイル権限の確認
ls -la filename

# 必要に応じて権限変更
chmod 644 filename
```

### 3. **エンコーディング問題**

```bash
# ファイルエンコーディング確認
file filename

# UTF-8での保存確認
```

## プロジェクト固有の考慮事項

### 1. **コード規約の遵守**

- 既存のインデント形式（タブ/スペース）
- 改行コード（LF/CRLF）
- 文字エンコーディング（UTF-8）

### 2. **フレームワーク固有ルール**

- React: JSX記法、Hooks規則
- Vue: template, script, style分離
- Node.js: CommonJS/ES Module

### 3. **言語固有の注意点**

- TypeScript: 型定義の整合性
- Python: インデント（4スペース）
- Go: gofmt準拠
