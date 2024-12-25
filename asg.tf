resource "aws_key_pair" "jumper_to_private_key_pair" {
  key_name   = "jumper_to_private_key_pair"
  public_key = file("~/.ssh/jumper_to_private_key_pair.pub")
}

resource "aws_launch_configuration" "app" {
    name = "app-launch-configuration"
    image_id = "ami-01816d07b1128cd2d"
    instance_type = "t2.micro"
    security_groups = [aws_security_group.HTTP-SSH-SG.id]
    key_name = aws_key_pair.jumper_to_private_key_pair.key_name
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
    max_size = 2
    min_size = 1
    desired_capacity = 2
    vpc_zone_identifier = [aws_subnet.private_sub1.id, aws_subnet.private_sub2.id]
    launch_configuration = aws_launch_configuration.app.id
    target_group_arns = [aws_alb_target_group.my_target_group.arn]
    health_check_type = "ELB"
    health_check_grace_period = 300
    
    tag {
      key = "Name"
      value = "ASG-instance"
      propagate_at_launch = true
    }

    lifecycle {
        ignore_changes = [ desired_capacity ]
    }
}
