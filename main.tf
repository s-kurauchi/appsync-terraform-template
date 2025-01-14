resource "aws_appsync_graphql_api" "main" {
  name                = "${var.project_name}-${var.environment}"
  authentication_type = "API_KEY"

  schema = file("${path.module}/graphql/schema.graphql")

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_appsync_api_key" "main" {
  api_id  = aws_appsync_graphql_api.main.id
  expires = timeadd(timestamp(), "2160h") # 90日
}

resource "aws_security_group" "aurora" {
  name        = "${var.project_name}-${var.environment}-aurora-sg"
  description = "Security group for Aurora Serverless"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # 注意: 本番環境では適切なIPレンジに制限することを推奨
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Aurora Serverlessクラスター
resource "aws_rds_cluster" "main" {
  cluster_identifier   = "${var.project_name}-${var.environment}"
  engine               = "aurora-postgresql"
  engine_mode          = "provisioned"
  database_name        = replace("${var.project_name}_${var.environment}", "-", "_")
  master_username      = var.db_username
  master_password      = var.db_password
  skip_final_snapshot  = true
  enable_http_endpoint = true # Data APIを有効化

  vpc_security_group_ids = [aws_security_group.aurora.id] # セキュリティグループを関連付け

  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 1
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Aurora Serverlessクラスターインスタンス
resource "aws_rds_cluster_instance" "main" {
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version

  publicly_accessible = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# AppSync用のIAMロール
resource "aws_iam_role" "appsync_rds_role" {
  name = "${var.project_name}-${var.environment}-appsync-rds-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "appsync.amazonaws.com"
        }
      }
    ]
  })
}

# AppSync用のIAMポリシー
resource "aws_iam_role_policy" "appsync_rds_policy" {
  name = "${var.project_name}-${var.environment}-appsync-rds-policy"
  role = aws_iam_role.appsync_rds_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "rds-data:ExecuteStatement",
          "rds-data:BatchExecuteStatement",
          "rds-data:BeginTransaction",
          "rds-data:CommitTransaction",
          "rds-data:RollbackTransaction"
        ]
        Resource = [
          aws_rds_cluster.main.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          aws_secretsmanager_secret.rds_credentials.arn
        ]
      }
    ]
  })
}

# RDSの認証情報をSecrets Managerに保存
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.project_name}-${var.environment}-rds-credentials"
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}

# AppSyncのRDSデータソース
resource "aws_appsync_datasource" "rds" {
  api_id           = aws_appsync_graphql_api.main.id
  name             = "rds_datasource"
  service_role_arn = aws_iam_role.appsync_rds_role.arn
  type             = "RELATIONAL_DATABASE"

  relational_database_config {
    http_endpoint_config {
      db_cluster_identifier = aws_rds_cluster.main.cluster_identifier
      database_name         = aws_rds_cluster.main.database_name
      aws_secret_store_arn  = aws_secretsmanager_secret.rds_credentials.arn
    }
  }
}
