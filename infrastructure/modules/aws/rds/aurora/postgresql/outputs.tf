output "endpoint" {
  value = {
    main = aws_rds_cluster.main.endpoint
    read = aws_rds_cluster.main.reader_endpoint
  }
}
