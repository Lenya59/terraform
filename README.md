# Terraform



In this repo you can find basic IaaC configuration. We can launch our instances on AWS using basic Terraform configuration.

 First of all, we need [download](https://www.terraform.io/downloads.html) and install [terraform](https://www.terraform.io/intro/index.html).

 Let's set up our first configuration



let it be:

```shell
$ terraform apply -auto-approve
data.aws_availability_zones.available: Refreshing state...
aws_eip.ip: Refreshing state... [id=eipalloc-033920bf62c9763d9]
aws_vpc.main-vpc: Refreshing state... [id=vpc-014db4ba9c387d542]
aws_internet_gateway.gw: Refreshing state... [id=igw-052eecf2b25aca447]
aws_security_group.front: Refreshing state... [id=sg-0a57da5ab10fccf8d]
aws_subnet.front_subnet: Refreshing state... [id=subnet-06b452b2a9ea551c6] aws_route_table.rtb: Refreshing state... [id=rtb-0834a93884b5ed719]
aws_route_table_association.rta_public_subnet: Refreshing state... [id=rtbassoc-09a59bb3cf7affc87]
aws_instance.front: Creating...
aws_instance.front: Still creating... [10s elapsed]
aws_instance.front: Still creating... [20s elapsed]
aws_instance.front: Still creating... [30s elapsed]
aws_instance.front: Creation complete after 38s [id=i-06ebdcb9fb85ee5e3]
aws_eip_association.eip_assoc: Creating...
aws_eip_association.eip_assoc: Creation complete after 2s [id=eipassoc-0b1a9185fd6a703e9]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

public_ip = 54.159.80.79
```
