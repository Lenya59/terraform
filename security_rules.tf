# resource "aws_security_group_rule" "http" {
#   type              = "egress"
#   to_port           = 0
#   protocol          = "-1"
#   prefix_list_ids   = ["${aws_vpc_endpoint.my_endpoint.prefix_list_id}"]
#   from_port         = 0
#   security_group_id = "sg-123456"
# }
#
# # ...
# resource "aws_vpc_endpoint" "my_endpoint" {
#   # ...
# }
#
#
#
#
#
# ingress {
#   from_port   = var.server_port
#   to_port     = var.server_port
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# }
# egress {
#   from_port   = var.server_port
#   to_port     = var.server_port
#   protocol    = "tcp"
#   cidr_blocks = ["0.0.0.0/0"]
# }
