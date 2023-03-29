resource "aws_db_subnet_group" "main" {
  name       = "${var.cluster_name}-subnet"
  subnet_ids = var.subnet_ids
}

resource "aws_iam_role" "main" {
  name               = "${var.cluster_name}-monitoring-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "monitoring.rds.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_rds_cluster_parameter_group" "main" {
  name   = "${var.cluster_name}-cluster-parameter-group"
  family = "aurora-mysql5.7"
}

resource "aws_db_parameter_group" "main" {
  name   = "${var.cluster_name}-parameter-group"
  family = "aurora-mysql5.7"
}

resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_rds_cluster" "main" {
  cluster_identifier              = var.cluster_name
  engine                          = "aurora-mysql"
  engine_version                  = var.engine_version
  engine_mode                     = "provisioned" # global,multimaster,parallelquery,serverless, default provisioned
  database_name                   = var.database_name
  master_username                 = var.master_username
  master_password                 = random_password.master_password.result
  storage_encrypted               = true # declare KMS key ARN if true, default false
  db_subnet_group_name            = aws_db_subnet_group.main.name
  vpc_security_group_ids          = var.vpc_security_group_ids
  port                            = 3306
  backup_retention_period         = var.backup_retention_period
  copy_tags_to_snapshot           = true # default false
  deletion_protection             = var.deletion_protection
  skip_final_snapshot             = true                    # default false
  final_snapshot_identifier       = "sample-aurora-mysql" # must be provided if skip_final_snapshot is set to false.
  preferred_backup_window         = "02:00-02:30"
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.main.name
  lifecycle {
    ignore_changes = [
      master_password,
    ]
  }
}

resource "aws_rds_cluster_instance" "main" {
  count                        = var.instance_amount
  identifier                   = "aurora-mysql-${var.project}-${var.database_name}-${count.index}"
  cluster_identifier           = aws_rds_cluster.main.cluster_identifier
  instance_class               = var.instance_class
  engine                       = "aurora-mysql"
  engine_version               = var.engine_version
  monitoring_interval          = 60 # 0, 1, 5, 10, 15, 30, 60 (seconds). default 0 (off)
  monitoring_role_arn          = aws_iam_role.main.arn
  preferred_maintenance_window = "Mon:03:00-Mon:04:00"
  db_parameter_group_name      = aws_db_parameter_group.main.name
  auto_minor_version_upgrade   = false
}

resource "aws_secretsmanager_secret" "rds_credentials" {
  name = var.rds_credentials_name
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = <<EOF
{
  "username": "${aws_rds_cluster.main.master_username}",
  "password": "${random_password.master_password.result}",
  "engine": "mysql",
  "host": "${aws_rds_cluster.main.endpoint}",
  "port": ${aws_rds_cluster.main.port},
  "dbClusterIdentifier": "${aws_rds_cluster.main.cluster_identifier}"
}
EOF
}
