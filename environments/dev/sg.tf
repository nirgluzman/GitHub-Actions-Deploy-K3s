resource "aws_security_group" "tf-k3s-sec-gr" {
  name = "${local.name}-k3s-sec-gr"
  tags = {
    Name        = "${local.name}-k3s-sec-gr"
    Description = "k3s security group"
  }

  ingress {
    description = "security group itself is a source"
    from_port = 0
    to_port   = 0
    protocol  = "-1" # all protocols
    self      = true # security group itself will be added as a source to this ingress rule.
  }

  dynamic "ingress" {
    for_each      = var.allowed_ports
    iterator      = port
    content {
      description = "allow TCP/SSH traffic"
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    description = "allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # all protocols
    cidr_blocks = ["0.0.0.0/0"]
  }
}
