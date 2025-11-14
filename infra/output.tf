output "api_endpoint_url" {
  description = "The public URL for the API Gateway."
  value       = aws_apigatewayv2_api.api.api_endpoint
}

output "bucket_website_endpoint" {
  description = "The static website endpoint for the S3 bucket."
  value       = aws_s3_bucket_website_configuration.website_config.website_endpoint
}





output "cloudfront_domain_name" {
  description = "The domain name for the CloudFront distribution."
  value       = aws_cloudfront_distribution.cdn.domain_name
}
