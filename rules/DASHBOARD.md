# Dashboard機能実装 (2026-02-09)

## 概要

元のShogunアーキテクチャにあったDashboard機能を実装しました。
**全エージェント**が自分のステータスを`status/dashboard.md`に更新します。

---

## Dashboard表示方法

### 方法1: VSCode Preview（推奨）

```bash
code status/dashboard.md
```

VSCodeのMarkdownプレビュー機能で、リアルタイムで更新を確認できます。

### 方法2: ターミナルで自動更新表示

```bash
watch -n 1 cat status/dashboard.md
```

1秒ごとに自動的に再読み込みされます。

### 方法3: 別tmuxペインで表示

```bash
tmux split-window -h
watch -n 1 cat status/dashboard.md
```

---

## Dashboard構成

```markdown
# 🚀 USS Enterprise Mission Dashboard

## 📊 Mission Overview
- Status, Objective, Target, Quality Threshold
- Start/Completion timestamps

## 👨‍✈️ Captain Picard
- Status: 🟢 Ready / Active / Waiting
- Current phase
- Last action / Next action

## 🖖 Vulcan (Mr. Spock)
- Status: 🔵 Standby / Planning / Reviewing / Reporting
- Phase, Iteration
- Last action / Next action

## 🤖 Android Unit 1 (Data)
- Status: 🟣 Standby / Processing / Completed
- Task
- Last action / Next action

## 🤖 Android Unit 2 (Data)
- Status: 🟣 Standby / Processing / Completed
- Task
- Last action / Next action

## ⚔️ Klingon (Worf)
- Status: 🔴 Standby / Reviewing / Completed
- Task
- Last action / Next action

## 📈 Quality Metrics
- Coverage, Depth, Consistency, Red Team Resolved
- Overall score
- Target vs Current

## 📋 Timeline
- Timestamped event log
```

---

## 更新責務

| エージェント | 更新タイミング |
|-------------|---------------|
| **Captain** | ミッション開始時、最終報告時 |
| **Vulcan** | 計画立案時、レビュー時、各フェーズ移行時 |
| **Android 1** | タスク開始時、完了時 |
| **Android 2** | タスク開始時、完了時 |
| **Klingon** | レビュー開始時、完了時 |

**重要**: Vulcanだけでなく、**全エージェント**が自分のセクションを更新します。

---

## 実装変更

### 新規ファイル

1. **[status/dashboard.md](status/dashboard.md)** - Dashboard本体

### 更新されたファイル

1. **[roles/captain.md](roles/captain.md)**
   - Dashboard更新指示追加
   - `Edit` ツールに `status/dashboard.md` 追加

2. **[roles/vulcan.md](roles/vulcan.md)**
   - 各フェーズでDashboard更新指示追加
   - `Edit` ツールに `status/dashboard.md` 追加

3. **[roles/android1.md](roles/android1.md)**
   - タスク開始時・完了時のDashboard更新指示追加
   - `Edit` ツールに `status/dashboard.md` 追加

4. **[roles/android2.md](roles/android2.md)**
   - タスク開始時・完了時のDashboard更新指示追加
   - `Edit` ツールに `status/dashboard.md` 追加

5. **[roles/klingon.md](roles/klingon.md)**
   - レビュー開始時のDashboard更新指示追加
   - `Edit` ツールに `status/dashboard.md` 追加

6. **[scripts/tmux-session.sh](scripts/tmux-session.sh)**
   - 全エージェントの初期化メッセージにDashboard更新指示追加

7. **[README.md](README.md)**
   - Dashboard表示方法セクション追加
   - 自動ワークフローにDashboard更新を明記

---

## 使い方

### 1. セッション起動

```bash
./enterprise start
```

### 2. Dashboard表示（別ターミナル）

```bash
code status/dashboard.md
```

または

```bash
watch -n 1 cat status/dashboard.md
```

### 3. ミッション実行

Captainペインでミッションを指示。

### 4. リアルタイム監視

Dashboardで各エージェントのステータスをリアルタイム確認：

```
## 👨‍✈️ Captain Picard
Status: 🟢 Active
Phase:  Mission Initiated
Action: Delegated to Vulcan
```

```
## 🖖 Vulcan (Mr. Spock)
Status: 🟢 Planning
Phase:  Investigation planning
Iteration: 1
```

```
## 🤖 Android Unit 1 (Data)
Status: 🟢 Processing
Task:   Collecting primary research papers
```

---

## メリット

1. **一目で進捗把握**: tmuxペインを切り替えずに全体像を確認
2. **ボトルネック特定**: どのエージェントが処理中か即座に判明
3. **タイムスタンプ連携**: mission.yamlのタイムスタンプと合わせて詳細な時系列を記録
4. **視覚的フィードバック**: 絵文字とステータスで直感的に理解
5. **デバッグ支援**: 問題発生時に「どのエージェントがどの状態で止まったか」を即座に確認

---

## 元のShogunとの違い

| 項目 | 元のShogun | USS Enterprise |
|------|-----------|---------------|
| Dashboard更新 | 主にKaroが更新 | **全エージェント**が更新 |
| 更新頻度 | フェーズごと | 各ステップごと（詳細） |
| 表示形式 | Markdown | Markdown（絵文字付き） |
| キャラクター | なし | Star Trekキャラクター反映 |
| タイムスタンプ | あり | あり（拡張版） |

---

## 次のステップ（オプション）

### Agent Skills機能

元のShogunにはAgent Skills（繰り返しパターンの自動スキル化）機能もありました。
現在のシステムが安定稼働してから、Phase 2として検討できます。

**Agent Skillsの機能**:
- 繰り返しパターンを検知
- Web検索で市場調査
- 公式ドキュメント分析
- 既存スキルとの重複確認
- 実装価値判定
- スキル生成 or 却下

---

**Dashboard実装完了**
**2026-02-09**

🖖 Live Long and Prosper
