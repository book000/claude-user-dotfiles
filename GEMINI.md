# Gemini CLI 作業方針

## 目的

このドキュメントは、claude-user-dotfiles リポジトリにおける Gemini CLI 向けのコンテキストと作業方針を定義します。

## 出力スタイル

- **言語**: 日本語
- **トーン**: 専門的かつ明確
- **形式**: Markdown 形式で構造化された回答

## 共通ルール

- **会話言語**: 日本語
- **コミット規約**: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) に従う
  - `<type>(<scope>): <description>` 形式
  - `<description>` は日本語で記載
  - 例: `feat: Discord 通知機能を追加`
- **ブランチ命名**: [Conventional Branch](https://conventional-branch.github.io) に従う
  - `<type>/<description>` 形式
  - `<type>` は短縮形（feat, fix）を使用
  - 例: `feat/add-notification-script`
- **日本語と英数字の間**: 半角スペースを挿入

## プロジェクト概要

- **目的**: Claude Code IDE のカスタム設定とユーティリティの管理
- **主な機能**:
  - Claude Code 完了通知スクリプト（Discord 連携）
  - Claude AI 利用制限監視スクリプト
  - Git プルラッパー
  - プラグイン設定と dotfiles 管理

## コーディング規約

- **コメント言語**: 日本語
- **エラーメッセージ言語**: 英語
- **シェバン**: `#!/usr/bin/env bash` を使用
- **クロスプラットフォーム対応**: Windows (Git Bash/WSL), Linux, macOS をサポート

## 開発コマンド

このリポジトリには package.json がありません。以下のコマンドで手動テストを実施します。

```bash
# Bash スクリプトの構文チェック
bash -n scripts/completion-notify/notify-completion-with-embed.sh
bash -n scripts/limit-unlocked/check-notify.sh
bash -n scripts/pull.sh

# スクリプトの実行（テスト環境で）
bash scripts/pull.sh

# Discord 通知スクリプトのテスト（環境変数が必要）
# DISCORD_TOKEN, MENTION_USER_ID を設定してから実行
# bash scripts/completion-notify/notify-completion-with-embed.sh

# 利用制限監視スクリプトのテスト（環境変数が必要）
# DISCORD_WEBHOOK_URL を設定してから実行
# bash scripts/limit-unlocked/check-notify.sh
```

## 注意事項

### セキュリティ / 機密情報

- **Discord webhook URL や token は `.env` ファイルで管理し、Git にコミットしない。**
- **環境変数 `DISCORD_TOKEN`, `MENTION_USER_ID`, `DISCORD_WEBHOOK_URL` は設定ファイルや環境変数で管理する。**
- **スクリプト内にハードコードされた認証情報を含めない。**
- **ログに個人情報や認証情報を出力しない。**

### 既存ルールの優先

- プロジェクトの既存のコーディングスタイルとパターンに従う
- 日本語コメントを記載する
- クロスプラットフォーム対応を考慮する

### 既知の制約

- **パッケージマネージャー**: なし（Bash スクリプトのみ）
- **テストフレームワーク**: なし（マニュアルテスト）
- **外部依存**: jq, curl, git, tmux, hostname, date が必要

## リポジトリ固有

### 技術スタック

- **言語**: Bash (Shell Script)
- **外部依存**: jq, curl, git, tmux, hostname, date
- **プラットフォーム**: Windows (Git Bash/WSL), Linux, macOS

### ディレクトリ構造

```text
claude-user-dotfiles/
├── .github/                       # GitHub 設定
│   └── copilot-instructions.md   # Copilot 向けプロンプト
├── CLAUDE.md                      # Claude Code 向けプロンプト
├── AGENTS.md                      # 汎用 AI エージェント向けプロンプト
├── GEMINI.md                      # Gemini CLI 向けプロンプト（このファイル）
├── settings.json                  # Claude Code 設定
├── rules/
│   └── context7.md               # Context7 使用ガイドライン
└── scripts/
    ├── pull.sh                    # Git プルラッパー
    ├── completion-notify/
    │   └── notify-completion-with-embed.sh  # Discord 完了通知
    └── limit-unlocked/
        └── check-notify.sh        # 利用制限監視
```

### 主要スクリプト

#### scripts/completion-notify/notify-completion-with-embed.sh

Claude Code セッション完了時に Discord へ通知を送信する。

- **トリガー**: Claude Code Stop hook イベント
- **入力**: Claude Code からの JSON（session_id, transcript_path, cwd 等）
- **処理**: Windows パス変換、transcript 抽出、Discord embed 構築、webhook 送信
- **依存**: jq, curl, DISCORD_TOKEN, MENTION_USER_ID 環境変数

#### scripts/limit-unlocked/check-notify.sh

Claude AI 利用制限を監視し、制限解除時に通知する。

- **トリガー**: 手動実行（cron や scheduled task から）
- **処理**: セッションファイルスキャン、制限メッセージ検索、Discord 通知、tmux 送信
- **依存**: tmux, jq, curl, DISCORD_WEBHOOK_URL 環境変数

#### scripts/pull.sh

git pull の convenience wrapper。"already up to date" メッセージをフィルタする。

### 実装パターン

#### 推奨パターン

- **クロスプラットフォーム対応**: Windows パス変換処理を含める
  - Git Bash: `/c/Users/...`
  - WSL: `/mnt/c/Users/...`
  - Windows: `C:\Users\...`
- **環境変数の使用**: 認証情報は環境変数で管理
- **エラーハンドリング**: ファイルが見つからない場合は graceful に終了
- **jq の活用**: JSON 操作には jq を使用

#### 非推奨パターン

- **ハードコードされた認証情報**: スクリプト内に認証情報を記載しない
- **プラットフォーム固有のパス**: 特定のプラットフォームでしか動作しないパスを使用しない
- **エラー無視**: エラーが発生した場合は適切にハンドリングする

### ドキュメント更新

スクリプトや設定を変更した場合、以下のドキュメントを更新すること：

- `CLAUDE.md`: プロジェクト固有のルールや制約が追加された場合
- `rules/context7.md`: Context7 の使用方法に変更があった場合
- `README.md` (存在する場合): リポジトリの概要や使い方に変更があった場合

### 環境変数

- `DISCORD_TOKEN`: Discord webhook URL (notify-completion-with-embed.sh で使用)
- `MENTION_USER_ID`: Discord メンション用ユーザー ID (notify-completion-with-embed.sh で使用)
- `DISCORD_WEBHOOK_URL`: Discord webhook URL (check-notify.sh で使用)

### 状態ファイル

- `~/.claude_limit_notified`: 利用制限監視スクリプトで通知済みイベントを追跡

### 設定ファイル

- `settings.json`: Claude Code のプラグイン設定を管理
  - 有効化されたプラグイン: wakatime, context7, code-review, feature-dev, serena, typescript-lsp, commit-commands, code-simplifier, pr-review-toolkit, plugin-dev, hookify, ask-codex, ask-gemini

## Gemini CLI の役割

Gemini CLI は、以下の観点で Claude Code をサポートします：

- **SaaS 仕様の確認**: Discord API、Claude API などの最新仕様
- **バージョン差の調査**: Bash のバージョン差、jq の機能差
- **外部一次情報の確認**: Discord webhook の仕様、Claude API の制限
- **最新情報の調査**: 新しいツールや手法の調査

Claude Code から相談を受けた場合は、最新の情報を調査し、明確な回答を提供してください。
