terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.95.0"
    }
  }
}
provider "azurerm" {
  features {}
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret

}

variable "tenant_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "subscription_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "client_id" {
  type        = string
  description = "(optional) describe your variable"
}

variable "client_secret" {
  type        = string
  description = "(optional) describe your variable"
}