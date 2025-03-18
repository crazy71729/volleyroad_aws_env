# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "example_oai" {
  comment = "OAI for accessing S3 bucket"
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "website_distribution" {
  origin {
    domain_name = "my-terraform-website1.s3.ap-northeast-1.amazonaws.com" # 修改成bucket domain name ,不是end point
    origin_id   = "S3-my-terraform-website1" # 修改成bucket name

    s3_origin_config {
      origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.example_oai.id}"
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront Distribution for my-terraform-website1"
  default_root_object = "index.html"

  aliases = ["test-us.volleyroad.com"] # Set Alternate Domain Name (CNAME)

  default_cache_behavior {
    target_origin_id = "S3-my-terraform-website1" # 修改成bucket name
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]  # Use list format for allowed methods
    cached_methods  = ["GET", "HEAD"]  # Use list format for cached methods

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:842675981499:certificate/431b7d4d-0ffc-4131-b804-dac10af432e3" # 修改成憑證id
    ssl_support_method  = "sni-only"
  }
}
