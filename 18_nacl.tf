/* resource "aws_network_acl" "public_acl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = aws_subnet.public.*.id

  ingress = [
    {
      protocol   = "tcp"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      ipv6_cidr_block = ""
      from_port  = 80
      to_port    = 80
      icmp_code  = 0
      icmp_type  = 0
    },
    {
      protocol   = "tcp"
      rule_no    = 101
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      ipv6_cidr_block = ""
      from_port  = 443
      to_port    = 443
      icmp_code  = 0
      icmp_type  = 0
    },
    {
      protocol   = "tcp"
      rule_no    = 102
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      ipv6_cidr_block = ""
      from_port  = var.sg_bastion.from_port
      to_port    = var.sg_bastion.to_port
      icmp_code  = 0
      icmp_type  = 0
    }
  ]

  egress {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = "0"
      to_port    = "0"
  }

  tags = {
    Name = "${format("%s-public-acl", var.name)}"
  }
}

resource "aws_network_acl" "private_acl" {
  vpc_id = aws_vpc.vpc.id
  subnet_ids = concat(aws_subnet.web_subnet.*.id, aws_subnet.was_subnet.*.id, aws_subnet.db_subnet.*.id, aws_subnet.ansible_subnet.*.id)
  
  ingress = [
    {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      ipv6_cidr_block = ""
      from_port  = "0"
      to_port    = "0"
      icmp_code  = 0
      icmp_type  = 0
    }
  ]

  egress {
      protocol   = "-1"
      rule_no    = 100
      action     = "allow"
      cidr_block = "0.0.0.0/0"
      from_port  = "0"
      to_port    = "0"
  }

  tags = {
    Name = "${format("%s-private-acl", var.name)}"
  }
} */