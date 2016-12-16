
resource "aws_instance" "bastion_host" {
  tags {
    Name = "SSH Bastion Host"
    Environment = "${var.environment}"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = ["${aws_security_group.bastion_host_access.id}"]
  subnet_id = "${aws_subnet.public_subnet.id}"
  key_name = "${aws_key_pair.bastion_keys.id}"
}

resource "aws_key_pair" "bastion_keys" {
  key_name   = "bastion-${var.environment}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_eip" "bastion_eip" {
  vpc = true
}

resource "aws_eip_association" "bastion_eip" {
  instance_id = "${aws_instance.bastion_host.id}"
  allocation_id = "${aws_eip.bastion_eip.id}"
}

resource "aws_security_group" "bastion_host_access" {
  tags {
    Name = "${var.service_name} Bastion Security Rules"
    Environment = "${var.environment}"
  }
  name = "bastion_security"
  vpc_id = "${aws_vpc.vpc_module.id}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ssh_inbound_to_bastion" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["${var.allowed_ip}/32"]
  security_group_id = "${aws_security_group.bastion_host_access.id}"
}

resource "aws_security_group_rule" "ping_inbound_to_bastion" {
  type = "ingress"
  from_port = 8
  to_port = 0
  protocol = "icmp"
  cidr_blocks = ["${var.allowed_ip}/32"]
  security_group_id = "${aws_security_group.bastion_host_access.id}"
}

resource "aws_security_group_rule" "all_outbound_from_bastion" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.bastion_host_access.id}"
}

