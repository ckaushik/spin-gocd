# 
# Load Balancer for GoCD Server
# 

resource "aws_security_group" "from_external_to_alb" {
  tags {
    Name = "External to Load Balancer"
    Environment = "${var.environment}"
  }
  name = "from_external_to_alb"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "goserver_ports" {
  type = "ingress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  cidr_blocks = ["${var.allowed_ip}/32"]
  security_group_id = "${aws_security_group.from_external_to_alb.id}"
}

resource "aws_alb" "go_server" {
  name = "gocd-server-alb-${var.environment}"
  internal = false
  security_groups = ["${aws_security_group.from_external_to_alb.id}"]
  subnets = ["${module.vpc.public_subnet_ids}"]
  tags {
    Name = "${var.environment} GoCD Server Load Balancer"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "go_server" {
  load_balancer_arn = "${aws_alb.go_server.id}"
  port              = 8153
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.go_server.id}"
    type             = "forward"
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
  health_check {
    path = "/go/home"
    matcher = "200,301,302"
  }
}

resource "aws_alb_target_group_attachment" "go_server" {
  target_group_arn = "${aws_alb_target_group.go_server.arn}"
  target_id = "${aws_instance.go_server.id}"
  port = 8153
}

output "go_server_lb_dns" {
  value = "${aws_alb.go_server.dns_name}"
}
