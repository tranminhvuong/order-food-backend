output "cloudfront_url" {
  value = aws_cloudfront_distribution.alb_distribution.domain_name
}
