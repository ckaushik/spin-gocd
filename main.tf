provider "aws" {
  region = "${var.aws_region}"
  profile = "default"
}

module "vpc" {
  source = "modules/vpc"
  service_name = "GoCD"
  environment = "${var.environment}"
  allowed_ip = "${var.allowed_ip}"
}

resource "aws_key_pair" "auth" {
  key_name   = "gocd-${var.environment}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "gocd" {
  tags {
    Name = "GoCD Server"
    Environment = "${var.environment}"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = ["${module.vpc.ssh_securitygroup_id}"]
  subnet_id = "${module.vpc.main_subnet_id}"
  key_name = "${aws_key_pair.auth.id}"
  associate_public_ip_address = true
}

output "gocd_server_ip" {
  value = "${aws_instance.gocd.public_ip}"
}
