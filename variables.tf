variable "ami" { type = "string" }
variable "region" { type = "string" }
variable "access_key" {}
variable "secret_key" {}
variable "amis_tags" { default = ["front", "back", "service"] }
variable "instance_type" { type = "string" }



# variable "name"
# variable "shape" { type = "string" }
# variable "vms_list" { type = "list" }
