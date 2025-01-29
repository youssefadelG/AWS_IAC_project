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