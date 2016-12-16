
variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-ac772edf"
  }
}

variable "service_name" {
  default = "not_set"
}

variable "environment" {
  default = "not_set"
}

variable "allowed_ip" {}

variable "public_key_path" {
  default = "/home/vagrant/.ssh/spin-gocd-key.pub"
}

variable "private_key_path" {
  default = "/home/vagrant/.ssh/spin-gocd-key"
}

variable "key_name" {
  default = "bastion_key"
}

