# Terraform configuration for an AWS S3 bucket with basic configuration
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # This would be configured in your CI/CD pipeline
    # bucket = "your-terraform-state-bucket"
    # key    = "terraform.tfstate"
    # region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
  
  # In production, use AWS credentials from environment variables or IAM roles
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}

# Create a secure S3 bucket for static website hosting
resource "aws_s3_bucket" "portfolio_bucket" {
  bucket = "my-portfolio-bucket-${random_id.bucket_suffix.hex}"
  
  tags = {
    Name        = "Portfolio Website"
    Environment = "Demo"
    Project     = "GitHub Profile"
  }
}

# Configure bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "bucket_ownership" {
  bucket = aws_s3_bucket.portfolio_bucket.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configure public access block
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure bucket ACL
resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.bucket_ownership,
    aws_s3_bucket_public_access_block.public_access,
  ]

  bucket = aws_s3_bucket.portfolio_bucket.id
  acl    = "public-read"
}

# Enable static website hosting
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Bucket policy to allow public read access
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.portfolio_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.portfolio_bucket.arn}/*"
      }
    ]
  })
}

# Generate random suffix for bucket name
resource "random_id" "bucket_suffix" {
  byte_length = 8
}

# Output the website URL
output "website_url" {
  description = "URL of the S3 static website"
  value       = aws_s3_bucket_website_configuration.website.website_endpoint
}

# Output the bucket name
output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.portfolio_bucket.bucket
}