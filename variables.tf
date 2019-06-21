#hide creds from all
variable "access_key" {}
variable "secret_key" {}
#string type
variable "ami" {
  type    = "string"
  default = "ami-098bb5d92c8886ca1"
}
variable "region" {
  type    = "string"
  default = "us-east-1"
}
variable "instance_type" {
  type    = "string"
  default = "t2.micro"
}
#
# list type
# https://www.terraform.io/docs/configuration-0-11/variables.html
#
#
#
variable "amis_tags" { default = ["back", "service"] }
#map type
#
# smthng  = var.cidr["main"]
variable "cidr" {
  type = "map"
  default = {
    "main"    = "10.0.0.0/24"
    "subnet"  = "10.0.0.12"
    "all"     = "0.0.0.0/0"
    "private" = "172.0.0.0/0"
  }
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  default     = 8080
}

# variable "name"
# variable "shape" { type = "string" }
# variable "vms_list" { type = "list" }
#
#
#
#https://www.terraform.io/docs/configuration/variables.html
#
#
#
#
#
#
#
#  terraform apply -auto-approve
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
#
