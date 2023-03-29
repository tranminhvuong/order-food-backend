output "ecs_task_exec_role" {
  value = aws_iam_role.ecs_task_exec_role.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.main.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.main.arn
}

output "ecs_task_exec_role_arn" {
  value = aws_iam_role.ecs_task_exec_role.arn
}
