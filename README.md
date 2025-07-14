
# AWS VPC Terraform Module

A production-grade, multi-AZ VPC module for AWS built with Terraform. This module creates a secure, scalable network foundation suitable for enterprise workloads, ML/AI infrastructure, and cloud-native applications.

![Terraform Version](https://img.shields.io/badge/Terraform-%3E%3D1.0-purple?logo=terraform)

## 🏗️ Architecture

This module creates:
- **1 VPC** with customizable CIDR block
- **2+ Public Subnets** across multiple AZs (for load balancers, NAT gateways)
- **2+ Private Subnets** across multiple AZs (for applications, databases)
- **1 Internet Gateway** for public subnet internet access
- **1 NAT Gateway** with Elastic IP for secure private subnet egress
- **Route Tables** with proper associations and routing rules

## 📋 Prerequisites

- Terraform >= 1.0
- AWS Provider >= 5.0
- AWS credentials configured
- S3 bucket for remote state (optional but recommended)
- Configure the Terraform backend in main.tf with your own S3 bucket and DynamoDB table (the provided values are placeholders and must be replaced).

## 🚀 Quick Start

```hcl
module "vpc" {
  source = "./modules/vpc"

  project_name         = "my-app"
  environment          = "prod"
  aws_region           = "us-east-1"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.4.0/24"]
}
```

## 📊 Module Inputs

| Variable | Description | Type | Default | Required |
|----------|-------------|------|---------|----------|
| `project_name` | Name of the project for resource naming | `string` | `"hands-on"` | no |
| `environment` | Deployment environment (dev/staging/prod) | `string` | `"dev"` | no |
| `aws_region` | AWS region to deploy resources | `string` | `"us-east-1"` | no |
| `availability_zones` | List of AZs to distribute subnets | `list(string)` | `["us-east-1a", "us-east-1b"]` | no |
| `vpc_cidr` | CIDR block for the VPC | `string` | `"10.0.0.0/16"` | no |
| `public_subnet_cidrs` | CIDR blocks for public subnets | `list(string)` | `["10.0.1.0/24", "10.0.3.0/24"]` | no |
| `private_subnet_cidrs` | CIDR blocks for private subnets | `list(string)` | `["10.0.2.0/24", "10.0.4.0/24"]` | no |
| `map_public_ip` | Whether to auto-assign public IPs to instances in public subnets | `bool` | `false` | no |

## 📤 Module Outputs

| Output | Description | Type |
|--------|-------------|------|
| `vpc_id` | The ID of the created VPC | `string` |
| `vpc_cidr` | The CIDR block of the VPC | `string` |
| `availability_zones` | List of availability zones used | `list(string)` |
| `public_subnet_ids` | List of public subnet IDs | `list(string)` |
| `private_subnet_ids` | List of private subnet IDs | `list(string)` |
| `internet_gateway_id` | ID of the Internet Gateway | `string` |
| `nat_gateway_id` | ID of the NAT Gateway | `string` |
| `nat_gateway_public_ip` | Public IP of the NAT Gateway | `string` |
| `public_route_table_id` | ID of the public route table | `string` |
| `private_route_table_id` | ID of the private route table | `string` |

## 🔧 Examples

### Basic Usage
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name = "webapp"
  environment  = "dev"
}
```

### Production Configuration
```hcl
module "vpc" {
  source = "./modules/vpc"
  
  project_name         = "ml-platform"
  environment          = "prod"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  vpc_cidr            = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.12.0/24", "10.100.13.0/24"]
}
```

## 🏛️ Architecture Decisions

1. **Single NAT Gateway**: Cost-optimized for non-production. For HA, deploy one NAT per AZ.
2. **CIDR Planning**: Default uses /24 subnets supporting 251 hosts each.
3. **Public Subnet Usage**: Reserved for load balancers and NAT gateways only.
4. **Private Subnet Usage**: All application workloads should deploy here.

## 🔒 Security Considerations

- All private subnets route through NAT Gateway (no direct internet access)
- Public subnets auto-assign public IPs (disable for production)
- Network ACLs use AWS defaults (stateless rules)
- Security groups should be defined at the application layer

## 💰 Cost Optimization

- NAT Gateway: ~$45/month + data transfer costs
- Consider VPC endpoints for S3/DynamoDB to reduce NAT costs
- Use single NAT for dev/test environments
- Monitor VPC Flow Logs costs if enabled

## 🧪 Testing

```bash
# Format code
terraform fmt -recursive

# Validate syntax
terraform validate

# Plan deployment
terraform plan

# Deploy
terraform apply
```

## 📝 License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 👥 Authors

- Aejaz Quaraishi - DevOps - https://github.com/asq-sheriff

---
