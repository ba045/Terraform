resource "aws_instance" "ansible" {
    ami = var.ansible.ami
    instance_type = var.ansible.instance_type
    key_name = var.key.name
    vpc_security_group_ids = [aws_security_group.security_ansible.id]
    subnet_id = aws_subnet.ansible_subnet.id
    iam_instance_profile = aws_iam_instance_profile.profile_ansible.name
    user_data = <<EOF
#!/bin/bash
sed -i "s/#Port 22/Port ${var.sg_ansible.from_port}/g" /etc/ssh/sshd_config
systemctl restart sshd
apt install software-properties-common
apt-add-repository ppa:ansible/ansible -y
apt update
apt install ansible -y
apt install python-boto3 -y
cd /home/ubuntu
su ubuntu -c "git clone ${var.ansible.github}"
su ubuntu -c "echo '${var.key.private}' > Ansible/${var.key.name}"
su ubuntu -c "chmod 600 Ansible/${var.key.name}"
EOF

    tags = {
        Name = "ansible"
    }
    root_block_device {
        volume_size = 30
    }
    credit_specification{
        cpu_credits = "unlimited"
    }
}

resource "aws_iam_instance_profile" "profile_ansible" {
  name = "${format("%s-profile-ansible", var.name)}"
  role = aws_iam_role.role_ansible.name
}

resource "aws_iam_role" "role_ansible" {
  name = "${format("%s-role-ansible", var.name)}"
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

resource "aws_iam_role_policy" "policy_ansible" {
  name = "${format("%s-policy-ansible", var.name)}"
  role = aws_iam_role.role_ansible.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}