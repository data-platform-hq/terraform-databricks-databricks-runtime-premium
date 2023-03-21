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
    condition = length([for item in values(var.iam)[*] : item.entitlements if item.entitlements != null]) != 0 ? alltrue([
      for entry in flatten(values(var.iam)[*].entitlements) : contains(["allow_cluster_create", "allow_instance_pool_create", "databricks_sql_access"], entry) if entry != null
    ]) : true
    error_message = "Entitlements validation. The only suitable values are: databricks_sql_access, allow_instance_pool_create, allow_cluster_create"
  }
}

# Default Cluster and Cluster Policy variables
variable "default_cluster_id" {
  type        = map(string)
  description = "Single value of default Cluster id created by 'databricks-runtime' module"
  default     = {}
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
  type = set(object({
    name                      = string
    cluster_size              = optional(string)
    min_num_clusters          = optional(number)
    max_num_clusters          = optional(number)
    auto_stop_mins            = optional(string)
    enable_photon             = optional(bool)
    enable_serverless_compute = optional(bool)
    spot_instance_policy      = optional(string)
    warehouse_type            = optional(string)
    permissions = optional(set(object({
      group_name       = string
      permission_level = string
    })))
  }))
  description = "Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups"
  default     = []
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

# Secret Scope ACLs variables
variable "secret_scope_object" {
  type = list(object({
    scope_name = string
    acl = list(object({
      principal  = string
      permission = string
    }))
  }))
  description = "List of objects, where 'scope_name' param is a Secret scope name and 'acl' are list of objects with 'principals' and one of allowed 'permission' ('READ', 'WRITE' or 'MANAGE')"
  default = [{
    scope_name = null
    acl        = null
  }]
}

variable "unity_cluster_enabled" {
  type        = bool
  description = "Boolean flag for creating databricks claster"
  default     = false
}

variable "unity_cluster_config" {
  type = object({
    cluster_name            = optional(string, "Unity Catalog")
    spark_version           = optional(string, "11.3.x-scala2.12")
    spark_conf              = optional(map(any), {})
    spark_env_vars          = optional(map(any), {})
    data_security_mode      = optional(string, "USER_ISOLATION")
    node_type_id            = optional(string, "Standard_D3_v2")
    autotermination_minutes = optional(number, 30)
    min_workers             = optional(number, 1)
    max_workers             = optional(number, 2)
    availability            = optional(string, "ON_DEMAND_AZURE")
    first_on_demand         = optional(number, 0)
    spot_bid_max_price      = optional(number, 1)

  })
  description = "Specifies the databricks unity cluster configuration"
  default     = {}
}
