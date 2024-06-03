# Required Providers and their versions
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      #version = ">= 3.0.2"
      version = "~> 3.106.0" # For production grade
    }
    # azuread = {
    #   source  = "hashicorp/azuread"
    #   version = "~> 2.15.0"
    # }
  }

# Terraform State Storage to Azure Storage Container. Comment out this backend for local deployments using PowerShell, leave it uncommented for use with Azure DevOps (ADO) pipelines
 backend "azurerm" {
   #resource_group_name  = "rg-tooling"
   #storage_account_name = "tfstatetemp01"
   #container_name       = "statecontainer"
   #key                  = "terraform.tfstate"
   #access_key = ""
 }
# Required Terraform Version

  required_version = ">= 1.1.0"
}

# MULTI (THREE SUBSCRIPTIONS)
# Connectivity Subscription
provider "azurerm" {
  alias           = "connectivity-sub"
  subscription_id = var.connectivity_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  } 
}

# Identity Subscription
provider "azurerm" {
  alias           = "identity-sub"
  subscription_id = var.identity_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Management Subscription
provider "azurerm" {
  alias           = "management-sub"
  subscription_id = var.management_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}


# tbd Development Subscription
provider "azurerm" {
  alias           = "alz-tbd-dev-01-sub"
  subscription_id = var.alz-tbd-dev-01_subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}