variable "project_name" {
  description = "terraform-vpc-project."
  type        = string
  default     = "hands-on"
}
variable "environment" {
  description = "The deployment environment."
  type        = string
  default     = "dev"
}
variable "aws_region" {
  description = "The AWS region to deploy into."
  type        = string
  default     = "us-east-1"
}