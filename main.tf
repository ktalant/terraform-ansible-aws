provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

# New VPC is being deployed
resource "aws_vpc" "wp_vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support = true

    tags = {
      Name = "wp-VPC"
    }
}

# Internet gateway is being created
resource "aws_internet_gateway" "wp_igw" {
    vpc_id = aws_vpc.wp_vpc.id
    tags = {
      Name = "wp-IGW"
    }
}

# Public route table is being created
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

# Default route table is being assigned as private route table
resource "aws_default_route_table" "wp_private_rt" {
    default_route_table_id = aws_vpc.wp_vpc.default_route_table_id

    tags = {
      Name = "wp-PrivateRT"
    }
}

# Public subent is being deployed
resource "aws_subnet" "wp_public_subnet1" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["public1"]
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
      Name = "wp-PublicSubnet-1"
    }
}

resource "aws_subnet" "wp_public_subnet2" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["public2"]
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
      Name = "wp-PublicSubnet-2"
    }
}

# Next 2 subnets are private subnets
resource "aws_subnet" "wp_private_subnet1" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["private1"]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
      Name = "wp-PrivateSubnet-1"
    }
}

resource "aws_subnet" "wp_private_subnet2" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["private2"]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
      Name = "wp-PrivateSubnet-2"
    }
}

# Next 3 subnet resources are for private subnets for our Database
resource "aws_subnet" "wp_rds_subnet1" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["rds1"]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[0]

    tags = {
      Name = "wp-RdsSubnet-1"
    }
}

resource "aws_subnet" "wp_rds_subnet2" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["rds2"]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[1]

    tags = {
      Name = "wp-RdsSubnet-2"
    }
}

resource "aws_subnet" "wp_rds_subnet3" {
    vpc_id = aws_vpc.wp_vpc.id
    cidr_block = var.cidrs["rds3"]
    map_public_ip_on_launch = false
    availability_zone = data.aws_availability_zones.available.names[2]

    tags = {
      Name = "wp-RdsSubnet-3"
    }
}

# Subnet groups are being created
# Rds subnet group
resource "aws_db_subnet_group" "wp_rds_subnet_group" {
    name = "wp_rds_subnet_group"
    subnet_ids = [aws_subnet.wp_rds_subnet1.id,
                  aws_subnet.wp_rds_subnet2.id,
                  aws_subnet.wp_rds_subnet3.id]
    tags = {
      Name = "wp_rds_subgroup"
    }
}

# Association subnets
resource "aws_route_table_association" "wp_public_assoc1" {
    subnet_id = aws_subnet.wp_public_subnet1.id
    route_table_id = aws_route_table.wp_public_rt.id
}

resource "aws_route_table_association" "wp_public_assoc2" {
    subnet_id = aws_subnet.wp_public_subnet2.id
    route_table_id = aws_route_table.wp_public_rt.id
}


resource "aws_route_table_association" "wp_private_assoc1" {
    subnet_id = aws_subnet.wp_private_subnet1.id
    route_table_id = aws_default_route_table.wp_private_rt.id
}

resource "aws_route_table_association" "wp_private_assoc2" {
    subnet_id = aws_subnet.wp_private_subnet2.id
    route_table_id = aws_default_route_table.wp_private_rt.id
}

# Security groups are being created
resource "aws_security_group" "wp_bastion_sg" {
    name = "bastion-ssh-SG"
    description = "Used for access to bastion host"
    vpc_id = aws_vpc.wp_vpc.id

    # SSH
    ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.localip]
    }

    # Http
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = [var.localip]
    }

    # egress
    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# Public security group
resource "aws_security_group" "wp_public_sg" {
    name = "wp-public-SG"
    description = "Used for elastic load balancer for public access"
    vpc_id = aws_vpc.wp_vpc.id

    # Http
    ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# Private security group
resource "aws_security_group" "wp_private_sg" {
    name = "wp-private-SG"
    description = "Used for private connections"
    vpc_id = aws_vpc.wp_vpc.id

    ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = [var.vpc_cidr]
    }

    egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

# RDS security group
resource "aws_security_group" "wp_rd_sg" {
    name = "wp-rds-SG"
    description = "Used for RDS instances"
    vpc_id = aws_vpc.wp_vpc.id

    # SQL access from public and private security groups
    ingress {
      from_port = 3306
      to_port = 3306
      protocol = "tcp"
      security_groups = [aws_security_group.wp_public_sg.id,
                         aws_security_group.wp_private_sg.id,
                         aws_security_group.wp_bastion_sg.id]
    }
}

# VPC Endpoint
resource "aws_vpc_endpoint" "wp_private-s3_endpoint" {
    vpc_id = aws_vpc.wp_vpc.id
    service_name = "com.amazonaws.${var.aws_region}.s3"
    route_table_ids = [aws_vpc.wp_vpc.main_route_table_id,
      aws_route_table.wp_public_rt.id]
    policy = <<-POLICY
    {
      "Statement": [
        {
          "Action": "*",
          "Effect": "Allow",
          "Resource": "*",
          "Principal": "*"
        }
      ]
    }
    POLICY
    tags = {
      Name = "wp-S3-Endpoint"
    }
}
