
variable "environment" {
  default = "sandbox"
}

variable "public_key_path" {
  default = "/home/vagrant/.ssh/spin-gocd-key.pub"
}

variable "private_key_path" {
  default = "/home/vagrant/.ssh/spin-gocd-key"
}

variable "key_name" {
  default = "infraworkbox"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-ac772edf"
  }
}

variable "allowed_ip" {}
