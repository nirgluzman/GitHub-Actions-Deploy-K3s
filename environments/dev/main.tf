# call modules, locals, and data sources to create all resources

locals {
  name    = "nioyatech"
  ami     = data.aws_ami.ubuntu_24_04.id
}

# get the ID of a registered AMI for use in other resources
# Ubuntu 20.04
data "aws_ami" "ubuntu_24_04" {
  most_recent      = true
  owners           = ["099720109477"] # ubuntu ami account ID (canonical)

  filter {
    name   = "name"
    values = ["*24.04-amd64*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# create RSA key of size 2048 bits
resource "tls_private_key" "rsa-2048" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# create AWS key pair from the RSA key above
resource "aws_key_pair" "ec2-key" {
  key_name   = "${var.ec2_keyname}"
  public_key = tls_private_key.rsa-2048.public_key_openssh
}

# store the private key in local directory
resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/ansible/${var.ec2_keyname}.pem"
  file_permission = "0400"
  content         = tls_private_key.rsa-2048.private_key_pem
}

resource "aws_instance" "server" {
  ami                     = local.ami
  instance_type           = "${var.ec2_type}"
  key_name                = "${var.ec2_keyname}"
  iam_instance_profile    = aws_iam_instance_profile.k3s.name
  user_data               = file("${path.module}/scripts/server.sh")
  vpc_security_group_ids  = [aws_security_group.tf-k3s-sec-gr.id]
  tags = {
    Name = "${local.name}-k3s-server"
    Description = "k3s server"
  }
}

resource "aws_instance" "agent" {
  ami                     = local.ami
  instance_type           = "${var.ec2_type}"
  key_name                = "${var.ec2_keyname}"
  iam_instance_profile    = aws_iam_instance_profile.k3s.name
  user_data               = file("${path.module}/scripts/agent.sh")
  vpc_security_group_ids  = [aws_security_group.tf-k3s-sec-gr.id]
  tags = {
    Name = "${local.name}-k3s-agent"
    Description = "k3s agent"
  }
}

resource "local_file" "ansible-inventory" {
   filename        = "${path.module}/ansible/inventory.ini"
   file_permission = "0640"
   content         = templatefile("${path.module}/ansible/template.inventory.ini",
    {
      k3s-server-public-ip = aws_instance.server.public_ip,
      k3s-agent-public-ip = aws_instance.agent.public_ip,
    })
}

resource "random_password" "k3s-token" {
  length  = 30
  special = true
}

resource "aws_ssm_parameter" "k3s-token" {
  description = "k3s token to secure the node join process"
  name        = "/${local.name}/K3S-TOKEN"
  type        = "String"
  value       = random_password.k3s-token.result
}

resource "local_file" "k3-server-config-file" {
   filename        = "${path.module}/ansible/server.config.yaml"
   file_permission = "0640"
   content         = templatefile("${path.module}/ansible/template.server.config.yaml", {})
}

resource "local_file" "k3-agent-config-file" {
   filename        = "${path.module}/ansible/agent.config.yaml"
   file_permission = "0640"
   content         = templatefile("${path.module}/ansible/template.agent.config.yaml",
    {
      k3s-server-private-ip = aws_instance.server.private_ip,
      k3s-token = random_password.k3s-token.result
    }
  )
}
