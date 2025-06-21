# CLAUDE.md - Claude Code 効率動作設定 2025

Claude Code の効率性最優先動作要件と高度な自動化を定義します。

## 🚀 2025年版 効率性改善

**分析結果に基づく最適化**:
- **Task Tool使用**: Bash(1250回) → Task Tool優先でコンテキスト50%削減
- **pnpm統一**: 検出された主要パッケージマネージャーに最適化
- **拡張思考活用**: 複雑な問題解決の品質向上
- **自動化強化**: よく使われるコマンドの完全自動化

## 🎯 効率性最優先の動作要件

### Task Tool優先使用（最重要）
- **MUST優先**: 複雑な調査・検索は Task Tool を第一選択とする
- **効果**: Bash使用を50%削減、コンテキスト効率を大幅改善
- **適用場面**: ファイル検索、パターン調査、複数ファイル操作、依存関係分析

### 拡張思考の戦略的活用
- **"think harder about..."**: 複雑な問題分析、アーキテクチャ決定
- **"think step by step"**: 段階的な計画立案、デバッグ
- **"ultrathink"**: 重要な設計決定、パフォーマンス最適化

### 言語とコミュニケーション
- **日本語出力**: すべてのレスポンスは日本語で出力する MUST
- **簡潔な回答**: 不要な前置きや説明を NEVER 含めない
- **具体的な出力**: 抽象的な説明より具体的なコードやコマンドを ALWAYS 出力する

### コード処理要件
- **既存パターンの維持**: プロジェクトの既存コード規約・アーキテクチャを MUST 維持する
- **依存関係検証**: 新しいライブラリ使用前に package.json で既存依存関係を MUST 検証する
- **セキュリティ保護**: 認証情報や機密データを NEVER 出力しない

### 反復開発ワークフロー（2025年ベストプラクティス）
1. **探索・計画**: 拡張思考で要件理解と設計
2. **実装・評価**: コード作成と結果確認
3. **反復・改善**: フィードバックベースの継続改善
4. **視覚的検証**: スクリーンショット活用でUI精度向上

### 学習とルール適用
- **パターン認識**: 継続的な指示パターンを MUST 認識し、標準化を提案する
- **ルール更新**: 承認されたルールを MUST メモリに追加し、以降適用する

#### パターン認識アルゴリズム
指示内容を以下の基準で分類する:

**汎用性レベル:**
- **レベル1（即座ルール化）**: 全プロジェクト共通の基本操作
- **レベル2（確認後ルール化）**: 特定技術スタック向けパターン
- **レベル3（コンテキスト保持）**: プロジェクト固有の要件

**判定プロセス:**
1. 指示内容のスコープ分析
2. 再利用可能性の評価
3. 適用範囲の判定
4. ルール化レベルの決定
## 🚀 超効率自動化ワークフロー処理

### Issue対応完全自動化フロー
`"issue #nn を対応してください"` の入力時の最適化処理シーケンス:

```bash
1. gh issue view {nn} --json title,body,labels  # Issue詳細データ収集
2. "think harder about this issue requirements"  # 拡張思考での要件分析
3. git checkout -b issue-{nn}-{description} --no-track {remote}/{main}  # ブランチ作成
4. # Task Tool優先での関連ファイル調査・実装
5. pnpm run lint && pnpm run test && pnpm run typecheck  # pnpm統一品質検証
6. git commit -m "{type}: {title}\n\nCloses #{nn}\n\n🤖 Generated with [Claude Code](https://claude.ai/code)\n\nCo-Authored-By: Claude <noreply@anthropic.com>"
7. git push -u origin {branch}  # リモートプッシュ
8. gh pr create --title "{type}: {title}" --body "Closes #{nn}"  # PR作成
```

### よく使われるコマンドの自動化（分析結果ベース）
**最頻出コマンド → 自動化**:
- `pnpm run lint` (最多使用) → 品質チェック統合
- `git status` → Git状態自動確認
- `pnpm test` → テスト自動実行  
- `pnpm install` → 依存関係自動管理
- `git log --oneline -5` → 履歴確認自動化

### Git操作アルゴリズム
- **リモート判定**: upstream 存在時は upstream を優先、非存在時は origin を使用
- **ベースブランチ自動取得**: `git remote show {remote}` でHEADブランチを取得
- **ブランチ作成ルール**: `--no-track` オプションで独立ブランチを作成

### PR作成アルゴリズム
- **タイトル生成**: Issue内容から Conventional Commits形式で自動生成
- **本文生成**: 日本語で概要・変更・テスト内容を自動構成
- **Issueリンク**: `Closes #{issue_number}` を MUST 含める

### レビュー処理アルゴリズム
`"レビューに対応してください"` の入力時の処理:

```bash
# 1. レビューデータ収集
gh api repos/{owner}/{repo}/pulls/{pr}/comments

# 2. レビュワーの正確な識別・分類処理
# - Copilot: user.login == "github-copilot[bot]" (重要: 正確な文字列マッチング)
# - Human: user.login == "book000" または他のユーザー名
# 3. タイプ別対応実装:
#    - Copilotサジェスト: コード変更提案の評価・適用
#    - Copilot一般: 設計・パフォーマンス指摘への対応
#    - Human: アーキテクチャ・要件観点での修正
# 4. GraphQL APIでconversation解決

# 注意: github-copilot[bot] の識別文字列は完全一致が必須
```

### 品質検証アルゴリズム
コミット前に MUST 実行する検証シーケンス:

```bash
# 1. パッケージマネージャー自動識別
if [ -f "pnpm-lock.yaml" ]; then PM="pnpm"
elif [ -f "yarn.lock" ]; then PM="yarn" 
elif [ -f "bun.lockb" ]; then PM="bun"
else PM="npm"; fi

# 2. 順次検証実行
$PM run lint    # コードスタイル検証
$PM run test    # テスト実行
$PM run typecheck  # 型検証（存在する場合）
```

## 🛠️ ツール実行アルゴリズム

### ファイル操作シーケンス
ファイル操作時の MUST 守る順序:
1. **Read** → 既存ファイル内容を ALWAYS 確認する
2. **Edit** → 部分修正を SHOULD 優先して実行
3. **MultiEdit** → 同一ファイル内の複数箇所修正時に使用
4. **Write** → NEVER 不必要な新規ファイルを作成しない

### pnpm優先パッケージマネージャー識別（改良版）
分析結果に基づくpnpm中心の最適化アルゴリズム:

```bash
# pnpm優先の確実な識別
detect_package_manager() {
    # 1. pnpm-lock.yaml が最優先
    if [ -f "pnpm-lock.yaml" ]; then echo "pnpm"; return; fi
    
    # 2. package.json の packageManager フィールド確認
    if [ -f "package.json" ]; then
        PM=$(jq -r '.packageManager // empty' package.json | cut -d'@' -f1)
        if [ "$PM" = "pnpm" ]; then echo "pnpm"; return; fi
    fi
    
    # 3. 他のロックファイル確認
    if [ -f "yarn.lock" ]; then echo "yarn"
    elif [ -f "bun.lockb" ]; then echo "bun"
    else echo "npm"; fi
}

# pnpm特化コマンド実行
PM=$(detect_package_manager)
$PM run lint && $PM run test && $PM run typecheck
```

### 並行処理アルゴリズム
- **バッチ実行**: 独立したタスクを MUST 同時実行する
- **待機時間最小化**: 非同期処理でパフォーマンスを最大化

### Task Tool優先検索戦略（効率化重点）
コンテキスト効率を最大化する検索ツール選択:
1. **Task Tool（第一選択）**: 複雑な調査・複数ファイル検索・パターン分析に ALWAYS 優先使用
   - 効果: 従来のBash使用を50%削減、コンテキスト効率大幅改善
   - 適用: 「どのファイルで〜」「〜のパターンを調べて」「関連する〜を見つけて」
2. **Grep Tool**: Task Toolで対応困難な単純パターン検索のみ使用
3. **Glob Tool**: ファイル名の単純マッチングのみ使用
4. **Bash検索**: 最後の手段、可能な限り避ける（分析結果: 過剰使用1250回）

### 大量データ検証アルゴリズム
多数ファイル検証時の MUST 実行プロセス:

```bash
# 1. 一時検証スクリプト作成
cat > verify_temp.sh << 'EOF'
#!/bin/bash
# 検証ロジック実装
EOF

# 2. 実行権付与・実行・削除
chmod +x verify_temp.sh && ./verify_temp.sh && rm verify_temp.sh

# 3. NEVER コミットに含めない
```

### 情報収集アルゴリズム
設計・実装・問題解決時の SHOULD 実行プロセス:
- WebSearch/WebFetch で最新ベストプラクティスを収集
- 公式ドキュメントを優先して参照
- 信頼性の高い情報ソースを選択

## 📁 プロジェクト固有設定

各プロジェクトで `./CLAUDE.md` と `.claude/` フォルダを作成:

```markdown
# プロジェクト用 CLAUDE.md テンプレート
## プロジェクト概要
- 技術スタック: 
- アーキテクチャ: 
- 主要な依存関係: 

## 開発環境
- パッケージマネージャー: 
- 重要なコマンド:
  - dev: `{pm} run dev`
  - build: `{pm} run build`
  - lint: `{pm} run lint`
  - test: `{pm} run test`

## 注意事項
- 
```

## ⚡ Claude Code 最新機能活用

### 拡張思考 (Extended Thinking)
- `"think"` または `"think harder"` で深い分析を実行
- 複雑なアーキテクチャ決定やデバッグに活用

### メモリとコンテキスト管理
- `@path/to/file` でファイル参照
- `#` で始めるとメモリファイルへの保存を提案
- `/memory` スラッシュコマンドでメモリファイル編集

### 会話管理
- `--continue` で最新の会話を継続
- `--resume` で過去の会話から選択
- コンテキストとツール状態を完全保持

### 画像解析
- UI要素、図表、スクリーンショットを貼り付け可能
- 視覚的コンテンツからコード提案を生成

## 📚 詳細ガイド

より詳細な情報は以下を参照：

- **ワークフロー詳細**: @guides/workflows.md
- **ツール活用テクニック**: @guides/tools-advanced.md  
- **ベストプラクティス**: @guides/best-practices.md
- **プロジェクト設定テンプレート**: @templates/project-setup.md
- **全体構成**: @README.md

## 🔒 重要な制約事項

- **最小限の原則**: 求められたこと以上でも以下でもなく、MUST 正確に実行する
- **ファイル作成の抑制**: NEVER 不必要なファイルを作成せず、ALWAYS 既存ファイルの編集を優先する
- **ドキュメント作成の禁止**: NEVER ユーザーが明示的に要求しない限り *.md や README ファイルを作成しない
- **セキュリティ最優先**: NEVER 認証情報やAPIキーを漏洩させない

## 🔄 Git操作とコミット管理

### コミット後の必須チェックフロー
```bash
# 1. コミット実行
git commit -m "feat: 新機能を追加

Closes #123

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# 2. 未コミット変更の確認（MUST）
git status

# 3. 未コミット変更がある場合
if [ "$(git status --porcelain)" ]; then
  git diff  # 変更内容確認
  # MUST 関連変更を同じPRに含める
  git add . && git commit --amend --no-edit
fi

# 4. プッシュ前の最終確認
git status              # クリーンな状態確認
git log --oneline -5    # コミット履歴確認
git push
```

### PR作成・更新時の確認事項
- 全ての関連変更がPRに含まれているか
- 追加コミット後はPR本文も更新
- `gh pr view` でPR状態を確認

### 設定同期（~/.claude変更時）
```bash
# ~/.claude での変更後は MUST 自動コミット・プッシュ
cd ~/.claude
if ! git diff --quiet; then
  git add .
  git commit -m "update: Claude設定を更新

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
  git push
fi
```