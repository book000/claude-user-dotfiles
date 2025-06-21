# Issue対応完全自動化ワークフロー

## 🎯 超効率Issue処理（2025年版）

### 基本コマンド
```bash
"issue #nn を対応してください"
```

### 🚀 最適化された処理フロー

#### 1. 拡張思考による要件分析
```bash
# Issue詳細の取得と深い分析
gh issue view {nn} --json title,body,labels,assignees,milestone

# 拡張思考での要件理解
"think harder about this issue requirements and implementation approach"
```

#### 2. Task Tool優先での関連調査
```bash
# 関連ファイル・パターンの効率的調査（Bash使用を50%削減）
Task Tool: "このIssueに関連するファイルやコンポーネントを調査"
Task Tool: "類似の実装パターンや既存のテストを調査"
```

#### 3. ブランチ戦略の実行
```bash
# upstream/origin自動判定
if git remote get-url upstream >/dev/null 2>&1; then
    REMOTE="upstream"
else
    REMOTE="origin"
fi

# メインブランチ取得
MAIN_BRANCH=$(git remote show $REMOTE | grep "HEAD branch" | cut -d' ' -f5)

# ブランチ作成（プロジェクト名も含む）
BRANCH_DESC=$(echo "$ISSUE_TITLE" | sed 's/[^a-zA-Z0-9]/-/g' | tr '[:upper:]' '[:lower:]' | cut -c1-30)
git checkout -b issue-${nn}-${BRANCH_DESC} --no-track $REMOTE/$MAIN_BRANCH
```

#### 4. pnpm統一品質チェック
```bash
# pnpm優先の品質チェック（分析結果ベース）
pnpm run lint
pnpm run test  
pnpm run typecheck  # TypeScript特化
```

#### 5. 反復開発アプローチ
```bash
# 1. 初期実装
# 2. 結果確認・評価
# 3. フィードバックベースの改善
# 4. 最終品質チェック
```

#### 6. 自動コミット・PR作成
```bash
# Conventional Commits自動生成
if [[ $ISSUE_TITLE =~ bug|fix|error|修正 ]]; then PREFIX="fix"
elif [[ $ISSUE_TITLE =~ feature|add|implement|機能|追加 ]]; then PREFIX="feat"
elif [[ $ISSUE_TITLE =~ doc|readme|ドキュメント ]]; then PREFIX="docs"
elif [[ $ISSUE_TITLE =~ test|テスト ]]; then PREFIX="test"
elif [[ $ISSUE_TITLE =~ refactor|リファクタ ]]; then PREFIX="refactor"
else PREFIX="fix"; fi

git add .
git commit -m "$PREFIX: $ISSUE_TITLE

Fixes #${nn}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"

git push -u origin issue-${nn}-${BRANCH_DESC}

gh pr create \
  --title "$PREFIX: $ISSUE_TITLE" \
  --body "## 概要
Issue #${nn} の対応

$ISSUE_TITLE

## 変更内容
- Issue #${nn} で報告された問題に対応
- 拡張思考とTask Tool活用による効率的な実装
- pnpm統一環境での品質保証

## テスト内容
- 既存テストの実行確認
- Issue要件の動作確認
- TypeScript型安全性の確認

## チェックリスト
- [x] pnpm lint/test/typecheckが通ることを確認
- [x] Task Tool活用による効率的な調査・実装
- [x] 既存機能に影響がないことを確認
- [x] Issue要件を満たしていることを確認

Closes #${nn}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## 📊 効率化効果

### 従来 vs 改善後
- **調査効率**: Bash過剰使用 → Task Tool優先（50%効率化）
- **品質保証**: 個別実行 → pnpm統一自動化
- **思考プロセス**: 直接実装 → 拡張思考による深い分析
- **反復改善**: 一発実装 → 段階的品質向上

### 期待される成果
- Issue対応時間の30%短縮
- コード品質の向上
- コンテキスト効率の大幅改善
- より安定したPR作成プロセス