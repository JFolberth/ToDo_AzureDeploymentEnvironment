terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.2"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "random" {}
variable "base_name" {
  default     = "deployenvironmenttf"
  description = "Base name that will appear for all resources."
}
variable "environment_name" {
  description = "Three leter environment abreviation to denote environment that will appear in all resource names"
  default     = "dev"
}
variable "resource_group_location" {
  description = "The Azure location the Resource Group will be deployed to"
}
variable "service_plan_sku_name" {
  description = "SKU for the App Service Plan"
  default     = "B1"
}

variable "log_analytics_workspace_name" {
  description = "Name of existing Log Analytics Workspace"
}

variable "log_analytics_workspace_resource_group_name" {
  description = "Name of existing Log Analytics Workspace's Resource Group"
}
variable "cosmosdb_account_name" {
  description = "Name of existing CosmosDB Account"
}

variable "cosmosdb_account_resource_group_name" {
  description = "Name of existing Cosmos DB Account's Resource Group"
}

variable "region_reference" {
  default = {
    centralus = "cus"
    eastus    = "eus"
    westus    = "wus"
    westus2   = "wus2"
  }
  description = "Object/map that will look up a full qualified region and convert it to an abreviation. Done to drive consistency"
}
variable "language" {
  default = "Terraform"
}
variable "resource_group_name" {}
locals {
  name_suffix = "${var.base_name}-${var.environment_name}-${lookup(var.region_reference, var.resource_group_location, "")}"
}

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_log_analytics_workspace" "log_analytics" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_workspace_resource_group_name
}
data "azurerm_cosmosdb_account" "cosmosdb_account" {
  name                = var.cosmosdb_account_name
  resource_group_name = var.cosmosdb_account_resource_group_name
}

module "service_plan_module" {
  source                = "./modules/appServicePlan"
  resource_group_name   = data.azurerm_resource_group.rg.name
  service_plan_location = var.resource_group_location
  service_plan_name     = local.name_suffix
  language              = var.language
  service_plan_sku_name = var.service_plan_sku_name
}


module "app_insights_module" {
  source                     = "./modules/appInsights"
  resource_group_name        = data.azurerm_resource_group.rg.name
  app_insights_location      = var.resource_group_location
  app_insights_name          = local.name_suffix
  language                   = var.language
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log_analytics.id
}

module "app_service_module" {
  source                = "./modules/appService"
  resource_group_name   = data.azurerm_resource_group.rg.name
  app_service_location  = var.resource_group_location
  app_service_name      = local.name_suffix
  language              = var.language
  service_plan_id       = module.service_plan_module.service_plan_id
  service_plan_sku_name = var.service_plan_sku_name
  app_service_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"             = module.app_insights_module.instrumentation_key
    "CosmosDb:Account"                           = "https://${data.azurerm_cosmosdb_account.cosmosdb_account.name}.documents.azure.com:443/"
    "CosmosDb:DatabaseName"                      = "Tasks"
    "CosmosDb:ContainerName"                     = "Items"
    "WEBSITE_RUN_FROM_PACKAGE"                   = 1
    "SCM_DO_BUILD_DURING_DEPLOYMENT"             = true
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~2"
  }
}

module "user_assigned_identity_module" {
  source                          = "./modules/userAssignedIdentity"
  resource_group_name             = data.azurerm_resource_group.rg.name
  user_assigned_identity_location = var.resource_group_location
  user_assigned_identity_name     = local.name_suffix
  language                        = var.language

}

module "cosmosdb_role_assignment_module" {
  source                          = "./modules/cosmosSqlRoleAssignment"
  cosmosdb_account_name           = data.azurerm_cosmosdb_account.cosmosdb_account.name
  cosmosdb_account_resource_group = data.azurerm_cosmosdb_account.cosmosdb_account.resource_group_name
  principal_id                    = module.user_assigned_identity_module.user_assigned_identity_principal_id

}