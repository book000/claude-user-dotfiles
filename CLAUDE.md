# CLAUDE.md - Claude Code 動作設定

Claude Code の動作要件と制約を定義します。

## 🎯 Claude Code 動作要件

### 言語とコミュニケーション
- **日本語出力**: すべてのレスポンスは日本語で出力する MUST
- **簡潔な回答**: 不要な前置きや説明を NEVER 含めない
- **具体的な出力**: 抽象的な説明より具体的なコードやコマンドを ALWAYS 出力する

### コード処理要件
- **既存パターンの維持**: プロジェクトの既存コード規約・アーキテクチャを MUST 維持する
- **依存関係検証**: 新しいライブラリ使用前に package.json で既存依存関係を MUST 検証する
- **セキュリティ保護**: 認証情報や機密データを NEVER 出力しない

### 学習とルール適用
- **パターン認識**: 継続的な指示パターンを MUST 認識し、標準化を提案する
- **ルール更新**: 承認されたルールを MUST メモリに追加し、以降適用する

#### パターン認識アルゴリズム
指示内容を以下の基準で分類する:

**汎用性レベル:**
- **レベル1（即座ルール化）**: 全プロジェクト共通の基本操作
- **レベル2（確認後ルール化）**: 特定技術スタック向けパターン
- **レベル3（コンテキスト保持）**: プロジェクト固有の要件

**判定プロセス:**
1. 指示内容のスコープ分析
2. 再利用可能性の評価
3. 適用範囲の判定
4. ルール化レベルの決定
## 🚀 自動化ワークフロー処理

### Issue対応フロー
`"issue #nn を対応してください"` の入力時の処理シーケンス:

```bash
1. gh issue view {nn}        # Issueデータ収集
2. git checkout -b issue-{nn}-{description} --no-track {remote}/{main}  # ブランチ作成
3. # コード実装処理
4. {package_manager} run lint && {package_manager} run test  # 品質検証
5. git commit -m "{type}: {title}\n\nCloses #{nn}"  # コミット作成
6. git push -u origin {branch}  # リモートプッシュ
7. gh pr create --title "{type}: {title}" --body "Closes #{nn}"  # PR作成
8. ~/.claude/scripts/github-pr/wait-for-ci.sh  # CI完了待機（必要に応じて）
```

### Git操作アルゴリズム
- **リモート判定**: upstream 存在時は upstream を優先、非存在時は origin を使用
- **ベースブランチ自動取得**: `git remote show {remote}` でHEADブランチを取得
- **ブランチ作成ルール**: `--no-track` オプションで独立ブランチを作成

### PR作成アルゴリズム
- **タイトル生成**: Issue内容から Conventional Commits形式で自動生成
- **本文生成**: 日本語で概要・変更・テスト内容を自動構成
- **Issueリンク**: `Closes #{issue_number}` を MUST 含める

### レビュー処理アルゴリズム
`"レビューに対応してください"` の入力時の処理:

```bash
# 1. レビューデータ収集（専用スクリプト活用）
~/.claude/scripts/github-pr/collect-review.sh {pr_number}

# 2. レビュワーの正確な識別・分類処理
# - Copilot: user.login == "github-copilot[bot]" (重要: 正確な文字列マッチング)
# - Human: user.login == "book000" または他のユーザー名
# 3. タイプ別対応実装:
#    - Copilotサジェスト: コード変更提案の評価・適用
#    - Copilot一般: 設計・パフォーマンス指摘への対応
#    - Human: アーキテクチャ・要件観点での修正
# 4. GraphQL APIでconversation解決

# 注意: github-copilot[bot] の識別文字列は完全一致が必須
```

### 品質検証アルゴリズム
コミット前に MUST 実行する検証シーケンス:

```bash
# 1. パッケージマネージャー自動識別
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn" 
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

# 2. 順次検証実行
$PM run lint    # コードスタイル検証
$PM run test    # テスト実行
$PM run typecheck  # 型検証（存在する場合）
```

## 🔧 専用スクリプト連携

### スクリプト自動実行ルール
特定の指示に対してスクリプトを MUST 自動実行する:

```bash
# GitHub PR関連
"レビューに対応してください" → collect-review.sh でコメント収集
"CIが完了するまで待機" → wait-for-ci.sh で監視実行
"未解決コメントを確認" → collect-review.sh でフィルタリング

# 設定管理
"Claude設定を同期" → pull.sh で最新取得
"設定変更を確認" → git status でローカル変更確認

# 通知システム
セッション完了時 → notify-completion-with-embed.sh（Hook経由）
制限解除検出時 → check-notify.sh（定期実行）
```

### スクリプト活用優先度
1. **High Priority**: GitHub PR操作（collect-review.sh, wait-for-ci.sh）
2. **Medium Priority**: 設定同期（pull.sh）
3. **Low Priority**: 通知システム（手動/自動実行）

### スクリプト実行前チェック
```bash
# 1. 実行権限確認
if [ ! -x ~/.claude/scripts/github-pr/collect-review.sh ]; then
    chmod +x ~/.claude/scripts/github-pr/*.sh
fi

# 2. 必要な依存関係確認
command -v gh >/dev/null || echo "GitHub CLI required"
command -v jq >/dev/null || echo "jq required"

# 3. 設定ファイル確認（Discord通知使用時）
[ -f ~/.claude/scripts/completion-notify/.env ] || echo "Discord設定が必要"
```

## 🛠️ ツール実行アルゴリズム

### ファイル操作シーケンス
ファイル操作時の MUST 守る順序:
1. **Read** → 既存ファイル内容を ALWAYS 確認する
2. **Edit** → 部分修正を SHOULD 優先して実行
3. **MultiEdit** → 同一ファイル内の複数箇所修正時に使用
4. **Write** → NEVER 不必要な新規ファイルを作成しない

### パッケージマネージャー識別アルゴリズム
プロジェクト環境で MUST 実行する識別プロセス:

```bash
# ロックファイルベースの識別
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn"
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

# 識別されたパッケージマネージャーでコマンド実行
$PM run lint
$PM run test
```

### 並行処理アルゴリズム
- **バッチ実行**: 独立したタスクを MUST 同時実行する
- **待機時間最小化**: 非同期処理でパフォーマンスを最大化

### 検索ツール選択アルゴリズム
検索タスクに応じたツール選択ルール:
1. **Task Tool**: 複雑な調査・複数ファイル検索時に ALWAYS 使用
2. **Grep Tool**: 特定パターンのコンテンツ検索時に使用  
3. **Glob Tool**: ファイル名パターンマッチング時に使用
4. **並行実行**: 独立した検索を MUST 同時実行

### 大量データ検証アルゴリズム
多数ファイル検証時の MUST 実行プロセス:

```bash
# 1. 一時検証スクリプト作成
cat > verify_temp.sh << 'EOF'
#!/bin/bash
# 検証ロジック実装
EOF

# 2. 実行権付与・実行・削除
chmod +x verify_temp.sh && ./verify_temp.sh && rm verify_temp.sh

# 3. NEVER コミットに含めない
```

### 情報収集アルゴリズム
設計・実装・問題解決時の SHOULD 実行プロセス:
- WebSearch/WebFetch で最新ベストプラクティスを収集
- 公式ドキュメントを優先して参照
- 信頼性の高い情報ソースを選択

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
- **スクリプトガイド**: @guides/scripts.md
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