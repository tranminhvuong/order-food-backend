resource "aws_ssm_parameter" "main" {
  for_each = toset(var.parameters)
  name     = each.key
  type     = "SecureString"
  value    = "xxxxxxxxxx"
  lifecycle {
    ignore_changes = [
      value,
    ]
  }
}
