
resource "aws_key_pair" "gokeys" {
  key_name   = "gocd-${var.environment}"
  public_key = "${file(var.public_key_path)}"
}

# resource "aws_eip" "gocd_eip" {
#   vpc = true
# }

# resource "aws_eip_association" "gocd_eip" {
#   instance_id = "${aws_instance.gocd.id}"
#   allocation_id = "${aws_eip.gocd_eip.id}"
# }

resource "aws_instance" "go_server" {
  tags {
    Name = "GoCD Server"
    Environment = "${var.environment}"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = ["${module.vpc.common_private_security_group_id}"]
  subnet_id = "${module.vpc.private_subnet_id}"
  key_name = "${aws_key_pair.gokeys.id}"
  # associate_public_ip_address = true
}

# echo "deb https://download.go.cd /" | sudo tee /etc/apt/sources.list.d/gocd.list
# curl https://download.go.cd/GOCD-GPG-KEY.asc | sudo apt-key add -
# sudo apt-get update
# sudo apt-get install go-server
# sudo /etc/init.d/go-server [start|stop|status|restart]


output "goserver_ip" {
  value = "${aws_instance.go_server.private_ip}"
}
