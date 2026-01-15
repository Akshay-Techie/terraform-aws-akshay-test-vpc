# ============================================================================
# Root Terraform Configuration - VPC Module Consumer
# ============================================================================
# This is the root module that consumes the custom VPC module
# It defines the AWS provider and configures the VPC with subnets
# ============================================================================

# Configure AWS Provider for the ap-south-1 (Mumbai) region
provider "aws" {
  region = "ap-south-1"
}

# ============================================================================
# VPC Module Configuration
# ============================================================================
# Calls the custom VPC module with specific configuration for:
# - VPC with CIDR block 10.0.0.0/16
# - 2 public subnets for internet-facing resources
# - 1 private subnet for internal resources
# ============================================================================
module "vpc" {
    # Source points to the local VPC module
    source = "./module/vpc"
    
    # VPC configuration: CIDR block and name
    vpc_config = {
        cidr_block = "10.0.0.0/16"  # VPC CIDR range (256 addresses)
        name       = "my-test-vpc"  # VPC resource name tag
    }
    
    # Subnet configuration for multiple subnets
    subnet_config = {
        # First public subnet - ap-south-1a
        public_subnet_1  = {
            cidr_block = "10.0.1.0/24"  # 256 addresses for public resources
            az         = "ap-south-1a"  # Availability zone
            public     = true             # Marked as public (will have IGW route)
        }

        # Second public subnet - ap-south-1a
        public_subnet_2  = {
            cidr_block = "10.0.2.0/24"  # 256 addresses for public resources
            az         = "ap-south-1a"  # Availability zone
            public     = true             # Marked as public (will have IGW route)
        }

        # Private subnet - ap-south-1b
        private_subnet = {
            cidr_block = "10.0.0.0/24"  # 256 addresses for private resources
            az         = "ap-south-1b"  # Different AZ for redundancy
            # public field defaults to false (optional parameter)
        }
    }
}