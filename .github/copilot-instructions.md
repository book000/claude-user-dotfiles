# GitHub Copilot Instructions

## プロジェクト概要

- **目的**: Claude Code IDE のカスタム設定とユーティリティの管理
- **主な機能**:
  - Claude Code 完了通知スクリプト（Discord 連携）
  - Claude AI 利用制限監視スクリプト
  - Git プルラッパー
  - プラグイン設定と dotfiles 管理
- **対象ユーザー**: Claude Code IDE ユーザー（個人用 dotfiles リポジトリ）

## 共通ルール

- 会話は日本語で行う。
- PR とコミットは Conventional Commits に従う。`<description>` は日本語で記載する。
  - 例: `feat: Discord 通知機能を追加`
- ブランチは Conventional Branch に従う。`<type>` は短縮形（feat, fix）を使用する。
  - 例: `feat/add-notification-script`
- 日本語と英数字の間には半角スペースを入れる。

## 技術スタック

- **言語**: Bash (Shell Script)
- **パッケージマネージャー**: なし（Bash スクリプトのみ）
- **外部依存**:
  - `jq`: JSON クエリと操作
  - `curl`: HTTP リクエスト（Discord webhook）
  - `git`: バージョン管理
  - `tmux`: ターミナルマルチプレクサー連携
  - `hostname`: マシン識別
  - `date`: タイムスタンプ生成

## コーディング規約

- **コメント言語**: 日本語
- **エラーメッセージ**: 英語
- **シェバン**: `#!/usr/bin/env bash` を使用
- **クロスプラットフォーム対応**: Windows (Git Bash/WSL), Linux, macOS をサポート
- **パス変換**: Windows パス（C:\, WSL, Git Bash）を Unix パスに変換する処理を含める

## 開発コマンド

このリポジトリには package.json がありません。以下のコマンドで手動テストを実施します。

```bash
# スクリプトの構文チェック
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

## テスト方針

- **テストフレームワーク**: なし（マニュアルテスト）
- **テスト方法**:
  - 構文チェック: `bash -n <スクリプトファイル>`
  - 実行テスト: テスト環境で実際に実行して動作確認
  - Discord webhook テスト: テスト用 webhook URL で通知確認

## セキュリティ / 機密情報

- **Discord webhook URL や token は `.env` ファイルで管理し、Git にコミットしない。**
- **環境変数 `DISCORD_TOKEN`, `MENTION_USER_ID`, `DISCORD_WEBHOOK_URL` は設定ファイルや環境変数で管理する。**
- **スクリプト内にハードコードされた認証情報を含めない。**
- **ログに個人情報や認証情報を出力しない。**

## ドキュメント更新

スクリプトや設定を変更した場合、以下のドキュメントを更新すること：

- `CLAUDE.md`: プロジェクト固有のルールや制約が追加された場合
- `rules/context7.md`: Context7 の使用方法に変更があった場合
- `README.md` (存在する場合): リポジトリの概要や使い方に変更があった場合

## リポジトリ固有

- **Git Worktree**: サポートされているが、現在は使用していない。必要に応じて `.bare/` 構成で作成する。
- **Renovate PR**: Renovate が作成した既存のプルリクエストには追加コミットや更新を行わない。
- **Serena ツール**: Claude Code で Serena が使用可能。
- **他エージェント連携**: ask-codex (コードレビュー) と ask-gemini (外部情報確認) が利用可能。
- **実行環境**: Windows (Git Bash) で動作するが、bash コマンドを使用する。PowerShell コマンドは `powershell -Command ...` で明示的に実行する。
- **スクリプトの配置**: `scripts/` ディレクトリ以下に機能ごとにサブディレクトリを作成して配置する。
  - `scripts/completion-notify/`: 完了通知関連
  - `scripts/limit-unlocked/`: 利用制限監視関連
- **設定ファイル**: `settings.json` で Claude Code のプラグイン設定を管理する。
