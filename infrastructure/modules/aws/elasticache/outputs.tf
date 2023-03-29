output "arn" {
  value = aws_elasticache_replication_group.main.arn
}

output "engine_version_actual" {
  value = aws_elasticache_replication_group.main.engine_version_actual
}

output "cluster_enabled" {
  value = aws_elasticache_replication_group.main.cluster_enabled
}

output "configuration_endpoint_address" {
  value = aws_elasticache_replication_group.main.configuration_endpoint_address
}

output "id" {
  value = aws_elasticache_replication_group.main.id
}

output "member_clusters" {
  value = aws_elasticache_replication_group.main.member_clusters
}

output "primary_endpoint_address" {
  value = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "reader_endpoint_address" {
  value = aws_elasticache_replication_group.main.reader_endpoint_address
}
