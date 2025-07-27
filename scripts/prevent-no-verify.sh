#!/bin/bash

# git --no-verify防止機能
# このスクリプトはgitコマンドをオーバーライドし、--no-verifyオプションの使用を防ぎます

# 元のgitコマンドのパスを保存
GIT_ORIGINAL_PATH=$(which git)

# gitコマンドをオーバーライドする関数
git() {
    local args=("$@")
    local has_no_verify=false
    local command=""
    
    # 引数を解析
    for arg in "${args[@]}"; do
        case "$arg" in
            commit|push|send-email|am|merge)
                command="$arg"
                ;;
            --no-verify|-n)
                has_no_verify=true
                ;;
        esac
    done
    
    # --no-verifyオプションが検出された場合
    if [[ "$has_no_verify" == true ]]; then
        echo "❌ Error: --no-verify オプションの使用は許可されていません"
        echo "   コマンド: git $*"
        echo ""
        echo "💡 理由: コード品質とセキュリティを保つため、hookのバイパスは禁止されています"
        echo "   適切なコミット・プッシュを行うか、必要に応じて管理者に相談してください"
        return 1
    fi
    
    # 通常のgitコマンドを実行
    "$GIT_ORIGINAL_PATH" "$@"
}

# 関数をエクスポート（サブシェルでも使用可能にする）
export -f git

echo "✅ git --no-verify防止機能が有効になりました"