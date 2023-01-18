variable "env" {
  type        = string
  description = "Environment name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "user_object_ids" {
  type        = map(string)
  description = "Map of AD usernames and corresponding object IDs"
  default     = {}
}

variable "workspace_admins" {
  type = object({
    user              = list(string)
    service_principal = list(string)
  })
  description = "Provide users or service principals to grant them Admin permissions."
  default = {
    user              = null
    service_principal = null
  }
}

variable "iam" {
  type = map(object({
    user              = optional(list(string))
    service_principal = optional(list(string))
    entitlements      = optional(list(string))
  }))
  description = "Used to create workspace group. Map of group name and its parameters, such as users and service principals added to the group. Also possible to configure group entitlements."
  default     = {}

  validation {
    condition = contains(values(var.iam), "entitlements") ? alltrue([
      for item in toset(flatten([for group, params in var.iam : params.entitlements])) : contains(["allow_cluster_create", "allow_instance_pool_create", "databricks_sql_access"], item)
    ]) : true
    error_message = "Entitlements validation. The only suitable values are: databricks_sql_access, allow_instance_pool_create, allow_cluster_create"
  }
}

variable "iam_permissions" {
  type = map(object({
    CAN_USE    = list(string)
    CAN_MANAGE = list(string)
  }))
  description = "Map of permission for groups. You can provide certain permission on services to groups. E.g., `'sql_endpoint'={'CAN_USE'=['group1', 'group2'] CAN_MANAGE=['group3']}"
  default = {
    "sql_endpoint" = {
      "CAN_USE"    = ["default"]
      "CAN_MANAGE" = []
    }
    "token" = {
      "CAN_USE"    = ["default"]
      "CAN_MANAGE" = []
    }
  }
}

variable "ip_rules" {
  type        = map(string)
  description = "Map of IP addresses permitted for access to DB"
  default     = {}
}

variable "sql_endpoint" {
  type        = map(map(string))
  description = "Map of SQL Endoints to be deployed in Databricks Workspace"
  default     = {}
}

variable "default_values_sql_endpoint" {
  description = "Default values for SQL Endpoint"
  type = object({
    cluster_size              = string
    min_num_clusters          = number
    max_num_clusters          = number
    auto_stop_mins            = string
    enable_photon             = bool
    enable_serverless_compute = bool
  })
  default = {
    cluster_size              = "2X-Small"
    min_num_clusters          = 0
    max_num_clusters          = 1
    auto_stop_mins            = "30"
    enable_photon             = false
    enable_serverless_compute = false
  }
}
