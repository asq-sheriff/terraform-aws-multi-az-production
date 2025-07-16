variable "project_name" {
  description = "The name of the project."
  type        = string
  default     = "hands-on"

  validation {
    condition     = length(var.project_name) > 0
    error_message = "Project name must be a non-empty string."
  }
}

variable "environment" {
  description = "The deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "test"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, test."
  }
}

variable "aws_region" {
  description = "The AWS region to deploy into."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = length(var.aws_region) > 0 && can(regex("^[a-z][a-z]-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be a valid region format (e.g., us-east-1)."
  }
}

variable "map_public_ip" {
  description = "Whether to auto-assign public IPs to instances in public subnets."
  type        = bool
  default     = false
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs"
  type        = bool
  default     = false
}

variable "enable_nacls" {
  description = "Enable custom Network ACLs"
  type        = bool
  default     = false
}

variable "availability_zones" {
  description = "The availability zones to use."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]

  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "At least one availability zone must be specified."
  }
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "The CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.3.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "Number of public subnet CIDRs must match the number of availability zones."
  }

  validation {
    condition     = length(var.public_subnet_cidrs) > 0 && length([for c in var.public_subnet_cidrs : c if can(cidrhost(c, 0))]) == length(var.public_subnet_cidrs)
    error_message = "All public subnet CIDRs must be valid IPv4 CIDR blocks."
  }

  # Approximate subset check - assumes /24 subnets from /16 VPC
  validation {
    condition     = length(var.public_subnet_cidrs) > 0 && length([for c in var.public_subnet_cidrs : c if cidrsubnet(var.vpc_cidr, 8, index(var.public_subnet_cidrs, c)) == c]) == length(var.public_subnet_cidrs)
    error_message = "All public subnet CIDRs must be subsets of the VPC CIDR."
  }
}

variable "private_subnet_cidrs" {
  description = "The CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.2.0/24", "10.0.4.0/24"]

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "Number of private subnet CIDRs must match the number of availability zones."
  }

  validation {
    condition     = length(var.private_subnet_cidrs) > 0 && length([for c in var.private_subnet_cidrs : c if can(cidrhost(c, 0))]) == length(var.private_subnet_cidrs)
    error_message = "All private subnet CIDRs must be valid IPv4 CIDR blocks."
  }

  # Approximate subset check - assumes /24 subnets from /16 VPC
  validation {
    condition     = length(var.private_subnet_cidrs) > 0 && length([for c in var.private_subnet_cidrs : c if cidrsubnet(var.vpc_cidr, 8, index(var.private_subnet_cidrs, c)) == c]) == length(var.private_subnet_cidrs)
    error_message = "All private subnet CIDRs must be subsets of the VPC CIDR."
  }
}
