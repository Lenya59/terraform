# Set our cloud provider and access details
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}



# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "10.0.0.0/16"
}

##ШЛЮЗ ДЛЯ ДОСТУПА ВО ВНЕШНИЙ МИР
# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

resource "aws_security_group" "front" {
  name        = "Apache Security Group"
  description = "Allow Https port inbound traffic"
  #vpc_id      = "${aws_vpc.main.id}" будем цеплять впс

  ingress { # Входящий
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }

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
  count                  = length(var.amis_tags)
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = element(var.amis_tags, count.index) }
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
}

resource "aws_instance" "front" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "frontend" }
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
  user_data              = file("install_httpd.sh")
}
