# A社 - ECバックエンド

## 基本情報

| 項目 | 内容 |
|------|------|
| 会社 | A社 |
| プロジェクト | ECバックエンド |
| リポジトリ | ~/work/company-a/ec-backend |
| 技術スタック | Go, PostgreSQL, Redis |

## アーキテクチャ

```
ec-backend/
├── cmd/
│   └── api/          # エントリーポイント
├── internal/
│   ├── handler/      # HTTPハンドラー
│   ├── usecase/      # ビジネスロジック
│   ├── domain/       # ドメインモデル
│   └── infra/        # DB・外部連携
├── pkg/              # 公開パッケージ
└── docker-compose.yml
```

## 開発コマンド

```bash
cd ~/work/company-a/ec-backend
docker-compose up -d      # 依存サービス起動
go run cmd/api/main.go    # 開発サーバー起動
go test ./...             # テスト実行
```

## 注意事項

- （A社固有のルールをここに記載）
