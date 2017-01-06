
variable "environment" {
  default = "sandbox"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
  default = "default"
}

variable "aws_amis" {
  default = {
    eu-west-1 = "ami-ac772edf"
  }
}

variable "gocd_server_ssh_key_public_file" {
  default = "/home/vagrant/.ssh/spin-gocd-key.pub"
}

variable "bastion_ssh_key_public_file" {
  default = "/home/vagrant/.ssh/spin-bastion-key.pub"
}

variable "http_port" {
  default = "80"
}

variable "https_port" {
  default = "443"
}

variable "vpc_git_repo_url" {
  default = "https://github.com/kief/spin-vpc.git"
}

variable "allowed_ip" {}
variable "gocd_ssl_certificate_arn" {}
variable "gocd_dns_name" {}
variable "parent_domain" {}
variable "gocd_agent_key" {}
variable "iam_instance_profile_for_builder" {}
