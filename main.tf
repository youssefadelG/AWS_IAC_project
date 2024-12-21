resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
    tags = {
        Name = "public_az1"
    }
}

resource "aws_subnet" "private_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_az1"
  } 
}

resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_az2"
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_az2"
  }
}

resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_az2.id
  depends_on = [ aws_subnet.public_az2 ]
  tags = {
    Name = "My NAT Gateway"
  }
  
}

resource "aws_eip" "nat" {
  tags = {
    Name = "My EIP"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "My IGW"
  }
}