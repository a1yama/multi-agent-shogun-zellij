# multi-agent-shogun

戦国マルチエージェント統率システム（Zellij版 for macOS）

## システム概要

このシステムは、複数のClaude Code CLIインスタンスを並列実行し、
戦国時代の階級制度をテーマにしたマルチエージェントオーケストレーションを実現する。

## 階級構成

```
あなた（殿）
  ↓ 指示
【将軍（Shogun）】× 1
  ├─ 役割：コマンド受付・委譲
  ├─ モデル：Opus（思考なし）
  └─ 特徴：即座に委譲して制御を返す

【家老（Karo）】× 1
  ├─ 役割：タスク配分・ダッシュボード管理
  └─ モデル：デフォルト（思考有効）

【足軽（Ashigaru）】× 8
  ├─ 役割：並列実行でタスク実装
  └─ モデル：デフォルト（思考有効）
```

## 通信方式

- **YAMLファイル**: タスク指示・報告
- **Zellij action**: エージェント間の起動通知
- **dashboard.md**: 状況の可視化

## ディレクトリ構造

```
~/multi-agent-shogun/
├── config/           # 設定ファイル
├── context/          # プロジェクト別コンテキスト
├── instructions/     # エージェント指示書
├── layouts/          # Zellijレイアウト
├── memory/           # 永続メモリ
├── queue/            # タスクキュー
│   ├── tasks/        # 足軽への指示
│   └── reports/      # 足軽からの報告
├── status/           # ステータス情報
├── templates/        # テンプレート
├── skills/           # スキル
└── dashboard.md      # 戦況報告板
```

## 起動方法

```bash
cd ~/multi-agent-shogun
./shutsujin_departure.sh
```

## セッション操作

```bash
# 将軍に接続
zellij attach shogun

# 家老に接続
zellij attach karo

# 足軽に接続
zellij attach ashigaru1

# セッション一覧
zellij list-sessions

# セッション終了
zellij kill-session shogun
```

## 重要なルール

1. **将軍は自分でタスクを実行しない** - 家老に委譲
2. **家老は自分でタスクを実行しない** - 足軽に委譲
3. **足軽は指示された作業のみ実行** - 勝手な作業禁止
4. **ポーリング禁止** - API代金の無駄
5. **同一ファイルへの同時書き込み禁止** - 競合防止

## ワークフロー

```
殿 → 将軍: 「○○をせよ」
      ↓
将軍 → YAML: queue/shogun_to_karo.yaml に書く
      ↓
将軍 → 家老: zellij action で起こす
      ↓
家老 → YAML: queue/tasks/ashigaru{N}.yaml に分解
      ↓
家老 → 足軽: zellij action で起こす
      ↓
足軽 → 作業実行
      ↓
足軽 → YAML: queue/reports/ashigaru{N}_report.yaml に報告
      ↓
足軽 → 家老: zellij action で起こす
      ↓
家老 → dashboard.md: 戦況を更新
```
