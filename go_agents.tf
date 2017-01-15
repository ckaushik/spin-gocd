
resource "aws_autoscaling_group" "go_agent_pool" {
  name = "agents-${var.environment}"
  # name = "${aws_launch_configuration.launch_a_go_agent.name}-pool"
  max_size = 2
  min_size = 1
  desired_capacity = 1
  vpc_zone_identifier = ["${module.vpc.private_subnet_id}"]
  launch_configuration = "${aws_launch_configuration.launch_a_go_agent.name}"
  lifecycle { create_before_destroy = true }
  tag {
    key = "Name"
    value = "GoCD Agent"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Service"
    value = "gocd"
    propagate_at_launch = true
  }
}

resource "aws_launch_configuration" "launch_a_go_agent" {
  name_prefix = "go-agent-"
  image_id = "${lookup(var.aws_amis, var.aws_region)}"
  instance_type = "t2.micro"
  security_groups = [
    "${module.vpc.common_private_security_group_id}",
    "${aws_security_group.gocd_agent_ruleset.id}"
  ]
  iam_instance_profile = "${var.iam_instance_profile_for_builder}"
  key_name = "${aws_key_pair.gocd_keypair.id}"
  user_data = "${data.template_file.go_agent_provisioning_script.rendered}"
  depends_on = ["aws_instance.go_server"]
  lifecycle { create_before_destroy = true }
}

data "template_file" "go_agent_provisioning_script" {
  template = "${file("provisioning-scripts/gocd_agent.sh")}"
  depends_on = ["aws_instance.go_server"]

  vars {
    go_server_url = "${aws_instance.go_server.private_ip}"
    go_server_actual_https_port = "8154"
    gocd_agent_key = "${var.gocd_agent_key}"
    environment = "${var.environment}"
  }
}

resource "aws_security_group" "gocd_agent_ruleset" {
  tags {
    Name = "GoCD Agent Rules"
    Service = "gocd"
    Environment = "${var.environment}"
  }
  name = "gocd_agent_ruleset"
  vpc_id = "${module.vpc.vpc_id}"
}

resource "aws_security_group_rule" "allow_gocd_ports_out_from_agents" {
  type = "egress"
  from_port = 8153
  to_port = 8154
  protocol = "tcp"
  cidr_blocks = ["10.0.0.0/16"]
  security_group_id = "${aws_security_group.gocd_agent_ruleset.id}"
}


