resource "aws_s3_bucket" "static_site" {
  bucket = var.bucket_name
}

#resource "aws_s3_bucket_website_configuration" "static_website_config" {
#    bucket = aws_s3_bucket.static_site.id
#
#    index_document {
#      suffix = "index.html"
#    }
#  
#}

resource "aws_s3_bucket_public_access_block" "static_site_access" {
    bucket = aws_s3_bucket.static_site.id
    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
  
}


#resource "aws_s3_bucket_policy" "static_site_policy" {
#    bucket = aws_s3_bucket.static_site.id
#
#policy = jsonencode({
#    Version = "2012-10-17"
#    Statement = [
#        {
#            Effect= "Allow"
#            Principal = "*"
#            Action = "s3:GetObject"
#            Resource = "${aws_s3_bucket.static_site.arn}/*"
#        }
#    ]
#})
#
#depends_on = [ aws_s3_bucket_public_access_block.static_site_access ]
#}
 
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "oac-${aws_s3_bucket.static_site.bucket}"
  description                       = "OAC for ${aws_s3_bucket.static_site.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.static_site.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = "S3-${aws_s3_bucket.static_site.bucket}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront Distro for ${aws_s3_bucket.static_site.bucket}"
  default_root_object = "index.html"

  aliases = ["web.aws.sercodit.com", "www.web.sercodit.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.static_site.bucket}"

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
  
  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-2:849267108111:certificate/672008f6-7d21-4dc7-9258-c39d5580a0a4"
  }
} 