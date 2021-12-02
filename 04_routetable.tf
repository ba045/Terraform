resource"aws_route_table" "public_route" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet_gateway.id
    }

    tags = {
        Name = "${format("%s-pubrt", var.name)}"
    }
}

resource"aws_route_table" "web_route" {
    count = "${length(var.cidr.web)}"
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway[(count.index)%2].id}"
    }

    tags = {
        Name = "${format("%s-webrt", var.name)}"
    }
}

resource"aws_route_table" "was_route" {
    count = "${length(var.cidr.was)}"
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway[(count.index)%2].id}"
    }

    tags = {
        Name = "${format("%s-wasrt", var.name)}"
    }
}

resource"aws_route_table" "ansible_route" {
    vpc_id = aws_vpc.vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.nat_gateway[0].id}"
    }

    tags = {
        Name = "${format("%s-ansiblert", var.name)}"
    }
}

resource "aws_route_table_association" "public_ass" {
    count = "${length(var.cidr.pub)}"
    subnet_id = "${aws_subnet.public[count.index].id}"
    route_table_id = "${aws_route_table.public_route.id}"
}

resource "aws_route_table_association" "web_ass" {
    count = "${length(var.cidr.web)}"
    subnet_id = "${aws_subnet.web_subnet[count.index].id}"
    route_table_id = "${aws_route_table.web_route[count.index].id}"
}

resource "aws_route_table_association" "was_ass" {
    count = "${length(var.cidr.was)}"
    subnet_id = "${aws_subnet.was_subnet[count.index].id}"
    route_table_id = "${aws_route_table.was_route[count.index].id}"
}

resource "aws_route_table_association" "ansible_ass" {
    subnet_id = "${aws_subnet.ansible_subnet.id}"
    route_table_id = "${aws_route_table.ansible_route.id}"
}