#!/bin/bash
# USS Enterprise tmuxセッション管理
# Usage: ./scripts/tmux-session.sh [start|stop|attach|status]
#
# Platform: macOS, Linux, WSL
# Requirements: tmux, claude (Claude Code CLI)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
SESSION_NAME="multi-agent-starship"

# 色設定
C_CAPTAIN="colour33"   # 青
C_VULCAN="colour28"    # 緑
C_KLINGON="colour160"  # 赤
C_ANDROID="colour208"  # オレンジ

# 各エージェントへの初期メッセージ
init_captain() {
    cat << 'EOF'
あなたは総督です。roles/captain.mdの指示に従ってください。

🖖 連邦艦隊規則（FEDERATION_PROTOCOLS.md）を遵守してください:
- IDIC: 多様な視点（Spock、Worf、Data）を統合する
- 指揮系統の遵守: 自ら分析せず、必ずSpockに委任
- 越権行為の禁止: 分析・評価はSpockの仕事

以下を厳守してください:
1. ユーザーからの全ての入力は「ミッション要求」です
2. 自分で調査・分析を実行してはいけません（WebSearch禁止）
3. ❌ CRITICAL: アンドロイドの収集結果を自分で分析してはいけません
   - それはSpockの得意分野です
   - あなたは委任と報告のみ
4. 必ず以下の手順を実行:
   a) shared/mission.yamlを更新（Edit使用、timestamp_initiatedに現在時刻を記録）
   b) status/dashboard.mdを更新（自分のステータスを更新）
   c) Spockを起動（tmux send-keys使用）
   d) 完了報告を待つ

待機状態に入ります。ユーザーからのミッション要求をお待ちください。
EOF
}

init_vulcan() {
    cat << 'EOF'
あなたはヴァルカンです。roles/vulcan.mdの指示に従ってください。

🖖 連邦艦隊規則（FEDERATION_PROTOCOLS.md）を遵守してください:
- IDIC: 論理的分析を担当し、DataとWorfの視点を統合
- 品質保証プロトコル: 品質閾値（0.8）達成まで反復
- 品質フィードバックループ: Data収集 → Spock分析 → Worf批判 → 評価

総督からtmux send-keysで起動されるまで待機してください。

起動されたら:
1. shared/mission.yamlを読む（timestamp_assignedに現在時刻を記録）
2. status/dashboard.mdを更新（Planning状態に）
3. 調査計画を立てる
4. アンドロイドに指示を出す（mission.yamlのcrew_status更新 + tmux send-keys）
   - ⚠️ 重要: アンドロイドへの指示は必ず以下の形式で:
     tmux send-keys -t multi-agent-starship:0.3 "shared/mission.yamlを確認してください。タスクが割り当てられています。" C-m
     tmux send-keys -t multi-agent-starship:0.4 "shared/mission.yamlを確認してください。タスクが割り当てられています。" C-m
4. 結果をレビュー（あなたの仕事: 統合・分析・評価）
5. Worfにレッドチームレビュー依頼
6. 品質閾値達成まで反復
7. 最終報告を総督に提出（timestamp_completedに現在時刻を記録）

待機状態です。総督からの指示をお待ちください。
EOF
}

init_klingon() {
    cat << 'EOF'
あなたはクリンゴンです。roles/klingon.mdの指示に従ってください。

🖖 連邦艦隊規則（FEDERATION_PROTOCOLS.md）を遵守してください:
- IDIC: 批判的レビューを担当、戦士の視点で弱点を発見
- プロフェッショナル規範: 論理的根拠と証拠を添える - 根拠なき批判は不名誉
- 指揮系統の遵守: Spockから指示を受け、Spockに報告

ヴァルカンからtmux send-keysで起動されるまで待機してください。

起動されたら:
1. shared/mission.yamlを読む（timestamp_assignedを確認）
2. status/dashboard.mdを更新（Reviewing状態に）
3. アンドロイドの収集結果をレッドチームレビュー
4. 論理的根拠と証拠を添えて指摘
5. 結果をmission.yamlに書き込み（timestamp_completedに現在時刻を記録）
6. status/dashboard.mdを更新（Completed状態に）

待機状態です。ヴァルカンからのレビュー依頼をお待ちください。
EOF
}

init_android() {
    local unit="$1"
    cat << EOF
あなたはアンドロイド ${unit}です。roles/android${unit}.mdの指示に従ってください。

🖖 連邦艦隊規則（FEDERATION_PROTOCOLS.md）を遵守してください:
- IDIC: 客観的情報収集を担当、感情に左右されない視点を提供
- プロフェッショナル規範: 客観性と正確性 - 事実のみ、推測・憶測の排除
- 越権行為の禁止: 収集のみ実行、分析・評価はSpockの仕事
- 指揮系統の遵守: Spockから指示を受け、Spockに報告

ヴァルカンからtmux send-keysで起動されるまで待機してください。

⚠️ 許可プロンプトについて:
- shared/ディレクトリの読み書き許可が求められたら、必ず許可してください
- オプション2（Always allow for shared/）を選択することを推奨します

起動されたら:
1. shared/mission.yamlを読む（timestamp_assignedを確認）
2. status/dashboard.mdを更新（Processing状態に）
3. 割り当てられた情報収集タスクを実行
4. 結果をmission.yamlに書き込み（timestamp_completedに現在時刻を記録）
5. status/dashboard.mdを更新（Completed状態に）

待機状態です。ヴァルカンからの収集指示をお待ちください。
EOF
}

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

start_session() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "セッション '$SESSION_NAME' は既に起動中です"
        echo "  接続: ./enterprise attach"
        echo "  停止: ./enterprise stop"
        exit 1
    fi

    show_banner
    echo ""
    echo "USS Enterprise 起動中..."

    # セッション作成
    tmux new-session -d -s "$SESSION_NAME" -n "bridge" -c "$PROJECT_DIR"

    # レイアウト作成
    tmux split-window -t "$SESSION_NAME" -v -p 66 -c "$PROJECT_DIR"
    tmux split-window -t "$SESSION_NAME" -v -p 50 -c "$PROJECT_DIR"
    tmux select-pane -t "$SESSION_NAME:0.1"
    tmux split-window -t "$SESSION_NAME" -h -p 50 -c "$PROJECT_DIR"
    tmux select-pane -t "$SESSION_NAME:0.3"
    tmux split-window -t "$SESSION_NAME" -h -p 50 -c "$PROJECT_DIR"

    # 各ペインでエージェント起動
    local agents=("captain" "vulcan" "klingon" "android1" "android2")
    local colors=("$C_CAPTAIN" "$C_VULCAN" "$C_KLINGON" "$C_ANDROID" "$C_ANDROID")

    for i in "${!agents[@]}"; do
        local pane="$SESSION_NAME:0.$i"
        local agent="${agents[$i]}"
        local color="${colors[$i]}"

        tmux send-keys -t "$pane" "cd '$PROJECT_DIR' && bash ./scripts/start-agent.sh $agent" C-m
        tmux set-option -t "$pane" pane-border-style "fg=$color"
        tmux set-option -t "$pane" pane-active-border-style "fg=$color"
    done

    # Claude Code起動待ち
    echo "エージェント起動待機中..."
    sleep 10

    # 各エージェントに初期メッセージ送信
    echo "初期メッセージ送信中..."

    # 総督
    tmux send-keys -t "$SESSION_NAME:0.0" "$(init_captain)"
    tmux send-keys -t "$SESSION_NAME:0.0" C-m

    sleep 2

    # ヴァルカン
    tmux send-keys -t "$SESSION_NAME:0.1" "$(init_vulcan)"
    tmux send-keys -t "$SESSION_NAME:0.1" C-m

    sleep 2

    # クリンゴン
    tmux send-keys -t "$SESSION_NAME:0.2" "$(init_klingon)"
    tmux send-keys -t "$SESSION_NAME:0.2" C-m

    sleep 2

    # アンドロイド 1
    tmux send-keys -t "$SESSION_NAME:0.3" "$(init_android 1)"
    tmux send-keys -t "$SESSION_NAME:0.3" C-m

    sleep 2

    # アンドロイド 2
    tmux send-keys -t "$SESSION_NAME:0.4" "$(init_android 2)"
    tmux send-keys -t "$SESSION_NAME:0.4" C-m

    # 総督 ペインを選択
    tmux select-pane -t "$SESSION_NAME:0.0"

    echo ""
    echo "USS Enterprise 準備完了"
    echo ""
    echo "  接続: ./enterprise attach"
    echo "  ペイン切替: Ctrl-b + 矢印キー"
    echo ""
}

stop_session() {
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "セッション '$SESSION_NAME' は起動していません"
        exit 1
    fi

    tmux kill-session -t "$SESSION_NAME"
    echo "USS Enterprise を停止しました"
}

attach_session() {
    if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "セッション '$SESSION_NAME' は起動していません"
        echo "  起動: ./enterprise start"
        exit 1
    fi

    tmux attach -t "$SESSION_NAME"
}

show_status() {
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        echo "USS Enterprise: 起動中"
        echo ""
        tmux list-panes -t "$SESSION_NAME" -F "  Pane #{pane_index}: #{pane_current_command}"
    else
        echo "USS Enterprise: 停止中"
    fi
}

show_help() {
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  start   - セッション起動"
    echo "  stop    - セッション停止"
    echo "  attach  - セッションに接続"
    echo "  status  - ステータス確認"
    echo "  help    - このヘルプを表示"
}

case "${1:-start}" in
    start)  start_session ;;
    stop)   stop_session ;;
    attach) attach_session ;;
    status) show_status ;;
    help|-h|--help) show_help ;;
    *)
        echo "不明なコマンド: $1"
        show_help
        exit 1
        ;;
esac
