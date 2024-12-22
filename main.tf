# AWS VPC
resource "aws_vpc" "main" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "main"
  }
}

# AWS Subnets
    # Public Subnet in AZ1
resource "aws_subnet" "public_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
    tags = {
        Name = "public_az1"
    }
}
        
    # Private Subnet in AZ1
resource "aws_subnet" "private_az1" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_az1"
  } 
}

    # Public Subnet in AZ2
resource "aws_subnet" "public_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_az2"
  }
}
    
    # Private Subnet in AZ2
resource "aws_subnet" "private_az2" {
  vpc_id = aws_vpc.main.id
  cidr_block = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_az2"
  }
}

# AWS NAT Gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public_az2.id
  depends_on = [ aws_subnet.public_az2 ]
  tags = {
    Name = "My-nat-gateway"
  }
  
}
# AWS Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  tags = {
    Name = "My EIP"
  }
}
# AWS Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-igw"
  }
}

# AWS Route Table
    # Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
    }
  tags = {
    Name = "public-route-table"
  }
}

    # Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.my_nat_gateway.id
    }
    tags = {
        Name = "private-route-table"
    }
}

resource "aws_route_table_association" "public_rt_az1" {
  subnet_id = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_rt_az2" {
  subnet_id = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_rt_az1" {
  subnet_id = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_rt_az2" {
    subnet_id = aws_subnet.private_az2.id
    route_table_id = aws_route_table.private.id
}

# Application Load Balancer
resource "aws_lb" "my_alb" {
  name = "my-alb"
  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.public_az1.id, aws_subnet.public_az2.id]
  security_groups = [aws_security_group.lb_sg.id]
}

    # Create ALB Listener
resource "aws_alb_listener" "my_alb_listener" {
    load_balancer_arn = aws_lb.my_alb.arn
    port = 80
    protocol = "HTTP"
    default_action {
        type = "forward"
        target_group_arn = aws_lb_target_group.my_target_group.arn
    }
}

    # Create ALB Target Group
resource "aws_alb_target_group" "my_target_group" {
  name = "my-target-group"
  port = 80
  protocol = HTTP
  vpc_id = aws_vpc.main.id
}

    # Create ALB Listener Rule
resource "aws_alb_listener_rule" "my_alb_listener_rule" {
    listener_arn = aws_alb_listener.my_alb_listener.arn
    priority = 1
    action {
        type = "forward"
        target_group_arn = aws_alb_target_group.my_target_group.arn
    }
    condition {
        path_pattern {
            values = ["/"]
        }
    }
}

# Security Groups
    # Security Group for ALB
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb-sg"
  }
}

    # Security Group for private instances
resource "aws_security_group" "private_sg_az1" {
    vpc_id = aws_vpc.main.id
    name = "private-sg-az1"
    description = "Security group for private subnet in AZ1"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["192.168.3.0/24"]
    }
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["192.168.3.0/24"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
    
    # Security Group for public instances
resource "aws_security_group" "public_sg_az1" {
    name = "public-sg-az1"
    description = "Security group for public subnet in AZ1"
    vpc_id = aws_vpc.main.id
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

