# Databricks Premium Workspace Terraform module
Terraform module used for management of Databricks Premium Resources

## Usage
### **Requires Workspace with "Premium" SKU** 

The main idea behind this module is to deploy resources for Databricks Workspace with Premium SKU only.

Here we provide some examples of how to provision it with a different options.

### In example below, these features of given module would be covered:
1. Workspace admins assignment, custom Workspace group creation, group assignments, group entitlements
2. Workspace IP Access list creation
3. SQL Endpoint creation and configuration 
4. Create Cluster policy and assign permissions to custom groups 
5. Create Secret Scope and assign permissions to custom groups
6. Connect to already existing Unity Catalog Metastore

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

# Given module is tightly coupled with this "Runtime Premium" module, it's usage is prerequisite.
module "databricks_runtime_core" {
  source  = "data-platform-hq/databricks-runtime/databricks"

  sku          = data.databricks_workspace.example.sku
  workspace_id = data.databricks_workspace.example.workspace_id

  # Parameters of Service principal used for ADLS mount
  # Imports App ID and Secret of Service Principal from target Key Vault
  key_vault_id             =  data.azurerm_key_vault.example.id
  sp_client_id_secret_name = "sp-client-id" # secret's name that stores Service Principal App ID
  sp_key_secret_name       = "sp-key" # secret's name that stores Service Principal Secret Key
  tenant_id_secret_name    = "infra-arm-tenant-id" # secret's name that stores tenant id value

  # Default cluster parameters
  custom_cluster_policies = [{
    name     = "custom_policy_1",
    assigned = true, # automatically assigns this policy to default shared cluster if set 'true'
    can_use  =  "DEVELOPERS", # custom workspace group name, that is allowed to use this policy
    definition = {
      "autoscale.max_workers": {
        "type": "range",
        "maxValue": 3,
        "defaultValue": 2
      },
    }
  }]

  # Additional Secret Scope
  secret_scope = [{
    scope_name = "extra-scope"
    # Only custom workspace group names are allowed. If left empty then only Workspace admins could access these keys
    acl = [
      { principal = "DEVELOPERS", permission = "READ" }
    ] 
    secrets = [
      { key = "secret-name", string_value = "secret-value"}
    ]
  }]

  providers = {
    databricks = databricks.main
  }
}

# Example usage of module for Runtime Premium resources.
module "databricks_runtime_premium" {
  source  = "data-platform-hq/databricks-runtime-premium/databricks"

  project  = "datahq"
  env      = "example"
  location = "eastus"
  
  # Workspace could be accessed only from these IP Addresses:
  ip_rules = {
    "ip_range_1" = "10.128.0.0/16",
    "ip_range_2" = "10.33.0.0/16",
  }
  
  # Here is the map of users and theirs object ids. 
  # This step is optional, in case of Service Principal assignment to workspace, 
  # please only required to provide APP ID as it's value
  user_object_ids = {
    "example-service-principal" = "ebfasddf-05sd-4sdc-aasa-ddffgs83c299"
    "user1@example.com"         = "ebfasddf-05sd-4sdc-aasa-ddffgs83c256"
    "user2@example.com"         = "ebfasddf-05sd-4sdc-aasa-ddffgs83c865"
  }
  
  # To connect to already existing metastore you have to provide it's id.
  # An example of new Metastore creation provided below
  databricks_external_metastore_id = "<uuid-of-metastore>"
  
  # Workspace admins
  workspace_admins = {
    user = [
      "user1@example.com"
    ]
    service_principal = [
      "example-app-id"
    ]
  }
  
  # Custom Workspace group with assigned users/service_principals.
  # In addition, provides an ability to create group entitlements and assign permission to a custom group on default cluster.
  iam = {
    DEVELOPERS = {
      user = [
        "user1@example.com",
        "user2@example.com"
      ]
    "service_principal" = []
    entitlements = ["allow_instance_pool_create","allow_cluster_create","databricks_sql_access"]
    default_cluster_permission = "CAN_RESTART" # assigns certain permission on default cluster to created group
    }
  }
  
  # Default cluster params, this cluster created in "Runtime Core module"
  default_cluster_id      = { default = module.databricks_runtime_core.cluster_id } 
  
  # Assigns permission on cluster policy to a custom group ("DEVELOPERS" in this example) 
  cluster_policies_object = module.databricks_runtime_core.cluster_policies_object
  
  # Assigns acls on secret scope to a custom group ("DEVELOPERS" in this example) 
  secret_scope_object     = module.databricks_runtime_core.secret_scope_object
  
  providers = {
    databricks = databricks.main
  }
}
```

### Create Unity Catalog metastore
An example below explains to create Unity Catalog Metastore. 
It is highly recommended to create Metastore on separate environment or even Azure subscription.

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

# This Access connector cloud be created with Databricks Workspace module
resource "azurerm_databricks_access_connector" "example" {
  name                = "databrickstest"
  resource_group_name = "example-rg"
  location            = "eastus"

  identity {
    type = "SystemAssigned"
  }
}

# Storage Account where metastore would be created
data "azurerm_storage_account" "example" {
  name                = "metastore"
  resource_group_name = "example-rg"
}

# Example usage of module for Unity Catalog Metastore creation
module "databricks_runtime_premium" {
  source  = "data-platform-hq/databricks-runtime-premium/databricks"

  project  = "datahq"
  env      = "example"
  location = "eastus"

  ip_rules = {
    "example_devops-0" = "10.128.0.0/16",
    "example_devops-1" = "10.33.0.0/16",
  }
  user_object_ids = {
    "example-app-id"    = "ebfasddf-05sd-4sdc-aasa-ddffgs83c299"
    "user1@example.com" = "ebfasddf-05sd-4sdc-aasa-ddffgs83c256"
  }
  
  # Unity Catalog
  create_metastore      = true
  metastore_grants      = { "account users" = ["CREATE_CATALOG"] }
  
  access_connector_id   = azurerm_databricks_access_connector.example.id
  workspace_id          = data.azurerm_databricks_workspace.example.id
  
  
  catalog = {
    catalog-one-data = {
      catalog_grants = {
        "user1@example.com" = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
        "account users"    = ["USE_CATALOG", "USE_SCHEMA", "SELECT"]
      }
      catalog_comment = "This catalog is created by Terraform"
      schema_name        = ["schema1", "schema2", "schema3"]
      schema_grants      = {
        "account_users" = ["USE_SCHEMA", "CREATE_TABLE","CREATE_VIEW", "MODIFY"]
      }
      schema_comment     = "Created by terraform. Allowed for SELECT operations"
      schema_properties  = { allowed = "all users"}
    }
    
    catalog-two-admin = {
      catalog_grants = {
        "user1@example.com" = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA", "CREATE_TABLE", "SELECT", "MODIFY"]
      }
      catalog_comment = "This catalog is created by Terraform"
      schema_name        = ["schema1"]
      schema_properties  = { allowed = "admin only"}
    }
}
  
  # Storage Account where Metastore would be created
  storage_account_id    = data.azurerm_storage_account.example.id
  storage_account_name  = data.azurerm_storage_account.example.name

  # Permissions
  workspace_admins = {
    user = [
      "user1@example.com",
    ]
    service_principal = [
      "example-app-id"
    ]
  }
  
  providers = {
    databricks = databricks.main
  }
}
```


<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version   |
| ---------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.0.0  |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.9.2  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)          | >= 3.40.0 |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.9.2   |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | 3.40.0  |

## Modules

No modules.

## Resources

| Name                                                                                                                                                                | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [databricks_group.admin](https://registry.terraform.io/providers/databricks/databricks/latest/docs/data-sources/group)                                              | data     |
| [databricks_group.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group)                                                  | resource |
| [databricks_user.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user)                                                    | resource |
| [databricks_service_principal.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal)                          | resource |
| [databricks_group_member.admin](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)                                   | resource |
| [databricks_group_member.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)                                    | resource |
| [databricks_entitlements.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/entitlements)                                    | resource |
| [databricks_permissions.default_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions)                           | resource |
| [databricks_permissions.cluster_policy](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions)                            | resource |
| [databricks_permissions.sql_endpoint](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions)                              | resource |
| [databricks_secret_acl.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_acl)                                        | resource |
| [databricks_workspace_conf.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_conf)                                | resource |
| [databricks_ip_access_list.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/ip_access_list)                                | resource |
| [databricks_sql_global_config.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_global_config)                          | resource |
| [databricks_sql_endpoint.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_endpoint)                                    | resource |
| [azurerm_storage_data_lake_gen2_filesystem.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_data_lake_gen2_filesystem) | resource |
| [databricks_metastore.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore)                                          | resource |
| [databricks_grants.metastore](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                                           | resource |
| [databricks_metastore_data_access.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_data_access)                  | resource |
| [databricks_metastore_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/metastore_assignment)                    | resource |
| [databricks_catalog.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/catalog)                                              | resource |
| [databricks_grants.catalog](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/grants)                                             | resource |
| [databricks_schema.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_endpoint)                                          | resource |
| [databricks_grants.schema](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/schema)                                              | resource |



## Inputs

| Name                                                                                                        | Description                                                                                                                                                                    | Type                                                                                                                                                                                                                                                                                                                                                                                              | Default                                                                                                                 | Required |
| ----------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_project"></a> [project](#input\_project)                                                     | Project name                                                                                                                                                                   | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                     |   yes    |
| <a name="input_env"></a> [env](#input\_env)                                                                 | Environment name                                                                                                                                                               | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                     |   yes    |
| <a name="input_location"></a> [location](#input\_location)                                                  | Azure location                                                                                                                                                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                     |   yes    |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id)                                    | Id of Azure Databricks workspace                                                                                                                                               | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                     |   yes    |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules)                                                | Map of IP addresses permitted for access to DB                                                                                                                                 | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                     | {}                                                                                                                      |    no    |
| <a name="input_user_object_ids"></a> [user\_object\_ids](#input\_user\_object\_ids)                         | Map of AD usernames and corresponding object IDs                                                                                                                               | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                     | {}                                                                                                                      |    no    |
| <a name="input_workspace_admins"></a> [workspace\_admins](#input\_workspace\_admins)                        | Provide users or service principals to grant them Admin permissions in Workspace.                                                                                              | <pre> object({ <br>    user              = list(string) <br>    service_principal = list(string)<br>  }) </pre>                                                                                                                                                                                                                                                                                   | <pre> { <br>   user              = null <br>   service_principal = null <br> } </pre>                                   |    no    |
| <a name="input_iam"></a> [iam](#input\_iam)                                                                 | Used to create workspace group. Map of group name and its parameters, such as users and service principals added to the group. Also possible to configure group entitlements.  | <pre> map(object({ <br>   user              = optional(list(string)) <br>   service_principal = optional(list(string)) <br>   entitlements      = optional(list(string)) <br> }))</pre>                                                                                                                                                                                                           | {}                                                                                                                      |    no    |
| <a name="input_iam_permissions"></a> [iam\_permissions](#input\_iam\_permissions)                           | Map of permission for groups. You can provide certain permission on services to groups. E.g., `'sql_endpoint'={'CAN_USE'=['group1', 'group2'] CAN_MANAGE=['group3']}           | <pre>  map(object({ <br>    CAN_USE    = list(string) <br>    CAN_MANAGE = list(string)<br>  })) </pre>                                                                                                                                                                                                                                                                                           | <pre> { <br>   "sql_endpoint" = { <br>     "CAN_USE"    = ["default"] <br>     "CAN_MANAGE" = [] <br>   } <br> } </pre> |    no    |
| <a name="input_default_cluster_id"></a> [default\_cluster\_id](#input\_default\_cluster\_id)                | Single value of default Cluster id created by 'databricks-runtime' module                                                                                                      | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                     | {}                                                                                                                      |    no    |
| <a name="input_cluster_policies_object"></a> [cluster\_policies\_object](#input\_cluster\_policies\_object) | List of objects that provides an ability to grant custom workspace group a permission to use(CAN_USE) cluster policy                                                           | <pre>list(object({<br>  id      = string<br>  name    = string<br>  can_use = list(string)<br>}))</pre>                                                                                                                                                                                                                                                                                           | <pre>[{<br>  id      = null<br>  name    = null<br>  can_use = null<br>}))</pre>                                        |    no    |
| <a name="input_sql_endpoint"></a> [sql\_endpoint](#input\_sql\_endpoint)                                    | Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups                                                                | <pre> map(object({ <br>   cluster_size              = string <br>   min_num_clusters          = optional(number) <br>   max_num_clusters          = optional(number) <br>   auto_stop_mins            = optional(string) <br>   enable_photon             = optional(bool) <br>   enable_serverless_compute = optional(bool) <br> })) </pre>                                                      | {}                                                                                                                      |    no    |
| <a name="input_create_metastore"></a> [create\_metastore](#input\_create\_metastore)                        | Boolean flag for Unity Catalog Metastore current in this environment. One Metastore per region                                                                                 | `bool`                                                                                                                                                                                                                                                                                                                                                                                            | false                                                                                                                   |    no    |
| <a name="input_access_connector_id"></a> [access\_connector\_id](#input\_access\_connector\_id)             | Databricks Access Connector Id that lets you to connect managed identities to an Azure Databricks account. Provides an ability to access Unity Catalog with assigned identity  | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                     |    no    |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id)                | Storage Account Id where Unity Catalog Metastore would be provisioned                                                                                                          | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                     |    no    |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)          | Storage Account Name where Unity Catalog Metastore would be provisioned                                                                                                        | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                     |    no    |
| <a name="input_catalog"></a> [catalog](#input\_catalog)                                                     | Map of SQL Endpoints to be deployed in Databricks Workspace                                                                                                                    | <pre> map(object({ <br>   catalog_grants     = optional(map(list(string))) <br>   catalog_comment    = optional(string) <br>   catalog_properties = optional(map(string)) <br>   schema_name        = optional(list(string)) <br>   schema_grants      = optional(map(list(string))) <br>   schema_comment     = optional(string) <br>   schema_properties  = optional(map(string))<br>})) </pre> | {}                                                                                                                      |    no    |
| <a name="input_suffix"></a> [suffix](#input\_suffix)                                                        | Optional suffix that would be added to the end of resources names.                                                                                                             | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                     |    no    |
| <a name="input_external_metastore_id"></a> [external\_metastore\_id](#input\_external\_metastore\_id)       | Unity Catalog Metastore Id that is located in separate environment. Provide this value to associate Databricks Workspace with target Metastore                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                     |    no    |
| <a name="input_metastore_grants"></a> [metastore\_grants](#input\_metastore\_grants)                        | Permissions to give on metastore to group                                                                                                                                      | `map(list(string))`                                                                                                                                                                                                                                                                                                                                                                               | {}                                                                                                                      |    no    |
| <a name="input_secret_scope_object"></a> [secret\_scope\_object](#input\_secret\_scope\_object)             | List of objects, where 'scope_name' param is a Secret scope name and 'acl' are list of objects with 'principals' and one of allowed 'permission' ('READ', 'WRITE' or 'MANAGE') | <pre>list(object({<br> scope_name = string<br> acl = list(object({<br>   principal  = string<br>   permission = string<br>   }))<br>}))</pre>                                                                                                                                                                                                                                                     | <pre>[{<br>  scope_name = null<br>  acl        = null<br>}]</pre>                                                       |    no    |




## Outputs

| Name                                                                                                                          | Description                             |
| ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| <a name="output_sql_endpoint_jdbc_url"></a> [sql\_endpoint\_jdbc\_url](#output\_sql\_endpoint\_jdbc\_url)                     | JDBC connection string of SQL Endpoint  |
| <a name="output_sql_endpoint_data_source_id"></a> [sql\_endpoint\_data\_source\_id](#output\_sql\_endpoint\_data\_source\_id) | ID of the data source for this endpoint |
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id)                                                    | Unity Catalog Metastore Id              |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/blob/main/LICENSE)
