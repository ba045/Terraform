resource "aws_instance" "bastion" {
    ami = var.bastion.ami
    instance_type = var.bastion.instance_type
    key_name = var.key.name
    vpc_security_group_ids = [aws_security_group.security_bastion.id]
    subnet_id = aws_subnet.public.0.id
    iam_instance_profile = aws_iam_instance_profile.profile_bastion.name
    user_data = <<EOF
#!/bin/bash
sed -i "s/#Port 22/Port ${var.sg_bastion.from_port}/g" /etc/ssh/sshd_config
systemctl restart sshd
su ubuntu -c "echo '${var.key.private}' > /home/ubuntu/${var.key.name}"
su ubuntu -c "chmod 600 /home/ubuntu/${var.key.name}"
EOF

    tags = {
        Name = "bastion"
    }
    root_block_device {
        volume_size = 30
    }
    credit_specification{
        cpu_credits = "unlimited"
    }
}
 resource "aws_eip" "eip_bastion" {
    vpc = true

    instance = aws_instance.bastion.id
    depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_iam_instance_profile" "profile_bastion" {
  name = "${format("%s-profile-bastion", var.name)}"
  role = aws_iam_role.role_bastion.name
}

resource "aws_iam_role" "role_bastion" {
  name = "${format("%s-role-bastion", var.name)}"
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_role_policy" "policy_bastion" {
  name = "${format("%s-policy-bastion", var.name)}"
  role = aws_iam_role.role_bastion.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AttachVolume",
                "ec2:DetachVolume"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:instance/*"
            ]
        }
    ]
}
EOF
}