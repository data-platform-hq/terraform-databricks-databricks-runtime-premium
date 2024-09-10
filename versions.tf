terraform {
  required_version = ">=1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.1"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1.30.0"
    }
  }
}
