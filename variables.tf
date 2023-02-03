variable "project" {
  type        = string
  description = "Project name"
}

variable "env" {
  type        = string
  description = "Environment name"
}

variable "location" {
  type        = string
  description = "Azure location"
}

variable "workspace_id" {
  type        = string
  description = "Id of Azure Databricks workspace"
}

variable "ip_rules" {
  type        = map(string)
  description = "Map of IP addresses permitted for access to DB"
  default     = {}
}

# Identity Access Management variables
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
  description = "Provide users or service principals to grant them Admin permissions in Workspace."
  default = {
    user              = null
    service_principal = null
  }
}

variable "iam" {
  type = map(object({
    user                       = optional(list(string))
    service_principal          = optional(list(string))
    entitlements               = optional(list(string))
    default_cluster_permission = optional(string)
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
  }
}

# Default Cluster and Cluster Policy variables
variable "default_cluster_id" {
  type    = string
  description = "Single value of default Cluster id created by 'databricks-runtime' module"
  default = ""
}

variable "cluster_policies_object" {
  type = list(object({
    id      = string
    name    = string
    can_use = list(string)
  }))
  description = "List of objects that provides an ability to grant custom workspace group a permission to use(CAN_USE) cluster policy"
  default = [{
    id      = null
    name    = null
    can_use = null
  }]
}

# SQL Endpoint variables
variable "sql_endpoint" {
  type = map(object({
    cluster_size              = string
    min_num_clusters          = optional(number)
    max_num_clusters          = optional(number)
    auto_stop_mins            = optional(string)
    enable_photon             = optional(bool)
    enable_serverless_compute = optional(bool)
  }))
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

# Unity Catalog variables
variable "create_metastore" {
  type        = bool
  description = "Boolean flag for Unity Catalog Metastore current in this environment. One Metastore per region"
  default     = false
}

variable "access_connector_id" {
  type        = string
  description = "Databricks Access Connector Id that lets you to connect managed identities to an Azure Databricks account. Provides an ability to access Unity Catalog with assigned identity"
  default     = ""
}

variable "storage_account_id" {
  type        = string
  description = "Storage Account Id where Unity Catalog Metastore would be provisioned"
  default     = ""
}
variable "storage_account_name" {
  type        = string
  description = "Storage Account Name where Unity Catalog Metastore would be provisioned"
  default     = ""
}

variable "catalog" {
  type = map(object({
    catalog_grants     = optional(map(list(string)))
    catalog_comment    = optional(string)
    catalog_properties = optional(map(string))
    schema_name        = optional(list(string))
    schema_grants      = optional(map(list(string)))
    schema_comment     = optional(string)
    schema_properties  = optional(map(string))
  }))
  description = "Map of catalog name and its parameters"
  default     = {}
}

variable "suffix" {
  type        = string
  description = "Optional suffix that would be added to the end of resources names."
  default     = ""
}

variable "external_metastore_id" {
  type        = string
  description = "Unity Catalog Metastore Id that is located in separate environment. Provide this value to associate Databricks Workspace with target Metastore"
  default     = ""
  validation {
    condition     = length(var.external_metastore_id) == 36 || length(var.external_metastore_id) == 0
    error_message = "UUID has to be either in nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn format or empty string"
  }
}

variable "metastore_grants" {
  type        = map(list(string))
  description = "Permissions to give on metastore to group"
  default     = {}
  validation {
    condition = values(var.metastore_grants) != null ? alltrue([
      for item in toset(flatten([for group, params in var.metastore_grants : params if params != null])) : contains([
        "CREATE_CATALOG", "CREATE_EXTERNAL_LOCATION", "CREATE_SHARE", "CREATE_RECIPIENT", "CREATE_PROVIDER"
      ], item)
    ]) : true
    error_message = "Metastore permission validation. The only possible values for permissions are: CREATE_CATALOG, CREATE_EXTERNAL_LOCATION, CREATE_SHARE, CREATE_RECIPIENT, CREATE_PROVIDER"
  }
}
