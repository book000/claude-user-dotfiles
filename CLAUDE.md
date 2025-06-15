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

@workflows/branch-strategy.md
@workflows/issue-handling.md
@workflows/quality-checks.md
@workflows/pr-creation.md
@workflows/copilot-review.md
@workflows/config-sync.md

## ツール使用指針

@tools/file-operations.md
@tools/search-strategies.md
@tools/package-manager.md
@tools/data-verification.md
@tools/internet-research.md

### 並行処理

- **複数ツール同時実行**: 独立したタスクのバッチ処理
- **効率的なワークフロー**: 待機時間の最小化

## important-instruction-reminders

Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
