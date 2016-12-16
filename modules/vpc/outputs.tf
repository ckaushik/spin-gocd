
output "vpc_id" {
  value = "${aws_vpc.vpc_module.id}"
}

output "main_subnet_id" {
  value = "${aws_subnet.public_subnet.id}"
}

output "default_securitygroup_id" {
  value = "${aws_security_group.default_security.id}"
}

output "bastion_host_ip" {
  value = "${aws_eip.bastion_eip.public_ip}"
}

