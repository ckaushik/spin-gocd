
output "vpc_id" {
  value = "${aws_vpc.vpc_module.id}"
}

output "private_subnet_id" {
  value = "${aws_subnet.private_subnet.id}"
}

output "default_securitygroup_id" {
  value = "${aws_security_group.accessible_from_bastion.id}"
}

output "bastion_host_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}

