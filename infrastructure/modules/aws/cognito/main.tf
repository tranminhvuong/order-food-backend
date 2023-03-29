// Resources
resource "aws_cognito_user_pool" "user_pool" {
  name = "pinfall-${var.environment}-user-pool"

  username_attributes = ["email", "phone_number"]
  password_policy {
    minimum_length = 8
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }
}

resource "aws_cognito_user_pool_client" "client" {
  name = "pinfall${var.environment}"

  user_pool_id                  = aws_cognito_user_pool.user_pool.id
  generate_secret               = false
  refresh_token_validity        = 90
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = "pinfall-${var.environment}"
  user_pool_id = aws_cognito_user_pool.user_pool.id
}
