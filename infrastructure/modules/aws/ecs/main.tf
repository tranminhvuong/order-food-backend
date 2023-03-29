resource "aws_iam_role" "ecs_task_exec_role" {
  name               = "${var.cluster_name}-${var.task_name}-task-execution"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_exec_role_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_exec_role_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "task_exec" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_policy" "ssm" {
  name = "${var.cluster_name}-${var.task_name}--task-execution-ssm-policy"
  policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Effect" = "Allow"
        "Action" = [
          "ssm:Get*",
        ]
        "Resource" = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ecs_task_exec_role.name
  policy_arn = aws_iam_policy.ssm.arn
}

resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.project}/${var.environment}/${var.task_name}"
  retention_in_days = var.retention_in_days
}

resource "aws_ecs_task_definition" "main" {
  family                   = format("%s-%s-%s-%s", var.cluster_name, var.task_name, "service", "task")
  execution_role_arn       = aws_iam_role.ecs_task_exec_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = <<EOF
  [
    {
      "name": "${var.cluster_name}-${var.task_name}-service-app",
      "image": "${var.repository_name}${var.image_tag}",
      "cpu": ${var.fargate_cpu},
      "memory": ${var.fargate_memory},
      "networkMode": "awsvpc",
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
            "awslogs-group": "/ecs/${var.project}/${var.environment}/${var.task_name}",
            "awslogs-region": "${var.aws_region}",
            "awslogs-stream-prefix": "ecs"
          }
      },
      "secrets": ${jsonencode(var.app_environments_vars)},
      "environment": ${jsonencode(var.app_environments_vars_normal)},
      "portMappings": %{if var.schedule_task == 1}[]%{else}[
        {
          "containerPort": ${var.port},
          "hostPort": ${var.port}
        }
      ]%{endif}
    }
  ]
  EOF
}

locals {
  ecs_depends_on = var.schedule_task == 1 ? [aws_iam_role_policy_attachment.task_exec.policy_arn] : [
    aws_iam_role_policy_attachment.task_exec.policy_arn, var.http_tcp_listener_arn
  ]
}

resource "aws_ecs_service" "main" {
  name            = "${var.cluster_name}-${var.task_name}-service"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  dynamic "load_balancer" {
    for_each = var.schedule_task == 1 ? [] : [1]
    content {
      target_group_arn = var.target_group_arn
      container_name   = "${var.cluster_name}-${var.task_name}-service-app"
      container_port   = var.port
    }
  }

  depends_on = [local.ecs_depends_on]
}
