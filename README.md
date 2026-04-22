

# 🏷️ Terraform Azure Naming Module

A Consistent approach for Naming-Generation in Terraform.

## 🌟 Overview

This module provides a structured solution for Azure resource naming and offers:

- 🎯 **Consistent Naming Conventions**: Unified naming for all Azure resources
- ⚙️ **Flexible Schema Configuration**: YAML-based configuration for patterns, mappings, and abbreviations
- 🌍 **Multi-Environment Support**: Support for different environments (dev, uat, prod)
- 🔢 **Index-based Naming**: Automatic name generation with indices for multiple resources
- ☁️ **Azure CAF Compliance**: Based on Azure Cloud Adoption Framework recommendations

## 📁 Module Structure

```
.
├── modules/
│   ├── naming-generator/     # Main module for name generation
│   ├── naming-schema/        # Schema loader and processing
│   └── resourceGroup/        # Resource group-specific module
├── env/                      # Environment-specific configurations
│   ├── dev/                  # Development environment
│   └── uat/                  # User Acceptance Testing environment
└── default.naming.yaml       # Default naming schema
```

## 🔧 Core Modules

### 1. naming-schema
Loads and processes the YAML-based naming configuration with:
- Default parameters
- Mappings for environments and locations
- Resource-specific patterns

### 2. naming-generator
Generates final resource names based on:
- Resource type and abbreviations
- Environment parameters
- Location information
- Index values for multiple instances

### 3. resourceGroup
Specialized module for resource group naming, outputing a naming ref for all dependent resources.

## 🚀 Usage

### 📖 Basic Example

```hcl
# Load schema
module "schema" {
  source = "./modules/naming-schema"
  
  naming = yamldecode(file("${path.root}/default.naming.yaml"))
  parameters = {
    location    = "westeurope"
    environment = "development"
    name        = "myapp"
  }
}

# Generate names for Azure Disk
module "disk_naming" {
  source = "./modules/naming-generator"
  
  schema   = module.schema
  resource = "Azure:Microsoft.Compute/disks"
  
  index = {
    count = 3  # Generates 3 different names with index
  }
}

# Output
output "disk_names" {
  value = {
    single    = module.disk_naming.name      # Single name
    multiple  = module.disk_naming.by_index  # Array with 3 names
  }
}
```

### 🔬 Advanced Configuration

```hcl
module "advanced_naming" {
  source = "./modules/naming-generator"
  
  schema   = module.schema
  resource = "Azure:Microsoft.Storage/storageAccounts"
  location = "East US"
  
  parameters = {
    override = {
      environment = "prod"
      custom_tag  = "api"
    }
  }
  
  index = {
    count  = 5
    offset = 10  # Starts at index 10
  }
}
```

## ⚙️ Schema Configuration

### 📋 default.naming.yaml Structure

```yaml
# Default parameters
default_parameters:
  name: poc

# Index modifier (starts at 1 instead of 0)
index_modifier: 1

# Case enforcement
enforce_lower_case:
  default: true
  azurerm:
    default: false
    container_registry: true
    storage_account: true

# Mappings for environments and locations
mappings:
  environment:
    development: dev
    staging: stg
    production: prod
    
  location:
    West Europe: euwe
    westeurope: euwe
    East US: eaus

# Resource-specific patterns

patterns:
  default: "<TYPE>-<LOCATION>-<ENVIRONMENT>-<NAME>-<INDEX;%02s>-<UNIQUE_ID_4>"

  azurerm:
    default: "<TYPE>-<LOCATION>-<ENVIRONMENT>-<NAME>-<INDEX;%02s>"

    container_registry:
      default: "<TYPE>-<LOCATION>-<ENVIRONMENT>-<NAME>-<INDEX;%02s>"

    storage_account:
      default: "<TYPE><LOCATION><ENVIRONMENT><NAME><INDEX;%02s>"
      # <name_id>: "<pattern>"
      # <name_kind>: "<pattern>"
```