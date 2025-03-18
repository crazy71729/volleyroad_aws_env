resource "aws_route53_record" "cloudfront_record" {
  zone_id = "Z03547012EKVOXNXV4WB4"  # 修改成你的host zone id
  name    = "test-us.volleyroad.com" # 修改成憑證網域
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.website_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

# Data resource for Route 53 Hosted Zone
data "aws_route53_zone" "main" {
  name = "volleyroad.com."  # Replace with your domain
}