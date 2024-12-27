output "appsync_api_url" {
  description = "AppSync API URL"
  value       = aws_appsync_graphql_api.main.uris["GRAPHQL"]
}

output "appsync_api_key" {
  description = "AppSync API Key"
  value       = aws_appsync_api_key.main.key
  sensitive   = true
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = aws_rds_cluster.main.endpoint
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = aws_rds_cluster.main.database_name
} 