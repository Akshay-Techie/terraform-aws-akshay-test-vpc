# ============================================================================
# VPC Module - Input Variables
# ============================================================================
# Defines the input variables required by the VPC module
# These variables are passed from the root module or terraform.tfvars
# ============================================================================

# ============================================================================
# VPC Configuration Variable
# ============================================================================
# Accepts VPC-level configuration including CIDR block and name
# Type: object with specific properties
# Example:
#   vpc_config = {
#     cidr_block = "10.0.0.0/16"
#     name       = "my-vpc"
#   }
variable "vpc_config" {
    description = "VPC configuration containing CIDR block and name"
    type = object({
        cidr_block = string  # Valid CIDR notation (e.g., 10.0.0.0/16)
        name       = string  # Name for the VPC resource
    })
    
    # Validation: Ensures the CIDR block is in valid format
    # Uses Terraform's cidrnetmask() function to validate CIDR
    validation {
      condition     = can(cidrnetmask(var.vpc_config.cidr_block))
      error_message = "Invalid CIDR Format - ${var.vpc_config.cidr_block}. Please provide a valid CIDR block (e.g., 10.0.0.0/16)."
    }
}

# ============================================================================
# Subnet Configuration Variable
# ============================================================================
# Map of subnets with their individual configurations
# Type: map of objects with CIDR block, AZ, and public flag
# Example:
#   subnet_config = {
#     public_subnet_1 = {
#       cidr_block = "10.0.1.0/24"
#       az         = "ap-south-1a"
#       public     = true
#     }
#     private_subnet = {
#       cidr_block = "10.0.0.0/24"
#       az         = "ap-south-1b"
#       public     = false  # or omitted (defaults to false)
#     }
#   }
variable "subnet_config" {
    description = "Map of subnets with CIDR block, availability zone, and public flag"
    type = map(object({
        cidr_block = string              # Subnet CIDR block (e.g., 10.0.1.0/24)
        az         = string              # AWS Availability Zone (e.g., ap-south-1a)
        public     = optional(bool, false)  # Whether subnet is public (optional, defaults to false)
    }))
    
    # Validation: Ensures all subnet CIDR blocks are in valid format
    # Checks all subnets in the map for valid CIDR notation
    validation {
      condition     = alltrue([for config in var.subnet_config : can(cidrnetmask(config.cidr_block))])
      error_message = "Invalid CIDR Format. Please provide valid CIDR blocks for all subnets (e.g., 10.0.1.0/24)."
    }
}