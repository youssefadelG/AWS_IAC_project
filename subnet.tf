resource "aws_subnet" "public-sub1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
        Name = "public_az1"
    }
}
        
    # Private Subnet in AZ1
resource "aws_subnet" "private-sub1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_az1"
  } 
}

    # Public Subnet in AZ2
resource "aws_subnet" "public-sub2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_az2"
  }
}
    
    # Private Subnet in AZ2
resource "aws_subnet" "private-sub2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_az2"
  }
}