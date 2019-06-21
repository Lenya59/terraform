
output "public_ip" {
  value = "${aws_instance.front.public_ip}"
}
