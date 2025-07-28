# Claude Code スクリプトガイド

## 📋 スクリプト一覧

### 🔄 基本操作スクリプト

#### pull.sh
```bash
# 場所: ~/.claude/scripts/pull.sh
# 用途: Claude設定の手動同期
~/.claude/scripts/pull.sh
```

**概要**: ~/.claude設定ディレクトリのGitリポジトリから最新変更を取得します。

**使用場面**:
- 他のマシンで設定を変更した後
- 手動でClaude設定を最新化したい時
- チーム環境での設定同期

### 🔧 GitHub連携スクリプト

#### collect-review.sh
```bash
# 場所: ~/.claude/scripts/github-pr/collect-review.sh
# 用途: PR未解決レビューコメント収集
~/.claude/scripts/github-pr/collect-review.sh <PR_NUMBER>
```

**概要**: 指定されたPRの未解決レビューコメントを収集し、整理して表示します。

**機能**:
- REST APIとGraphQL APIの組み合わせ活用
- 解決済みコメントの自動除外
- ファイル別・行別の詳細情報表示
- コメントURL付きの見やすい出力

**使用例**:
```bash
# PR #123の未解決コメントを取得
~/.claude/scripts/github-pr/collect-review.sh 123
```

#### wait-for-ci.sh
```bash
# 場所: ~/.claude/scripts/github-pr/wait-for-ci.sh
# 用途: GitHub Actions CI実行の監視
~/.claude/scripts/github-pr/wait-for-ci.sh [OPTIONS]
```

**概要**: 現在のブランチのGitHub Actions CIを監視し、完了まで待機します。

**主要オプション**:
- `--no-loop`: 一度だけチェックして終了
- `--debug`: デバッグ出力を有効化
- `--timeout N`: タイムアウト時間（秒）
- `--interval N`: チェック間隔（秒）

**機能**:
- リアルタイムCI進捗表示
- 平均実行時間との比較
- 推定残り時間表示
- 詳細な成功/失敗レポート

**使用例**:
```bash
# 通常の監視
~/.claude/scripts/github-pr/wait-for-ci.sh

# 30分タイムアウトで監視
~/.claude/scripts/github-pr/wait-for-ci.sh --timeout 1800

# 一度だけ状態確認
~/.claude/scripts/github-pr/wait-for-ci.sh --no-loop
```

## ⚙️ 設定とセットアップ

### 実行権限の設定

```bash
# すべてのスクリプトに実行権限を付与
find ~/.claude/scripts -name "*.sh" -exec chmod +x {} \;
```

## 🚀 Claude Code との統合

### 自動実行の活用

Claude Code の通常ワークフローでこれらのスクリプトを活用：

```bash
# レビュー対応時の自動実行例
"レビューに対応してください" 
→ Claude Code が collect-review.sh を自動実行
→ 未解決コメントを収集・対応
→ CI監視のために wait-for-ci.sh を実行

# Issue対応時の自動実行例  
"issue #123 を対応してください"
→ 実装完了後
→ wait-for-ci.sh でCI完了を待機
```

## 🔧 カスタマイズとメンテナンス

### スクリプトの改良

スクリプトは定期的に改良・更新されます：

- パフォーマンス最適化
- エラーハンドリング強化
- 新機能追加
- UI/UX改善

### デバッグとトラブルシューティング

各スクリプトにはデバッグ機能が組み込まれています：

```bash
# デバッグモードでの実行例
~/.claude/scripts/github-pr/wait-for-ci.sh --debug
```

### セキュリティ考慮事項

- スクリプトの実行権限は最小限に
- 定期的なセキュリティ監査の実施

## 📚 参考情報

### 依存関係

これらのスクリプトが依存するツール：

- `gh` (GitHub CLI)
- `jq` (JSON processor)
- `curl` (HTTP client)
- `bash` (Shell)

### 関連ドキュメント

- [Claude Code Hook システム](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [GitHub CLI Manual](https://cli.github.com/manual/)