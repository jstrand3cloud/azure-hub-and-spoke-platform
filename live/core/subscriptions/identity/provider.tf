#------------------------------
# PROVIDERS
#------------------------------

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = ">= 3.0.2"
      version = "~> 3.106.0" # For production grade
    }
  }
# Required Terraform Version
  required_version = ">= 1.1.0"
}