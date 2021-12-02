resource "aws_route53_zone" "route53_zone" {
  name       = var.domain
}

resource "aws_route53_record" "route53_record" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name    = "${format("%s.%s", var.name, var.domain)}"
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.alb.dns_name}"
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain
  subject_alternative_names = ["*.${var.domain}"]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route53_record_cert" {
  zone_id = aws_route53_zone.route53_zone.zone_id
  name                   = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
  type                   = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
  records                = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
  ttl                    = 60
}

resource "aws_acm_certificate_validation" "cert_valid" {
  certificate_arn         = aws_acm_certificate.cert.arn
}
