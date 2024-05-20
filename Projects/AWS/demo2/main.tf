provider "aws" {
  region = "ap-southeast-1"
}

resource "aws_instance" "example" {
  count                  = 1
  ami                    = "ami-003c463c8207b4dfa"
  instance_type          = "t2.micro"
  key_name               = "devops-demo"
  security_groups        = ["default"]

  tags = {
    Name = "AWS-Chris-DEVOps-demo${count.index}"
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y nginx
              sudo systemctl start nginx
              sudo systemctl enable nginx
              sudo amazon-linux-extras install -y mysql8.0
              sudo yum install -y mysql-community-server
              sudo systemctl start mysqld
              sudo systemctl enable mysqld
              EOF
}
