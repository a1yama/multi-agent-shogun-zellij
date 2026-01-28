# 🏯 multi-agent-shogun-zellij

戦国マルチエージェント統率システム - Zellij版 for macOS

複数のClaude Code CLIインスタンスを並列実行し、戦国時代の階級制度をテーマにしたマルチエージェントオーケストレーションを実現します。

> 本プロジェクトは [yohey-w/multi-agent-shogun](https://github.com/yohey-w/multi-agent-shogun) を参考に、tmuxの代わりにZellijを使用してmacOS向けに再実装したものです。

## 特徴

- **⚡ 並列実行**: 最大8人の足軽（ワーカー）が同時にタスクを処理
- **🔄 ノンブロッキング**: 将軍がタスクを委譲後、即座に次の指示を受付可能
- **📡 イベント駆動**: YAMLファイルとZellij actionによるエージェント間通信
- **🖥️ macOS対応**: Zellijを使用したネイティブなターミナル体験

## 階級構成

```
あなた（殿）
  ↓ 指示
【将軍（Shogun）】× 1
  ├─ 役割：コマンド受付・委譲
  ├─ モデル：Opus（思考なし）
  └─ 特徴：即座に委譲して制御を返す

【家老（Karo）】× 1
  ├─ 役割：タスク分解・ダッシュボード管理
  └─ モデル：デフォルト（思考有効）

【足軽（Ashigaru）】× 8
  ├─ 役割：並列実行でタスク実装
  └─ モデル：デフォルト（思考有効）
```

## 必要条件

- macOS
- [Zellij](https://zellij.dev/) (`brew install zellij`)
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)
- Node.js v20+

## インストール

```bash
# リポジトリをクローン
git clone https://github.com/a1yama/multi-agent-shogun-zellij.git ~/multi-agent-shogun

# ディレクトリに移動
cd ~/multi-agent-shogun

# 実行権限を付与
chmod +x shutsujin_departure.sh
```

## 使い方

### 1. 出陣（起動）

```bash
cd ~/multi-agent-shogun
./shutsujin_departure.sh
```

### 2. 将軍に接続

```bash
zellij attach shogun
```

### 3. 指示を出す

将軍（Claude）に自然言語で指示を出すだけです：

```
「Notionのタスク一覧を整理せよ」
「このプロジェクトのREADMEを改善せよ」
「APIのエラーハンドリングを調査せよ」
```

### 4. セッション操作

| コマンド | 説明 |
|----------|------|
| `zellij attach shogun` | 将軍に接続 |
| `zellij attach karo` | 家老に接続 |
| `zellij attach ashigaru1` | 足軽1に接続 |
| `zellij list-sessions` | セッション一覧 |
| `Ctrl+O, w` | セッション切り替え（接続中） |

### 5. 終了

```bash
# 全セッションを終了
for s in shogun karo ashigaru{1..8}; do
  zellij delete-session $s --force 2>/dev/null
done
```

## ディレクトリ構造

```
~/multi-agent-shogun/
├── shutsujin_departure.sh  # 起動スクリプト
├── CLAUDE.md               # システム説明
├── dashboard.md            # 戦況報告板（リアルタイム更新）
├── config/
│   ├── settings.yaml       # 言語設定など
│   └── projects.yaml       # プロジェクト定義
├── context/                # プロジェクト別コンテキスト
├── instructions/           # エージェント指示書
│   ├── shogun.md
│   ├── karo.md
│   └── ashigaru.md
├── layouts/                # Zellijレイアウト
├── memory/                 # 永続メモリ
├── queue/
│   ├── tasks/             # 足軽への指示
│   └── reports/           # 足軽からの報告
├── skills/                # カスタムスキル
├── status/                # ステータス情報
└── templates/             # テンプレート
```

## 複数プロジェクト・マイクロサービス対応

`config/projects.yaml` でプロジェクトを定義し、`context/` にコンテキストファイルを作成することで、複数のプロジェクトやマイクロサービス構成に対応できます。

詳細は [config/projects.yaml](config/projects.yaml) を参照してください。

## オリジナルとの違い

| 項目 | オリジナル (tmux) | 本リポジトリ (Zellij) |
|------|-------------------|----------------------|
| ターミナルマルチプレクサ | tmux | Zellij |
| 対象OS | Windows (WSL2) / Linux / macOS | macOS |
| セッション管理 | 1セッション内に複数ペイン | 各エージェントが独立セッション |
| メッセージ送信 | `tmux send-keys` | `zellij action write-chars` |

## ライセンス

MIT License

## クレジット

- オリジナル: [yohey-w/multi-agent-shogun](https://github.com/yohey-w/multi-agent-shogun)
- ASCIIアート: [syntax-samurai/ryu](https://github.com/syntax-samurai/ryu) (CC0 1.0)
