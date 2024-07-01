# declarations of variables

variable "aws_region" {
  description = "deployment region"
  type        = string
}

variable "ec2_type" {
  description = "ec2 instance type"
  type        = string
}

variable "ec2_keyname" {
  description = "SSH key pair name to be stored on AWS"
  type        = string
}

variable "allowed_ports" {
  description = "allowed TCP ports e.g. [22, 80, 443]"
  type        = list(number)
}
