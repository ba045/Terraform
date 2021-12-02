resource "aws_lb" "nlb" {
    name = "${format("%s-nlb", var.name)}"
    internal = true
    load_balancer_type = "network"
    subnets = "${aws_subnet.web_subnet.*.id}"
    access_logs {
        bucket = aws_s3_bucket.log_bucket.bucket
        enabled = true
    }
    enable_deletion_protection = false
}

resource "aws_lb_target_group" "nlb_target" {
    name = "${format("%s-nlb-tg", var.name)}"
    port = var.nlb.port
    protocol = var.nlb.protocol
    target_type = "instance"
    vpc_id = aws_vpc.vpc.id
}

resource "aws_lb_listener" "nlb_front" {
    load_balancer_arn = aws_lb.nlb.arn
    port = var.nlb.port
    protocol = var.nlb.protocol

    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.nlb_target.arn
    }
}

resource "aws_lb_target_group_attachment" "nlb_target_ass" {
    count = var.was.count
    target_group_arn = aws_lb_target_group.nlb_target.arn
    target_id = aws_instance.was[count.index].id
    port = var.nlb.port
}