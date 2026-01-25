# AI エージェント共通作業方針

## 目的

このドキュメントは、claude-user-dotfiles リポジトリにおける AI エージェント共通の作業方針を定義します。

## 基本方針

- **会話言語**: 日本語
- **コメント言語**: 日本語
- **エラーメッセージ言語**: 英語
- **コミット規約**: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) に従う
  - `<type>(<scope>): <description>` 形式
  - `<description>` は日本語で記載
  - 例: `feat: Discord 通知機能を追加`
- **日本語と英数字の間**: 半角スペースを挿入

## 判断記録のルール

判断は必ずレビュー可能な形で記録すること：

1. **判断内容**: 何を決定したか
2. **代替案**: 他にどのような選択肢があったか
3. **採用理由**: なぜその案を選んだか
4. **前提条件**: 判断の前提となる条件や仮定
5. **不確実性**: 不明な点や将来変更が必要になる可能性

**重要**: 前提・仮定・不確実性を明示すること。仮定を事実のように扱わないこと。

## 開発手順（概要）

### 1. プロジェクト理解

- リポジトリの目的と主な機能を理解する
- ディレクトリ構造と主要ファイルを確認する
- 既存のドキュメント（CLAUDE.md, README.md 等）を読む

### 2. 依存関係インストール

このリポジトリには package.json がないため、依存関係のインストールは不要。

外部依存ツール（jq, curl, tmux 等）がシステムにインストールされていることを確認する。

### 3. 変更実装

- コードを変更する前に、既存のコードスタイルを確認する
- 日本語コメントを記載する
- クロスプラットフォーム対応（Windows/Linux/macOS）を考慮する

### 4. テストと Lint/Format 実行

```bash
# Bash スクリプトの構文チェック
bash -n scripts/completion-notify/notify-completion-with-embed.sh
bash -n scripts/limit-unlocked/check-notify.sh
bash -n scripts/pull.sh
```

テスト環境で実際に実行して動作確認を行う。

## セキュリティ / 機密情報

- **Discord webhook URL や token は `.env` ファイルで管理し、Git にコミットしない。**
- **環境変数 `DISCORD_TOKEN`, `MENTION_USER_ID`, `DISCORD_WEBHOOK_URL` は設定ファイルや環境変数で管理する。**
- **`DISCORD_TOKEN` は歴史的な名前だが、実際には Discord webhook URL を保持する環境変数として使用されていることに注意する（`scripts/completion-notify/notify-completion-with-embed.sh` 参照）。今後は `DISCORD_WEBHOOK_URL` の使用を推奨する。**
- **スクリプト内にハードコードされた認証情報を含めない。**
- **ログに個人情報や認証情報を出力しない。**

## リポジトリ固有

### プロジェクト概要

- **目的**: Claude Code IDE のカスタム設定とユーティリティの管理
- **主な機能**:
  - Claude Code 完了通知スクリプト（Discord 連携）
  - Claude AI 利用制限監視スクリプト
  - Git プルラッパー
  - プラグイン設定と dotfiles 管理

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
├── AGENTS.md                      # 汎用 AI エージェント向けプロンプト（このファイル）
├── GEMINI.md                      # Gemini CLI 向けプロンプト
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

- **入力**: Claude Code からの JSON（session_id, transcript_path, cwd 等）
- **処理**: Windows パス変換、transcript 抽出、Discord embed 構築、webhook 送信
- **依存**: jq, curl, DISCORD_TOKEN, MENTION_USER_ID 環境変数

#### scripts/limit-unlocked/check-notify.sh

Claude AI 利用制限を監視し、制限解除時に通知する。

- **処理**: セッションファイルスキャン、制限メッセージ検索、Discord 通知、tmux 送信
- **依存**: tmux, jq, curl, DISCORD_WEBHOOK_URL, MENTION_USER_ID 環境変数

#### scripts/pull.sh

git pull の convenience wrapper。"already up to date" メッセージをフィルタする。

### 実装時の注意点

- **クロスプラットフォーム対応**: Windows パス変換処理を含める
- **環境変数の使用**: 認証情報は環境変数で管理
- **エラーハンドリング**: ファイルが見つからない場合は graceful に終了
- **jq の活用**: JSON 操作には jq を使用

### ドキュメント更新

スクリプトや設定を変更した場合、以下のドキュメントを更新すること：

- `CLAUDE.md`: プロジェクト固有のルールや制約が追加された場合
- `rules/context7.md`: Context7 の使用方法に変更があった場合
- `README.md` (存在する場合): リポジトリの概要や使い方に変更があった場合
