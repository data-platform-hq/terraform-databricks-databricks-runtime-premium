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
    user              = optional(list(string))
    service_principal = optional(list(string))
    entitlements      = optional(list(string))
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

# SQL Endpoint variables
variable "sql_endpoint" {
  type = set(object({
    name                      = string
    cluster_size              = optional(string, "2X-Small")
    min_num_clusters          = optional(number, 0)
    max_num_clusters          = optional(number, 1)
    auto_stop_mins            = optional(string, "30")
    enable_photon             = optional(bool, false)
    enable_serverless_compute = optional(bool, false)
    spot_instance_policy      = optional(string, "COST_OPTIMIZED")
    warehouse_type            = optional(string, "PRO")
    permissions = optional(set(object({
      group_name       = string
      permission_level = string
    })), [])
  }))
  description = "Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups"
  default     = []
}

variable "suffix" {
  type        = string
  description = "Optional suffix that would be added to the end of resources names."
  default     = ""
}

variable "sp_client_id_secret_name" {
  type        = string
  description = "The name of Azure Key Vault secret that contains ClientID of Service Principal to access in Azure Key Vault"
}

variable "sp_key_secret_name" {
  type        = string
  description = "The name of Azure Key Vault secret that contains client secret of Service Principal to access in Azure Key Vault"
}

# Secret Scope variables
variable "secret_scope" {
  type = list(object({
    scope_name = string
    acl = optional(list(object({
      principal  = string
      permission = string
    })))
    secrets = optional(list(object({
      key          = string
      string_value = string
    })))
  }))
  description = <<-EOT
Provides an ability to create custom Secret Scope, store secrets in it and assigning ACL for access management
scope_name - name of Secret Scope to create;
acl - list of objects, where 'principal' custom group name, this group is created in 'Premium' module; 'permission' is one of "READ", "WRITE", "MANAGE";
secrets - list of objects, where object's 'key' param is created key name and 'string_value' is a value for it;
EOT
  default = [{
    scope_name = null
    acl        = null
    secrets    = null
  }]
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault instance where the Secret resides"
}

variable "tenant_id_secret_name" {
  type        = string
  description = "The name of Azure Key Vault secret that contains tenant ID secret of Service Principal to access in Azure Key Vault"
}

variable "mountpoints" {
  type = map(object({
    storage_account_name = string
    container_name       = string
  }))
  description = "Mountpoints for databricks"
  default     = {}
}

# Unity Catalog Metastore assignment variables
variable "assign_unity_catalog_metastore" {
  type        = bool
  description = "Boolean flag provides an ability to assign Unity Catalog Metastore to this Workspace"
  default     = false
}

variable "external_metastore_id" {
  type        = string
  description = "Unity Catalog Metastore Id that is located in separate environment. Provide this value to associate Databricks Workspace with target Metastore"
  default     = ""
  validation {
    condition     = anytrue([length(var.external_metastore_id) == 36, length(var.external_metastore_id) == 0])
    error_message = "UUID has to be either in nnnnnnnn-nnnn-nnnn-nnnn-nnnnnnnnnnnn format or empty string"
  }
}

variable "custom_cluster_policies" {
  type = list(object({
    name       = string
    can_use    = list(string)
    definition = any
  }))
  description = <<-EOT
Provides an ability to create custom cluster policy, assign it to cluster and grant CAN_USE permissions on it to certain custom groups
name - name of custom cluster policy to create
can_use - list of string, where values are custom group names, there groups have to be created with Terraform;
definition - JSON document expressed in Databricks Policy Definition Language. No need to call 'jsonencode()' function on it when providing a value;
EOT
  default = [{
    name       = null
    can_use    = null
    definition = null
  }]
}

variable "clusters" {
  type = set(object({
    cluster_name                 = string
    spark_version                = optional(string, "11.3.x-scala2.12")
    spark_conf                   = optional(map(any), {})
    cluster_conf_passthrought    = optional(bool, false)
    spark_env_vars               = optional(map(any), {})
    data_security_mode           = optional(string, "USER_ISOLATION")
    node_type_id                 = optional(string, "Standard_D3_v2")
    autotermination_minutes      = optional(number, 30)
    min_workers                  = optional(number, 1)
    max_workers                  = optional(number, 2)
    availability                 = optional(string, "ON_DEMAND_AZURE")
    first_on_demand              = optional(number, 0)
    spot_bid_max_price           = optional(number, 1)
    cluster_log_conf_destination = optional(string, null)
    permissions = optional(set(object({
      group_name       = string
      permission_level = string
    })), [])
  }))
  description = "Set of objects with parameters to configure Databricks clusters and assign permissions to it for certain custom groups"
  default     = []
}

variable "pat_token_lifetime_seconds" {
  type        = number
  description = "The lifetime of the token, in seconds. If no lifetime is specified, the token remains valid indefinitely"
  default     = 315569520
}

variable "mount_adls_passthrough" {
  type        = bool
  description = "Boolean flag to use mount options for credentals passthrough. Should be used with mount_cluster_name, specified cluster should have option cluster_conf_passthrought == true"
  default     = false
}

variable "mount_cluster_name" {
  type        = string
  description = "Name of the cluster that will be used during storage mounting. If mount_adls_passthrough == true, cluster should also have option cluster_conf_passthrought == true"
  default     = null
}

variable "key_vault_secret_scope" {
  type = object({
    key_vault_id = string
    dns_name     = string
  })
  description = "Object with Azure Key Vault parameters required for creation of Azure-backed Databricks Secret scope"
  default = {
    key_vault_id = null
    dns_name     = null
  }
}
