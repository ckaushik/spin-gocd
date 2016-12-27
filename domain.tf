
data "aws_route53_zone" "parent_domain" {
  name = "${var.parent_domain}."
}

resource "aws_route53_record" "gocd_hostname" {
  zone_id = "${data.aws_route53_zone.parent_domain.zone_id}"
  name = "gocd.${var.environment}.${data.aws_route53_zone.parent_domain.name}"
  type = "A"

  alias {
    name = "${aws_alb.gocd_lb.dns_name}"
    zone_id = "${aws_alb.gocd_lb.zone_id}"
    evaluate_target_health = false
  }
}

