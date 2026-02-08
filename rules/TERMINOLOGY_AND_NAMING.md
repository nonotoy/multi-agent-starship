# 用語統一とファイル命名規則 (2026-02-09)

## 用語統一

### 原則

- **日本語説明文内**: 日本語用語を使用
- **英語台詞/ステータス内**: 英語用語を維持
- **指示は人名を使用**: 役割名ではなく人名で指示する

### 用語対応表

| 英語 | 日本語 | 人名 | 使い分け |
|------|--------|------|---------|
| Captain | 総督 | Picard | 指示: "Picardに報告" |
| Vulcan | ヴァルカン | Spock | 指示: "Spockに委任" |
| Klingon | クリンゴン | Worf | 指示: "Worfに依頼" |
| Android | アンドロイド | Data (Unit 1/2) | 指示: "Androidに指示" (複数いるため) |

### 例

**❌ 間違い**:
```
ヴァルカンに指示を出す
クリンゴンにレビュー依頼
```

**✅ 正しい**:
```
Spockに指示を出す
Worfにレビュー依頼
```

**英語台詞では**:
```
Acknowledged, Captain.
Awaiting Vulcan's assignment
```

**日本語説明文では**:
```
総督から指示を受けたら、Spockが計画を立案します。
Worfがレッドチームレビューを実施します。
```

---

## 出力ファイル構造

### 形式

```
reports/
  YYYYMMDDHHMM_[作業名]/
    final_report.md          # 最終統合レポート（Spock分析 + Worfレビュー含む）
    command_history.md       # 指示系統履歴
```

### 詳細

#### フォルダ名

```
YYYYMMDDHHMM_[作業名]
```

- **YYYYMMDDHHMM**: ユーザーが総督に最初にミッションを投げた日時
- **[作業名]**: ミッションの簡潔な説明（英数字、アンダースコア）

**例**:
```
202602091430_voynich_manuscript_research/
202602091530_code_review_authentication/
202602091630_market_analysis_competitors/
```

#### final_report.md

Spockが作成する統合レポート。以下を全て含む:

1. **ミッション概要**
   - 総督からの指示
   - 目標と品質閾値

2. **Data収集結果**
   - Android Unit 1の一次データ
   - Android Unit 2の関連情報・コンテキスト

3. **Spock論理的分析**
   - 収集データの統合分析
   - 論理的評価と結論

4. **Worfレッドチームレビュー**
   - 批判的指摘事項
   - 脆弱性と推奨対応

5. **品質評価**
   - Coverage, Depth, Consistency, Red Team Resolved
   - Overall スコア

6. **最終結論と推奨事項**

#### command_history.md

総督またはSpockが作成する指示系統の履歴:

1. **タイムライン**
   - 各フェーズの開始・完了時刻
   - 誰が誰に何を指示したか

2. **ツール実行ログ**
   - 各エージェントが使用したツール
   - 実行回数と結果

3. **品質フィードバックループ**
   - イテレーション回数
   - 再調査が発生した理由

---

## 実装

### 1. mission.yamlの構造

```yaml
mission:
  request_id: "202602091430"  # YYYYMMDDHHMMフォーマット
  work_name: "voynich_manuscript_research"  # 作業名

reports:
  output_dir: "reports/202602091430_voynich_manuscript_research/"
  final_report: "reports/202602091430_voynich_manuscript_research/final_report.md"
  command_history: "reports/202602091430_voynich_manuscript_research/command_history.md"
```

### 2. 総督の責務

ミッション開始時に:

1. `request_id` を生成 (YYYYMMDDHHMM)
2. `work_name` を生成 (目標から英数字で生成)
3. `output_dir` を作成

```bash
REQUEST_ID=$(date +"%Y%m%d%H%M")
WORK_NAME="voynich_manuscript_research"
OUTPUT_DIR="reports/${REQUEST_ID}_${WORK_NAME}"
mkdir -p "$OUTPUT_DIR"
```

### 3. Spockの責務

最終報告時に:

1. **final_report.md** を作成
   - Android 1/2の結果を統合
   - 自分の論理的分析を追加
   - Worfのレビューを組み込み
   - 最終結論を記載

2. **command_history.md** を作成
   - タイムラインを記録
   - 指示系統を可視化
   - 品質ループの詳細を記載

---

## ディレクトリ構成例

```
uss-enterprise/
  reports/
    202602091430_voynich_manuscript_research/
      final_report.md          (22KB)
      command_history.md       (8KB)
    202602091530_code_review_authentication/
      final_report.md          (15KB)
      command_history.md       (6KB)
  shared/
    mission.yaml
  status/
    dashboard.md
```

---

## メリット

1. **整理された構造**: 1ミッション = 1フォルダ
2. **時系列管理**: タイムスタンプでソート可能
3. **追跡性**: command_historyで経緯を追跡
4. **シンプル**: 中間ファイルなし、最終成果物のみ
5. **検索性**: 作業名でフォルダを特定しやすい

---

## 変更されたファイル

### 用語統一（人名使用）
- [roles/captain.md](roles/captain.md) - "Spockに委任"
- [roles/vulcan.md](roles/vulcan.md) - "Dataに指示", "Worfに依頼"
- [roles/klingon.md](roles/klingon.md) - "Spockに報告"
- [roles/android1.md](roles/android1.md) - "Spockから指示"
- [roles/android2.md](roles/android2.md) - "Spockから指示"
- [scripts/tmux-session.sh](scripts/tmux-session.sh) - "Spockを起動"

### ファイル構造
- [shared/mission.yaml](shared/mission.yaml) - `output_dir`, `work_name` 追加

---

**実施日**: 2026-02-09

🖖 Live Long and Prosper
