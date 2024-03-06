# TODO - UPDATE DOCS
# Databricks Premium Workspace Terraform module
Terraform module used for management of Databricks Premium Resources

## Usage
### **Requires Workspace with "Premium" SKU** 

The main idea behind this module is to deploy resources for Databricks Workspace with Premium SKU only.

Here we provide some examples of how to provision it with a different options.

### In example below, these features of given module would be covered:
1. Workspace admins assignment, custom Workspace group creation, group assignments, group entitlements
2. Clusters (i.e., for Unity Catalog and Shared Autoscaling)             
3. Workspace IP Access list creation                                     
4. ADLS Gen2 Mount                                                       
5. Create Secret Scope and assign permissions to custom groups                                                  
6. SQL Endpoint creation and configuration                               
7. Create Cluster policy                                                 
8. Create an Azure Key Vault-backed secret scope                         
9. Connect to already existing Unity Catalog Metastore                   

```hcl
# Prerequisite resources

# Databricks Workspace with Premium SKU
data "azurerm_databricks_workspace" "example" {
  name                = "example-workspace"
  resource_group_name = "example-rg"
}

# Databricks Provider configuration
provider "databricks" {
  alias                       = "main"
  host                        = data.azurerm_databricks_workspace.example.workspace_url
  azure_workspace_resource_id = data.azurerm_databricks_workspace.example.id
}

# Key Vault where Service Principal's secrets are stored. Used for mounting Storage Container
data "azurerm_key_vault" "example" {
  name                = "example-key-vault"
  resource_group_name = "example-rg"
}

# Example usage of module for Runtime Premium resources.
module "databricks_runtime_premium" {
  source  = "data-platform-hq/databricks-runtime-premium/databricks"

  project  = "datahq"
  env      = "example"
  location = "eastus"

  # Parameters of Service principal used for ADLS mount
  # Imports App ID and Secret of Service Principal from target Key Vault
  key_vault_id             =  data.azurerm_key_vault.example.id
  sp_client_id_secret_name = "sp-client-id" # secret's name that stores Service Principal App ID
  sp_key_secret_name       = "sp-key" # secret's name that stores Service Principal Secret Key
  tenant_id_secret_name    = "infra-arm-tenant-id" # secret's name that stores tenant id value

  # 1.1 Workspace admins 
  workspace_admins = {
    user = ["user1@example.com"]
    service_principal = ["example-app-id"]
  }

  # 1.2 Custom Workspace group with assignments.
  # In addition, provides an ability to create group and entitlements.
  iam = [{
    group_name = "DEVELOPERS"
    permissions  = ["ADMIN"]
    entitlements = [
      "allow_instance_pool_create",
      "allow_cluster_create",
      "databricks_sql_access"
    ] 
  }]

  # 2. Databricks clusters configuration, and assign permission to a custom group on clusters.
  databricks_cluster_configs = [ {
    cluster_name       = "Unity Catalog"
    data_security_mode = "USER_ISOLATION"
    availability       = "ON_DEMAND_AZURE"
    spot_bid_max_price = 1
    permissions        = [{ group_name = "DEVELOPERS", permission_level = "CAN_RESTART" }]
  },
  {
    cluster_name       = "shared autoscaling"
    data_security_mode = "NONE"
    availability       = "SPOT_AZURE"
    spot_bid_max_price = -1
    permissions        = [{group_name = "DEVELOPERS", permission_level = "CAN_MANAGE"}]
  }]

  # 3. Workspace could be accessed only from these IP Addresses:
  ip_rules = {
    "ip_range_1" = "10.128.0.0/16",
    "ip_range_2" = "10.33.0.0/16",
  }
  
  # 4. ADLS Gen2 Mount
  mountpoints = {
    storage_account_name = data.azurerm_storage_account.example.name
    container_name       = "example_container"
  }

  # 5. Create Secret Scope and assign permissions to custom groups 
  secret_scope = [{
    scope_name = "extra-scope"
    acl        = [{ principal = "DEVELOPERS", permission = "READ" }] # Only custom workspace group names are allowed. If left empty then only Workspace admins could access these keys
    secrets    = [{ key = "secret-name", string_value = "secret-value"}]
  }]

  # 6. SQL Warehouse Endpoint
  databricks_sql_endpoint = [{
    name        = "default"  
    enable_serverless_compute = true  
    permissions = [{ group_name = "DEVELOPERS", permission_level = "CAN_USE" },]
  }]

  # 7. Databricks cluster policies
  custom_cluster_policies = [{
    name     = "custom_policy_1",
    can_use  =  "DEVELOPERS", # custom workspace group name, that is allowed to use this policy
    definition = {
      "autoscale.max_workers": {
        "type": "range",
        "maxValue": 3,
        "defaultValue": 2
      },
    }
  }]

  # 8. Azure Key Vault-backed secret scope
  key_vault_secret_scope = [{
    name         = "external"
    key_vault_id = data.azurerm_key_vault.example.id
    dns_name     = data.azurerm_key_vault.example.vault_uri
  }]  
    
  providers = {
    databricks = databricks.main
  }
}

# 9 Assignment already existing Unity Catalog Metastore
module "metastore_assignment" {
  source  = "data-platform-hq/metastore-assignment/databricks"
  version = "1.0.0"

  workspace_id = data.azurerm_databricks_workspace.example.workspace_id
  metastore_id = "<uuid-of-metastore>"

  providers = {
    databricks = databricks.workspace
  }
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >=3.40.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >=1.38.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >=3.40.0 |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | >=1.38.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault_access_policy.databricks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) | resource |
| [databricks_cluster.cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster) | resource |
| [databricks_cluster_policy.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster_policy) | resource |
| [databricks_entitlements.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/entitlements) | resource |
| [databricks_group.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group) | resource |
| [databricks_group_member.admin](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_group_member.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member) | resource |
| [databricks_ip_access_list.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/ip_access_list) | resource |
| [databricks_mount.adls](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mount) | resource |
| [databricks_permissions.clusters](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_permissions.sql_endpoint](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions) | resource |
| [databricks_secret.main](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret) | resource |
| [databricks_secret.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret) | resource |
| [databricks_secret_acl.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl) | resource |
| [databricks_secret_acl.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl) | resource |
| [databricks_secret_scope.external](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope) | resource |
| [databricks_secret_scope.main](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope) | resource |
| [databricks_secret_scope.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope) | resource |
| [databricks_service_principal.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal) | resource |
| [databricks_sql_endpoint.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_endpoint) | resource |
| [databricks_sql_global_config.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_global_config) | resource |
| [databricks_system_schema.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/system_schema) | resource |
| [databricks_token.pat](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token) | resource |
| [databricks_user.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user) | resource |
| [databricks_workspace_conf.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_conf) | resource |
| [databricks_group.account_groups](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group) | data source |
| [databricks_group.admin](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_clusters"></a> [clusters](#input\_clusters) | Set of objects with parameters to configure Databricks clusters and assign permissions to it for certain custom groups | <pre>set(object({<br>    cluster_name                 = string<br>    spark_version                = optional(string, "13.3.x-scala2.12")<br>    spark_conf                   = optional(map(any), {})<br>    cluster_conf_passthrought    = optional(bool, false)<br>    spark_env_vars               = optional(map(any), {})<br>    data_security_mode           = optional(string, "USER_ISOLATION")<br>    node_type_id                 = optional(string, "Standard_D3_v2")<br>    autotermination_minutes      = optional(number, 30)<br>    min_workers                  = optional(number, 1)<br>    max_workers                  = optional(number, 2)<br>    availability                 = optional(string, "ON_DEMAND_AZURE")<br>    first_on_demand              = optional(number, 0)<br>    spot_bid_max_price           = optional(number, 1)<br>    cluster_log_conf_destination = optional(string, null)<br>    init_scripts_workspace       = optional(set(string), [])<br>    init_scripts_volumes         = optional(set(string), [])<br>    init_scripts_dbfs            = optional(set(string), [])<br>    init_scripts_abfss           = optional(set(string), [])<br>    single_user_name             = optional(string, null)<br>    single_node_enable           = optional(bool, false)<br>    custom_tags                  = optional(map(string), { "ResourceClass" = "SingleNode" })<br>    permissions = optional(set(object({<br>      group_name       = string<br>      permission_level = string<br>    })), [])<br>    pypi_library_repository = optional(set(string), [])<br>    maven_library_repository = optional(set(object({<br>      coordinates = string<br>      exclusions  = set(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_create_databricks_access_policy_to_key_vault"></a> [create\_databricks\_access\_policy\_to\_key\_vault](#input\_create\_databricks\_access\_policy\_to\_key\_vault) | Boolean flag to enable creation of Key Vault Access Policy for Databricks Global Service Principal. | `bool` | `true` | no |
| <a name="input_custom_cluster_policies"></a> [custom\_cluster\_policies](#input\_custom\_cluster\_policies) | Provides an ability to create custom cluster policy, assign it to cluster and grant CAN\_USE permissions on it to certain custom groups<br>name - name of custom cluster policy to create<br>can\_use - list of string, where values are custom group names, there groups have to be created with Terraform;<br>definition - JSON document expressed in Databricks Policy Definition Language. No need to call 'jsonencode()' function on it when providing a value; | <pre>list(object({<br>    name       = string<br>    can_use    = list(string)<br>    definition = any<br>  }))</pre> | <pre>[<br>  {<br>    "can_use": null,<br>    "definition": null,<br>    "name": null<br>  }<br>]</pre> | no |
| <a name="input_global_databricks_sp_object_id"></a> [global\_databricks\_sp\_object\_id](#input\_global\_databricks\_sp\_object\_id) | Global 'AzureDatabricks' SP object id. Used to create Key Vault Access Policy for Secret Scope | `string` | `"9b38785a-6e08-4087-a0c4-20634343f21f"` | no |
| <a name="input_iam_account_groups"></a> [iam\_account\_groups](#input\_iam\_account\_groups) | List of objects with group name and entitlements for this group | <pre>list(object({<br>    group_name   = optional(string)<br>    entitlements = optional(list(string))<br>  }))</pre> | `[]` | no |
| <a name="input_iam_workspace_groups"></a> [iam\_workspace\_groups](#input\_iam\_workspace\_groups) | Used to create workspace group. Map of group name and its parameters, such as users and service principals added to the group. Also possible to configure group entitlements. | <pre>map(object({<br>    user              = optional(list(string))<br>    service_principal = optional(list(string))<br>    entitlements      = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules) | Map of IP addresses permitted for access to DB | `map(string)` | `{}` | no |
| <a name="input_key_vault_secret_scope"></a> [key\_vault\_secret\_scope](#input\_key\_vault\_secret\_scope) | Object with Azure Key Vault parameters required for creation of Azure-backed Databricks Secret scope | <pre>list(object({<br>    name         = string<br>    key_vault_id = string<br>    dns_name     = string<br>    tenant_id    = string<br>  }))</pre> | `[]` | no |
| <a name="input_mount_adls_passthrough"></a> [mount\_adls\_passthrough](#input\_mount\_adls\_passthrough) | Boolean flag to use mount options for credentials passthrough. Should be used with mount\_cluster\_name, specified cluster should have option cluster\_conf\_passthrought == true | `bool` | `false` | no |
| <a name="input_mount_cluster_name"></a> [mount\_cluster\_name](#input\_mount\_cluster\_name) | Name of the cluster that will be used during storage mounting. If mount\_adls\_passthrough == true, cluster should also have option cluster\_conf\_passthrought == true | `string` | `null` | no |
| <a name="input_mount_enabled"></a> [mount\_enabled](#input\_mount\_enabled) | Boolean flag that determines whether mount point for storage account filesystem is created | `bool` | `false` | no |
| <a name="input_mount_service_principal_client_id"></a> [mount\_service\_principal\_client\_id](#input\_mount\_service\_principal\_client\_id) | Application(client) Id of Service Principal used to perform storage account mounting | `string` | `null` | no |
| <a name="input_mount_service_principal_secret"></a> [mount\_service\_principal\_secret](#input\_mount\_service\_principal\_secret) | Service Principal Secret used to perform storage account mounting | `string` | `null` | no |
| <a name="input_mount_service_principal_tenant_id"></a> [mount\_service\_principal\_tenant\_id](#input\_mount\_service\_principal\_tenant\_id) | Service Principal tenant id used to perform storage account mounting | `string` | `null` | no |
| <a name="input_mountpoints"></a> [mountpoints](#input\_mountpoints) | Mountpoints for databricks | <pre>map(object({<br>    storage_account_name = string<br>    container_name       = string<br>  }))</pre> | `{}` | no |
| <a name="input_pat_token_lifetime_seconds"></a> [pat\_token\_lifetime\_seconds](#input\_pat\_token\_lifetime\_seconds) | The lifetime of the token, in seconds. If no lifetime is specified, the token remains valid indefinitely | `number` | `315569520` | no |
| <a name="input_secret_scope"></a> [secret\_scope](#input\_secret\_scope) | Provides an ability to create custom Secret Scope, store secrets in it and assigning ACL for access management<br>scope\_name - name of Secret Scope to create;<br>acl - list of objects, where 'principal' custom group name, this group is created in 'Premium' module; 'permission' is one of "READ", "WRITE", "MANAGE";<br>secrets - list of objects, where object's 'key' param is created key name and 'string\_value' is a value for it; | <pre>list(object({<br>    scope_name = string<br>    acl = optional(list(object({<br>      principal  = string<br>      permission = string<br>    })))<br>    secrets = optional(list(object({<br>      key          = string<br>      string_value = string<br>    })))<br>  }))</pre> | <pre>[<br>  {<br>    "acl": null,<br>    "scope_name": null,<br>    "secrets": null<br>  }<br>]</pre> | no |
| <a name="input_sql_endpoint"></a> [sql\_endpoint](#input\_sql\_endpoint) | Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups | <pre>set(object({<br>    name                      = string<br>    cluster_size              = optional(string, "2X-Small")<br>    min_num_clusters          = optional(number, 0)<br>    max_num_clusters          = optional(number, 1)<br>    auto_stop_mins            = optional(string, "30")<br>    enable_photon             = optional(bool, false)<br>    enable_serverless_compute = optional(bool, false)<br>    spot_instance_policy      = optional(string, "COST_OPTIMIZED")<br>    warehouse_type            = optional(string, "PRO")<br>    permissions = optional(set(object({<br>      group_name       = string<br>      permission_level = string<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_suffix"></a> [suffix](#input\_suffix) | Optional suffix that would be added to the end of resources names. | `string` | `""` | no |
| <a name="input_system_schemas"></a> [system\_schemas](#input\_system\_schemas) | Set of strings with all possible System Schema names | `set(string)` | <pre>[<br>  "access",<br>  "billing",<br>  "compute",<br>  "marketplace",<br>  "storage"<br>]</pre> | no |
| <a name="input_system_schemas_enabled"></a> [system\_schemas\_enabled](#input\_system\_schemas\_enabled) | System Schemas only works with assigned Unity Catalog Metastore. Boolean flag to enabled this feature | `bool` | `false` | no |
| <a name="input_user_object_ids"></a> [user\_object\_ids](#input\_user\_object\_ids) | Map of AD usernames and corresponding object IDs | `map(string)` | `{}` | no |
| <a name="input_workspace_admins"></a> [workspace\_admins](#input\_workspace\_admins) | Provide users or service principals to grant them Admin permissions in Workspace. | <pre>object({<br>    user              = list(string)<br>    service_principal = list(string)<br>  })</pre> | <pre>{<br>  "service_principal": null,<br>  "user": null<br>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_clusters"></a> [clusters](#output\_clusters) | Provides name and unique identifier for the clusters |
| <a name="output_sql_endpoint_data_source_id"></a> [sql\_endpoint\_data\_source\_id](#output\_sql\_endpoint\_data\_source\_id) | ID of the data source for this endpoint |
| <a name="output_sql_endpoint_jdbc_url"></a> [sql\_endpoint\_jdbc\_url](#output\_sql\_endpoint\_jdbc\_url) | JDBC connection string of SQL Endpoint |
| <a name="output_token"></a> [token](#output\_token) | Databricks Personal Authorization Token |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/blob/main/LICENSE)
