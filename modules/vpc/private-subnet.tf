
resource "aws_subnet" "private_subnet" {
  tags {
    Name = "${var.service_name} Private Subnet"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
  cidr_block = "10.0.2.0/24"
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "vpc_module" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  allocation_id = "${aws_eip.nat_eip.id}"
  depends_on = ["aws_internet_gateway.vpc_module"]
}

resource "aws_route_table" "private_routes" {
  vpc_id = "${aws_vpc.vpc_module.id}"
  tags {
    Name = "${var.service_name} Private Route Table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id = "${aws_route_table.private_routes.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.private_routes"]
  nat_gateway_id = "${aws_nat_gateway.vpc_module.id}"
}

resource "aws_route_table_association" "routes_for_private_subnet" {
  subnet_id = "${aws_subnet.private_subnet.id}"
  route_table_id = "${aws_route_table.private_routes.id}"
}

resource "aws_security_group" "common_access_private_hosts" {
  tags {
    Name = "${var.service_name} Common Rules for Private Subnet"
    Environment = "${var.environment}"
  }
  name = "common_access_private_hosts"
  vpc_id = "${aws_vpc.vpc_module.id}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_inbound_from_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.bastion_host_access.id}"
  security_group_id = "${aws_security_group.common_access_private_hosts.id}"
}

resource "aws_security_group_rule" "all_outbound_from_private" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.common_access_private_hosts.id}"
}
