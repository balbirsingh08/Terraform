# Variables for AWS configuration
variable "aws_region" {
  description = "AWS region to create resources"
  type        = string
  default     = "us-east-1"
}

# Example of how you would handle sensitive variables
# variable "aws_access_key" {
#   description = "AWS access key"
#   type        = string
#   sensitive   = true
# }

# variable "aws_secret_key" {
#   description = "AWS secret key"
#   type        = string
#   sensitive   = true
# }