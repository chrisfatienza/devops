provider "aws" {
  region = "ap-south-1"
}

resource "aws_route53_zone" "example_zone" {
  name = "example.com."
}

resource "aws_route53_record" "example_record" {
  zone_id = aws_route53_zone.example_zone.zone_id
  name    = "www.example.com"
  type    = "A"
  ttl     = 300
  records = ["1.2.3.4"]  # Replace with your desired IP address
}
