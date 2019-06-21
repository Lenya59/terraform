################################################################################
# Set our cloud provider and access details,
# such as AWS security credentials
# https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials
# it stored in ./terraform.tdvars
#
################################################################################
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}
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
# Provides a resource to create a VPC Internet Gateway
# vpc_id - (Required) The VPC ID to create in
#
# https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
################################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main-vpc.id}"
}
################################################################################
# Define subnet
#
#
#################################################################################
resource "aws_subnet" "front_subnet" {
  vpc_id                  = "${aws_vpc.main-vpc.id}"
  cidr_block              = var.cidr["subnet"]
  map_public_ip_on_launch = true
  depends_on              = ["aws_internet_gateway.gw"]
}
################################################################################
#
#
#
################################################################################
resource "aws_eip" "ip" {
  instance = aws_instance.front.id
}
#################################################################################
#
#
#
#################################################################################
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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress { #Исходящий
    from_port   = 443
    to_port     = 443    #Любой порт
    protocol    = "-1" # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"]
  #allow server_port ./variable.tf for input
  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress { # Входящий
    from_port   = 22
    to_port     = 22
    protocol    = "-1"     # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }
  egress { # Входящий
    from_port   = 22
    to_port     = 22
    protocol    = "-1"         # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }
  tags = {
    Name = "allow_all"
  }
}
#
#
#
#
################################################################################
# create aws_instanse for "front"
################################################################################
resource "aws_instance" "front" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "frontend" }
  private_ip             = "10.0.0.12"
  subnet_id              = "${aws_subnet.front_subnet.id}"
  vpc_security_group_ids = [aws_security_group.apache_front.id]       #Берем айди секюрити групы после ее создания
  user_data              = file("install_httpd.sh")
}

#
#
# resource "aws_subnet" "aws_subnet_private" {
#   cidr_block              = "172.31.64.0/20"
#   vpc_id                  = "${aws_vpc.aws_vpc.id}"
#   map_public_ip_on_launch = "false"
#   availability_zone       = "us-east-1a"
#   tags {
#     Name = "aws_subnet_private"
#   }
# }



#---------------------------------------------------
# Create
#---------------------------------------------------
# resource "aws_instance" "web" {
#   count         = length(var.amis_tags)
#   ami           = var.ami
#   instance_type = var.instance_type
#   tags          = { name = element(var.amis_tags, count.index) }
# }
