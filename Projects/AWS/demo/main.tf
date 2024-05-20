# Provider Configuration
provider "aws" {
  region = "ap-south-1" # Primary region for initial setup
}

resource "aws_instance" "Demo" {
  ami           = "ami-0f58b397bc5c1f2e8"
  instance_type = "t2.micro"
  key_name = "devops-demo"
  tags = {
    Name = "demo"
  }
}