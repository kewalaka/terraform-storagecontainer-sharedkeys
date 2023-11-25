terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  storage_use_azuread        = true
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.0"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  name     = module.naming.resource_group.name_unique
  location = "AustraliaEast"
}

locals {
  # a simple example where all containers share the same properties
  containers = ["mycontainer1", "mycontainer2"]
}

# create the container(s) with the storage account - uses AZAPI under the covers
module "storage_account" {
  source = "git::github.com/kewalaka/terraform-azurerm-avm-res-storage-storageaccount"

  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.this.name

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"

  storage_container = {
    for container_name in local.containers :
    container_name => {
      name = container_name
      # add other properties as needed, such as public_access, metadata
    }
  }
}
