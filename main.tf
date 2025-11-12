# 1. Configure the AWS provider
provider "aws" {
  region = "us-east-1" # Or your preferred region
}

# 2. Define the S3 bucket for your website
resource "aws_s3_bucket" "website_bucket" {
  # This bucket name must be globally unique.
  # Using resume.chigoziennadi.com is a good choice.
  bucket = "resume.chigoziennadi.com"
}

# 3. Configure the bucket for static website hosting
resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

# 4. Define the public access block
# This allows public access *after* we apply a policy.
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 5. Define the bucket policy (this is what makes it public)
# We use a special Terraform data source to build the policy JSON.
data "aws_iam_policy_document" "public_policy_doc" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

# 6. Apply the public policy to the bucket
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.public_policy_doc.json

  # This depends_on block tells Terraform to create the
  # public access block *before* trying to apply the policy.
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}
