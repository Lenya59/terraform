################################################################################
## Set our cloud provider and access details,
## such as AWS security credentials
## https://console.aws.amazon.com/iam/home?region=us-east-1#/security_credentials
##
## it stored in ./terraform.tdvar
##
################################################################################
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

data "aws_availability_zones" "available" {}
################################################################################
## Create a VPC to launch main VPC-network
## determine the CIDR block for our VPC
##
##                          NETWORKING
##
## https://www.terraform.io/docs/providers/aws/d/vpc.html
################################################################################
resource "aws_vpc" "main-vpc" {
  cidr_block           = var.cidr["main"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "MAIN_VPC"
  }
}
################################################################################
##
##    Define subnets
##
##  https://www.terraform.io/docs/providers/aws/r/subnet.html
##
################################################################################
resource "aws_subnet" "front_subnet" {
  vpc_id                  = aws_vpc.main-vpc.id
  cidr_block              = var.cidr["front"]
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  depends_on              = ["aws_internet_gateway.gw"]

  tags = {
    Name = "front_subnet"
  }
}

resource "aws_subnet" "back_subnet" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.cidr["back"]
  #map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "back_subnet"
  }
}

resource "aws_subnet" "services_subnet" {
  vpc_id            = aws_vpc.main-vpc.id
  cidr_block        = var.cidr["services"]
  availability_zone = "us-east-1a"
  tags = {
    Name = "services_subnet"
  }
}
################################################################################
## Provides a resource to create a VPC Internet Gateway
## vpc_id - (Required) The VPC ID to create in
##
## https://www.terraform.io/docs/providers/aws/r/internet_gateway.html
################################################################################
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main-vpc.id}"
}
################################################################################
##
## NAT_gateway
##
## https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
##
################################################################################

resource "aws_eip" "nat" {
  #instance   = "${aws_instance.back.id}"
  vpc        = true
  depends_on = ["aws_internet_gateway.gw"]
}


resource "aws_nat_gateway" "aws_nat_gateway" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${aws_subnet.back_subnet.id}"
  depends_on    = ["aws_internet_gateway.gw"]

  tags = {
    Name = "aws_nat_gateway"
  }
}
#
################################################################################
##
##                               ROUTING
##   route_table
##
##   https://www.terraform.io/docs/providers/aws/r/route_table.html
##
################################################################################
resource "aws_route_table" "private_subnet_rt" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }
}

# resource "aws_route_table" "public_subnet_rt" {
#   vpc_id = "${aws_vpc.main-vpc.id}"
#
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = "${aws_internet_gateway.gw.id}"
#   }
# }
################################################################################
##
##  route_table_association
##
##  https://www.terraform.io/docs/providers/aws/r/route_table_association.html
##
################################################################################
# resource "aws_route_table_association" "rta_public_subnet" {
#   subnet_id      = "${aws_subnet.front_subnet.id}"
#   route_table_id = "${aws_route_table.public_subnet_rt.id}"
# }

resource "aws_route_table_association" "rta_private_subnet" {
  subnet_id      = "${aws_subnet.front_subnet.id}"
  route_table_id = "${aws_route_table.private_subnet_rt.id}"
}


################################################################################
##
##    Define security groups
##
## this sec group allow :443 for input/output
##
## https://www.terraform.io/docs/providers/aws/r/security_group.html\
##
################################################################################
resource "aws_security_group" "front" {
  name        = "Apache Security Group"
  description = "Allow Https port inbound traffic"
  vpc_id      = "${aws_vpc.main-vpc.id}" #будем цеплять впс
  ################################################################################
  ##
  ##    Dynamic block
  ##
  ## this block allow :443,80,22 port for input/output
  ##
  ## https://www.terraform.io/docs/configuration/expressions.html
  ##
  ################################################################################

  dynamic "ingress" {
    for_each = ["443", "80", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  # #allow 443 port for input
  # ingress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  # ingress { # Входящий
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"         # Любой протокол ТСР и UDP
  #   cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  # }
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
resource "aws_security_group" "access_via_nat" {
  name        = "Access via nat"
  description = "Access to nat instance"
  vpc_id      = "${aws_vpc.main-vpc.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Nat access"
  }
}
resource "aws_security_group" "services" {
  name        = "services_sg"
  description = "Access"
  vpc_id      = "${aws_vpc.main-vpc.id}"

  ingress {
    from_port   = 7
    to_port     = 7
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 7
    to_port     = 7
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ICMP"
  }
}
# next one's need to use in this task:
#  https://www.terraform.io/docs/providers/aws/r/network_acl.html
#  https://www.terraform.io/docs/providers/aws/r/network_acl_rule.html
#
#
##

################################################################################
##
##                            INSTANCES
##
## Create aws_instanse for "front"
##
##########################################   ######################################
resource "aws_instance" "front" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "frontend" }
  subnet_id              = "${aws_subnet.front_subnet.id}"
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
  user_data              = file("install_httpd.sh")
  key_name               = "ssh"
}
################################################################################
##
## Create two another instances
##
################################################################################
##
##   Backend instance
##
resource "aws_instance" "back" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "back" }
  user_data              = "ping 8.8.8.8"
  subnet_id              = "${aws_subnet.back_subnet.id}"
  vpc_security_group_ids = [aws_security_group.access_via_nat.id]
  key_name               = "ssh"
}
##
##
##
resource "aws_instance" "services" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "services" }
  user_data              = "ping 8.8.8.8"
  subnet_id              = "${aws_subnet.services_subnet.id}"
  vpc_security_group_ids = [aws_security_group.services.id]
  key_name               = "ssh"

}
