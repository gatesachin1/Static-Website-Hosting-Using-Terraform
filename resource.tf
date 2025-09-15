terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# -------------------
# S3 bucket
# -------------------
resource "aws_s3_bucket" "bucket1" {
  bucket = "web-bucket-sachin-deployment-s3"
}

# -------------------
# Allow public access (disable blocks)
# -------------------
resource "aws_s3_bucket_public_access_block" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# -------------------
# Upload static files
# -------------------
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.bucket1.bucket
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"

  depends_on = [aws_s3_bucket.bucket1]
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.bucket1.bucket
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"

  depends_on = [aws_s3_bucket.bucket1]
}

# -------------------
# Website configuration
# -------------------
resource "aws_s3_bucket_website_configuration" "bucket1" {
  bucket = aws_s3_bucket.bucket1.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# -------------------
# Public read bucket policy
# -------------------
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket     = aws_s3_bucket.bucket1.id
  depends_on = [aws_s3_bucket_public_access_block.bucket1]

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": [ "s3:GetObject" ],
      "Resource": "${aws_s3_bucket.bucket1.arn}/*"
    }
  ]
}
EOF
}

# -------------------
# Output Website Endpoint
# -------------------
output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.bucket1.website_endpoint
}
