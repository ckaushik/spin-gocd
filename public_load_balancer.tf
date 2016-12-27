# 
# Load Balancer for GoCD Server
# 

resource "aws_security_group" "gocd_lb_ruleset" {
  tags {
    Name = "GoCD Load Balancer Rules"
    Environment = "${var.environment}"
  }
  name = "gocd_lb_ruleset"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "lb_allow_gocd_ports_in" {
  type = "ingress"
  from_port = 8153
  to_port = 8154
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
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "gocd_listener" {
  load_balancer_arn = "${aws_alb.gocd_lb.id}"
  port              = 8153
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.gocd_group.id}"
    type             = "forward"
  }
}

resource "aws_alb_target_group" "gocd_group" {
  name     = "gocd-lb-group-${var.environment}"
  port     = 8153
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
  tags {
    Name = "GoCD LB Group"
    Environment = "${var.environment}"
  }
  health_check {
    path = "/go/home"
    matcher = "200,301,302"
  }
}

resource "aws_alb_target_group_attachment" "gocd_group_to_instance" {
  target_group_arn = "${aws_alb_target_group.gocd_group.arn}"
  target_id = "${aws_instance.go_server.id}"
  port = 8153
}

output "gocd_lb_dns" {
  value = "${aws_alb.gocd_lb.dns_name}"
}
