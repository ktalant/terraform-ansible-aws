provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

resource "aws_vpc" "wp_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "wp-VPC"
    }
}

# Internet gateway
resource "aws_internet_gateway" "wp_igw" {
    vpc_id = aws_vpc.wp_vpc.id
    tags = {
      Name = "wp-IGW"
    }
}

# Route table
resource "aws_route_table" "wp_public_rt" {
    vpc_id = aws_vpc.wp_vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.wp_igw.id
    }

    tags = {
      Name = "wp-PublicRT"
    }
}

resource "aws_default_route_table" "wp_private_rt" {
    default_route_table_id = aws_vpc.wp_vpc.default_route_table_id

    tags = {
      Name = "wp-PrivateRT"
    }
}
