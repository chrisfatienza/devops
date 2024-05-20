# Provider Configuration
provider "aws" {
  region = "ap-south-1" # Primary region for initial setup
}

resource "aws_instance" "Demo" {
  ami           = "ami-05e00961530ae1b55"
  instance_type = "t2.micro"
  key_name = "devops-demo"
  tags = {
    Name = "demo"
  }
}