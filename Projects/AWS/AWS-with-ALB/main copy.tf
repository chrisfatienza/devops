provider "aws" {
  region = "your_region"
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_instance" "web_server" {
  count         = 2
  ami           = "ami-12345678" // Replace with Ubuntu AMI ID
  instance_type = "t2.micro" // Change instance type as needed
  key_name      = "devops-demo" // Change to your key pair
  subnet_id     = data.aws_vpc.selected.public_subnets[0] // Assuming you're using the first public subnet

  tags = {
    Name = "Web Server ${count.index + 1}"
  }

  // Example user_data script to install Apache web server
  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2
              systemctl start apache2
              EOF
}

resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.lb.id}"]
  subnets            = data.aws_vpc.selected.public_subnets // Use all public subnets in the VPC

  tags = {
    Name = "Web Load Balancer"
  }
}

resource "aws_lb_target_group" "web_target_group" {
  name     = "web-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 10
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = "${aws_lb.web_lb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.web_target_group.arn}"
  }
}

resource "aws_security_group" "lb" {
  name        = "web-lb-sg"
  description = "Security group for web load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// MongoDB setup (you may need to use a module or separate configuration for more complex setups)
resource "aws_instance" "mongodb_instance" {
  ami           = "ami-12345678" // Replace with MongoDB AMI ID
  instance_type = "t2.micro" // Change instance type as needed
  key_name      = "devops-demo" // Change to your key pair
  subnet_id     = data.aws_vpc.selected.public_subnets[0] // Assuming you're using the first public subnet
  tags = {
    Name = "MongoDB Server"
  }

  // Example user_data script to install MongoDB
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y mongodb
              EOF
}

// DDOS protection (example using AWS Shield Advanced)
resource "aws_shield_protection" "ddos_protection" {
  resource_arn = "${aws_lb.web_lb.arn}"
}
