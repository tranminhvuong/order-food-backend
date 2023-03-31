locals {
  project            = var.project
  environment        = var.environment
  cloudfront_api_url = var.cloudfront_api_url
}


resource "aws_iot_policy" "iot_pubsub" {
  name = "${local.project}-${local.environment}-PubSubToAnyTopic"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iot_certificate" "cert" {
  active = true
}

resource "aws_iot_policy_attachment" "att" {
  policy = aws_iot_policy.iot_pubsub.name
  target = aws_iot_certificate.cert.arn
}

resource "aws_iot_thing" "order_food_thing" {
  name = "${local.project}-${local.environment}-thing"
}

resource "aws_iot_thing_principal_attachment" "att" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.order_food_thing.name
}

# Message toppic rule
resource "aws_iot_topic_rule" "rule_partert1" {
  name        = "gps_${local.environment}_message_rule_partern1"
  enabled     = true
  sql         = "SELECT * FROM 'vehicle-status-pattern-1'"
  sql_version = "2016-03-23"
  http {
    url              = "https://${local.cloudfront_api_url}/api/iot/vehicle-data/string-only"
    confirmation_url = "https://${local.cloudfront_api_url}/api/iot/"
    http_header {
      key   = "x-aws-iot-core"
      value = "2392k1j29f2912321o9f012"
    }
  }
}

resource "aws_iot_topic_rule" "rule_partert2" {
  name        = "gps_${local.environment}_message_rule_partern2"
  enabled     = true
  sql         = "SELECT * FROM 'vehicle-status-pattern-2'"
  sql_version = "2016-03-23"
  http {
    url              = "https://${local.cloudfront_api_url}/api/iot/vehicle-data/key-value-string"
    confirmation_url = "https://${local.cloudfront_api_url}/api/iot/"
    http_header {
      key   = "x-aws-iot-core"
      value = "2392k1j29f2912321o9f012"
    }
  }
}

resource "aws_iot_topic_rule" "rule_partert3" {
  name        = "gps_${local.environment}_message_rule_partern3"
  enabled     = true
  sql         = "SELECT * FROM 'vehicle-status-pattern-3'"
  sql_version = "2016-03-23"
  http {
    url              = "https://${local.cloudfront_api_url}/api/iot/vehicle-data"
    confirmation_url = "https://${local.cloudfront_api_url}/api/iot/"
    http_header {
      key   = "x-aws-iot-core"
      value = "2392k1j29f2912321o9f012"
    }
  }
}

resource "aws_iot_topic_rule" "rule_partert4" {
  name        = "gps_${local.environment}_vehicle_status_rule"
  enabled     = true
  sql         = "SELECT * FROM 'gps_vehicle_status_rule'"
  sql_version = "2016-03-23"
  http {
    url              = "https://${local.cloudfront_api_url}/api/iot/vehicle-data/gps-vehicle-status"
    confirmation_url = "https://${local.cloudfront_api_url}/api/iot/"
    http_header {
      key   = "x-aws-iot-core"
      value = "2392k1j29f2912321o9f012"
    }
  }
}
