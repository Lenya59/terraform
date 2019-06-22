# Terraform



In this repo you can find basic IaaC configuration. We can launch our instances on AWS using basic Terraform configuration.

 First of all, we need [download](https://www.terraform.io/downloads.html) and install [terraform](https://www.terraform.io/intro/index.html).

 Let's set up our first configuration


```HCL
resource "aws_instance" "front" {
  ami                    = var.ami
  instance_type          = var.instance_type
  tags                   = { name = "frontend" }
  subnet_id              = "${aws_subnet.front_subnet.id}"
  vpc_security_group_ids = [aws_security_group.front.id] #Берем айди секюрити групы после ее создания
  user_data              = file("install_httpd.sh")
}
resource "aws_instance" "back" {
  ami           = var.ami
  instance_type = var.instance_type
  tags          = { name = "back" }
  subnet_id     = "${aws_subnet.private.id}"

}
resource "aws_instance" "services" {
  ami           = var.ami
  instance_type = var.instance_type
  tags          = { name = "services" }
  subnet_id     = "${aws_subnet.private.id}"

}
```
