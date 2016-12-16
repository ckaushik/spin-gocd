
resource "aws_vpc" "vpc_module" {
  tags {
    Name = "${var.service_name} VPC"
    Environment = "${var.environment}"
  }
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "vpc_module" {
  tags {
    Name = "${var.service_name} Gateway"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.vpc_module.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vpc_module.id}"
}

resource "aws_subnet" "main_subnet" {
  tags {
    Name = "${var.service_name} Main Subnet"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "limited_ssh_access" {
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
  security_group_id = "${aws_security_group.limited_ssh_access.id}"
}

