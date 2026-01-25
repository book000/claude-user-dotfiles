# Claude Code 作業方針

## 目的

このドキュメントは、claude-user-dotfiles リポジトリにおける Claude Code の作業方針とプロジェクト固有ルールを定義します。

## 判断記録のルール

判断は必ずレビュー可能な形で記録すること：

1. **判断内容の要約**: 何を決定したか
2. **検討した代替案**: 他にどのような選択肢があったか
3. **採用しなかった案とその理由**: なぜその案を選ばなかったか
4. **前提条件・仮定・不確実性**: 判断の前提となる条件や仮定
5. **他エージェントによるレビュー可否**: ask-codex や ask-gemini でレビュー可能か

**重要**: 前提・仮定・不確実性を明示すること。仮定を事実のように扱ってはならない。

## プロジェクト概要

- **目的**: Claude Code IDE のカスタム設定とユーティリティの管理
- **主な機能**:
  - Claude Code 完了通知スクリプト（Discord 連携）
  - Claude AI 利用制限監視スクリプト
  - Git プルラッパー
  - プラグイン設定と dotfiles 管理

## 重要ルール

- **会話言語**: 日本語
- **コミット規約**: [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) に従う。`<description>` は日本語で記載する。
  - 例: `feat: Discord 通知機能を追加`
- **コメント言語**: 日本語
- **エラーメッセージ言語**: 英語
- **日本語と英数字の間**: 半角スペースを挿入する

## 環境のルール

- **ブランチ命名**: [Conventional Branch](https://conventional-branch.github.io) に従う。`<type>` は短縮形（feat, fix）を使用する。
  - 例: `feat/add-notification-script`
- **GitHub リポジトリ調査**: テンポラリディレクトリに git clone して、そこでコード検索する。
- **Renovate PR の扱い**: Renovate が作成した既存のプルリクエストには追加コミットや更新を行わない。
- **実行環境**: Windows (Git Bash) で動作するが、bash コマンドを使用する。PowerShell コマンドは `powershell -Command ...` で明示的に実行する。
- **CLAUDE.md の更新**: このファイルの内容は適宜更新すること。
- **Serena の使用**: このプロジェクトでは Serena が使用可能。

## Git Worktree

このプロジェクトでは Git Worktree がサポートされているが、現在は使用していない。

Git Worktree を使用する場合のディレクトリ構成：

```text
.bare/              # bare リポジトリ（隠しディレクトリ）
master/             # master ブランチの worktree
develop/            # develop ブランチの worktree
feature/
  x/                # feature/x ブランチの worktree
```

新規ブランチを作成する場合は、ブランチ作成後に Git Worktree を新規作成すること。

## コード改修時のルール

- **日本語と英数字の間**: 半角スペースを挿入すること
- **エラーメッセージの絵文字**: 既存のエラーメッセージで、先頭に絵文字がある場合は、全体でエラーメッセージに絵文字を設定すること。絵文字はエラーメッセージに即した一文字の絵文字である必要がある。
- **docstring の記載**: 関数には docstring (コメント) を記載・更新すること。日本語で記載する。

## 相談ルール

Codex CLI や Gemini CLI の他エージェントに相談することができる。以下の観点で使い分けること：

### Codex CLI (ask-codex)

- 実装コードに対するソースコードレビュー
- 関数設計、モジュール内部の実装方針などの局所的な技術判断
- アーキテクチャ、モジュール間契約、パフォーマンス / セキュリティといった全体影響の判断
- 実装の正当性確認、機械的ミスの検出、既存コードとの整合性確認

### Gemini CLI (ask-gemini)

- SaaS 仕様、言語・ランタイムのバージョン差、料金・制限・クォータといった、最新の適切な情報が必要な外部依存の判断
- 外部一次情報の確認、最新仕様の調査、外部前提条件の検証

### 他エージェントからの指摘への対応

他エージェントが指摘・異議を提示した場合、Claude Code は必ず以下のいずれかを行う。**黙殺・無言での不採用は禁止する。**

- 指摘を受け入れ、判断を修正する
- 指摘を退け、その理由を明示する

以下は必ず実施すること：

- 他エージェントの提案を鵜呑みにせず、その根拠や理由を理解する
- 自身の分析結果と他エージェントの意見が異なる場合は、双方の視点を比較検討する
- 最終的な判断は、両者の意見を総合的に評価した上で、自身で下す

## 開発コマンド

このリポジトリには package.json がない。以下のコマンドで手動テストを実施する。

```bash
# スクリプトの構文チェック
bash -n scripts/completion-notify/notify-completion-with-embed.sh
bash -n scripts/limit-unlocked/check-notify.sh
bash -n scripts/pull.sh

# スクリプトの実行（テスト環境で）
bash scripts/pull.sh
```

## アーキテクチャと主要ファイル

### ディレクトリ構造

```text
claude-user-dotfiles/
├── .github/                       # GitHub 設定
│   └── copilot-instructions.md   # Copilot 向けプロンプト
├── CLAUDE.md                      # Claude Code 向けプロンプト（このファイル）
├── AGENTS.md                      # 汎用 AI エージェント向けプロンプト
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

- **目的**: Claude Code セッション完了時に Discord へ通知を送信
- **トリガー**: Claude Code Stop hook イベント
- **入力**: Claude Code からの JSON（session_id, transcript_path, cwd 等）
- **処理**:
  1. Windows パス（C:\, WSL, Git Bash）を Unix パスに変換
  2. セッション transcript を jq で抽出
  3. 最後の 5 メッセージを解析
  4. Discord embed ペイロードを構築
  5. curl で Discord webhook に送信
- **依存**: jq, curl, DISCORD_TOKEN, MENTION_USER_ID 環境変数

#### scripts/limit-unlocked/check-notify.sh

- **目的**: Claude AI 利用制限を監視し、制限解除時に通知
- **トリガー**: 手動実行（cron や scheduled task から）
- **処理**:
  1. `~/.claude/projects/**/*.jsonl` からセッションファイルをスキャン
  2. "Claude AI usage limit reached" メッセージを検索
  3. イベントを "past" (期限切れ) または "future" (未来) に分類
  4. 新たに期限切れになった制限を検出
  5. Discord 通知を送信
  6. tmux セッションに "続けてください" を送信
  7. 状態ファイルで通知済みイベントを追跡
- **依存**: tmux, jq, curl, DISCORD_WEBHOOK_URL, MENTION_USER_ID 環境変数

#### scripts/pull.sh

- **目的**: git pull の convenience wrapper
- **処理**: git pull を実行し、"already up to date" メッセージをフィルタ

## 実装パターン

### 推奨パターン

- **クロスプラットフォーム対応**: Windows パス変換処理を含める
  - Git Bash: `/c/Users/...`
  - WSL: `/mnt/c/Users/...`
  - Windows: `C:\Users\...`
- **環境変数の使用**: 認証情報は環境変数で管理
- **エラーハンドリング**: ファイルが見つからない場合は graceful に終了
- **jq の活用**: JSON 操作には jq を使用
- **ログ出力**: 重要な処理はログに記録

### 非推奨パターン

- **ハードコードされた認証情報**: スクリプト内に認証情報を記載しない
- **プラットフォーム固有のパス**: 特定のプラットフォームでしか動作しないパスを使用しない
- **エラー無視**: エラーが発生した場合は適切にハンドリングする

## テスト

### テスト方針

- **テストフレームワーク**: なし（マニュアルテスト）
- **構文チェック**: `bash -n <スクリプトファイル>` で構文エラーを検出
- **実行テスト**: テスト環境で実際に実行して動作確認
- **Discord webhook テスト**: テスト用 webhook URL で通知確認

### テスト追加条件

- スクリプトの追加・変更時は、必ず構文チェックを実施すること
- Discord 通知機能の変更時は、テスト用 webhook URL で通知確認を行うこと

## ドキュメント更新ルール

### 更新対象

- `CLAUDE.md` (このファイル): プロジェクト固有のルールや制約が追加された場合
- `rules/context7.md`: Context7 の使用方法に変更があった場合
- `README.md` (存在する場合): リポジトリの概要や使い方に変更があった場合

### 更新タイミング

- スクリプトや設定を変更した場合
- 新しいルールや制約が追加された場合
- プロジェクトの構成が変更された場合

## 作業チェックリスト

以下の内容については、Todo ツールを使用し、漏らさずすべてを実施すること。

### 新規改修時

新規改修を行う前に、以下を必ず確認すること：

1. プロジェクトについて詳細に探索し理解すること
2. 作業を行うブランチが適切であること。すでに PR を提出しクローズされたブランチでないこと
3. 最新のリモートブランチに基づいた新規ブランチであること
4. PR がクローズされ、不要となったブランチは削除されていること
5. プロジェクトで指定されたパッケージマネージャにより、依存パッケージをインストールしたこと
   - **注**: このリポジトリにはパッケージマネージャがないため、この項目はスキップ可能

### コミット・プッシュ前

コミット・プッシュする前に、以下を必ず確認すること：

1. コミットメッセージが [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) に従っていること。ただし、`<description>` は日本語で記載する。
2. コミット内容にセンシティブな情報が含まれていないこと
3. Lint / Format エラーが発生しないこと
   - Bash スクリプトの場合: `bash -n <スクリプトファイル>` で構文チェック
4. 動作確認を行い、期待通り動作すること

### プルリクエスト作成前

プルリクエストを作成する前に、以下を必ず確認すること：

1. プルリクエストの作成をユーザーから依頼されていること
2. コミット内容にセンシティブな情報が含まれていないこと
3. コンフリクトする恐れが無いこと

### プルリクエスト作成後

プルリクエストを作成したあとは、以下を必ず実施すること。PR 作成後のプッシュ時に毎回実施すること。

**時間がかかる処理が多いため、Task を使って並列実行すること。**

1. コンフリクトが発生していないこと
2. PR 本文の内容は、ブランチの現在の状態を、今までのこの PR での更新履歴を含むことなく、最新の状態のみ、漏れなく日本語で記載されていること。この PR を見たユーザーが、最終的にどのような変更を含む PR なのかをわかりやすく、細かく記載されていること
3. `gh pr checks <PR ID> --watch` で GitHub Actions CI を待ち、その結果がエラーとなっていないこと。成功している場合でも、ログを確認し、誤って成功扱いになっていないこと。もし GitHub Actions が動作しない場合は、ローカルで CI と同等のテストを行い、CI が成功することを保証すること。
4. `request-review-copilot` コマンドが存在する場合、`request-review-copilot https://github.com/$OWNER/$REPO/pull/$PR_NUMBER` で GitHub Copilot へレビューを依頼すること。レビュー依頼は自動で行われる場合もあるし、制約により `request-review-copilot` を実行しても GitHub Copilot がレビューしないケースがある
5. 10 分以内に投稿される GitHub Copilot レビューへの対応を行うこと。対応したら、レビューコメントそれぞれに対して返信を行うこと。レビュアーに GitHub Copilot がアサインされていない場合はスキップして構わない
6. `/code-review:code-review` によるコードレビューを実施したこと。コードレビュー内容に対しては、**スコアが 50 以上の指摘事項** に対して対応すること（80 がボーダーラインではない）

## リポジトリ固有

- **Discord 連携**: 完了通知と利用制限監視で Discord webhook を使用
- **tmux 連携**: 利用制限監視スクリプトで tmux セッションに自動送信
- **クロスプラットフォーム**: Windows (Git Bash/WSL), Linux, macOS 対応
- **環境変数**: `DISCORD_TOKEN`, `MENTION_USER_ID`, `DISCORD_WEBHOOK_URL` を使用
- **状態ファイル**: 利用制限監視で `~/.claude/scripts/limit-unlocked/data/past.txt`, `~/.claude/scripts/limit-unlocked/data/future.txt`, `~/.claude/scripts/limit-unlocked/data/notified.txt` を使用
- **設定ファイル**: `settings.json` で Claude Code のプラグイン設定を管理
- **プラグイン**: wakatime, context7, code-review, feature-dev, serena, typescript-lsp, commit-commands, code-simplifier, pr-review-toolkit, plugin-dev, hookify, ask-codex, ask-gemini を有効化

@CLAUDE.local.md
