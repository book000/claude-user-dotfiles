# git --no-verify 防止機能

この機能は、Gitの`--no-verify`オプションや`-n`オプションの使用を防ぎ、コード品質とセキュリティを強制的に維持します。

## 🛡️ 対象コマンド

以下のGitコマンドで`--no-verify`または`-n`オプションが検出された場合、実行を拒否します：

- `git commit --no-verify` / `git commit -n`
- `git push --no-verify`
- `git merge --no-verify`
- `git send-email --no-verify`
- `git am --no-verify`

## 🚀 セットアップ

### 自動セットアップ
```bash
# ~/.claude ディレクトリから実行
./scripts/setup-git-no-verify-prevention.sh
```

このスクリプトは：
- 現在のシェル（bash/zsh）を自動検出
- 適切な設定ファイル（.bashrc/.zshrc/.profile）に防止機能を組み込み
- 新しいターミナルセッションで自動的に有効化

### 手動セットアップ
```bash
# 一時的に有効化（現在のセッションのみ）
source ./scripts/prevent-no-verify.sh

# 永続化（設定ファイルに追加）
echo 'source ~/.claude/scripts/prevent-no-verify.sh' >> ~/.bashrc
```

## 🧪 動作確認

```bash
# エラーになることを確認
git commit --no-verify -m "test"
git push --no-verify

# 通常のコマンドは正常動作
git commit -m "normal commit"
git push origin main
```

## 🔧 無効化方法

一時的に無効化したい場合：
```bash
unset -f git  # 現在のセッションのみ
```

永続的に無効化したい場合：
- シェル設定ファイル（.bashrc/.zshrc/.profile）から関連行を削除

## 💡 理由

`--no-verify`オプションは以下のセキュリティ・品質チェックをバイパスします：
- pre-commit hooks（コードフォーマット・リント・テスト）
- pre-push hooks（追加の品質チェック・セキュリティスキャン）
- commit-msg hooks（コミットメッセージ検証）

これらのチェックをバイパスすることで、以下のリスクが生じます：
- コード品質の低下
- セキュリティ脆弱性の混入
- チーム開発でのコード規約違反
- CI/CDパイプラインでのビルド失敗

## 🔍 トラブルシューティング

### 機能が有効にならない場合
1. 新しいターミナルを開く
2. 設定ファイルを再読み込み：`source ~/.bashrc`
3. スクリプトのパスが正しいか確認

### 正常なgitコマンドがエラーになる場合
1. 引数の順序を確認（オプションがコマンド名の後にあるか）
2. スクリプトの引数解析ロジックを確認
3. 必要に応じて一時的に無効化：`unset -f git`

### セットアップスクリプトが動作しない場合
1. 実行権限を確認：`chmod +x setup-git-no-verify-prevention.sh`
2. スクリプトのパスが正しいか確認
3. HOME環境変数が正しく設定されているか確認