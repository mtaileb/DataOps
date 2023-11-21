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
        google = {
            source = "hashicorp/google"
            version = "4.51.0"
        }
    }
    required_version = ">= 1.1.0"
}

provider azurerm {
  features {}
}

provider "aws" {
  region  = "us-west-2"
}

provider "google" {
  credentials = file("<NAME>.json")
  project = "<PROJECT_ID>"
  region  = "us-central1"
  zone    = "us-central1-c"
}


