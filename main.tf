
provider "aws" {
  region = "${var.aws_region}"
  profile = "default"
}

module "vpc" {
  source = "github.com/kief/spin-vpc/modules/vpc"
  service_name = "GoCD"
  environment = "${var.environment}"
  allowed_ip = "${var.allowed_ip}"
  bastion_ssh_key_public_file = "${var.bastion_ssh_key_public_file}"
}

output "bastion_host_ip" {
  value = "${module.vpc.bastion_host_ip}"
}

