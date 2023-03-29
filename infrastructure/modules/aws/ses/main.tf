resource "aws_ses_domain_identity" "ses" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "dkim" {
  domain = var.domain
}

resource "aws_route53_record" "ses_record" {
  zone_id = var.zone_id
  name    = "_amazonses.${var.domain}"
  type    = "TXT"
  ttl     = "600"
  records = ["${aws_ses_domain_identity.ses.verification_token}"]
}

resource "aws_route53_record" "dkim_record" {
  count   = 3
  zone_id = var.zone_id
  name    = "${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}._domainkey.${var.domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(aws_ses_domain_dkim.dkim.dkim_tokens, count.index)}.dkim.amazonses.com"]
}

resource "aws_ses_email_identity" "email_address" {
  email = var.email_address
}
