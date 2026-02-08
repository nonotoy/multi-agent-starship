#!/bin/bash
# 個別エージェント起動スクリプト
# Usage: ./scripts/start-agent.sh <role> [model]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
ROLE="${1:-}"
MODEL="${2:-}"

# デフォルトモデルを決定
get_default_model() {
    case "$1" in
        captain|vulcan|klingon) echo "sonnet" ;;
        android1|android2) echo "haiku" ;;
        *) echo "sonnet" ;;
    esac
}

# 役割名を取得
get_role_name() {
    case "$1" in
        captain) echo "キャプテン" ;;
        vulcan) echo "ヴァルカン科学士官" ;;
        klingon) echo "クリンゴン保安士官" ;;
        android1) echo "アンドロイド ユニット1" ;;
        android2) echo "アンドロイド ユニット2" ;;
        *) echo "不明な役割" ;;
    esac
}

# ヘルプ表示
show_help() {
    echo "Usage: $0 <role> [model]"
    echo ""
    echo "Roles:"
    echo "  captain   - 戦略的指揮"
    echo "  vulcan    - 中間管理・調査統括"
    echo "  klingon   - レッドチームレビュー"
    echo "  android1  - 一次情報収集"
    echo "  android2  - 関連情報収集"
    echo ""
    echo "Models (optional):"
    echo "  sonnet    - 深い分析向け（デフォルト: captain, vulcan, klingon）"
    echo "  haiku     - 高速収集向け（デフォルト: android1, android2）"
    echo "  opus      - 最高精度"
    exit 0
}

# 引数チェック
if [[ -z "$ROLE" || "$ROLE" == "-h" || "$ROLE" == "--help" ]]; then
    show_help
fi

# 役割の検証
case "$ROLE" in
    captain|vulcan|klingon|android1|android2) ;;
    *)
        echo "エラー: 不明な役割 '$ROLE'"
        echo ""
        show_help
        ;;
esac

# モデルの決定（指定がなければデフォルト）
if [[ -z "$MODEL" ]]; then
    MODEL="$(get_default_model "$ROLE")"
fi

# 役割ファイルのパス
ROLE_FILE="$PROJECT_DIR/roles/${ROLE}.md"

if [[ ! -f "$ROLE_FILE" ]]; then
    echo "エラー: 役割ファイルが見つかりません: $ROLE_FILE"
    exit 1
fi

# 役割ファイルの内容を読み込む
SYSTEM_PROMPT="$(cat "$ROLE_FILE")"

# バナー表示
show_banner() {
    cat << 'EOF'
 ██╗   ██╗███████╗███████╗    ███████╗███╗   ██╗████████╗███████╗██████╗ ██████╗ ██████╗ ██╗███████╗███████╗
 ██║   ██║██╔════╝██╔════╝    ██╔════╝████╗  ██║╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗██║██╔════╝██╔════╝
 ██║   ██║███████╗███████╗    █████╗  ██╔██╗ ██║   ██║   █████╗  ██████╔╝██████╔╝██████╔╝██║███████╗█████╗
 ██║   ██║╚════██║╚════██║    ██╔══╝  ██║╚██╗██║   ██║   ██╔══╝  ██╔══██╗██╔═══╝ ██╔══██╗██║╚════██║██╔══╝
 ╚██████╔╝███████║███████║    ███████╗██║ ╚████║   ██║   ███████╗██║  ██║██║     ██║  ██║██║███████║███████╗
  ╚═════╝ ╚══════╝╚══════╝    ╚══════╝╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚══════╝
                                          ◇ NCC-1701 ◇
EOF
}

# 起動
show_banner
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  $(get_role_name "$ROLE")"
echo "  モデル: $MODEL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd "$PROJECT_DIR"
exec claude --system-prompt "$SYSTEM_PROMPT" --model "$MODEL"
