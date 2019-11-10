provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# TODO
# rds
# elasticache
# security groups
# vpc (default)
# cloudfront

####################
# Elastic Beanstalk
####################

resource "aws_elastic_beanstalk_application" "ebcustom_app" {
  name        = "ebcustom"
  description = "ebcustom app managed by terraform"

  tags {
    Description = var.tf_description
  }
}

resource "aws_elastic_beanstalk_environment" "ebcustom_dev_app_env" {
  application         = aws_elastic_beanstalk_application.ebcustom_app
  name                = "dev"
  cname_prefix        = "dev"
  description         = "ebcustom app development environment"
  tier                = "WebServer"
  solution_stack_name = "Python 3.6 version 2.9.3"

  tags {
    Description = var.tf_description
  }
}

####################
# S3
####################

resource "aws_s3_bucket" "ebcustom_public_assets_bucket" {
  bucket = "ebcustom-public-assets"
  acl    = "public-read"

  tags {
    Description = var.tf_description
  }
}

