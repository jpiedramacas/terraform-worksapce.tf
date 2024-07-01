provider "aws" {
  region = "us-east-1"
}

locals {
  environment   = terraform.workspace
  bucket_name   = terraform.workspace == "prod" ? "prod-example-bucket" : "dev-example-bucket"
  instance_type = terraform.workspace == "prod" ? "t2.small" : "t2.micro"
}

resource "aws_instance" "example" {
  ami           = "ami-01b799c439fd5516a" # Amazon Linux 2 AMI
  instance_type = local.instance_type

  tags = {
    Name        = "${local.environment}-example-instance"
    Environment = local.environment
  }
}