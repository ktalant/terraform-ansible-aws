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
variable ""
