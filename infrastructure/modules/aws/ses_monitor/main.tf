resource "aws_ses_configuration_set" "configuration_set" {
  name = var.ses_configuration_set_name
}

resource "aws_ses_event_destination" "sns" {
  name                   = var.ses_event_destination_name
  configuration_set_name = aws_ses_configuration_set.configuration_set.name
  enabled                = true
  matching_types         = var.matching_types

  sns_destination {
    topic_arn = aws_sns_topic.topic.arn
  }
}

resource "aws_sns_topic" "topic" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.topic.arn

  policy = data.aws_iam_policy_document.open-email-sns-topic-policy.json
}

data "aws_iam_policy_document" "open-email-sns-topic-policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Publish"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"

      values = [
        var.aws_account_id,
      ]
    }

    condition {
      test     = "StringLike"
      variable = "AWS:SourceArn"

      values = [
        "arn:aws:ses:*",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.topic.arn
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_subscription" "open_email_subscription" {
  topic_arn              = aws_sns_topic.topic.arn
  protocol               = "lambda"
  endpoint               = module.aws_new_lambda.lambda_function_arn
  endpoint_auto_confirms = true
}

module "aws_new_lambda" {
  source = "terraform-aws-modules/lambda/aws"
  function_name = var.lambda_function_name
  description   = var.lambda_function_name
  handler       = var.lambda_handler
  runtime       = var.lambda_runtime
  memory_size = var.lambda_memory_size
  create_package         = false
  local_existing_package = var.lambda_package_zip
  layers                 = var.layers
  vpc_security_group_ids = var.vpc_security_group_ids
  vpc_subnet_ids             = var.vpc_subnet_ids
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.aws_new_lambda.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.topic.arn
}
