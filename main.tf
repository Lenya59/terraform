# Set our cloud provider and access details
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

# Create a VPC to launch our instances into
resource "aws_vpc" "main-vpc" {
  cidr_block        = "172.20.0.0/16"
  security_group_id = "${aws_security_group.front.id}"
  tags = {
    Name = "VI_PI_SI"
  }
}

# Define subnet for back-services
resource "aws_subnet" "main-subnet" {
  vpc_id     = "${aws_vpc.main-vpc.id}"
  cidr_block = "172.20.0.0/24"

  tags = {
    Name = "SUBNET_back-services"
  }
}

# Provides a resource to create a VPC NAT Gateway.
# resource "aws_nat_gateway" "gw" {
#   allocation_id = "${aws_eip.nat.id}"
#   subnet_id     = "${aws_subnet.public.id}"
#
#   tags = {
#     Name = "gw_NAT"
#   }
# }



resource "aws_security_group" "front" {
  name        = "Apache Security Group"
  description = "Allow Https port inbound traffic"
  vpc_id      = "${aws_vpc.main-vpc.id}" #будем цеплять впс

  ingress { # Входящий
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }
  # ingress { # Входящий
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"         # Любой протокол ТСР и UDP
  #   cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  # }
  egress { #Исходящий
    from_port   = 0
    to_port     = 0    #Любой порт
    protocol    = "-1" # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#---------------------------------------------------
# Create
#---------------------------------------------------
resource "aws_instance" "web" {
  count         = length(var.amis_tags)
  ami           = var.ami
  instance_type = var.instance_type
  tags          = { name = element(var.amis_tags, count.index) }
}

resource "aws_instance" "front" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "frontend" }
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
  user_data              = file("install_httpd.sh")
}
