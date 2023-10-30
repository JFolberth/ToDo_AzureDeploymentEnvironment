variable "resource_group_name" {
  type        = string
  description = "Name of the resource group the App Insights will be deployed to"
}

variable "app_service_location" {
  type        = string
  description = "Location the App Insights will be deployed to"
}

variable "app_service_name" {
  type        = string
  description = "Name for the instance of App Service"
}
variable "language" {
  type        = string
  description = "Language used to build the resource"
}
variable "app_service_settings" {
  type        = map(string)
  description = "object contain the app Service settings"
}
variable "service_plan_id" {
  type        = string
  description = "App Service Plan ID the App Service will live under"
}

variable "service_plan_sku_name" {
  type        = string
  description = "SKU for the App Service Plan, needed to determine appropriate settings"
}