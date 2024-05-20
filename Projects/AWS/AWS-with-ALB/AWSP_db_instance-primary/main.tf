provider "aws" {
  region = "ap-south-1"  # Change to your desired AWS region
}

resource "aws_db_instance" "mysql_primary" {
  identifier            = "mysql-primary"
  allocated_storage     = 20
  storage_type          = "gp2"
  engine                = "mysql"
  engine_version        = "5.7"
  instance_class        = "db.t2.micro"
  name                  = "mydb"
  username              = "admin"
  password              = "testboxDB"
  parameter_group_name  = "default.mysql5.7"
  publicly_accessible   = false
}
