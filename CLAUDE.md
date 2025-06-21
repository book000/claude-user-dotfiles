# CLAUDE.md - Claude Code グローバル設定

Claude Code (claude.ai/code) のグローバル指針を提供します。

## 🎯 基本原則

### コミュニケーション
- **日本語優先**: すべての会話は日本語で行う（MUST）
- **簡潔性**: 前置きや不要な説明は NEVER 含めず、直接的に回答する SHOULD
- **具体性**: 抽象的な説明よりも具体的なコード例や手順を ALWAYS 提示する

### コード品質とパターン
- **既存規約の尊重**: プロジェクトの既存コード規約・アーキテクチャに MUST 従う
- **依存関係の確認**: 新しいライブラリ使用前に package.json で既存依存関係を ALWAYS 確認する
- **セキュリティ重視**: 認証情報や機密データを NEVER 漏洩させない

### 学習とルール管理
- **継続指示の標準化**: 一回限りでない指示は ALWAYS「これを標準ルールにしますか？」と確認する
- **ルール追加**: YES回答時は MUST CLAUDE.mdに追加し、以降の標準として適用する

#### 継続的指示の判断基準
**汎用性レベルによる分類:**
- **レベル1（即座にルール化）**: 全プロジェクト共通の基本操作・品質基準
  - 例: コミットメッセージ形式、ファイル命名規則、テスト実行手順
- **レベル2（確認後ルール化）**: 多くのプロジェクトで適用可能な指示
  - 例: 特定技術スタックでの実装パターン、開発ツール設定
- **レベル3（プロジェクト固有）**: 特定プロジェクトのみで有効な指示
  - 例: 固有のビジネスロジック、特殊な環境設定

**判定フロー:**
1. 指示内容の汎用性評価（上記レベル分け）
2. 再利用頻度の予測（週次/月次/年次）
3. 適用範囲の確認（個人/チーム/組織）
4. レベル1→即座にルール化、レベル2→確認、レベル3→記録のみ
## 🚀 主要ワークフロー

### Issue対応（自動化フロー）
`"issue #nn を対応してください"` → 完全自動実行:

```bash
1. gh issue view {nn}        # Issue内容確認
2. git checkout -b issue-{nn}-{description} --no-track {remote}/{main}
3. # 実装作業
4. {package_manager} run lint && {package_manager} run test
5. git commit -m "{type}: {title}\n\nCloses #{nn}"
6. git push -u origin {branch}
7. gh pr create --title "{type}: {title}" --body "Closes #{nn}"
```

### ブランチとGit操作
- **upstream優先**: 存在する場合はupstreamのメインブランチをベース
- **メインブランチ自動判定**: `git remote show {remote}` でHEADブランチを取得
- **no-track設定**: `git checkout -b {branch} --no-track {remote}/{main}`

### PR作成の標準
- **タイトル**: Conventional Commits形式 (`feat:`, `fix:`, `docs:`等)
- **本文**: 日本語で概要、変更内容、テスト内容を記載
- **Issue連携**: `Closes #{issue_number}` で自動クローズ

### レビュー対応プロセス
`"レビューに対応してください"` → PRコメント・サジェストコメント両方に対応:

```bash
# Copilot レビュー取得
gh api repos/{owner}/{repo}/pulls/{pr}/comments | jq '.[] | select(.user.login == "github-copilot[bot]")')

# Human レビュー対応後は「Resolve conversation」で解決
```

### 品質チェック（コミット前必須）
```bash
# パッケージマネージャー自動判定
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn"
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

# 品質チェック実行
$PM run lint && $PM run test && $PM run typecheck
```

## 🛠️ ツール使用の最適化

### ファイル操作の優先順位
1. **Read** → 既存ファイル内容を ALWAYS 確認する（MUST）
2. **Edit** → 部分的な修正を SHOULD 優先する
3. **MultiEdit** → 同一ファイル内の複数箇所修正時に使用
4. **Write** → 新規ファイルを NEVER 不必要に作成せず、明示的要求時のみ使用

### パッケージマネージャー判定（自動化）
```bash
# ロックファイルで判定
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn"
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

# プロジェクト固有のコマンド実行
$PM run lint
$PM run test
```

### 並行処理と効率化
- **複数ツール同時実行**: 独立したタスクのバッチ処理
- **効率的なワークフロー**: 待機時間の最小化

### 検索戦略の効率化
1. **Task Tool**: 複雑な調査・複数ファイルにわたる検索は ALWAYS これを使用
2. **Grep Tool**: 特定パターンの高速検索に SHOULD 使用
3. **Glob Tool**: ファイル名パターンでの検索に使用
4. **並行実行**: 独立した検索を MUST 同時実行してパフォーマンス向上

### 大量データ検証
多数ファイル参照時は ALWAYS 一時的な検証スクリプトを作成・実行し、NEVER コミットしない:

```bash
# 検証スクリプト例
cat > verify_temp.sh << 'EOF'
#!/bin/bash
# 具体的な検証ロジック
EOF
chmod +x verify_temp.sh && ./verify_temp.sh && rm verify_temp.sh
```

### 最新情報の活用
設計・実装・問題解決時は WebSearch/WebFetch で最新のベストプラクティスを調査

## 📁 プロジェクト固有設定

各プロジェクトで `./CLAUDE.md` と `.claude/` フォルダを作成:

```markdown
# プロジェクト用 CLAUDE.md テンプレート
## プロジェクト概要
- 技術スタック: 
- アーキテクチャ: 
- 主要な依存関係: 

## 開発環境
- パッケージマネージャー: 
- 重要なコマンド:
  - dev: `{pm} run dev`
  - build: `{pm} run build`
  - lint: `{pm} run lint`
  - test: `{pm} run test`

## 注意事項
- 
```

## ⚡ Claude Code 最新機能活用

### 拡張思考 (Extended Thinking)
- `"think"` または `"think harder"` で深い分析を実行
- 複雑なアーキテクチャ決定やデバッグに活用

### メモリとコンテキスト管理
- `@path/to/file` でファイル参照
- `#` で始めるとメモリファイルへの保存を提案
- `/memory` スラッシュコマンドでメモリファイル編集

### 会話管理
- `--continue` で最新の会話を継続
- `--resume` で過去の会話から選択
- コンテキストとツール状態を完全保持

### 画像解析
- UI要素、図表、スクリーンショットを貼り付け可能
- 視覚的コンテンツからコード提案を生成

## 📚 詳細ガイド

より詳細な情報は以下を参照：

- **ワークフロー詳細**: @guides/workflows.md
- **ツール活用テクニック**: @guides/tools-advanced.md  
- **ベストプラクティス**: @guides/best-practices.md
- **プロジェクト設定テンプレート**: @templates/project-setup.md
- **全体構成**: @README.md

## 🔒 重要な制約事項

- **最小限の原則**: 求められたこと以上でも以下でもなく、MUST 正確に実行する
- **ファイル作成の抑制**: NEVER 不必要なファイルを作成せず、ALWAYS 既存ファイルの編集を優先する
- **ドキュメント作成の禁止**: NEVER ユーザーが明示的に要求しない限り *.md や README ファイルを作成しない
- **セキュリティ最優先**: NEVER 認証情報やAPIキーを漏洩させない

## 🔄 Git操作とコミット管理

### コミット後の必須チェックフロー
```bash
# 1. コミット実行
git commit -m "feat: 新機能を追加

Closes #123

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 2. 未コミット変更の確認（MUST）
git status

# 3. 未コミット変更がある場合
if [ "$(git status --porcelain)" ]; then
  git diff  # 変更内容確認
  # MUST 関連変更を同じPRに含める
  git add . && git commit --amend --no-edit
fi

# 4. プッシュ前の最終確認
git status              # クリーンな状態確認
git log --oneline -5    # コミット履歴確認
git push
```

### PR作成・更新時の確認事項
- 全ての関連変更がPRに含まれているか
- 追加コミット後はPR本文も更新
- `gh pr view` でPR状態を確認

### 設定同期（~/.claude変更時）
```bash
# ~/.claude での変更後は MUST 自動コミット・プッシュ
cd ~/.claude
if ! git diff --quiet; then
  git add .
  git commit -m "update: Claude設定を更新

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
  git push
fi
```