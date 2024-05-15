# Provider configuration for AWS - us-east-1 region
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# Provider configuration for AWS - backup region (e.g., us-west-1)
provider "aws" {
  alias  = "backup"
  region = "us-west-1"  # Change this to your desired backup region
}

# Define security group for the instances in us-east-1
resource "aws_security_group" "web_sg" {
  provider = aws.us_east_1

  name        = "web_sg"
  description = "Security group for web servers"
  
  # Define inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow inbound HTTP traffic from anywhere
  }

  # Define outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Define security group for the instances in backup region
resource "aws_security_group" "backup_web_sg" {
  provider = aws.backup

  name        = "backup_web_sg"
  description = "Security group for web servers in backup region"
  
  # Define inbound rules
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow inbound HTTP traffic from anywhere
  }

  # Define outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# Define the launch configuration in us-east-1
resource "aws_launch_configuration" "web_lc" {
  provider = aws.us_east_1

  name                 = "web_lc"
  image_id             = "ami-12345678"  # Specify your desired AMI ID
  instance_type        = "t3.micro"      # Specify your desired instance type
  security_groups      = [aws_security_group.web_sg.name]
  user_data            = <<-EOF
                          #!/bin/bash
                          # Add any necessary startup scripts here
                          EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Define the launch configuration in backup region
resource "aws_launch_configuration" "backup_web_lc" {
  provider = aws.backup

  name                 = "backup_web_lc"
  image_id             = "ami-12345678"  # Specify your desired AMI ID in the backup region
  instance_type        = "t3.micro"      # Specify your desired instance type
  security_groups      = [aws_security_group.backup_web_sg.name]
  user_data            = <<-EOF
                          #!/bin/bash
                          # Add any necessary startup scripts here
                          EOF
  lifecycle {
    create_before_destroy = true
  }
}

# Define the auto scaling group in us-east-1
resource "aws_autoscaling_group" "web_asg" {
  provider = aws.us_east_1

  name                 = "web_asg"
  launch_configuration = aws_launch_configuration.web_lc.id
  min_size             = 2  # Minimum number of instances
  max_size             = 5  # Maximum number of instances
  desired_capacity     = 2  # Desired number of instances
  availability_zones   = ["us-east-1a", "us-east-1b"]  # Specify availability zones
  
  # Define tags as needed
  # tags = {
  #   Name = "web_server"
  # }
}

# Define the auto scaling group in backup region
resource "aws_autoscaling_group" "backup_web_asg" {
  provider = aws.backup

  name                 = "backup_web_asg"
  launch_configuration = aws_launch_configuration.backup_web_lc.id
  min_size             = 2  # Minimum number of instances
  max_size             = 5  # Maximum number of instances
  desired_capacity     = 2  # Desired number of instances
  availability_zones   = ["us-west-1a", "us-west-1b"]  # Specify availability zones in the backup region
  
  # Define tags as needed
  # tags = {
  #   Name = "web_server"
  # }
}

# Define the application load balancer in us-east-1
resource "aws_lb" "web_alb" {
  provider = aws.us_east_1

  name               = "web_alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-12345678", "subnet-87654321"]  # Specify subnets

  enable_deletion_protection = false  # Set to true if you want to protect against accidental deletion

  tags = {
    Name = "web_alb"
  }
}

# Define the application load balancer in backup region
resource "aws_lb" "backup_web_alb" {
  provider = aws.backup

  name               = "backup_web_alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-12345678", "subnet-87654321"]  # Specify subnets in the backup region

  enable_deletion_protection = false  # Set to true if you want to protect against accidental deletion

  tags = {
    Name = "backup_web_alb"
  }
}

# Define target group for the ALB in us-east-1
resource "aws_lb_target_group" "web_target_group" {
  provider = aws.us_east_1

  name        = "web_target_group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-12345678"  # Specify your VPC ID
}

# Define target group for the ALB in backup region
resource "aws_lb_target_group" "backup_web_target_group" {
  provider = aws.backup

  name        = "backup_web_target_group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "vpc-87654321"  # Specify your VPC ID in the backup region
}

# Attach ASG instances to the target group in us-east-1
resource "aws_autoscaling_attachment" "asg_attachment" {
  provider = aws.us_east_1

  autoscaling_group_name = aws_autoscaling_group.web_asg.name
  alb_target_group_arn   = aws_lb_target_group.web_target_group.arn
}

# Attach ASG instances to the target group in backup region
resource "aws_autoscaling_attachment" "backup_asg_attachment" {
  provider = aws.backup

  autoscaling_group_name = aws_autoscaling_group.backup_web_asg.name
  alb_target_group_arn   = aws_lb_target_group.backup_web_target_group.arn
}

# Define listener for the ALB in us-east-1
resource "aws_lb_listener" "web_alb_listener" {
  provider = aws.us_east_1

  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_target_group.arn
  }
}

# Define listener for the ALB in backup region
resource "aws_lb_listener" "backup_web_alb_listener" {
  provider = aws.backup

  load_balancer_arn = aws_lb.backup_web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backup_web_target_group.arn
  }
}

# Define S3 bucket for storing static assets in us-east-1
resource "aws_s3_bucket" "web_assets_bucket" {
  provider = aws.us_east_1

  bucket = "your-unique-bucket-name"
  acl    = "private"  # Set ACL as per your requirement

  # Enable versioning for the bucket
  versioning {
    enabled = true
  }

  # Enable server-side encryption for the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Optional: Define tags for the bucket
  tags = {
    Name = "web_assets_bucket"
  }
}

# Define S3 bucket for storing static assets in backup region
resource "aws_s3_bucket" "backup_web_assets_bucket" {
  provider = aws.backup

  bucket = "backup-your-unique-bucket-name"
  acl    = "private"  # Set ACL as per your requirement

  # Enable versioning for the bucket
  versioning {
    enabled = true
  }

  # Enable server-side encryption for the bucket
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  # Optional: Define tags for the bucket
  tags = {
    Name = "backup_web_assets_bucket"
  }
}

# Define AWS Shield Advanced Protection
resource "aws_shield_protection" "web_ddos_protection" {
  name = "web_ddos_protection"
  resource_arn = aws_lb.web_alb.arn
}

# Define AWS WAF Web ACL for protection against common web vulnerabilities
resource "aws_wafregional_web_acl" "web_waf_acl" {
  name        = "web_waf_acl"
  metric_name = "webWafMetrics"

  default_action {
    type = "ALLOW"
  }

  rule {
    name        = "SQLInjectionRule"
    priority    = 1
    action {
      type = "BLOCK"
    }
    statement {
      rule_statement {
        xss_match_statement {
          field_to_match {
            type  = "QUERY_STRING"
            data  = "example"
          }
          text_transformations {
            priority = 0
            type     = "NONE"
          }
        }
      }
    }
  }
  # Add more rules as needed
}

# Associate AWS WAF Web ACL with the ALB
resource "aws_wafregional_web_acl_association" "web_acl_association" {
  web_acl_id = aws_wafregional_web_acl.web_waf_acl.id
  resource_arn = aws_lb.web_alb.arn
}

# Associate AWS WAF Web ACL with the backup ALB
resource "aws_wafregional_web_acl_association" "backup_web_acl_association" {
  web_acl_id = aws_wafregional_web_acl.web_waf_acl.id
  resource_arn = aws_lb.backup_web_alb.arn
}

# Output the name of the S3 bucket in us-east-1
output "s3_bucket_name" {
  value = aws_s3_bucket.web_assets_bucket.bucket
}

# Output the name of the S3 bucket in backup region
output "backup_s3_bucket_name" {
  value = aws_s3_bucket.backup_web_assets_bucket.bucket
}
