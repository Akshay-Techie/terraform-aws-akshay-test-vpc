# ============================================================================
# Terraform and Provider Version Requirements
# ============================================================================
# Specifies the required Terraform version and AWS provider version
# Ensures compatibility and prevents breaking changes from newer versions
# ============================================================================

terraform {
    # Require Terraform version 1.0.0 or later
    # Version 1.0.0+ introduced important features like variable validation
    required_version = ">= 1.0.0"

    # Configure required providers and their versions
    required_providers {
        aws = {
            source  = "hashicorp/aws"  # Official AWS provider from HashiCorp Registry
            version = ">6.27.0"         # Require AWS provider version 6.27.0 or higher
        }
    }
}