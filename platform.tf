provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
  common_tags = {
    Description = var.tf_description
  }
}

# TODO
# security groups
# vpc (default)

####################
# Elastic Beanstalk
####################

resource "aws_elastic_beanstalk_application" "ebcustom_app" {
  name        = "ebcustom"
  description = "ebcustom app managed by terraform"
  tags        = local.common_tags
}

resource "aws_elastic_beanstalk_environment" "ebcustom_dev_app_env" {
  application         = aws_elastic_beanstalk_application.ebcustom_app.name
  name                = "dev"
  cname_prefix        = "dev"
  description         = "ebcustom app development environment"
  tier                = "WebServer"
  solution_stack_name = "Python 3.6 version 2.9.3"
  tags                = local.common_tags
}

####################
# S3
####################

resource "aws_s3_bucket" "ebcustom_public_assets_bucket" {
  bucket = "ebcustom-public-assets"
  acl    = "public-read"
  tags   = local.common_tags
}


####################
# CloudFront
####################

resource "aws_cloudfront_distribution" "ebcustom_cloudfront_distribution" {
  comment         = "ebcustom public assets cloudfront distribution"
  enabled         = false
  is_ipv6_enabled = true
  default_cache_behavior {
    allowed_methods        = [
      "HEAD",
      "GET"
    ]
    cached_methods         = [
      "HEAD",
      "GET"
    ]
    compress               = true
    target_origin_id       = "S3-octo-waffle/ebcustom"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  origin {
    domain_name = "public.hankehly.xyz"
    origin_id   = "S3-octo-waffle/ebcustom"
  }
  price_class     = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.ebcustom_acm_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
  tags            = local.common_tags
}

####################
# ElastiCache
####################

resource "aws_elasticache_cluster" "ebcustom_elasticache_cluster" {
  cluster_id      = "ebcustom-redis-cluster"
  engine          = "redis"
  engine_version  = "5.0.5"
  num_cache_nodes = 1
  port            = 6379
  tags            = local.common_tags
}

####################
# RDS
####################

resource "aws_db_instance" "ebcustom_db_instance" {
  allocated_storage          = 20
  auto_minor_version_upgrade = true
  instance_class             = "db.t2.micro"
  # try aurora with 1 writer and multiple readers
  engine                     = "postgres"
  engine_version             = "11.5"
  # because this is just for dev/test
  skip_final_snapshot        = false
  identifier                 = "ebcustom-1"
  name                       = "ebcustom"
  # maybe prompt the user at runtime
  username                   = "ebcustom"
  password                   = "ebcustom"
  port                       = 5432
  publicly_accessible        = false
  storage_type               = "gp2"
  tags                       = local.common_tags
}

####################
# ACM
####################

resource "aws_acm_certificate" "ebcustom_acm_certificate" {
  domain_name               = "hankehly.xyz"
  validation_method         = "DNS"
  subject_alternative_names = [
    "hankehly.xyz",
    "*.hankehly.xyz"
  ]
  tags                      = local.common_tags
}

resource "aws_acm_certificate_validation" "ebcustom_acm_certificate_validation" {
  certificate_arn         = aws_acm_certificate.ebcustom_acm_certificate.arn
  validation_record_fqdns = [
    aws_route53_record.ebcustom_acm_certificate_validation.fqdn
  ]
}


####################
# Route53
####################

# NS and SOA records are created automatically
resource "aws_route53_zone" "ebcustom_route53_zone" {
  name    = "hankehly.xyz."
  comment = "ebcustom app domain name"
  tags    = local.common_tags
}

resource "aws_route53_record" "ebcustom_acm_certificate_validation" {
  name    = aws_acm_certificate.ebcustom_acm_certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.ebcustom_acm_certificate.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.ebcustom_route53_zone.zone_id
  records = [
    aws_acm_certificate.ebcustom_acm_certificate.domain_validation_options.0.resource_record_value
  ]
}

resource "aws_route53_record" "public" {
  name    = "public.hankehly.xyz"
  type    = "A"
  zone_id = aws_route53_zone.ebcustom_route53_zone.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.ebcustom_cloudfront_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.ebcustom_cloudfront_distribution.hosted_zone_id
  }
}
