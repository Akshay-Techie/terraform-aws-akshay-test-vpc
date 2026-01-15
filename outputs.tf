# ============================================================================
# VPC Module - Output Values
# ============================================================================
# These outputs expose important information about the created VPC and subnets
# They can be consumed by the root module or other modules
# ============================================================================

# ============================================================================
# VPC ID Output
# ============================================================================
# Returns the ID of the created VPC for use in other resources
output "vpc_id" {
    value       = aws_vpc.main.id
    description = "The ID of the created VPC"
}

# ============================================================================
# Local Variables - Formatted Subnet Outputs
# ============================================================================
# Formats subnet information into structured maps containing:
# - subnet_id: The ID of the subnet
# - az: The availability zone of the subnet
# This format makes it easier to consume subnet information
locals {
  # Format public subnets into a map with subnet ID and availability zone
  # Example output: { subnet_name = { subnet_id = "subnet-xxx", az = "ap-south-1a" } }
  public_subnet_output = {
    for key, config in local.public_subnet: key => {
        subnet_id = aws_subnet.main[key].id                    # Subnet resource ID
        az        = aws_subnet.main[key].availability_zone     # Availability zone
    }
  }
  
  # Format private subnets into a map with subnet ID and availability zone
  # Example output: { subnet_name = { subnet_id = "subnet-yyy", az = "ap-south-1b" } }
  private_subnet_output = {
    for key, config in local.private_subnet: key => {
        subnet_id = aws_subnet.main[key].id                    # Subnet resource ID
        az        = aws_subnet.main[key].availability_zone     # Availability zone
    }
  }
}

# ============================================================================
# Public Subnets Output
# ============================================================================
# Returns map of all public subnets with their IDs and availability zones
# Format: { subnet_name = { subnet_id = "subnet-xxx", az = "ap-south-1a" } }
output "public_subnets" {
  value       = local.public_subnet_output
  description = "Map of public subnets with their IDs and availability zones"
}

# ============================================================================
# Private Subnets Output
# ============================================================================
# Returns map of all private subnets with their IDs and availability zones
# Format: { subnet_name = { subnet_id = "subnet-yyy", az = "ap-south-1b" } }
output "private_subnets" {
    value       = local.private_subnet_output
    description = "Map of private subnets with their IDs and availability zones"
}