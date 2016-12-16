
resource "aws_vpc" "vpc_module" {
  tags {
    Name = "${var.service_name} VPC"
    Environment = "${var.environment}"
  }
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_security_group" "default_security" {
  tags {
    Name = "${var.service_name} Inbound SSH"
    Environment = "${var.environment}"
  }
  name = "inbound_ssh"
  vpc_id = "${aws_vpc.vpc_module.id}"
}

resource "aws_security_group_rule" "limited_ssh_inbound" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${var.allowed_ip}/32"]
  security_group_id = "${aws_security_group.default_security.id}"
}

resource "aws_security_group_rule" "everything_out" {
  type = "egress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.default_security.id}"
}

