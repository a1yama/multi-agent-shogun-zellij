# A社 - EC管理画面

## 基本情報

| 項目 | 内容 |
|------|------|
| 会社 | A社 |
| プロジェクト | EC管理画面 |
| リポジトリ | ~/work/company-a/ec-admin |
| 技術スタック | PHP, Laravel, MySQL |

## アーキテクチャ

```
ec-admin/
├── app/
│   ├── Http/Controllers/
│   ├── Models/
│   └── Services/
├── resources/views/
├── routes/
└── docker-compose.yml
```

## 開発コマンド

```bash
cd ~/work/company-a/ec-admin
docker-compose up -d
composer install
php artisan serve
php artisan test
```

## 注意事項

- （A社固有のルールをここに記載）
