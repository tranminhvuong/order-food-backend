output "certificate_pem" {
  value     = aws_iot_certificate.cert.certificate_pem
  sensitive = true
}

output "private_key" {
  value     = aws_iot_certificate.cert.private_key
  sensitive = true
}

output "public_key" {
  value     = aws_iot_certificate.cert.public_key
  sensitive = true
}

output "arn" {
  value = aws_iot_thing.order_food_thing.arn
}
