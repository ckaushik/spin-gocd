# 
# Load Balancer for GoCD Server
# 

resource "aws_security_group" "external_to_goserver_alb" {
  tags {
    Name = "External Access to GoCD Load Balancer"
    Environment = "${var.environment}"
  }
  name = "external_to_goserver_alb"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "goserver_ports_inbound" {
  type = "ingress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  cidr_blocks = ["${var.allowed_ip}/32"]
  security_group_id = "${aws_security_group.external_to_goserver_alb.id}"
}

resource "aws_alb" "go_server" {
  name = "gocd-server-alb-${var.environment}"
  internal = false
  security_groups = ["${aws_security_group.external_to_goserver_alb.id}"]
  subnets = ["${module.vpc.public_subnet_ids}"]
  tags {
    Name = "${var.environment} Load Balancer"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "go_server" {
  name     = "gocd-server-alb-group-${var.environment}"
  port     = 8153
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"
  tags {
    Name = "GoCD Server Load Balancer Group"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.go_server.id}"
  port              = 8153
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.go_server.id}"
    type             = "forward"
  }
}


output "go_server_lb_dns" {
  value = "${aws_alb.go_server.dns_name}"
}
