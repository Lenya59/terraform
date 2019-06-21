################################################################################
# Set our cloud provider and access details,
# such as AWS security credentials
# https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials
#
# it stored in ./terraform.tdvar
#
################################################################################
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_availability_zones" "available" {}
################################################################################
# Create a VPC to launch main VPC-network
# determine the CIDR block for our VPC
#
#
# https://www.terraform.io/docs/providers/aws/d/vpc.html
################################################################################
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.cidr["main"]
  enable_dns_hostnames = true
  enable_dns_support   = "true"

  tags = {
    Name = "MAIN_VPC"
  }
}
################################################################################
#
# Define subnets
#
################################################################################
resource "aws_subnet" "front_subnet" {
  vpc_id                  = "${aws_vpc.main-vpc.id}"
  cidr_block              = var.cidr["public_subnet"]
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  depends_on              = ["aws_internet_gateway.gw"]

  tags = {
    Name = "front_subnet"
  }
}

# resource "aws_subnet" "backend_subnet" {
#   vpc_id                  = "${aws_vpc.aws_vpc.id}"
#   cidr_block              = var.cidr["nat_subset"]
#   map_public_ip_on_launch = "false"
#   availability_zone       = "${var.aws_region}a"
#   tags {
#     Name = "backend_subnet"
#   }
# }
#
# resource "aws_subnet" "service_subnet" {
#   vpc_id                  = "${aws_vpc.aws_vpc.id}"
#   cidr_block              = var.cidr["private_subnet"]
#   map_public_ip_on_launch = "false"
#   availability_zone       = "${var.aws_region}b"
#   tags {
#     Name = "services_subnet"
#   }
# }
################################################################################
# Provides a resource to create a VPC Internet Gateway
# vpc_id - (Required) The VPC ID to create in
#
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
################################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main-vpc.id}"
}
################################################################################
#
# elastic internet portal
#
################################################################################
resource "aws_eip" "ip" {
  vpc = true
}
################################################################################
#
# ROUTING
#
################################################################################
resource "aws_route_table" "rtb" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}
################################################################################
#
# route table
#
################################################################################
resource "aws_route_table_association" "rta_public_subnet" {
  subnet_id      = "${aws_subnet.front_subnet.id}"
  route_table_id = "${aws_route_table.rtb.id}"
}
################################################################################
#
# # elastic internet portal associations
#
################################################################################
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.front.id}"
  allocation_id = "${aws_eip.ip.id}"
}
################################################################################
# Define security groups
#
# this sec group allow :443 for input/output
#
################################################################################
resource "aws_security_group" "front" {
  name        = "Apache Security Group"
  description = "Allow Https port inbound traffic"
  vpc_id      = "${aws_vpc.main-vpc.id}" #будем цеплять впс
  #allow 443 port for input
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Входящий
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"         # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }
  egress { # Входящий
    from_port   = 0
    to_port     = 0
    protocol    = "-1"          # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }
  tags = {
    Name = "front_acces"
  }
}
#
#
################################################################################
# Create aws_instanse for "front"
################################################################################
resource "aws_instance" "front" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "frontend" }
  private_ip             = "10.20.0.12"
  subnet_id              = "${aws_subnet.front_subnet.id}"
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
  user_data              = file("install_httpd.sh")
}
################################################################################
# Create aws_instance by ami_tags
################################################################################
# resource "aws_instance" "web" {
#   count         = length(var.amis_tags)
#   ami           = var.ami
#   instance_type = var.instance_type
#   tags          = { name = element(var.amis_tags, count.index) }
# }
