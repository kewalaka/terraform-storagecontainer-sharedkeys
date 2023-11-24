terraform {
  required_version = ">= 1.3.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.7.0, < 4.0.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.9.0"
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

# deploy a basic storage account
module "storage_account" {
  source = "git::github.com/kewalaka/terraform-azurerm-avm-res-storage-storageaccount"

  name                = module.naming.storage_account.name_unique
  resource_group_name = azurerm_resource_group.this.name

  storage_account_account_replication_type = "LRS"
  storage_account_account_tier             = "Standard"
}

# deploy a container using the azapi provider
resource "azapi_resource" "storage_container" {
  type      = "Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01"
  name      = module.naming.storage_container.name_unique
  parent_id = "${module.storage_account.resource.id}/blobServices/default"
  body = jsonencode({
    properties = {
      metadata     = {}
      publicAccess = "None"
    }
  })
}
