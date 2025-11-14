variable "aws_region" {
  description = "The AWS region to deploy infrastructure in."
  type        = string
  default     = "us-east-1"
}

variable "website_domain" {
  description = "The domain name for the S3 bucket and CloudFront CNAME."
  type        = string
  default     = "resume.chigoziennadi.com"
}

variable "table_name" {
  description = "The name of the DynamoDB table."
  type        = string
  default     = "cloud-resume-views"
}
