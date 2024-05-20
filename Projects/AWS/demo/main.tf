# Provider Configuration
provider "aws" {
  region = "ap-south-1" # Primary region for initial setup
}

resource "aws_instance" "Demo" {
  ami           = "ami-0dda4ba9a42839a4b"
  instance_type = "t2.micro"
  key_name = "devops-demo"
  tags = {
    Name = "demo"
  }
}