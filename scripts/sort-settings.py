#!/usr/bin/env python3
"""
USS Enterprise - settings.local.json Sorter

このスクリプトは .claude/settings.local.json の permissions.allow リストを
アルファベット昇順でソートします。

Usage:
    python scripts/sort-settings.py

Platform: macOS, Linux, WSL
Requirements: Python 3.6+
"""

import json
import sys
from pathlib import Path


def sort_settings(settings_path: Path) -> bool:
    """
    settings.local.json を読み込んでソートし、保存する

    Args:
        settings_path: settings.local.json のパス

    Returns:
        成功したら True、失敗したら False
    """
    try:
        # ファイルが存在しない場合はスキップ
        if not settings_path.exists():
            print(f"⚠️  {settings_path} が見つかりません。スキップします。")
            return True

        # JSON を読み込む
        with open(settings_path, 'r', encoding='utf-8') as f:
            settings = json.load(f)

        # permissions.allow が存在するか確認
        if 'permissions' not in settings:
            print("⚠️  'permissions' キーが見つかりません。")
            return False

        if 'allow' not in settings['permissions']:
            print("⚠️  'permissions.allow' キーが見つかりません。")
            return False

        # allow リストをソート
        original_allow = settings['permissions']['allow']
        sorted_allow = sorted(original_allow)

        # 変更がない場合
        if original_allow == sorted_allow:
            print("✅ すでにソート済みです。変更はありません。")
            return True

        # ソート結果を適用
        settings['permissions']['allow'] = sorted_allow

        # ファイルに書き込む（インデント2、末尾改行あり）
        with open(settings_path, 'w', encoding='utf-8') as f:
            json.dump(settings, f, indent=2, ensure_ascii=False)
            f.write('\n')

        print(f"✅ ソート完了: {len(sorted_allow)} 件のエントリをアルファベット順にソートしました。")
        return True

    except json.JSONDecodeError as e:
        print(f"❌ JSON パースエラー: {e}")
        return False
    except Exception as e:
        print(f"❌ エラー: {e}")
        return False


def main():
    """メイン関数"""
    # スクリプトのディレクトリから相対パスでプロジェクトルートを取得
    script_dir = Path(__file__).resolve().parent
    project_dir = script_dir.parent
    settings_path = project_dir / '.claude' / 'settings.local.json'

    print("USS Enterprise - settings.local.json Sorter")
    print("=" * 50)
    print(f"対象ファイル: {settings_path}")
    print()

    success = sort_settings(settings_path)

    if success:
        print()
        print("🖖 Live Long and Prosper")
        sys.exit(0)
    else:
        print()
        print("❌ ソート処理に失敗しました。")
        sys.exit(1)


if __name__ == '__main__':
    main()
