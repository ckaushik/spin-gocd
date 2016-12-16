
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

resource "aws_route_table" "public_routes" {
  tags {
    Name = "${var.service_name} Public Route Table"
    Environment = "${var.environment}"
  }
  vpc_id = "${aws_vpc.vpc_module.id}"
}

resource "aws_route" "public_gateway_route" {
  route_table_id = "${aws_route_table.public_routes.id}"
  depends_on = ["aws_route_table.public_routes"]
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.vpc_module.id}"
}

resource "aws_route_table_association" "route_public_subnet" {
  subnet_id = "${aws_subnet.public_subnet.id}"
  route_table_id = "${aws_route_table.public_routes.id}"
}
