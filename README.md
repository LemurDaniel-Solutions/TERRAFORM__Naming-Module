

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
  resource = "Azure::Microsoft.Compute/disks::os"
  
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
  resource = "Azure::Microsoft.Storage/storageAccounts::default"
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
#
# ################################################################################################
# ## (Optional) Define default parameters.

default_parameters:

#
# ################################################################################################
# ## Define general settings.

index_modifier: 1

enforce_lower_case:
  default: true

  azurerm:
    default: false
    container_registry: true
    storage_account: true

#
# ################################################################################################
# ## Define any mappings for the schema.

mappings:
  # Map location names to their corresponding shortnames.
  location:
    global: glob

    westeurope: euwe
    West Europe: euwe

    germanynorth: geno
    Germany North: geno

    germanywestcentral: gewc
    Germany West Central: gewc

  # Use shortened environment names.
  environment:
    development: dev
    staging: stg
    test: tst
    production: prod

#
# ################################################################################################
# ## Define the patterns for generating names.

patterns:
  default: "<TYPE>-<LOCATION>-<ENVIRONMENT>-<NAME>-<INDEX;%02s>-<UNIQUE_ID_4>"

  Azure:
    default: "<TYPE>-<LOCATION>-<ENVIRONMENT>-<NAME>-<INDEX;%02s>"

    Microsoft.ContainerRegistry/registries:
      default: "<TYPE>-<LOCATION>-<ENVIRONMENT>-<NAME>-<INDEX;%02s>"

    Microsoft.Storage/storageAccounts:
      default: "<TYPE><LOCATION><ENVIRONMENT><NAME><INDEX;%02s>"
      # <name_id>: "<pattern>"
      # <name_kind>: "<pattern>"

```