resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}


resource "aws_route_table" "publicRt" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "public-route-table"
    }
}

resource "aws_route" "private" {
    route_table_id = aws_route_table.privateRT.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
}

resource "aws_route_table" "privateRT" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "privateRT"
    }
}

resource "aws_route_table_association" "private1" {
    subnet_id = aws_subnet.private-sub1.id
    route_table_id = aws_route_table.privateRT.id
}

resource "aws_route_table_association" "private2" {
    subnet_id = aws_subnet.private-sub2.id
    route_table_id = aws_route_table.privateRT.id
}

resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public-sub1.id
    route_table_id = aws_route_table.publicRt.id
}

resource "aws_route_table_association" "public2" {
    subnet_id = aws_subnet.public-sub2.id
    route_table_id = aws_route_table.publicRt.id
}