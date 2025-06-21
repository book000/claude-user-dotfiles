# Claude Code 効率化ユーザー設定 2025

このディレクトリは Claude Code のグローバルユーザー設定を管理し、全プロジェクト会話ログ分析に基づく効率化改善を提供します。

## 🚀 2025年版改善内容

**全40ファイル・5プロジェクト分析結果による最適化**:
- **Task Tool優先**: Bash過剰使用(1250回)を50%削減
- **pnpm統一**: 検出された主要パッケージマネージャーに最適化
- **拡張思考活用**: 複雑な問題解決の品質向上
- **自動化強化**: よく使われるコマンドの完全自動化

## 📋 構成

```
~/.claude/
├── CLAUDE.md                    # 効率化メイン設定（2025年版）
├── workflows/                   # 自動化ワークフロー（新設）
│   └── issue-automation.md     # Issue対応完全自動化
├── best-practices/              # 2025年ベストプラクティス（新設）
│   └── efficiency.md           # 効率性向上テクニック
├── tech-stacks/                 # 技術スタック別最適化（新設）
│   └── pnpm-optimization.md    # pnpm中心最適化
├── analysis/                    # 分析結果（新設）
│   └── conversation-patterns.md # 全プロジェクト分析結果
├── templates/                   # 改善されたテンプレート
│   ├── project-claude-2025.md  # 2025年版プロジェクト設定
│   └── project-setup.md        # 従来設定（保持）
├── guides/                      # 詳細ガイド（保持）
│   ├── workflows.md            # ワークフロー詳細
│   ├── tools-advanced.md       # ツール活用テクニック
│   └── best-practices.md       # ベストプラクティス
├── guidelines/                  # 記述方針（保持）
│   └── documentation-guidelines.md
├── archive/                     # 旧設定保管
│   ├── workflows/              # 旧ワークフロー
│   └── tools/                  # 旧ツール設定
└── README.md                   # このファイル
```

### 📚 ディレクトリの使い分け

#### **guides/ vs guidelines/ の違い**

- **guides/（ガイド）**: 「どうやってやるか」の具体的手順
  - 実行可能なコマンド例・スクリプト
  - 段階的な操作手順
  - 具体的なテクニック・ノウハウ

- **guidelines/（ガイドライン）**: 「何をすべきか・なぜそうするか」の原則
  - 抽象的な方針・判断基準
  - 行動規範・記述原則
  - 考え方・アプローチの指針

## 🚀 主要機能

### 自動化ワークフロー
- **Issue対応**: `"issue #nn を対応してください"` で完全自動実行
- **レビュー対応**: `"レビューに対応してください"` でPRコメント対応
- **品質チェック**: コミット前の自動lint/test実行
- **設定同期**: ~/.claude変更時の自動コミット・プッシュ

### ツール最適化
- **検索戦略**: Task Tool → Grep → Glob の効率的使い分け
- **ファイル操作**: Read → Edit → Write の優先順位
- **パッケージマネージャー**: 自動判定と統一的な実行
- **大量データ検証**: 一時スクリプトによる効率的処理

### Claude Code 最新機能
- **拡張思考**: `"think harder"` で深い分析
- **メモリ管理**: `@ファイル名` でコンテキスト参照
- **画像解析**: UI・エラー画面からの実装支援
- **会話継続**: `--resume` で過去の会話から再開

## ⚙️ 使用方法

### 初回設定
1. この設定が自動的に読み込まれます
2. プロジェクト固有設定は `./CLAUDE.md` で上書き可能
3. 詳細は `guides/` ディレクトリの各ファイルを参照

### カスタマイズ
1. `CLAUDE.md` を直接編集
2. 新しいパターンを学習時は設定に追加
3. 変更は自動的にGitで管理・同期

### トラブルシューティング
1. `guides/best-practices.md` でよくある問題の解決法を確認
2. 複雑な問題は `"think harder about..."` で深い分析を要求
3. 設定の競合は `archive/` の旧設定と比較

## 🔧 メンテナンス

### 定期作業
- **月次**: 依存関係・設定の見直し
- **四半期**: 新機能・ベストプラクティスの追加
- **年次**: 全体的なアーキテクチャ見直し

### 品質保持
- 設定変更後は必ずテスト実行
- 新機能追加時は段階的ロールアウト
- チーム共有時は影響範囲を事前確認

## 📚 関連リンク

- [Claude Code 公式ドキュメント](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)

## 🔒 セキュリティ

- `.gitignore` で機密情報を適切に除外
- プロジェクト履歴はプライバシー保護のため除外
- 認証情報は環境変数またはSecure Storage使用

---

*このファイルは Claude Code により生成・管理されています。*
*手動編集時は変更内容をGitで管理してください。*