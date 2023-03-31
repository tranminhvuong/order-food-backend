locals {
  project     = var.project
  environment = var.environment
  iot_arn     = var.iot_arn
}

resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "identity pool"
  allow_unauthenticated_identities = true
}


data "aws_iam_policy_document" "unauthenticated" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.main.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["unauthenticated"]
    }
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "authenticated" {
  statement {
    effect = "Allow"

    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "cognito-identity.amazonaws.com:aud"
      values   = [aws_cognito_identity_pool.main.id]
    }

    condition {
      test     = "ForAnyValue:StringLike"
      variable = "cognito-identity.amazonaws.com:amr"
      values   = ["authenticated"]
    }
    principals {
      type        = "Federated"
      identifiers = ["cognito-identity.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "authenticated_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "unauthenticated_role_policy" {
  statement {
    effect = "Allow"

    actions = [
      "mobileanalytics:PutEvents",
      "cognito-sync:*",
      "cognito-identity:*",
    ]

    resources = [local.iot_arn]

  }
}


resource "aws_iam_role" "authenticated" {
  name               = "${local.project}_${local.environment}_cognito_authenticated"
  assume_role_policy = data.aws_iam_policy_document.authenticated.json
}

resource "aws_iam_role" "unauthenticated" {
  name               = "${local.project}_${local.environment}_cognito_unauthenticated"
  assume_role_policy = data.aws_iam_policy_document.unauthenticated.json
}

resource "aws_iam_role_policy" "authenticated" {
  name   = "${local.project}_${local.environment}_authenticated_policy"
  role   = aws_iam_role.authenticated.id
  policy = data.aws_iam_policy_document.authenticated_role_policy.json
}

resource "aws_iam_role_policy" "unauthenticated" {
  name   = "${local.project}_${local.environment}_unauthenticated_policy"
  role   = aws_iam_role.unauthenticated.id
  policy = data.aws_iam_policy_document.unauthenticated_role_policy.json
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.main.id

  roles = {
    "authenticated"   = aws_iam_role.authenticated.arn
    "unauthenticated" = aws_iam_role.unauthenticated.arn
  }
}
