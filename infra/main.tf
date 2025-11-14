# --- S3 WEBSITE FRONTEND ---
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.website_domain
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id
  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

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

resource "aws_s3_bucket_policy" "public_policy" {
  bucket     = aws_s3_bucket.website_bucket.id
  policy     = data.aws_iam_policy_document.public_policy_doc.json
  depends_on = [aws_s3_bucket_public_access_block.public_access]
}

# --- DYNAMODB DATABASE ---
resource "aws_dynamodb_table" "view_counter_table" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "page_id"

  attribute {
    name = "page_id"
    type = "S" # S = String
  }
}

# --- IAM ROLE & POLICY FOR LAMBDA ---
data "aws_iam_policy_document" "lambda_policy_doc" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:UpdateItem", "dynamodb:GetItem"]
    resources = [aws_dynamodb_table.view_counter_table.arn]
  }
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "CloudResumeLambdaRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "CloudResumeLambdaPolicy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

# --- LAMBDA FUNCTION ---
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda/lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "view_counter_lambda" {
  function_name = "updateVisitorCount"
  role          = aws_iam_role.lambda_role.arn

  filename         = data.archive_file.lambda_zip.output_path
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.12"
}

# --- API GATEWAY (HTTP API) ---
resource "aws_apigatewayv2_api" "api" {
  name          = "cloud-resume-api"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET"]
    allow_headers = ["*"]
  }
}

resource "aws_apigatewayv2_integration" "api_lambda_integration" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = aws_lambda_function.view_counter_lambda.invoke_arn
}

resource "aws_apigatewayv2_route" "api_get_views" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /views"
  target    = "integrations/${aws_apigatewayv2_integration.api_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "api_stage" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "api_gateway_permission" {
  statement_id  = "AllowAPIGatewayToInvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.view_counter_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

# --- ACM SSL CERTIFICATE ---
data "aws_acm_certificate" "existing_cert" {
  provider = aws.us_east_1_provider
  domain   = var.website_domain
  statuses = ["ISSUED"]
}

provider "aws" {
  alias  = "us_east_1_provider"
  region = "us-east-1"
}

# --- CLOUDFRONT DISTRIBUTION ---
resource "aws_cloudfront_distribution" "cdn" {
  origin {
    domain_name = aws_s3_bucket_website_configuration.website_config.website_endpoint
    origin_id   = "S3-${var.website_domain}"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = "CDN for ${var.website_domain}"

  aliases = [var.website_domain]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${var.website_domain}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.existing_cert.arn
    ssl_support_method  = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
