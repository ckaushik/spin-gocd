
output "vpc_id" {
  value = "${aws_vpc.vpc_module.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.private_subnet.id}"
}

output "common_private_security_group_id" {
  value = "${aws_security_group.common_access_private_hosts.id}"
}

output "bastion_host_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}

