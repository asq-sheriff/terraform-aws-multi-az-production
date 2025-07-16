provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Module      = "terraform-aws-multi-az-production"
    CreatedAt   = timestamp()
  }
}

# Create the main VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-vpc-${var.environment}" }
  )
}

# Create the Public Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = var.map_public_ip

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-public-subnet-${var.availability_zones[count.index]}" }
  )
}

# Create the Private Subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-private-subnet-${var.availability_zones[count.index]}" }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-igw-${var.environment}" }
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-public-rt-${var.environment}" }
  )
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id

  # Associations don't support tags, so skip
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-eip-nat-${var.environment}" }
  )
}

# Create the NAT Gateway
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-nat-gw-${var.environment}" }
  )

  depends_on = [aws_internet_gateway.main]
}

# Create a route table for the private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-private-rt-${var.environment}" }
  )
}

# Associate the private route table with the private subnets
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id

  # Associations don't support tags
}

# Optional VPC Flow Logs
resource "aws_flow_log" "main" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = aws_iam_role.flow_log[0].arn
  log_destination = aws_cloudwatch_log_group.flow_log[0].arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.main.id

  tags = local.common_tags
}

# Supporting resources for Flow Logs
resource "aws_cloudwatch_log_group" "flow_log" {
  count             = var.enable_flow_logs ? 1 : 0
  name              = "${var.project_name}-vpc-flow-logs"
  retention_in_days = 14

  tags = local.common_tags
}

resource "aws_iam_role" "flow_log" {
  count = var.enable_flow_logs ? 1 : 0
  name  = "${var.project_name}-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "vpc-flow-logs.amazonaws.com" }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "flow_log" {
  count      = var.enable_flow_logs ? 1 : 0
  role       = aws_iam_role.flow_log[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonVPCFlowLogsIamRolePolicy"

  # Attachments don't support tags
}

# Optional NACLs (basic example: allow all, but customize rules)
resource "aws_network_acl" "public" {
  count      = var.enable_nacls ? length(var.public_subnet_cidrs) : 0
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.public[count.index].id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-public-nacl-${var.availability_zones[count.index]}" }
  )
}

resource "aws_network_acl" "private" {
  count      = var.enable_nacls ? length(var.private_subnet_cidrs) : 0
  vpc_id     = aws_vpc.main.id
  subnet_ids = [aws_subnet.private[count.index].id]

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-private-nacl-${var.availability_zones[count.index]}" }
  )
}