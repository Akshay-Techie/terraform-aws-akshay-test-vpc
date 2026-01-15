# VPC Terraform Module

A reusable, production-ready Terraform module for creating a complete AWS VPC infrastructure with public and private subnets.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Module Architecture](#module-architecture)
- [Project Structure](#project-structure)
- [Requirements](#requirements)
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Examples](#examples)
- [File Descriptions](#file-descriptions)
- [Advanced Configuration](#advanced-configuration)

---

## Overview

This Terraform module simplifies the creation of AWS VPC infrastructure by providing a flexible, parameterized approach to provisioning:

- **Virtual Private Cloud (VPC)** with customizable CIDR blocks
- **Multiple Subnets** across different availability zones
- **Public and Private Subnets** automatically separated based on configuration
- **Internet Gateway** for public subnet internet access
- **Route Tables** with internet routes for public subnets
- **Route Table Associations** linking subnets to route tables

The module is designed to be flexible, maintainable, and follows Terraform best practices.

---

## Features

✅ **Dynamic Subnet Creation** - Create any number of subnets with for_each  
✅ **Automatic Routing** - Internet Gateway and route tables created conditionally  
✅ **Public/Private Separation** - Automatic classification based on configuration  
✅ **Multi-AZ Support** - Distribute subnets across availability zones  
✅ **Input Validation** - Built-in CIDR block validation  
✅ **Descriptive Naming** - Auto-generated resource names based on VPC and subnet names  
✅ **Modular Design** - Can be easily consumed by other modules  
✅ **State Management** - Clean separation of variables, outputs, and resources  

---

## Module Architecture

```
┌─────────────────────────────────────────────────┐
│           VPC Module Architecture                │
├─────────────────────────────────────────────────┤
│                                                   │
│  ┌────────────────────────────────────────────┐ │
│  │ Virtual Private Cloud (VPC)                │ │
│  │ CIDR: 10.0.0.0/16                         │ │
│  │                                            │ │
│  │  ┌──────────────────┐  ┌──────────────┐  │ │
│  │  │  Public Subnet 1 │  │ Private Sub  │  │ │
│  │  │  10.0.1.0/24     │  │ 10.0.0.0/24  │  │ │
│  │  │  AZ: ap-south-1a │  │ AZ: ap-south │  │ │
│  │  └────────┬─────────┘  └──────────────┘  │ │
│  │           │                                │ │
│  │  ┌────────┴─────────┐                    │ │
│  │  │  Public Subnet 2 │                    │ │
│  │  │  10.0.2.0/24     │                    │ │
│  │  │  AZ: ap-south-1a │                    │ │
│  │  └────────┬─────────┘                    │ │
│  │           │                                │ │
│  │           ↓                                │ │
│  │  ┌─────────────────────────────────────┐  │ │
│  │  │ Internet Gateway (IGW)              │  │ │
│  │  │ Enables internet access for public  │  │ │
│  │  │ subnets                             │  │ │
│  │  └────────────────┬────────────────────┘  │ │
│  │                   │                        │ │
│  │                   ↓                        │ │
│  │  ┌─────────────────────────────────────┐  │ │
│  │  │ Route Table (Public)                │  │ │
│  │  │ 0.0.0.0/0 → IGW                   │  │ │
│  │  └─────────────────────────────────────┘  │ │
│  │                                            │ │
│  └────────────────────────────────────────────┘ │
│                                                   │
└─────────────────────────────────────────────────┘
```

---

## Project Structure

```
proj-own-module-vpc/
├── root-main.tf              # Root module configuration (module consumer)
├── root-outputs.tf           # Root module outputs
├── terraform.tfstate         # Terraform state file
├── terraform.tfstate.backup  # State backup
├── .terraform/               # Terraform working directory (generated)
├── .terraform.lock.hcl       # Dependency lock file (generated)
│
└── module/
    └── vpc/                  # VPC Module
        ├── main.tf           # VPC resources definition
        ├── variable.tf       # Input variable declarations
        ├── outputs.tf        # Module output values
        ├── versions.tf       # Terraform and provider versions
        ├── README.md         # Module documentation (this file)
```

---

## Requirements

| Requirement | Version |
|-------------|---------|
| Terraform   | >= 1.0.0 |
| AWS Provider | > 6.27.0 |
| AWS Account | Required |
| AWS Region  | ap-south-1 (Mumbai) |

### AWS Permissions Required

- `ec2:CreateVpc`
- `ec2:CreateSubnet`
- `ec2:CreateInternetGateway`
- `ec2:CreateRouteTable`
- `ec2:CreateRoute`
- `ec2:AssociateRouteTable`
- `ec2:DescribeVpcs`
- `ec2:DescribeSubnets`

---

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

### Apply the Configuration

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply
```

---

## Input Variables

### vpc_config

**Type:** `object`

**Required:** Yes

Configuration for the VPC with CIDR block and name.

| Argument   | Type   | Description |
|-----------|--------|-------------|
| `cidr_block` | `string` | VPC CIDR block (e.g., `10.0.0.0/16`) - must be in valid CIDR notation |
| `name` | `string` | Name tag for the VPC (e.g., `my-vpc`) |

**Validation:** CIDR block must be valid according to AWS standards.

**Example:**
```hcl
vpc_config = {
  cidr_block = "10.0.0.0/16"
  name       = "production-vpc"
}
```

---

### subnet_config

**Type:** `map(object)`

**Required:** Yes

Map of subnets with their configurations. Each subnet can have unique settings.

| Argument   | Type   | Optional | Default | Description |
|-----------|--------|----------|---------|-------------|
| `cidr_block` | `string` | No | - | Subnet CIDR block (e.g., `10.0.1.0/24`) - must be valid |
| `az` | `string` | No | - | AWS Availability Zone (e.g., `ap-south-1a`) |
| `public` | `bool` | Yes | `false` | Whether subnet is public (has internet access via IGW) |

**Validation:** All CIDR blocks must be valid according to AWS standards.

**Example:**
```hcl
subnet_config = {
  # Public subnet in AZ 1
  public_subnet_1 = {
    cidr_block = "10.0.1.0/24"
    az         = "ap-south-1a"
    public     = true
  }
  
  # Public subnet in AZ 1 (for redundancy)
  public_subnet_2 = {
    cidr_block = "10.0.2.0/24"
    az         = "ap-south-1a"
    public     = true
  }
  
  # Private subnet in AZ 2
  private_subnet = {
    cidr_block = "10.0.3.0/24"
    az         = "ap-south-1b"
    # public defaults to false
  }
}
```

---

## Outputs

### vpc_id

**Type:** `string`

**Description:** The ID of the created VPC.

**Example Output:** `vpc-0a1b2c3d4e5f6g7h8`

**Usage:**
```hcl
output "vpc_id" {
  value = module.vpc.vpc_id
}
```

---

### public_subnets

**Type:** `map(object)`

**Description:** Map of all public subnets with their IDs and availability zones.

**Structure:**
```hcl
{
  subnet_name = {
    subnet_id = "subnet-xxx"
    az        = "ap-south-1a"
  }
}
```

**Example Output:**
```json
{
  "public_subnet_1" = {
    "az" = "ap-south-1a"
    "subnet_id" = "subnet-0a1b2c3d4e5f6g7h8"
  }
  "public_subnet_2" = {
    "az" = "ap-south-1a"
    "subnet_id" = "subnet-1b2c3d4e5f6g7h8i9"
  }
}
```

---

### private_subnets

**Type:** `map(object)`

**Description:** Map of all private subnets with their IDs and availability zones.

**Structure:**
```hcl
{
  subnet_name = {
    subnet_id = "subnet-yyy"
    az        = "ap-south-1b"
  }
}
```

**Example Output:**
```json
{
  "private_subnet" = {
    "az" = "ap-south-1b"
    "subnet_id" = "subnet-2c3d4e5f6g7h8i9j0"
  }
}
```

---

## Examples

### Example 1: Multi-AZ VPC with High Availability

```hcl
module "production_vpc" {
  source = "./module/vpc"
  
  vpc_config = {
    cidr_block = "172.16.0.0/16"
    name       = "prod-vpc"
  }
  
  subnet_config = {
    # Public subnets across multiple AZs
    public_subnet_1a = {
      cidr_block = "172.16.1.0/24"
      az         = "ap-south-1a"
      public     = true
    }
    
    public_subnet_1b = {
      cidr_block = "172.16.2.0/24"
      az         = "ap-south-1b"
      public     = true
    }
    
    # Private subnets across multiple AZs
    private_subnet_1a = {
      cidr_block = "172.16.10.0/24"
      az         = "ap-south-1a"
    }
    
    private_subnet_1b = {
      cidr_block = "172.16.11.0/24"
      az         = "ap-south-1b"
    }
  }
}

# Launch EC2 instances in public subnets
resource "aws_instance" "web_server" {
  for_each = module.production_vpc.public_subnets
  
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id     = each.value.subnet_id
  
  tags = {
    Name = "web-server-${each.key}"
  }
}
```

### Example 2: Development VPC (Single AZ)

```hcl
module "dev_vpc" {
  source = "./module/vpc"
  
  vpc_config = {
    cidr_block = "10.100.0.0/16"
    name       = "dev-vpc"
  }
  
  subnet_config = {
    dev_public = {
      cidr_block = "10.100.1.0/24"
      az         = "ap-south-1a"
      public     = true
    }
    
    dev_private = {
      cidr_block = "10.100.2.0/24"
      az         = "ap-south-1a"
    }
  }
}
```

---

## File Descriptions

### `main.tf` - VPC Resources

Contains all AWS resource definitions:

- **aws_vpc.main** - Creates the VPC with specified CIDR block
- **aws_subnet.main** - Creates multiple subnets using `for_each` for dynamic creation
- **locals** - Classifies subnets into public and private based on the `public` flag
- **aws_internet_gateway.main** - Conditionally creates IGW only if public subnets exist
- **aws_route_table.main** - Creates route table with internet route (only if public subnets exist)
- **aws_route_table_association.main** - Associates route table with each public subnet

**Key Concepts:**
- Uses `for_each` for dynamic resource creation
- Conditional resource creation with `count`
- Local values for subnet classification
- Descriptive naming with string interpolation

---

### `variable.tf` - Input Variables

Declares all input variables with types and validation:

- **vpc_config** - Object containing VPC CIDR and name
  - Validates CIDR block format
  - Example: `{ cidr_block = "10.0.0.0/16", name = "my-vpc" }`

- **subnet_config** - Map of objects for subnet configurations
  - Each object: `{ cidr_block = "...", az = "...", public = optional(bool) }`
  - Validates all CIDR blocks
  - Supports dynamic number of subnets

**Validation Features:**
- Built-in CIDR block validation using `cidrnetmask()`
- Ensures all subnets have valid CIDR notation
- Error messages guide users to correct format

---

### `outputs.tf` - Module Outputs

Exports important resource information:

- **vpc_id** - Direct output of the VPC ID
- **public_subnets** - Map with subnet details for easy consumption
  - Contains: `subnet_id` and `az` (availability zone)
  - Formatted using locals for better usability
  - Example: `{ subnet_name = { subnet_id = "subnet-xxx", az = "ap-south-1a" } }`

- **private_subnets** - Same format as public_subnets but for private subnets

**Output Features:**
- Formatted locals make outputs easy to consume
- Descriptions help users understand each output
- Structure allows easy iteration in other modules

---

### `versions.tf` - Version Constraints

Specifies Terraform and provider requirements:

- **terraform** - Requires version >= 1.0.0
- **aws provider** - Requires version > 6.27.0 from hashicorp/aws

**Why These Versions?**
- Terraform 1.0.0+ has improved validation and stability
- AWS Provider 6.27.0+ provides VPC/subnet features used in this module

---

### `README.md` - Documentation

This comprehensive documentation file including:
- Module overview and features
- Architecture diagrams
- Usage examples
- Variable documentation
- File descriptions

---

## Advanced Configuration

### Using Outputs in Other Modules

```hcl
# Launch database in private subnet
resource "aws_db_instance" "main" {
  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = false
  
  # Reference private subnet from VPC module
  # ... other configuration ...
}

# Security group for private resources
resource "aws_security_group" "db" {
  vpc_id = module.vpc.vpc_id  # Reference VPC ID from module
  
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }
}
```

### Conditional Subnets

```hcl
# Create different subnet configurations based on environment
variable "environment" {
  type    = string
  default = "dev"
}

locals {
  subnet_configs = {
    dev = {
      subnet_1 = {
        cidr_block = "10.0.1.0/24"
        az         = "ap-south-1a"
        public     = true
      }
    }
    
    prod = {
      public_1a = {
        cidr_block = "10.0.1.0/24"
        az         = "ap-south-1a"
        public     = true
      }
      public_1b = {
        cidr_block = "10.0.2.0/24"
        az         = "ap-south-1b"
        public     = true
      }
      private_1a = {
        cidr_block = "10.0.10.0/24"
        az         = "ap-south-1a"
      }
      private_1b = {
        cidr_block = "10.0.11.0/24"
        az         = "ap-south-1b"
      }
    }
  }
}

module "vpc" {
  source = "./module/vpc"
  
  vpc_config     = local.vpc_config[var.environment]
  subnet_config  = local.subnet_configs[var.environment]
}
```

---

## Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "Invalid CIDR Format" | Incorrect CIDR notation | Use valid CIDR (e.g., `10.0.0.0/16` not `10.0.0.0/33`) |
| "Subnet overlaps with VPC" | Subnet CIDR not within VPC CIDR | Ensure subnet CIDR is subset of VPC CIDR |
| "Invalid AZ" | Incorrect availability zone name | Use valid AZ names like `ap-south-1a`, `ap-south-1b`, etc. |
| "IGW already exists" | Attempting to create duplicate IGW | Check if IGW already attached to VPC |

---

## Maintenance and Best Practices

1. **Always validate before applying:**
   ```bash
   terraform validate
   terraform plan
   ```

2. **Use state locking in production:**
   ```hcl
   terraform {
     backend "s3" {
       bucket         = "terraform-state"
       key            = "vpc/terraform.tfstate"
       region         = "ap-south-1"
       dynamodb_table = "terraform-locks"
       encrypt        = true
     }
   }
   ```

3. **Keep modules small and focused** - This VPC module focuses only on VPC/subnet creation

4. **Use descriptive names** - Makes debugging and management easier

5. **Document custom modifications** - If you fork this module, document changes

---

## Related Resources

- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Language Documentation](https://www.terraform.io/language)

---

## Support and Contributions

For issues or improvements:
1. Check existing documentation
2. Validate configuration with `terraform validate`
3. Review AWS limits and quotas
4. Check CloudTrail logs for AWS-side errors

---

**Version:** 1.0  
**Last Updated:** January 15, 2026  
**Terraform Version:** >= 1.0.0  
**AWS Provider:** > 6.27.0
