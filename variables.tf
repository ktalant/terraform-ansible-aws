data "aws_availability_zones" "available" {}

variable "aws_region" {}
variable "aws_profile" {}
variable "vpc_cidr" {}
variable "cidrs" {
  type = map
}
variable "localip" {}
variable "bucketname" {}
variable "instance_class" {}
variable "db_name" {}
variable "dbuser" {}
variable "dbpassword" {}

variable "key_path" {}
variable "key_name" {}
variable "dev_instance_type" {}

variable "domain_name" {}
