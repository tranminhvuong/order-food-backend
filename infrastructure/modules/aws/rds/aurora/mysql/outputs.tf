output "endpoint" {
  value = {
    main = aws_rds_cluster.main.endpoint
    read = aws_rds_cluster.main.reader_endpoint
  }
}
output "rds_cluster_master_password" {
  value = nonsensitive(aws_rds_cluster.main.master_password)
}
