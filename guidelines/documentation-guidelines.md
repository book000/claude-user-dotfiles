# ドキュメント記述ガイドライン

## 基本方針

### 問題の認識と解決
- **Claude Code誤実行**: 指示文中のスクリプトを実行しようとするリスク
- **プロセス理解の混乱**: スクリプト中心の説明では実際の動作が不明瞭
- **不要な複雑性**: 大部分は手動実行されないスクリプトで文書が複雑化

### 新しいアプローチ
- **プロセス中心**: Claude Codeの実際の動作フローに焦点
- **最小限のスクリプト**: 手動実行が必要な特殊ケースのみ
- **明確な動作説明**: 何がどう自動化されるかを明示

## ドキュメント記述の原則

### 1. **Claude Code動作の説明を優先**

#### **推奨記述パターン**
```markdown
## Issue対応フロー

Claude Codeが以下を自動実行：
1. Issue詳細の取得・分析
2. 優先度・複雑度の評価
3. Conventional Commits形式のブランチ作成
4. 実装の実行
5. 品質チェック（lint/test/typecheck）
6. コミット・プッシュ
7. PR作成
```

#### **避けるべきパターン**
```markdown
## Issue対応フロー

```bash
gh issue view $ISSUE_NUMBER
git checkout -b fix/issue-name
# 実装作業...
npm run lint && npm run test
git commit -m "fix: issue description"
```
```

### 2. **手動実行スクリプトの提供基準**

#### **提供すべきケース**
- Claude Codeでは対応困難な特殊な技術要件
- 外部システム連携が必要な場合
- プロジェクト固有の複雑な手順
- 緊急時のフォールバック手順

#### **提供しないケース**
- Claude Codeで自動化される一般的なワークフロー
- 概念説明のためのサンプルコード
- 教育・理解促進のみが目的のスクリプト

### 3. **効果的な説明方法**

#### **動作フロー中心**
```markdown
### ブランチ作成プロセス

Claude Codeが以下を判定・実行：
- upstream/origin の優先順位判定
- メインブランチ（main/master）の自動検出
- Issueタイトルからの適切なタイプ判定（feat/fix/docs等）
- Conventional Commits形式のブランチ名生成
- no-track設定でのブランチ作成・切り替え

結果例: `git checkout -b feat/user-authentication --no-track upstream/main`
```

#### **具体的な判定ロジック**
```markdown
### タイプ判定ルール

Issueタイトルから以下のパターンで自動判定：
- `bug|fix|error|修正` → `fix/`
- `feature|add|implement|機能|追加` → `feat/`
- `doc|readme|ドキュメント` → `docs/`
- その他 → `fix/`（デフォルト）
```

## 手動実行スクリプトの記述方法

### **明確な目的と使用場面の説明**

```markdown
## 手動実行が必要な場合

Claude Codeを使用せず手動でIssue対応を行う特殊ケース向け：

### 使用場面
- Claude Codeでは対応困難な特殊な技術要件
- 外部システムとの連携が必要な場合
- 手動での詳細な調査・検証が必要な場合

### 手動Issue対応スクリプト
```

### **安全なスクリプト設計**

#### **入力待ちの回避**
```bash
# ❌ 危険（フリーズリスク）
read -r user_input

# ✅ 安全（引数ベース）
USER_INPUT=${1:-"default_value"}
if [ -z "$USER_INPUT" ]; then
    echo "Usage: $0 <input_value>"
    exit 1
fi
```

#### **破壊的操作の明示**
```bash
# 重要なファイル操作前の確認促進
echo "⚠️ 注意: このコマンドはファイルを削除します"
echo "実行前に必ずバックアップを取ってください"
echo "続行する場合は以下を実行："
echo "rm important_file.txt"
```

### **完全なスクリプト例**
```bash
#!/bin/bash
# manual_issue_handling.sh - 手動Issue対応スクリプト

ISSUE_NUMBER=$1
TYPE=${2:-"fix"}
DESCRIPTION=${3:-"manual-fix"}

if [ -z "$ISSUE_NUMBER" ]; then
    echo "Usage: $0 <issue_number> [type] [description]"
    echo "Example: $0 123 feat user-auth"
    exit 1
fi

# Issue確認
gh issue view $ISSUE_NUMBER

# ブランチ作成
git checkout -b $TYPE/$DESCRIPTION --no-track origin/main

echo "手動実装を開始してください"
echo "完了後、以下を実行："
echo "  git add ."
echo "  git commit -m \"$TYPE: $(gh issue view $ISSUE_NUMBER --json title -q '.title')\""
echo "  git push -u origin $TYPE/$DESCRIPTION"
```

## ファイル種別ごとの指針

### **ワークフロー定義ファイル**
- Claude Codeの動作フロー説明を中心に
- 判定ロジック・処理手順の明確化
- 手動実行は特殊ケースのみ提供

### **ツール使用指針**
- ツールの使い分け基準を明確に
- 実際の使用パターンを具体例で説明
- 設定・注意事項を簡潔に記載

### **プロジェクト固有設定**
- そのプロジェクトでの実際の運用方法
- 環境固有の設定値・制約事項
- 緊急時の手動対応手順

## 実装における配慮事項

### **Claude Code理解の促進**
- 自動化される範囲の明確化
- 判定・処理ロジックの透明性
- 期待される結果の具体的な説明

### **保守性の確保**
- 動作フローの変更に追従しやすい構造
- スクリプトに依存しない説明
- 本質的な理解を促す内容

### **実用性の重視**
- 実際に必要な情報に焦点
- 過度な詳細説明の回避
- 迅速な理解・実行を支援

この指針により、Claude Codeの実際の動作に即した分かりやすいドキュメントを作成し、不要なスクリプトによる混乱を防ぎます。