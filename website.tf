provider "aws" {
  region = "us-east-1"
}

module "web1" {
  source       = "./static-website"
  count_bucket = 3
  website_name = "anyisud"

}

module "web2" {
  source       = "./static-website"
  count_bucket = 2
  website_name = "anyisudmod"

}

##### Creating VPC #####
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

##### Creating Single EC2 Instance #####
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "single-instance"

  instance_type               = "t2.micro"
  monitoring                  = true
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  ami                         = "ami-053b0d53c279acc90"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  create_spot_instance = true
  iam_instance_profile  = "ssm-role-sudo"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

##### Creating security groups #####
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}