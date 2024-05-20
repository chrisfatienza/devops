provider "aws" {
  region = "us-east-1" # Set your desired region
}

# Internet Subnet
resource "aws_subnet" "internet_subnet" {
  vpc_id            = "your_vpc_id"
  cidr_block        = "10.0.0.0/24" # Define your CIDR block
  availability_zone = "us-east-1a"   # Define your desired AZ
}

# Primary AWS Region
resource "aws_instance" "web_server_primary" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0" # Define your AMI ID
  instance_type = "t2.micro"             # Define your instance type
  subnet_id     = aws_subnet.internet_subnet.id
  # Add other necessary configurations like security groups, key name, etc.
}

resource "aws_alb" "application_load_balancer_primary" {
  name            = "primary-alb"
  internal        = false
  security_groups = ["your_security_group_id"]
  subnets         = [aws_subnet.internet_subnet.id]
}

resource "aws_lb_target_group" "target_group_primary" {
  name     = "primary-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "your_vpc_id"
}

resource "aws_shield_protection" "shield_protection_primary" {
  name = "primary-shield-protection"
}

resource "aws_waf_web_acl" "waf_acl_primary" {
  name        = "primary-waf-acl"
  metric_name = "primary-waf-metric"
  default_action {
    block {}
  }
  rules {
    name        = "rule1"
    priority    = 1
    action {
      block {}
    }
    override_action {
      none {}
    }
    statement {
      # Define your WAF rule statement
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      sampled_requests_enabled   = true
      metric_name                = "primary-rule1-metric"
    }
  }
  # Add other necessary WAF rules
}

resource "aws_security_group" "mysql_security_group_primary" {
  # Define your MySQL security group configuration
}

resource "aws_db_instance" "mysql_instance_primary" {
  # Define your MySQL instance configuration
}

resource "aws_route53_record" "route53_primary" {
  zone_id = "your_route53_zone_id"
  name    = "example.com"
  type    = "A"
  alias {
    name                   = aws_alb.application_load_balancer_primary.dns_name
    zone_id                = aws_alb.application_load_balancer_primary.zone_id
    evaluate_target_health = true
  }
}

# Backup AWS Region (Similar resource definitions as in Primary Region)
