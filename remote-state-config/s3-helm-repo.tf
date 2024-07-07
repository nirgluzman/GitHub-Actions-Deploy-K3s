# Helm chart repository in Amazon S3
resource "aws_s3_bucket" "helm-charts-repo" {
  bucket = "nioyatech-helm-repo"

  force_destroy = true # normally it must be false. because if we delete s3 mistakenly, we lost all of the states.

  tags = {
    Name = "Helm Charts Repository"
  }
}

# upload an empty Helm index.yaml file
resource "aws_s3_object" "chart-index" {
  bucket = "${aws_s3_bucket.helm-charts-repo.bucket}"
  key    = "charts/index.yaml" # name of the object once it is in the bucket
  source = "./index.yaml" # path to a file that will be read and uploaded

}
