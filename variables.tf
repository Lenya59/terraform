variable "ami" { type = "string" }
variable "region" { type = "string" }
variable "access_key" {}
variable "secret_key" {}
variable "amis" { default = ["mariadbserver", "lampserver", "elkserver"] }






# variable "name"
# variable "shape" { type = "string" }
# variable "vms_list" { type = "list" }
