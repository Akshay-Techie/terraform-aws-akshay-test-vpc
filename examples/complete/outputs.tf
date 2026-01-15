# ============================================================================
# Root Module Outputs
# ============================================================================
# These outputs expose important VPC and subnet information from the module
# They can be referenced by other modules or displayed to the user
# ============================================================================

# Output: VPC ID
# Returns the ID of the created VPC for use in other resources
output "vpc" {
  value       = module.vpc.vpc_id
  description = "The ID of the created VPC"
}

# Output: Public Subnets
# Returns details of all public subnets including subnet IDs and availability zones
output "public_subnet" {
  value       = module.vpc.public_subnets
  description = "Map of public subnets with their IDs and availability zones"
}

# Output: Private Subnets
# Returns details of all private subnets including subnet IDs and availability zones
output "private_subnet" {
  value       = module.vpc.private_subnets
  description = "Map of private subnets with their IDs and availability zones"
}