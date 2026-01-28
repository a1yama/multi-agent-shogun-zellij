# B社 - SaaS API

## 基本情報

| 項目 | 内容 |
|------|------|
| 会社 | B社 |
| プロジェクト | SaaS API |
| リポジトリ | ~/work/company-b/saas-api |
| 技術スタック | Go, gRPC, PostgreSQL |

## マルチテナント設計

- テナント識別: JWT内のtenant_id
- DB分離: スキーマ分離方式

## 開発コマンド

```bash
cd ~/work/company-b/saas-api
make run
make test
make proto  # gRPCコード生成
```

## 注意事項

- （B社固有のルールをここに記載）
