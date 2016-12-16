
provider "aws" {
  region = "${var.aws_region}"
  profile = "default"
}

module "vpc" {
  source = "modules/vpc"
  service_name = "GoCD"
  environment = "${var.environment}"
  allowed_ip = "${var.allowed_ip}"
  # aws_region = "${aws_region}"
  # aws_amis = "${aws_amis}"
  # public_key_path = "${public_key_path}"
}

resource "aws_key_pair" "auth" {
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

# resource "aws_instance" "gocd" {
#   tags {
#     Name = "GoCD Server"
#     Environment = "${var.environment}"
#   }
#   instance_type = "t2.micro"
#   ami = "${lookup(var.aws_amis, var.aws_region)}"
#   vpc_security_group_ids = ["${module.vpc.default_securitygroup_id}"]
#   subnet_id = "${module.vpc.main_subnet_id}"
#   key_name = "${aws_key_pair.auth.id}"
#   # associate_public_ip_address = true
# }

# echo "deb https://download.go.cd /" | sudo tee /etc/apt/sources.list.d/gocd.list
# curl https://download.go.cd/GOCD-GPG-KEY.asc | sudo apt-key add -
# sudo apt-get update
# sudo apt-get install go-server
# sudo /etc/init.d/go-server [start|stop|status|restart]


output "bastion_host_ip" {
  value = "${module.vpc.bastion_host_ip}"
}
