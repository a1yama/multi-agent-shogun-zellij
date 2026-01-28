# ECサイト マイクロサービスシステム

## アーキテクチャ概要

```
                    ┌─────────────────┐
                    │   Client App    │
                    └────────┬────────┘
                             │
                    ┌────────▼────────┐
                    │   API Gateway   │ :8080
                    │   (Go/Kong)     │
                    └────────┬────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼───────┐   ┌───────▼───────┐   ┌───────▼───────┐
│ User Service  │   │ Order Service │   │Product Service│
│  (Node.js)    │   │   (Python)    │   │    (Go)       │
│    :8081      │   │    :8082      │   │    :8083      │
└───────┬───────┘   └───────┬───────┘   └───────────────┘
        │                   │
        │           ┌───────▼───────┐
        └──────────►│ Notification  │
                    │   Service     │
                    │    :8084      │
                    └───────────────┘
```

## サービス間通信

| From | To | Protocol | Purpose |
|------|-----|----------|---------|
| API Gateway | All Services | REST/gRPC | リクエストルーティング |
| Order Service | User Service | gRPC | ユーザー情報取得 |
| Order Service | Product Service | gRPC | 在庫確認・更新 |
| Order Service | Notification | RabbitMQ | 注文通知 |
| User Service | Notification | RabbitMQ | 登録完了通知 |

## 共通ルール

1. **API設計**: OpenAPI 3.0準拠
2. **認証**: JWT (API Gatewayで検証)
3. **ログ**: JSON形式、correlation ID必須
4. **エラー**: RFC 7807 Problem Details
5. **テスト**: 単体テストカバレッジ80%以上

## 環境

| 環境 | URL | 用途 |
|------|-----|------|
| local | localhost:8080 | 開発 |
| dev | dev.example.com | 統合テスト |
| staging | stg.example.com | 本番前検証 |
| prod | api.example.com | 本番 |

## よくある作業パターン

### 新機能追加（複数サービス）
1. shared_libs に型定義追加
2. 各サービスで実装
3. API Gateway にルート追加
4. 統合テスト

### バグ修正
1. ログから該当サービス特定
2. 単体テストで再現
3. 修正・テスト
4. 他サービスへの影響確認
