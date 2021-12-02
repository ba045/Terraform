/*
resource "aws_launch_configuration" "launch_conf" {
  name = "${format("%s-web-conf", var.name)}"
  image_id      = aws_ami_from_instance.web_ami.id
  instance_type = var.web.instance_type
  iam_instance_profile = "admin_role"
  security_groups = [aws_security_group.security_web.id]
  key_name = var.web.key_name
  # user_data = file("./install.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "autoscaling" {
  name = "${format("%s-ag", var.name)}"
  max_size                  = var.autoscaling.max_size
  min_size                  = var.autoscaling.min_size
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = var.autoscaling.desired_capacity
  force_delete              = true
  #placement_group           = aws_placement_group.fox_pg.id
  launch_configuration      = aws_launch_configuration.launch_conf.name
  vpc_zone_identifier       = "${aws_subnet.public.*.id}"
}

resource "aws_autoscaling_attachment" "asg_attachment_bar" {
  autoscaling_group_name = aws_autoscaling_group.autoscaling.id
  alb_target_group_arn   = aws_lb_target_group.alb_target.arn
}
*/