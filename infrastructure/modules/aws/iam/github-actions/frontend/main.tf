resource "aws_iam_user" "main" {
  name = var.iam_name
  path = var.iam_path
}

resource "aws_iam_policy" "main" {
  name = "${var.iam_name}-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        "Sid" : "${replace(title(var.iam_name), "-", "")}",
        "Effect" : "Allow",
        "Action" : [
          "s3:*",
          "cloudfront:*",
          "ecr:*",
          "ecs:*",
          "iam:PassRole"
        ],
        "Resource" : ["*"]
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "main" {
  user       = aws_iam_user.main.name
  policy_arn = aws_iam_policy.main.arn
}
