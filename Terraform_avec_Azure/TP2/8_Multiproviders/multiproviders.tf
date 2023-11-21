terraform {
    required_providers {
        azurerm = {
            source  = "registry.terraform.io/hashicorp/azurerm"
            version = "~>2.36, ~>2.40"        
        }    
        aws = {
          source  = "hashicorp/aws"
          version = "~> 4.16"
        }
    }
}

provider "aws" {
  region  = "us-west-2"
}

provider azurerm {
  features {}
}


