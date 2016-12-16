
resource "aws_vpc" "vpc_module" {
  tags {
    Name = "${var.service_name} VPC"
    Environment = "${var.environment}"
  }
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "vpc_module" {
  tags {
    Name = "${var.service_name} Gateway"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
}

resource "aws_subnet" "public_subnet" {
  tags {
    Name = "${var.service_name} Public Subnet"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_route_table" "public" {
  tags {
    Name = "${var.service_name} Public Route Table"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
}

resource "aws_route" "public_gateway_route" {
  route_table_id = "${aws_route_table.public.id}"
  depends_on = ["aws_route_table.public"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.vpc_module.id}"
}

resource "aws_route_table_association" "route_public_subnet" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public.id}"
}

# resource "aws_eip" "nat_eip" {
#   vpc = true
# }

# resource "aws_nat_gateway" "vpc_module" {
#   subnet_id = "${aws_subnet.public_subnet.id}"
#   allocation_id = "${aws_eip.nat_eip.id}"
#   depends_on = ["aws_internet_gateway.vpc_module"]
# }

# resource "aws_route_table" "private" {
#   vpc_id = "${aws_vpc.vpc_module.id}"
#   tags {
#     Name = "${var.service_name} Private Route Table"
#     Environment = "${var.environment}"
#   }
# }

# resource "aws_route" "private_nat_gateway_route" {
#   route_table_id = "${aws_route_table.private.id}"
#   destination_cidr_block = "0.0.0.0/0"
#   depends_on = ["aws_route_table.private"]
#   nat_gateway_id = "${aws_nat_gateway.vpc_module.id}"
# }

# resource "aws_route_table_association" "route_private_subnet" {
#   subnet_id = "${aws_subnet.private_subnet.id}"
#   route_table_id = "${aws_route_table.private.id}"
# }

# resource "aws_subnet" "private_subnet" {
#   tags {
#     Name = "${var.service_name} Private Subnet"
#     Environment = "${var.environment}"
#   }
#   vpc_id = "${aws_vpc.vpc_module.id}"
#   cidr_block = "10.0.2.0/24"
# }


# resource "aws_route" "outbound_nat" {
#   route_table_id         = "${aws_vpc.vpc_module.main_route_table_id}"
#   destination_cidr_block = "0.0.0.0/0"
#   nat_eip_id         = "${aws_nat_gateway.vpc_module.id}"
# }




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

