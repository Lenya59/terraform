# Set your cloud provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


# Define resources
resource "aws_instance" "instance" {
  count         = length(var.amis)
  ami           = var.ami
  instance_type = "t2.micro"
  tags          = { name = element(var.amis, count.index) }
}
