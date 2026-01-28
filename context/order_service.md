# Order Service コンテキスト

## 基本情報
- **リポジトリ**: ~/repos/order-service
- **技術スタック**: Python, FastAPI, PostgreSQL, RabbitMQ
- **ポート**: 8082

## ディレクトリ構造
```
order-service/
├── src/
│   ├── api/          # エンドポイント
│   ├── domain/       # ビジネスロジック
│   ├── infra/        # DB・外部連携
│   └── tests/
├── docker-compose.yml
└── README.md
```

## 依存サービス
- **user_service**: 顧客情報取得 (gRPC)
- **product_service**: 在庫確認・更新 (gRPC)
- **notification_service**: 注文通知 (RabbitMQ)

## API エンドポイント
| Method | Path | 説明 |
|--------|------|------|
| POST | /orders | 注文作成 |
| GET | /orders/{id} | 注文詳細 |
| GET | /orders | 注文一覧 |
| PATCH | /orders/{id}/cancel | 注文キャンセル |

## 開発コマンド
```bash
cd ~/repos/order-service
docker-compose up -d     # 依存サービス起動
poetry install           # 依存関係
poetry run pytest        # テスト
poetry run uvicorn src.main:app --reload  # 起動
```

## 注意事項
- 在庫更新は product_service 経由（直接DBアクセス禁止）
- 決済処理は外部API（Stripe）
