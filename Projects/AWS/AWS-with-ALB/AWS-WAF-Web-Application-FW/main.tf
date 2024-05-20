provider "aws" {
  region = "us-east-1"  # Change to your desired AWS region
}

# Define the AWS WAF web ACL
resource "aws_wafv2_web_acl" "example" {
  name        = "example-web-acl"
  description = "Example Web ACL"

  scope = "CLOUDFRONT"

  default_action {
    allow {}
  }

  # Define a rule to block based on IP addresses
  rule {
    name     = "BlockIPRule"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.example.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockIPRuleMetric"
      sampled_requests_enabled   = true
    }
  }
}

# Define an IP set containing IP addresses to block
resource "aws_wafv2_ip_set" "example" {
  name        = "example-ip-set"
  description = "Example IP Set"

  scope = "CLOUDFRONT"

  addresses = ["192.0.2.0/24", "203.0.113.0/24"]  # Add the IP addresses you want to block
}
