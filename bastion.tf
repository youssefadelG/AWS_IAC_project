resource "aws_instance" "bastion" {
  ami = "ami-01816d07b1128cd2d"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.public-sub1.id
  availability_zone = "us-east-1a"
  security_groups = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "bastion"
  }
}