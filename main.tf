# Set our cloud provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


# Define resources for instances
resource "aws_instance" "instance" {
  count                  = 1 #length(var.amis_tags) расскомитить
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = element(var.amis_tags, count.index) }
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
  user_data              = <<EOF
#!/bin/bash
sudo su-
yum update -y
yum install httpd -y
myip =`curl http://169.254.169.254/latest/meta-data/local-ipv4`
echo "<h2>ITA DevOps</h2><br>"  >  /var/www/html/index.html
service httpd start
chkconfig httpd on
EOF

}

resource "aws_security_group" "front" {
  name = "Apache Security Group"
  description = "Allow Https port inbound traffic"
  #vpc_id      = "${aws_vpc.main.id}" будем цеплять впс

  ingress { # Входящий
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Разрешаем ходить с инета
  }

  egress { #Исходящий
    from_port = 0
    to_port = 0 #Любой порт
    protocol = "-1" # Любой протокол ТСР и UDP
    cidr_blocks = ["0.0.0.0/0"]
  }

}



# # Define resources for networking
# resource "aws_subnet" "subnet"{
#   vpc_id                  =
#   cidr_block              = "10.0.1.0/24"
# }
