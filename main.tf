# Set our cloud provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


# Define resources for instances
resource "aws_instance" "instance" {
  count         = length(var.amis_tags)
  ami           = var.ami
  instance_type = "t2.micro"
  tags          = { name = element(var.amis_tags, count.index) }
}





# # Define resources for networking
# resource "aws_subnet" "subnet"{
#   vpc_id                  =
#   cidr_block              = "10.0.1.0/24"
# }
