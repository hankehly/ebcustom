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
# VPC (default) ?
# Security Groups ?
# SQS

####################
# Elastic Beanstalk
####################

resource "aws_elastic_beanstalk_application" "app" {
  name        = "ebcustom"
  description = "ebcustom app managed by terraform"
  tags        = local.common_tags
}

resource "aws_elastic_beanstalk_environment" "web" {
  application         = aws_elastic_beanstalk_application.app.name
  name                = "dev-web"
  description         = "ebcustom app development web environment"
  tier                = "WebServer"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.3 running Python 3.6"
  tags                = local.common_tags
}

# worker environment cant have a cname prefix
resource "aws_elastic_beanstalk_environment" "worker" {
  application         = aws_elastic_beanstalk_application.app.name
  name                = "dev-worker"
  description         = "ebcustom app development worker environment"
  tier                = "Worker"
  solution_stack_name = "64bit Amazon Linux 2018.03 v2.9.3 running Python 3.6"
  tags                = local.common_tags
}

####################
# S3
####################

resource "aws_s3_bucket" "bucket" {
  bucket = "ebcustom-public-assets"
  acl    = "public-read"
  tags   = local.common_tags
}


####################
# CloudFront
####################

resource "aws_cloudfront_distribution" "assets" {
  aliases = [
    "public.hankehly.xyz"
  ]

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
    target_origin_id       = "S3-ebcustom-public-assets"
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = "S3-ebcustom-public-assets"
  }
  price_class     = "PriceClass_All"
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
  tags            = local.common_tags
}

####################
# ElastiCache
####################

resource "aws_elasticache_cluster" "redis" {
  cluster_id      = "ebcustom-redis-cluster"
  engine          = "redis"
  engine_version  = "5.0.5"
  node_type       = "cache.t2.micro"
  num_cache_nodes = 1
  port            = 6379
  tags            = local.common_tags
}

####################
# RDS
####################

resource "aws_db_instance" "db" {
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

resource "aws_acm_certificate" "cert" {
  domain_name               = "hankehly.xyz"
  validation_method         = "DNS"
  subject_alternative_names = [
    "hankehly.xyz",
    "*.hankehly.xyz"
  ]
  tags                      = local.common_tags
}

resource "aws_acm_certificate_validation" "cert_validation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [
    aws_route53_record.cert_validation.fqdn
  ]
}


####################
# Route53
####################

# NS and SOA records are created automatically
resource "aws_route53_zone" "primary" {
  name    = "hankehly.xyz."
  comment = "ebcustom app domain name"
  tags    = local.common_tags
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.cert.domain_validation_options.0.resource_record_type
  zone_id = aws_route53_zone.primary.zone_id
  ttl     = 300
  records = [
    aws_acm_certificate.cert.domain_validation_options.0.resource_record_value
  ]
}

resource "aws_route53_record" "public" {
  name    = "public.hankehly.xyz"
  type    = "A"
  zone_id = aws_route53_zone.primary.zone_id
  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.assets.domain_name
    zone_id                = aws_cloudfront_distribution.assets.hosted_zone_id
  }
}
