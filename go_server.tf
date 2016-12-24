
resource "aws_key_pair" "gocd_keypair" {
  key_name   = "gocd_keypair-${var.environment}"
  public_key = "${file(var.gocd_server_ssh_key_public_file)}"
}

resource "aws_instance" "go_server" {
  tags {
    Name = "GoCD Server"
    Environment = "${var.environment}"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = [
    "${module.vpc.common_private_security_group_id}",
    "${aws_security_group.alb_to_goserver.id}"
  ]
  subnet_id = "${module.vpc.private_subnet_id}"
  key_name = "${aws_key_pair.gocd_keypair.id}"
  user_data = "${file("provisioning-scripts/gocd_server.sh")}"
}

resource "aws_security_group" "alb_to_goserver" {
  tags {
    Name = "ALB Connectivity to GoCD Server"
    Environment = "${var.environment}"
  }
  name = "alb_to_goserver"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "limited_gocd_inbound" {
  type = "ingress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.external_to_goserver_alb.id}"
  security_group_id = "${aws_security_group.alb_to_goserver.id}"
}

output "goserver_ip" {
  value = "${aws_instance.go_server.private_ip}"
}
