output "master_user_secret_arn" {
  value = aws_rds_cluster.postgres.master_user_secret[0].secret_arn
}

output "cluster_arn" {
  value = aws_rds_cluster.postgres.arn
}