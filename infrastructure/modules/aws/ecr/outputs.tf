output "repository_url" {
  value = aws_ecr_repository.main.repository_url
}

output "ecr_repo" {
  value = aws_ecr_repository.main.name
}

output "repository_arn" {
  value = aws_ecr_repository.main.arn
}
