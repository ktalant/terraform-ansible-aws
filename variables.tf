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

variable "keypath" {}
variable "dev_ami" {}
variable "dev_instance_type" {}

variable "domain_name" {}
