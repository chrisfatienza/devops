# Provider Configuration
provider "aws" {
  region = "us-east-1" # Primary region for initial setup
}

resource "aws_instance" "Demo" {
  ami           = "instance_id"
  instance_type = "instance_type"
  key_name = "key_name"
  tags = {
    Name = "demo"
  }
}