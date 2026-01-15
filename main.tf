# ============================================================================
# VPC Module - Main Terraform Configuration
# ============================================================================
# This module creates a complete VPC infrastructure including:
# - VPC with customizable CIDR block
# - Multiple subnets across different availability zones
# - Internet Gateway for public subnet connectivity
# - Route tables and associations for public subnets
# ============================================================================

# ============================================================================
# VPC Resource
# ============================================================================
# Creates the main Virtual Private Cloud (VPC) with the specified CIDR block
# CIDR block defines the IP address range for all resources in this VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_config.cidr_block  # VPC CIDR block from input variable
  tags = {
    Name = var.vpc_config.name             # Tag the VPC with a friendly name
  }
}

# ============================================================================
# Subnets Resource (Dynamic Creation)
# ============================================================================
# Creates multiple subnets using for_each
# Each subnet has:
# - Unique CIDR block for IP allocation
# - Specific availability zone for redundancy
# - Name tag combining VPC name and subnet key
resource "aws_subnet" "main" {
  for_each = var.subnet_config              # Iterate through subnet_config map
  
  vpc_id            = aws_vpc.main.id       # Associate with the VPC created above
  cidr_block        = each.value.cidr_block # Subnet CIDR from config
  availability_zone = each.value.az         # Availability zone for this subnet

  tags = {
    Name = "${var.vpc_config.name}-subnet-${each.key}"  # Generate descriptive name
  }
}

# ============================================================================
# Local Variables - Subnet Classification
# ============================================================================
# Separates subnets into public and private based on the 'public' flag
# Used to determine which subnets need internet access
locals {
  # Public subnets: filter subnets where public=true
  public_subnet = {
    for key, config in var.subnet_config: key => config if config.public
  }
  
  # Private subnets: filter subnets where public=false (or not set)
  private_subnet = {
    for key, config in var.subnet_config: key => config if !config.public
  }
}

# ============================================================================
# Internet Gateway Resource (Conditional)
# ============================================================================
# Creates an Internet Gateway if there is at least one public subnet
# IGW is required for public subnets to communicate with the internet
# count is used to conditionally create this resource:
# - count = 1 if public subnets exist (length > 0)
# - count = 0 if no public subnets (don't create)
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id  # Associate IGW with the VPC
    count  = length(local.public_subnet) > 0 ? 1 : 0  # Conditional creation
}

# ============================================================================
# Route Table for Public Subnets (Conditional)
# ============================================================================
# Creates a route table for public subnets with internet route
# This route table directs all outbound traffic (0.0.0.0/0) to the IGW
# Conditional creation: only created if public subnets exist
resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id  # Associate with VPC
    count  = length(local.public_subnet) > 0 ? 1 : 0  # Conditional creation
    
    # Route: Send all external traffic to Internet Gateway
    route {
        cidr_block      = "0.0.0.0/0"                      # All external traffic
        gateway_id      = aws_internet_gateway.main[0].id  # Direct to IGW
    }

    tags = {
      Name = "${var.vpc_config.name}-public-rt"  # Descriptive name for the route table
    }
}

# ============================================================================
# Route Table Association (Dynamic)
# ============================================================================
# Associates the public route table with each public subnet
# This enables internet access for resources in public subnets
# for_each iterates through all public subnets and creates associations
resource "aws_route_table_association" "main" {
    for_each = local.public_subnet  # Only for public subnets

    subnet_id      = aws_subnet.main[each.key].id    # Reference the specific subnet
    route_table_id = aws_route_table.main[0].id      # Reference the public route table
}