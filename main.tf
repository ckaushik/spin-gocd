
provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

module "vpc" {
  source = "github.com/kief/spin-vpc/modules/vpc"
  aws_region = "${var.aws_region}"
  availability_zones = "${var.availability_zones}"
  vpc_name = "gocd"
  aws_amis = "${var.aws_amis}"
  environment = "${var.environment}"
  allowed_ip = "${var.allowed_ip}"
  bastion_ssh_key_public_file = "${var.bastion_ssh_key_public_file}"
}

output "bastion_host_ip" {
  value = "${module.vpc.bastion_host_ip}"
}

