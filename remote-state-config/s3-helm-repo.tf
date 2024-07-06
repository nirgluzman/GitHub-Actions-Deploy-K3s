resource "aws_s3_bucket" "helm-charts-repo" {
  bucket = "nioyatech-helm-repo"

  force_destroy = true # normally it must be false. because if we delete s3 mistakenly, we lost all of the states.

  tags = {
    Name = "Helm Charts Repository"
  }
}
