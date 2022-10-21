variable "env" {
  type        = string
  description = "Environment name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "workspace_id" {
  type        = string
  description = "Id of Databricks workspace"
}

variable "sku" {
  type        = string
  description = "The sku to use for the Databricks Workspace: [standard|premium|trial]"
}

# Optional
variable "user_object_ids" {
  type        = map(string)
  description = "Map of AD usernames and corresponding object IDs"
  default     = {}
}

variable "iam" {
  type = map(object({
    user              = list(string)
    service_principal = list(string)
  }))
  description = "Map of groups and members of users and service principals to be created. You can add you own groups and members. E.g., `'group' = { user = ['user1','user2'] service_principal = ['sp1']}` and etc."
  default = {
    "admins" = {
      "user"              = []
      "service_principal" = []
    }
    "default" = {
      "user"              = []
      "service_principal" = []
    }
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
