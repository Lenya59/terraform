

output "public_ip" {
  value = "${aws_instance.front.public_ip}"
}
output "front_sg_id" {
  value = "${aws_security_group.front.id}"
}

output "aws_nat_gateway_id" {
  value = "${aws_nat_gateway.gw.id}"
}
