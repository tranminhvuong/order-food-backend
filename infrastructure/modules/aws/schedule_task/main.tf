data "aws_iam_policy_document" "scheduled_task_cw_event_role_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["events.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "scheduled_task_cw_event_role_cloudwatch_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = ["*"]
  }
  statement {
    actions   = ["iam:PassRole"]
    resources = [var.task_definition_exec_role_arn]
  }
}

resource "aws_iam_role" "scheduled_task_cw_event_role" {
  name               = "${var.cluster_name}-${var.task_name}-scheduled-task-cloudwatch-role"
  assume_role_policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_assume_role_policy.json
}

resource "aws_iam_role_policy" "scheduled_task_cw_event_role_cloudwatch_policy" {
  name   = "${var.cluster_name}-${var.task_name}-scheduled-task-cloudwatch-policy"
  role   = aws_iam_role.scheduled_task_cw_event_role.id
  policy = data.aws_iam_policy_document.scheduled_task_cw_event_role_cloudwatch_policy.json
}

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT RULE
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.cluster_name}-${var.task_name}-event-rule"
  schedule_expression = var.schedule_expression
  is_enabled          = true
  tags                = {
    Name = "${var.cluster_name}-${var.task_name}-event-rule"
  }
}

#------------------------------------------------------------------------------
# CLOUDWATCH EVENT TARGET
#------------------------------------------------------------------------------
resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule           = aws_cloudwatch_event_rule.event_rule.name
  event_bus_name = aws_cloudwatch_event_rule.event_rule.event_bus_name
  arn            = var.cluster_arn
  role_arn       = aws_iam_role.scheduled_task_cw_event_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_count          = var.task_count
    task_definition_arn = var.task_definition_arn

    network_configuration {
      subnets         = var.subnet_ids
      security_groups = var.security_groups
    }
  }
}
