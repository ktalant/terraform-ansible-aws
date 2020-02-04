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
resource "aws_security_group" "wp_dev_sg" {
    name = "dev-ssh-SG"
    description = "Used for access to dev host"
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
                         aws_security_group.wp_dev_sg.id]
    }
}

# -----------VPC Endpoint-----------
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

# -----------S3 bucket being created--------------
resource "random_id" "s3_random_id" {
    byte_length = 2
}

resource "aws_s3_bucket" "wp_code_bucket" {
    bucket = "${var.bucketname}-${random_id.s3_random_id.dec}"
    acl = "private"
    force_destroy = true

    tags = {
      Name = "wp-code-bucket"
    }
}

#-----------RDS instance being created--------------
resource "aws_db_instance" "wp_db" {
    allocated_storage = 10
    engine = "mysql"
    engine_version = "5.6.44"
    instance_class = var.instance_class
    name = var.db_name
    username = var.dbuser
    password = var.dbpassword
    db_subnet_group_name = aws_db_subnet_group.wp_rds_subnet_group.name
    vpc_security_group_ids = [aws_security_group.wp_rd_sg.id]
    skip_final_snapshot = true
}

#-----------dev server being created--------------
resource "aws_key_pair" "wp_keypair" {
    key_name = var.key_name
    public_key = file(var.key_path)
}
resource "aws_instance" "wp_dev" {
    instance_type = var.dev_instance_type
    ami = var.ami_id

    tags = {
      Name = "wp-dev-server"
    }
    key_name = aws_key_pair.wp_keypair.id
    vpc_security_group_ids = [aws_security_group.wp_dev_sg.id]
    iam_instance_profile = aws_iam_instance_profile.s3_access_profile.id
    subnet_id = aws_subnet.wp_public_subnet1.id

    provisioner "local-exec" {
      command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.wp_dev.id}"
      command = <<-EOD
      cat <<EOF > aws_hosts
      [dev]
      ${aws_instance.wp_dev.public_ip}

      [dev:vars]
      s3code=${aws_s3_bucket.wp_code_bucket.bucket}
      domain=${var.domain_name}
      EOF
      EOD
    }
}
