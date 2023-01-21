resource "azurerm_resource_group" "rg" {
  name     = "demoRg"
  location = "West Europe"

  tags = {
    environment = "Terraform Azure"
  }
}

