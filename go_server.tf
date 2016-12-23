
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
  vpc_security_group_ids = ["${module.vpc.common_private_security_group_id}"]
  subnet_id = "${module.vpc.private_subnet_id}"
  key_name = "${aws_key_pair.gocd_keypair.id}"
  user_data = "${file("provisioning-scripts/gocd_server.sh")}"
}

output "goserver_ip" {
  value = "${aws_instance.go_server.private_ip}"
}
