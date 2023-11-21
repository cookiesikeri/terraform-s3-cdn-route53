# S3 bucket for website.
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "bucket-acl" {
  depends_on = [
    aws_s3_bucket_public_access_block.bucket-public-access-block,
    aws_s3_bucket_ownership_controls.bucket-ownership-controls,
  ]
  bucket = aws_s3_bucket.bucket.bucket
  acl    = "public-read"  # Access control for the bucket (e.g., private, public-read, etc.)
}

resource "aws_s3_bucket_public_access_block" "bucket-public-access-block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "bucket-ownership-controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.bucket.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_cors_configuration" "example" {
  bucket = aws_s3_bucket.bucket.bucket
  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST", "PUT", "DELETE"]
    allowed_origins = ["https://${var.domain_name}"]
    max_age_seconds = 3000
  }
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "AllowPublicRead",
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject", "s3:DeleteObject"], #types: s3:ListBucket,:s3:GetBucketLocation, s3:PutObjectAcl, s3:GetObjectAcl, s3:ListBucketMultipartUpload, s3:AbortMultipartUpload, s3:RestoreObject
      Resource  = "${aws_s3_bucket.bucket.arn}/*"
      
    }]
  })
}


resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }

}


