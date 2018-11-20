resource "aws_cloudfront_distribution" "releases" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"
  aliases         = ["releases.nixos.org"]

  origin {
    origin_id   = "default"
    domain_name = "nix-releases.s3.amazonaws.com"

    s3_origin_config {
      origin_access_identity = ""

      #origin_access_identity = "${aws_cloudfront_origin_access_identity.releases.cloudfront_access_identity_path}"
    }
  }

  default_cache_behavior {
    allowed_methods        = ["HEAD", "GET"]
    cached_methods         = ["HEAD", "GET"]
    target_origin_id       = "default"
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    acm_certificate_arn            = "${aws_acm_certificate.releases.arn}"
    ssl_support_method             = "sni-only"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  logging_config {
    bucket = "nix-cache-logs.s3.amazonaws.com"
  }
}

resource "aws_acm_certificate" "releases" {
  provider          = "aws.us"
  domain_name       = "releases.nixos.org"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

/*
resource "aws_cloudfront_origin_access_identity" "releases" {
  comment = "Cloudfront identity for releases"
}
*/

