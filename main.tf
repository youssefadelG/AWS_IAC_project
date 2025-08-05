resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    # Name on aws console
    Name = "vpc"
  }
}

resource "aws_subnet" "public-sub1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_az1"
  }
}

# Private Subnet in AZ1
resource "aws_subnet" "private-sub1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "private_az1"
  }
}

# Public Subnet in AZ2
resource "aws_subnet" "public-sub2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_az2"
  }
}

# Private Subnet in AZ2
resource "aws_subnet" "private-sub2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "192.168.2.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "private_az2"
  }
}

# Security Groups
# Security Group for ALB
resource "aws_security_group" "HTTP-SSH-SG" {
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "http-ssh-sg"
  }
}

# Security Group for private instances
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["192.168.3.0/24"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

resource "aws_lb" "alb" {
  name               = "application-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.private-sub1.id, aws_subnet.private-sub2.id]
}

# Create ALB Listener
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}

# Create ALB Target Group
resource "aws_lb_target_group" "targetgroup" {
  name     = "targetgroup"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    port                = 80
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}
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
  route_table_id         = aws_route_table.privateRT.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "privateRT"
  }
}

resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.private-sub1.id
  route_table_id = aws_route_table.privateRT.id
}

resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.private-sub2.id
  route_table_id = aws_route_table.privateRT.id
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public-sub1.id
  route_table_id = aws_route_table.publicRt.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public-sub2.id
  route_table_id = aws_route_table.publicRt.id
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public-sub2.id
  tags = {
    Name = "natgw"
  }
}

resource "aws_eip" "nat_eip" {
  tags = {
    Name = "nat-eip"
  }
}

resource "aws_key_pair" "asg-key" {
  key_name   = "asg-key"
  public_key = file("${path.module}/my-key.pub")
}

resource "aws_launch_configuration" "app" {
  name                 = "app-launch-configuration"
  image_id             = var.ubuntu-ami
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.HTTP-SSH-SG.id]
  key_name             = aws_key_pair.asg-key.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install httpd -y
                sudo systemctl start httpd
                sudo systemctl enable httpd
                echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
                EOF  
}

resource "aws_autoscaling_group" "ec2_app" {
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.private-sub1.id, aws_subnet.private-sub2.id]
  launch_configuration      = aws_launch_configuration.app.id
  target_group_arns         = [aws_lb_target_group.targetgroup.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "ASG-instance"
    propagate_at_launch = true
  }

  lifecycle {
    ignore_changes = [desired_capacity]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = file("${path.module}/my-key.pub")
}
resource "aws_instance" "bastion" {
  ami                         = var.ubuntu-ami
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public-sub1.id
  availability_zone           = "us-east-1a"
  security_groups             = [aws_security_group.bastion_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  tags = {
    Name = "bastion"
  }
}