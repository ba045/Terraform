resource "aws_vpc" "vpc" {
    cidr_block       = var.cidr.vpc
    instance_tenancy = "default"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags = {
        Name = "${format("%s-vpc", var.name)}"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.vpc.id
    count = "${length(var.cidr.pub)}"
    cidr_block = "${var.cidr.pub[count.index]}"
    availability_zone = "${var.region.region}${var.region.az[count.index]}"

    tags = {
        Name = "${format("pub-%s", var.region.az[count.index])}" 
    }
}

resource "aws_subnet" "web_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = "${length(var.cidr.web)}"
    cidr_block = "${var.cidr.web[count.index]}"
    availability_zone = "${var.region.region}${var.region.az[count.index]}"

    tags = {
        Name = "${format("web-%s", var.region.az[count.index])}" 
    }
}

resource "aws_subnet" "was_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = "${length(var.cidr.was)}"
    cidr_block = "${var.cidr.was[count.index]}"
    availability_zone = "${var.region.region}${var.region.az[count.index]}"

    tags = {
        Name = "${format("was-%s", var.region.az[count.index])}" 
    }
}

resource "aws_subnet" "db_subnet" {
    vpc_id = aws_vpc.vpc.id
    count = "${length(var.cidr.db)}"
    cidr_block = "${var.cidr.db[count.index]}"
    availability_zone = "${var.region.region}${var.region.az[count.index]}"

    tags = {
        Name = "${format("db-%s", var.region.az[count.index])}" 
    }
}

resource "aws_db_subnet_group" "db_subnet_group" {
    name = "${format("%s-db-sg", var.name)}"
    subnet_ids = "${aws_subnet.db_subnet.*.id}"

    tags = {
        name = "${format("%s-db-sg", var.name)}"
    }
}

resource "aws_subnet" "ansible_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.cidr.ansible
    availability_zone = "${var.region.region}${var.region.az[0]}"

    tags = {
        Name = "ansible" 
    }
}