
resource "aws_key_pair" "gocd_keypair" {
  key_name   = "gocd_keypair-${var.environment}"
  public_key = "${file(var.gocd_server_ssh_key_public_file)}"
}

data "template_file" "go_server_provisioning_script" {
  template = "${file("provisioning-scripts/gocd_server.sh")}"

  vars {
    gocd_git_repo_url = "${var.gocd_git_repo_url}"
    gocd_agent_key = "${var.gocd_agent_key}"
  }
}

resource "aws_instance" "go_server" {
  tags {
    Name = "GoCD Server"
    Vpc = "gocd"
    Environment = "${var.environment}"
  }
  instance_type = "t2.micro"
  ami = "${lookup(var.aws_amis, var.aws_region)}"
  vpc_security_group_ids = [
    "${aws_security_group.gocd_server_ruleset.id}"
  ]
  subnet_id = "${var.subnet_id}"
  key_name = "${aws_key_pair.gocd_keypair.id}"
  user_data = "${data.template_file.go_server_provisioning_script.rendered}"
}

resource "aws_security_group" "gocd_server_ruleset" {
  tags {
    Name = "Load Balancer to GoCD Server"
    Vpc = "gocd"
    Environment = "${var.environment}"
  }
  name = "gocd_server_ruleset"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "allow_gocd_ports_into_server" {
  type = "ingress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.gocd_lb_ruleset.id}"
  security_group_id = "${aws_security_group.gocd_server_ruleset.id}"
}

resource "aws_security_group_rule" "allow_gocd_agent_ports_into_server" {
  type = "ingress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.gocd_agent_ruleset.id}"
  security_group_id = "${aws_security_group.gocd_server_ruleset.id}"
}

resource "aws_security_group_rule" "allow_gocd_to_access_internet" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.gocd_server_ruleset.id}"
}

output "goserver_ip" {
  value = "${aws_instance.go_server.private_ip}"
}
