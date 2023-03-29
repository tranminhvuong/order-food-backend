output "aws_cognito_user_pool" {
  value = aws_cognito_user_pool.user_pool.id
}
output "client_id" {
  value = aws_cognito_user_pool_client.client.id
}

output "app_client_name" {
  value = aws_cognito_user_pool_client.client.name
}
