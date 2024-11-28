terraform {
  required_version = ">= 0.12" 
required_providers {
    azurerm = {
      version = "~> 2.51.0"
      source = "hashicorp/azurerm"
    }
  }
}
