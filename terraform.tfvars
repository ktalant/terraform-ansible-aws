aws_region = "us-east-1"
aws_profile = "jasmine"

vpc_cidr = "192.168.0.0/16"

cidrs = {
  public1 = "192.168.1.0/24"
  public2 = "192.168.2.0/24"
  private1 = "192.168.11.0/24"
  private2 = "192.168.12.0/24"

  rds1 = "192.168.21.0/24"
  rds2 = "192.168.22.0/24"
  rds3 = "192.168.23.0/24"
}

localip = "0.0.0.0/0"

# bucket variables
bucketname = "wp-code-bucket"

# rds variables
instance_class = "db.t2.micro"
db_name = "talant_db"
dbuser = "talant"
dbpassword = "talant123456"

# dev instance variables
key_name = "devkey"
key_path = "/root/.ssh/id_rsa.pub"

dev_instance_type = "t2.medium"
ami_id = "ami-062f7200baf2fa504"
domain_name = "talantzon"
