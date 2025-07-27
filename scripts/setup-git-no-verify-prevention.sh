#!/bin/bash

# Claude Code git --no-verify防止機能セットアップスクリプト
# ユーザーのシェル設定に防止機能を自動組み込みします

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREVENT_SCRIPT="$SCRIPT_DIR/prevent-no-verify.sh"

# サポートするシェル設定ファイル
SHELL_CONFIGS=(
    "$HOME/.bashrc"
    "$HOME/.zshrc"
    "$HOME/.profile"
)

# 組み込み用のコード
SOURCE_LINE="# Claude Code git --no-verify防止機能"
SOURCE_CMD="source \"$PREVENT_SCRIPT\""

setup_shell_integration() {
    local config_file="$1"
    
    # ファイルが存在しない場合は作成
    if [[ ! -f "$config_file" ]]; then
        echo "📝 $config_file を作成します..."
        touch "$config_file"
    fi
    
    # 既に組み込まれているかチェック
    if grep -q "prevent-no-verify.sh" "$config_file"; then
        echo "✅ $config_file には既に防止機能が組み込まれています"
        return 0
    fi
    
    # 組み込みコードを追加
    echo "" >> "$config_file"
    echo "$SOURCE_LINE" >> "$config_file"
    echo "$SOURCE_CMD" >> "$config_file"
    
    echo "✅ $config_file に防止機能を組み込みました"
}

main() {
    echo "🛡️  Claude Code git --no-verify防止機能セットアップ"
    echo "================================================="
    
    # 防止スクリプトの存在確認
    if [[ ! -f "$PREVENT_SCRIPT" ]]; then
        echo "❌ Error: $PREVENT_SCRIPT が見つかりません"
        exit 1
    fi
    
    # 現在のシェルを検出
    local current_shell=$(basename "$SHELL")
    echo "🔍 現在のシェル: $current_shell"
    
    # 各シェル設定ファイルをチェック・セットアップ
    for config in "${SHELL_CONFIGS[@]}"; do
        local config_name=$(basename "$config")
        
        # シェルに対応する設定ファイルのみ処理
        case "$current_shell" in
            bash)
                if [[ "$config_name" == ".bashrc" || "$config_name" == ".profile" ]]; then
                    setup_shell_integration "$config"
                fi
                ;;
            zsh)
                if [[ "$config_name" == ".zshrc" || "$config_name" == ".profile" ]]; then
                    setup_shell_integration "$config"
                fi
                ;;
            *)
                # その他のシェルの場合は.profileのみ
                if [[ "$config_name" == ".profile" ]]; then
                    setup_shell_integration "$config"
                fi
                ;;
        esac
    done
    
    echo ""
    echo "🎉 セットアップ完了！"
    echo ""
    echo "📋 次の手順:"
    echo "   1. 新しいターミナルを開く、または以下を実行:"
    echo "      source ~/.${current_shell}rc  (${current_shell}を使用中)"
    echo "   2. 防止機能をテスト:"
    echo "      git commit --no-verify  (エラーになることを確認)"
    echo ""
    echo "🔧 無効化したい場合:"
    echo "   該当のシェル設定ファイルから関連行を削除してください"
}

main "$@"