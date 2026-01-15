## Usage

### Basic Module Consumption

```hcl
# main.tf - Root module using the VPC module

provider "aws" {
  region = "ap-south-1"
}

module "vpc" {
  source = "./module/vpc"
  
  vpc_config = {
    cidr_block = "10.0.0.0/16"
    name       = "my-test-vpc"
  }
  
  subnet_config = {
    public_subnet_1 = {
      cidr_block = "10.0.1.0/24"
      az         = "ap-south-1a"
      public     = true
    }
    
    public_subnet_2 = {
      cidr_block = "10.0.2.0/24"
      az         = "ap-south-1a"
      public     = true
    }
    
    private_subnet = {
      cidr_block = "10.0.0.0/24"
      az         = "ap-south-1b"
      public     = false  # or omitted (defaults to false)
    }
  }
}

# Access the outputs
output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}
```