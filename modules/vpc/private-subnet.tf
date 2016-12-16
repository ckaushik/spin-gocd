
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



