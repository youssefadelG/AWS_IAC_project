resource "aws_lb" "alb" {
  name = "application-load-balancer"
  internal = false
  load_balancer_type = "application"
  subnets = [aws_subnet.private-sub1.id, aws_subnet.private-sub2.id]
}

    # Create ALB Listener
resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.targetgroup.arn
  }
}

    # Create ALB Target Group
resource "aws_lb_target_group" "targetgroup" {
  name = "targetgroup"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id
  health_check {
        path = "/"
        protocol = "HTTP"
        port = 80
        interval = 30
        timeout = 5
        healthy_threshold = 2
        unhealthy_threshold = 2
  }
}
