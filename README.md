# Databricks Premium Workspace Terraform module
Terraform module used for management of Databricks Premium Resources

## Usage

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
| [databricks_permissions.unity_cluster](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions)                             | resource |
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
| [databricks_cluster.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster)                                              | resource |




## Inputs

| Name                                                                                                                      | Description                                                                                                                                                                    | Type                                                                                                                                                                                                                                                                                                                                                                                              | Default                                                                                                                                                                                                                                                                 | Required |
| ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_project"></a> [project](#input\_project)  | Project name   |  	`string`  | n/a |   yes    |
| <a name="input_env"></a> [env](#input\_env)                                                                               | Environment name                                                                                                                                                               | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                                                                                                                                                                     |   yes    |
| <a name="input_location"></a> [location](#input\_location)                                                                | Azure location                                                                                                                                                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                                                                                                                                                                     |   yes    |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id)                                                  | Id of Azure Databricks workspace                                                                                                                                               | `string`                                                                                                                                                                                                                                                                                                                                                                                          | n/a                                                                                                                                                                                                                                                                     |   yes    |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules)                                                              | Map of IP addresses permitted for access to DB                                                                                                                                 | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                     | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_user_object_ids"></a> [user\_object\_ids](#input\_user\_object\_ids)                                       | Map of AD usernames and corresponding object IDs                                                                                                                               | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                     | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_workspace_admins"></a> [workspace\_admins](#input\_workspace\_admins)                                      | Provide users or service principals to grant them Admin permissions in Workspace.                                                                                              | <pre> object({ <br>    user              = list(string) <br>    service_principal = list(string)<br>  }) </pre>                                                                                                                                                                                                                                                                                   | <pre> { <br>   user              = null <br>   service_principal = null <br> } </pre>                                                                                                                                                                                   |    no    |
| <a name="input_iam"></a> [iam](#input\_iam)                                                                               | Used to create workspace group. Map of group name and its parameters, such as users and service principals added to the group. Also possible to configure group entitlements.  | <pre> map(object({ <br>   user              = optional(list(string)) <br>   service_principal = optional(list(string)) <br>   entitlements      = optional(list(string)) <br> }))</pre>                                                                                                                                                                                                           | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_iam_permissions"></a> [iam\_permissions](#input\_iam\_permissions)                                         | Map of permission for groups. You can provide certain permission on services to groups. E.g., `'sql_endpoint'={'CAN_USE'=['group1', 'group2'] CAN_MANAGE=['group3']}           | <pre>  map(object({ <br>    CAN_USE    = list(string) <br>    CAN_MANAGE = list(string)<br>  })) </pre>                                                                                                                                                                                                                                                                                           | <pre> { <br>   "sql_endpoint" = { <br>     "CAN_USE"    = ["default"] <br>     "CAN_MANAGE" = [] <br>   } <br> } </pre>                                                                                                                                                 |    no    |
| <a name="input_default_cluster_id"></a> [default\_cluster\_id](#input\_default\_cluster\_id)                              | Single value of default Cluster id created by 'databricks-runtime' module                                                                                                      | `map(string)`                                                                                                                                                                                                                                                                                                                                                                                     | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_cluster_policies_object"></a> [cluster\_policies\_object](#input\_cluster\_policies\_object)               | List of objects that provides an ability to grant custom workspace group a permission to use(CAN_USE) cluster policy                                                           | <pre>list(object({<br>  id      = string<br>  name    = string<br>  can_use = list(string)<br>}))</pre>                                                                                                                                                                                                                                                                                           | <pre>[{<br>  id      = null<br>  name    = null<br>  can_use = null<br>}))</pre>                                                                                                                                                                                        |    no    |
| <a name="input_sql_endpoint"></a> [sql\_endpoint](#input\_sql\_endpoint)                                                  | Set of objects with parameters to configure SQL Endpoint and assign permissions to it for certain custom groups| <pre> map(object({ <br>   cluster_size              = string <br>   min_num_clusters          = optional(number) <br>   max_num_clusters          = optional(number) <br>   auto_stop_mins            = optional(string) <br>   enable_photon             = optional(bool) <br>   enable_serverless_compute = optional(bool) <br> })) </pre>                                                      | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_create_metastore"></a> [create\_metastore](#input\_create\_metastore)                                      | Boolean flag for Unity Catalog Metastore current in this environment. One Metastore per region                                                                                 | `bool`                                                                                                                                                                                                                                                                                                                                                                                            | false                                                                                                                                                                                                                                                                   |    no    |
| <a name="input_access_connector_id"></a> [access\_connector\_id](#input\_access\_connector\_id)                           | Databricks Access Connector Id that lets you to connect managed identities to an Azure Databricks account. Provides an ability to access Unity Catalog with assigned identity  | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id)                              | Storage Account Id where Unity Catalog Metastore would be provisioned                                                                                                          | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_storage_account_name"></a> [storage\_account\_name](#input\_storage\_account\_name)                        | Storage Account Name where Unity Catalog Metastore would be provisioned                                                                                                        | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_catalog"></a> [catalog](#input\_catalog)                                                                   | Map of SQL Endpoints to be deployed in Databricks Workspace                                                                                                                    | <pre> map(object({ <br>   catalog_grants     = optional(map(list(string))) <br>   catalog_comment    = optional(string) <br>   catalog_properties = optional(map(string)) <br>   schema_name        = optional(list(string)) <br>   schema_grants      = optional(map(list(string))) <br>   schema_comment     = optional(string) <br>   schema_properties  = optional(map(string))<br>})) </pre> | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_suffix"></a> [suffix](#input\_suffix)                                                                      | Optional suffix that would be added to the end of resources names.                                                                                                             | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_external_metastore_id"></a> [external\_metastore\_id](#input\_external\_metastore\_id)                     | Unity Catalog Metastore Id that is located in separate environment. Provide this value to associate Databricks Workspace with target Metastore                                 | `string`                                                                                                                                                                                                                                                                                                                                                                                          | " "                                                                                                                                                                                                                                                                     |    no    |
| <a name="input_metastore_grants"></a> [metastore\_grants](#input\_metastore\_grants)                                      | Permissions to give on metastore to group                                                                                                                                      | `map(list(string))`                                                                                                                                                                                                                                                                                                                                                                               | {}                                                                                                                                                                                                                                                                      |    no    |
| <a name="input_secret_scope_object"></a> [secret\_scope\_object](#input\_secret\_scope\_object)                           | List of objects, where 'scope_name' param is a Secret scope name and 'acl' are list of objects with 'principals' and one of allowed 'permission' ('READ', 'WRITE' or 'MANAGE') | <pre>list(object({<br> scope_name = string<br> acl = list(object({<br>   principal  = string<br>   permission = string<br>   }))<br>}))</pre>                                                                                                                                                                                                                                                     | <pre>[{<br>  scope_name = null<br>  acl        = null<br>}]</pre>                                                                                                                                                                                                       |    no    |
| <a name="input_unity_cluster_enabled"></a> [unity\_cluster\_enabled](#input\_unity\_cluster\_enabled)  | Boolean flag for creating databricks claster   | `bool` | false | no |
| <a name="input_unity_cluster_config"></a> [unity\_unity\_cluster\_config](#input\_unity\_cluster\_config)  | Specifies the databricks unity cluster configuration   |  <pre>object({ <br>   cluster_name            = optional(string)<br>   spark_version           = optional(string)<br>   spark_conf              = optional(map(any))<br>   spark_env_vars          = optional(map(any))<br>   data_security_mode      = optional(string)<br>   node_type_id            = optional(string)<br>   autotermination_minutes = optional(number)<br>   min_workers             = optional(number)<br>   max_workers             = optional(number)<br>   availability            = optional(string)<br>   first_on_demand         = optional(number)<br>   spot_bid_max_price      = optional(number)<br>   permissions = optional(set(object({<br>     group_name       = string<br>     permission_level = string<br>   })))<br>})<br></pre> |  <pre>object({ <br>   cluster_name            = optional("Unity Catalog")<br>   spark_version           = optional("11.3.x-scala2.12")<br>   spark_conf              = optional({})<br>   spark_env_vars          = optional({})<br>   data_security_mode      = optional("USER_ISOLATION")<br>   node_type_id            = optional("Standard_D3_v2")<br>   autotermination_minutes = optional(30)<br>   min_workers             = optional(1)<br>   max_workers             = optional(2)<br>   availability            = optional("ON_DEMAND_AZURE")<br>   first_on_demand         = optional(0)<br>   spot_bid_max_price      = optional(1)<br>   permissions = optional(set(object({<br>     group_name       = string<br>     permission_level = string<br>   })),null)<br>})<br></pre> |   no    |
| <a name="input_cluster_log_conf_destination"></a> [cluster\_log\_conf\_destination](#input\_cluster\_log\_conf\_destination)  | Provide a dbfs location, example 'dbfs:/cluster-logs', to push all cluster logs to certain location | `string` | " " | no |




## Outputs

| Name                                                                                                                          | Description                             |
| ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| <a name="output_sql_endpoint_jdbc_url"></a> [sql\_endpoint\_jdbc\_url](#output\_sql\_endpoint\_jdbc\_url)                     | JDBC connection string of SQL Endpoint  |
| <a name="output_sql_endpoint_data_source_id"></a> [sql\_endpoint\_data\_source\_id](#output\_sql\_endpoint\_data\_source\_id) | ID of the data source for this endpoint |
| <a name="output_metastore_id"></a> [metastore\_id](#output\_metastore\_id)                                                    | Unity Catalog Metastore Id              |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/blob/main/LICENSE)
