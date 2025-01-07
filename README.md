# AppSync Terraform Template

このプロジェクトは、AWS AppSync と Aurora Serverless を使用した GraphQL API を Terraform で構築するためのテンプレートです。

## 前提条件

- [Visual Studio Code](https://code.visualstudio.com/)
- [Docker](https://www.docker.com/)
- [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) VSCode 拡張機能
- AWS 認証情報（`~/.aws/credentials`）

## セットアップ

1. このリポジトリをクローンします
2. VSCode でプロジェクトを開きます
3. コマンドパレット（`Cmd/Ctrl + Shift + P`）を開き、`Dev Containers: Reopen in Container`を選択します
4. コンテナのビルドと起動を待ちます

## 環境変数の設定

`terraform.tfvars`ファイルを作成し、以下の変数を設定します：

```hcl
db_username = "your_username"
db_password = "your_secure_password"
vpc_id      = "your_vpc_id"
```

## 使用方法

以下の Make コマンドを使用して Terraform とデータベースを操作できます：

```bash
# Terraform コマンド
make init          # 初期化
make setup         # 初期化、フォーマット、バリデーションを実行
make plan          # プラン確認
make apply         # リソースのデプロイ
make destroy       # リソースの削除

# データベースコマンド
make db-dry-run    # データベーススキーマの変更をドライラン
make db-apply      # データベーススキーマの変更を適用
```

## アーキテクチャ

このテンプレートは以下の AWS リソースを作成します：

- AppSync GraphQL API
- Aurora Serverless（PostgreSQL）
- Secrets Manager（データベース認証情報用）
- 必要な IAM ロールとポリシー
- VPC エンドポイント（AWS AppSync と Aurora Serverless の接続用）

## 注意事項

- Aurora Serverless はサーバーレスモードで動作し、使用量に応じて自動的にスケーリングします
- データベースの認証情報は安全に管理するため、AWS Secrets Manager に保存されます
- AppSync は Aurora Serverless の Data API を使用してデータベースにアクセスします
- データベースのスキーマ管理には psqldef を使用しています
