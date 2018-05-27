provider "aws" {
  region = "${var.aws_region}"
  profile = "${var.aws_profile}"
}

terraform {
  backend "s3" {
    bucket               = "terraform-hotstar-state"
    region               = "ap-south-1"
    key                  = "gocd"
    workspace_key_prefix = "terraform-states"
  }
}
