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

## 開発ワークフロー

### Issue対応（最重要）
「issue #nnを対応してください」→ 完全自動実行：
1. Issue内容確認 → 2. ブランチ作成（type/description） → 3. 実装 → 4. 品質チェック → 5. コミット・プッシュ → 6. PR作成（Closes #nn）
詳細: @workflows/issue-handling.md

### ブランチ戦略
upstream優先、メインブランチ自動判定、no-track設定、Conventional Commits形式ブランチ名（feat/, fix/, docs/等）
詳細: @workflows/branch-strategy.md

### PR作成・更新
タイトル: Conventional Commits形式、本文: 日本語、Issue連携: Closes #nn、**継続的更新**: 実装変更時PR本文・タイトル適宜更新
詳細: @workflows/pr-creation.md

### レビュー対応（完全タスク管理）
「レビューに対応してください」→ **即座にTodoWrite実行**、全手順をタスク化して逐次完了チェック
1. レビュー情報収集 → 2. 各コメント対応実装 → 3. 品質チェック → 4. **コミット・プッシュ** → 5. Resolve conversation → 6. 完了報告
- Copilot: gh apiでサジェスト含む全取得、不適切なコメントは簡潔にReply→Resolve
- Human (book000): 全コメント確認・対応・GraphQL APIでresolve
- **重要**: 各手順完了時に即座にTodo完了マーク、漏れ防止徹底
詳細: @workflows/copilot-review.md

### 品質チェック
コミット前必須: パッケージマネージャー自動判定 → lint/test/typecheck実行
詳細: @workflows/quality-checks.md

### 設定同期（重要・自動実行）
~/.claude変更時 → **即座に自動コミット・プッシュ実行**（ユーザー指示不要）、セッション開始時 → pull実行
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

### ドキュメント記述（重要）
**プロセス中心**: Claude Codeの実際の動作に焦点、スクリプトは手動実行時のみ提供、説明は動作フローを重視
詳細: @guidelines/documentation-guidelines.md

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