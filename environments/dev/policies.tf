
resource "aws_iam_instance_profile" "k3s" {
  name = "${local.name}-k3s-profile"
  role = aws_iam_role.k3s-ec2-role.name
}

resource "aws_iam_role" "k3s-ec2-role" {
  name = "${local.name}-k3s-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "k3s-ec2-policy"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect": "Allow",
          "Action": [
              "ssm:GetParameter",
              "ssm:GetParameters",
              "ssm:GetParametersByPath"
          ],
          "Resource": "arn:aws:ssm:us-east-1:493101195870:parameter/${local.name}/*"
        }
      ]
    })
  }
}
