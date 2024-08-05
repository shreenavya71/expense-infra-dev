# creating the AWS ACM certificate

resource "aws_acm_certificate" "expence" {
    domain_name       = "devopsnavyahome"
    validation_method = "DNS"

    tags = merge(
        var.common_tags,
        {
            "Name" = "${var.project_name}-${var.environment}"
        }
    )
}

# updating the R53 records
resource "aws_route53_record" "backend" {
    for_each = {
    for dvo in aws_acm_certificate.backend.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
        }
    }

    allow_overwrite = true
    name            = each.value.name
    records         = [each.value.record]
    ttl             = 1
    type            = each.value.type
    zone_id         = var.zone_id
}

# automatic validation
resource "aws_acm_certificate_validation" "backend" {
    certificate_arn         = aws_acm_certificate.backend.arn
    validation_record_fqdns = [for record in aws_route53_record.backend : record.fqdn]
}