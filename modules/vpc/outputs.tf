
output "vpc_id" {
  value = "${aws_vpc.vpc_module.id}"
}

output "main_subnet_id" {
  value = "${aws_subnet.main_subnet.id}"
}

output "ssh_securitygroup_id" {
  value = "${aws_security_group.limited_ssh_access.id}"
}
