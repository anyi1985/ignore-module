resource "aws_s3_bucket" "globalteck-s3-bucket" {
  count         = var.count_bucket
  bucket_prefix = var.website_name

  tags = {
    Name        = "anyi-globalteck-test-bucket"
    Environment = "Dev"
  }
}