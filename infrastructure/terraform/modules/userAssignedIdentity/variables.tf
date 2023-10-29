variable "resource_group_name" {
  type        = string
  description = "Name of the resource group the User Assigned Identity will be deployed to"
}

variable "user_assigned_identity_location" {
  type        = string
  description = "Location the User Assigned Identity will be deployed to"
}

variable "user_assigned_identity_name" {
  type        = string
  description = "Name for the instance of user assigned identity"
}
variable "language" {
  type        = string
  description = "Language used to build the resource"
}