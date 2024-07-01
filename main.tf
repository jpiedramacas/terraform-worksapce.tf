provider "aws" {
  region = "us-east-1"
}

locals {
  environment         = terraform.workspace
  bucket_name         = terraform.workspace == "prod" ? "prod-example-bucket" : "dev-example-bucket"
  instance_type       = terraform.workspace == "prod" ? "t2.small" : "t3.micro"
  db_instance_class   = terraform.workspace == "prod" ? "db.t3.medium" : "db.t3.micro"
  db_allocated_storage= terraform.workspace == "prod" ? 20 : 10
}

resource "aws_instance" "example" {
  ami           = "ami-01b799c439fd5516a" # Amazon Linux 2 AMI
  instance_type = local.instance_type

  tags = {
    Name        = "${local.environment}-example-instance"
    Environment = local.environment
  }
}

resource "aws_db_instance" "example" {
  allocated_storage    = local.db_allocated_storage
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = local.db_instance_class
  db_name              = "exampledb"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"

  tags = {
    Name        = "${local.environment}-example-db"
    Environment = local.environment
  }
}
