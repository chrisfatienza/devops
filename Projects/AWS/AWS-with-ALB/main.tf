# Define the AWS provider
provider "aws" {
  region = "ap-south-1"
}

# Define Internet-facing resources
resource "aws_route53_record" "users_dns" {
  zone_id = "your_route53_zone_id"
  name    = "your_domain_name"
  type    = "A"
  ttl     = "300"
  records = ["your_primary_alb_dns_name"]
}

# Define Primary AWS Region resources
resource "aws_instance" "web_server_primary" {
  count         = 2
  # Define EC2 instance configuration
}

resource "aws_alb" "primary_alb" {
  # Define Application Load Balancer configuration
}

resource "aws_alb_target_group" "primary_tg" {
  # Define Target Group configuration
}

resource "aws_shield" "shield" {
  # Define Shield Protection configuration
  name              = "example-shield-protection"
  resource_arn      = "arn:aws:elasticloadbalancing:us-east-1:123456789012:loadbalancer/app/example-lb/abcdef1234567890"
  protection_type   = "ELB"

}

resource "aws_waf" "waf" {
  # Define WAF configuration
}

resource "aws_db_instance" "mysql_primary" {
  # Define MySQL RDS instance configuration
}

resource "aws_route53_record" "primary_alb_dns" {
  # Define Route53 record for ALB
}

# Define Backup AWS Region resources
provider "aws" {
  alias  = "backup"
  region = "ap-southeast-1"
}

resource "aws_instance" "web_server_backup" {
  provider      = aws.backup
  count         = 2
  # Define EC2 instance configuration for backup region
}

resource "aws_alb" "backup_alb" {
  provider = aws.backup
  # Define Application Load Balancer configuration for backup region
}

resource "aws_alb_target_group" "backup_tg" {
  provider = aws.backup
  # Define Target Group configuration for backup region
}

resource "aws_shield" "shield_backup" {
  provider = aws.backup
  # Define Shield Protection configuration for backup region
}

resource "aws_waf" "waf_backup" {
  provider = aws.backup
  # Define WAF configuration for backup region
}

resource "aws_db_instance" "mysql_backup" {
  provider = aws.backup
  # Define MySQL RDS instance configuration for backup region
}

resource "aws_route53_record" "backup_alb_dns" {
  provider = aws.backup
  # Define Route53 record for ALB in backup region
}