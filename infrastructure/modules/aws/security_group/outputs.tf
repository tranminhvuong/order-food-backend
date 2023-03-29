output "ids" {
  value = [
    aws_security_group.alb.id,
    aws_security_group.common.id,
  ]
}

output "common_id" {
  value = aws_security_group.common.id
}

output "alb_id" {
  value = aws_security_group.alb.id
}
