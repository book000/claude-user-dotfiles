# CLAUDE.md

このファイルはClaude Code (claude.ai/code) のグローバル指針を提供します。

## 基本原則

### コミュニケーション
- **日本語での会話**: すべての会話は日本語で行う
- **直接的な回答**: 前置きや説明は最小限に

### コード品質
- **既存パターンの踏襲**: プロジェクトの既存コード規約とパターンに従う
- **ライブラリ確認**: 新しいライブラリ使用前に既存依存関係を確認

### ルール管理
- **継続的指示の標準化**: 今回限りでない指示を受けた場合は「これを標準のルールにしますか？」と確認
- **ルール追加プロセス**: YES回答時はCLAUDE.mdに追加し、以降標準ルールとして適用

## 開発ワークフロー

### Issue対応（最重要）
「issue #nnを対応してください」→ 完全自動実行：
1. Issue内容確認 → 2. ブランチ作成（issue-nn-description） → 3. 実装 → 4. 品質チェック → 5. コミット・プッシュ → 6. PR作成（Closes #nn）
詳細: @workflows/issue-handling.md

### ブランチ戦略
upstream優先、メインブランチ自動判定、no-track設定でブランチ作成
詳細: @workflows/branch-strategy.md

### PR作成
タイトル: Conventional Commits形式、本文: 日本語、Issue連携: Closes #nn
詳細: @workflows/pr-creation.md

### レビュー対応
「レビューに対応してください」→ PRコメント・サジェストコメント両方に対応
- Copilot: gh apiでサジェスト含む全取得
- Human (book000): 全コメント確認・対応・Resolve
詳細: @workflows/copilot-review.md

### 品質チェック
コミット前必須: パッケージマネージャー自動判定 → lint/test/typecheck実行
詳細: @workflows/quality-checks.md

### 設定同期
~/.claude変更時 → 自動コミット・プッシュ、セッション開始時 → pull実行
詳細: @workflows/config-sync.md

## ツール使用指針

### ファイル操作（重要）
優先順位: Read → Edit → Write（新規ファイル作成は最小限）
詳細: @tools/file-operations.md

### パッケージマネージャー（重要）
必ずプロジェクト固有のパッケージマネージャーを確認・使用（lock file判定）
詳細: @tools/package-manager.md

### データ検証（重要）
多くのファイル参照時 → List/Read使用せず検証用スクリプト作成・実行（コミットしない）
詳細: @tools/data-verification.md

### 検索戦略
Task Tool（推奨）→ Grep → Glob、並行検索活用
詳細: @tools/search-strategies.md

### インターネット検索
設計・実装・問題解決で最新情報・ベストプラクティス調査
詳細: @tools/internet-research.md

### 並行処理
- **複数ツール同時実行**: 独立したタスクのバッチ処理
- **効率的なワークフロー**: 待機時間の最小化

## プロジェクト固有設定

各プロジェクトでCLAUDE.mdと.claudeフォルダを作成、グローバル設定を参照
詳細: @project-specific/README.md

## important-instruction-reminders

Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.