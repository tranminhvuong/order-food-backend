output "s3_build_bucket" {
  value = aws_s3_bucket.codebuild_cache.id
}

output "s3_build_bucket_arn" {
  value = aws_s3_bucket.codebuild_cache.arn
}
