# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.vpc.cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [aws_subnet.public-sub1.id, aws_subnet.public-sub2.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [aws_subnet.private-sub1.id, aws_subnet.private-sub2.id]
}

# Load Balancer Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.alb.dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the Application Load Balancer"
  value       = aws_lb.alb.zone_id
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.alb.arn
}

output "target_group_arn" {
  description = "ARN of the Target Group"
  value       = aws_lb_target_group.targetgroup.arn
}

# Security Group Outputs
output "alb_security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.HTTP-SSH-SG.id
}

output "bastion_security_group_id" {
  description = "ID of the bastion security group"
  value       = aws_security_group.bastion_sg.id
}

# Bastion Host Outputs
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "bastion_public_dns" {
  description = "Public DNS name of the bastion host"
  value       = aws_instance.bastion.public_dns
}

output "bastion_instance_id" {
  description = "Instance ID of the bastion host"
  value       = aws_instance.bastion.id
}

# NAT Gateway Outputs
output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = aws_nat_gateway.natgw.id
}

output "nat_eip_public_ip" {
  description = "Public IP of the NAT Gateway Elastic IP"
  value       = aws_eip.nat_eip.public_ip
}

# Auto Scaling Group Outputs
output "autoscaling_group_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.ec2_app.arn
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.ec2_app.name
}

# Internet Gateway Output
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

# Key Pair Outputs
output "bastion_key_name" {
  description = "Name of the key pair used for bastion host"
  value       = aws_key_pair.deployer.key_name
}

output "asg_key_name" {
  description = "Name of the key pair used for ASG instances"
  value       = aws_key_pair.asg-key.key_name
}

# Application URL
output "application_url" {
  description = "URL to access the application through the load balancer"
  value       = "http://${aws_lb.alb.dns_name}"
}

# SSH Connection Information
output "bastion_ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i my-key ubuntu@${aws_instance.bastion.public_ip}"
}

# S3 Bucket Outputs
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.web_bucket.bucket
}

output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = aws_s3_bucket.web_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.web_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Domain name of the S3 bucket"
  value       = aws_s3_bucket.web_bucket.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name of the S3 bucket"
  value       = aws_s3_bucket.web_bucket.bucket_regional_domain_name
}

output "s3_bucket_hosted_zone_id" {
  description = "Route 53 hosted zone ID for the S3 bucket"
  value       = aws_s3_bucket.web_bucket.hosted_zone_id
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket"
  value       = aws_s3_bucket.web_bucket.region
}

# S3 Bucket URLs
output "s3_bucket_website_endpoint" {
  description = "Website endpoint for the S3 bucket (if configured for static website hosting)"
  value       = "http://${aws_s3_bucket.web_bucket.bucket}.s3-website-${aws_s3_bucket.web_bucket.region}.amazonaws.com"
}

output "s3_bucket_url" {
  description = "S3 bucket URL"
  value       = "https://${aws_s3_bucket.web_bucket.bucket}.s3.amazonaws.com"
}