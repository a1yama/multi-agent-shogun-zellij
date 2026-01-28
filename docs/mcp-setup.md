# Memory MCP セットアップガイド

## Claude Code でMCPを有効にする

### 1. MCP設定ファイルを編集

`~/.claude.json` または Claude Code の設定ファイルに以下を追加:

```json
{
  "mcpServers": {
    "memory": {
      "command": "node",
      "args": ["~/multi-agent-shogun/mcp/memory-server.js"]
    }
  }
}
```

### 2. 確認

Claude Code を再起動後、以下のツールが使えるようになります:

- `mcp__memory__read_graph` - メモリを読み込む
- `mcp__memory__create_entities` - エンティティを作成
- `mcp__memory__add_observations` - 観察を追加

## 将軍の指示書での使い方

将軍（shogun）の指示書では、セッション開始時に自動でメモリを読み込むよう設定されています:

```yaml
# instructions/shogun.md より
memory:
  on_session_start:
    - action: mcp__memory__read_graph
```

## 記憶されるもの

| カテゴリ | 例 |
|----------|-----|
| 殿の好み | 「シンプルがいい」「過剰機能は不要」 |
| 意思決定 | 「認証方式はJWTを採用」 |
| 解決済み問題 | 「このバグの原因と解決法」 |

## メモリファイルの場所

```
~/multi-agent-shogun/memory/shogun_memory.jsonl
```

JSON Lines形式で保存されます。
