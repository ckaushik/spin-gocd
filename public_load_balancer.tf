# 
# Load Balancer for GoCD Server
# 

resource "aws_security_group" "gocd_lb_ruleset" {
  tags {
    Name = "GoCD Load Balancer Rules"
    Service = "gocd"
    Environment = "${var.environment}"
  }
  name = "gocd_lb_ruleset"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "lb_allow_gocd_ports_in" {
  type = "ingress"
  from_port = "${var.http_port}"
  to_port = "${var.https_port}"
  protocol = "tcp"
  cidr_blocks = ["${var.allowed_ip}/32"]
  security_group_id = "${aws_security_group.gocd_lb_ruleset.id}"
}

resource "aws_security_group_rule" "lb_allow_gocd_ports_out" {
  type = "egress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  # source_security_group_id = "${aws_security_group.gocd_server_ruleset.id}"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = "${aws_security_group.gocd_lb_ruleset.id}"
}

resource "aws_alb" "gocd_lb" {
  name = "gocd-server-alb-${var.environment}"
  internal = false
  security_groups = ["${aws_security_group.gocd_lb_ruleset.id}"]
  subnets = ["${module.vpc.public_subnet_ids}"]
  tags {
    Name = "GoCD LB for ${var.environment} "
    Service = "gocd"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "gocd_listener_http" {
  load_balancer_arn = "${aws_alb.gocd_lb.id}"
  port              = "${var.http_port}"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.gocd_group_http.id}"
    type             = "forward"
  }
}

resource "aws_alb_listener" "gocd_listener_https" {
  load_balancer_arn = "${aws_alb.gocd_lb.id}"
  port              = "${var.https_port}"
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2015-05"
  certificate_arn = "${var.gocd_ssl_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.gocd_group_https.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "gocd_group_http" {
  name     = "gocd-lb-group-http-${var.environment}"
  port     = 8153
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
  tags {
    Name = "GoCD LB Group"
    Service = "gocd"
    Environment = "${var.environment}"
  }
  health_check {
    path = "/go/home"
    matcher = "200,301,302"
  }
}

resource "aws_alb_target_group" "gocd_group_https" {
  name     = "gocd-lb-group-https-${var.environment}"
  port     = 8154
  protocol = "HTTPS"
  vpc_id   = "${module.vpc.vpc_id}"
  tags {
    Name = "GoCD LB Group SSL"
    Service = "gocd"
    Environment = "${var.environment}"
  }
  health_check {
    path = "/go/home"
    protocol = "HTTPS"
    matcher = "200,301,302"
  }
}

resource "aws_alb_target_group_attachment" "gocd_group_to_instance_http" {
  target_group_arn = "${aws_alb_target_group.gocd_group_http.arn}"
  target_id = "${aws_instance.go_server.id}"
  port = 8153
}

resource "aws_alb_target_group_attachment" "gocd_group_to_instance_https" {
  target_group_arn = "${aws_alb_target_group.gocd_group_https.arn}"
  target_id = "${aws_instance.go_server.id}"
  port = 8154
}

output "gocd_lb_dns" {
  value = "${aws_alb.gocd_lb.dns_name}"
}
