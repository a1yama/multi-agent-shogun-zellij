# C社 - データパイプライン

## 基本情報

| 項目 | 内容 |
|------|------|
| 会社 | C社 |
| プロジェクト | データパイプライン |
| リポジトリ | ~/work/company-c/data-pipeline |
| 技術スタック | Python, Airflow, BigQuery |

## アーキテクチャ

```
data-pipeline/
├── dags/              # Airflow DAGs
├── plugins/           # カスタムオペレーター
├── scripts/           # ETLスクリプト
├── tests/
└── requirements.txt
```

## 開発コマンド

```bash
cd ~/work/company-c/data-pipeline
poetry install
poetry run pytest
airflow dags test <dag_id>
```

## 注意事項

- （C社固有のルールをここに記載）
