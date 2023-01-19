# Databricks Premium Workspace Terraform module
Terraform module used for managment of Databricks Premium Resources

## Usage

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version  |
| ---------------------------------------------------------------------------- | -------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.0.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.9.0 |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.9.0   |

## Modules

No modules.

## Resources

| Name                                                                                                                                                 | Type     |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [databricks_group.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group)                                   | resource |
| [databricks_user.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user)                                     | resource |
| [databricks_service_principal.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/service_principal)           | resource |
| [databricks_permission_assignment.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permission_assignment)   | resource |
| [databricks_group_member.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/group_member)                     | resource |
| [databricks_entitlements.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/entitlements)                     | resource |
| [databricks_permissions.sql_endpoint](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions)               | resource |
| [databricks_permissions.token](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/permissions)                      | resource |
| [databricks_workspace_conf.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/workspace_conf)                 | resource |
| [databricks_ip_access_list.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/ip_access_list)                 | resource |
| [databricks_sql_endpoint.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/sql_endpoint)                     | resource |


## Inputs

| Name                                                                                                                      | Description                                                                                                                                                                                        | Type                                                                                                                                                                                                                                                                                  | Default                                                                                                                                                                                                                                                                 | Required |
| ------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_env"></a> [env](#input\_env) | Environment name | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | Project name | `string` | n/a | yes |
| <a name="input_user_object_ids"></a> [user\_object\_ids](#input\_user\_object\_ids) | Map of AD usernames and corresponding object IDs | `map(string)` | {} | no |
| <a name="input_workspace_admins"></a> [workspace\_admins](#input\_workspace\_admins) | Provide users or service principals to grant them Admin permissions. | <pre> object({ <br>    user              = list(string) <br>    service_principal = list(string)<br>  }) </pre> |<pre> { <br>   user              = null <br>   service_principal = null <br> } </pre> | no |
| <a name="input_iam"></a> [iam](#input\_iam) | Used to create workspace group. Map of group name and its parameters, such as users and service principals added to the group. Also possible to configure group entitlements. | <pre> map(object({ <br>   user              = optional(list(string)) <br>   service_principal = optional(list(string)) <br>   entitlements      = optional(list(string)) <br> }))</pre> | {} | no |
| <a name="input_iam_permissions"></a> [iam\_permissions](#input\_iam\_permissions) | Map of permission for groups. You can provide certain permission on services to groups. E.g., `'sql_endpoint'={'CAN_USE'=['group1', 'group2'] CAN_MANAGE=['group3']} | <pre>  map(object({ <br>    CAN_USE    = list(string) <br>    CAN_MANAGE = list(string)<br>  })) </pre> | <pre> { <br>   "sql_endpoint" = { <br>     "CAN_USE"    = ["default"] <br>     "CAN_MANAGE" = [] <br>   } <br>   "token" = { <br>     "CAN_USE"    = ["default"] <br>     "CAN_MANAGE" = [] <br>   } <br> } </pre> | no |
| <a name="input_ip_rules"></a> [ip\_rules](#input\_ip\_rules)| Map of IP addresses permitted for access to DB | `map(string)` | {} | no |
| <a name="input_sql_endpoint"></a> [sql\_endpoint](#input\_sql\_endpoint) | Map of SQL Endoints to be deployed in Databricks Workspace | `map(map(string))` | {} | no |
| <a name="input_default_values_sql_endpoint"></a> [default\_values\_sql\_endpoint](#input\_default\_values\_sql\_endpoint) | Default values for SQL Endpoint | <pre> object({ <br>   cluster_size              = string <br>   min_num_clusters          = number <br>   max_num_clusters          = number <br>   auto_stop_mins            = string <br>   enable_photon             = bool <br>   enable_serverless_compute = bool <br> }) </pre> | <pre> { <br>   cluster_size              = "2X-Small" <br>   min_num_clusters          = 0 <br>   max_num_clusters          = 1 <br>   auto_stop_mins            = "30" <br>   enable_photon             = false <br>   enable_serverless_compute = false <br> } </pre> | no |

## Outputs

| Name                                                                                                                          | Description                             |
| ----------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| <a name="output_sql_endpoint_jdbc_url"></a> [sql\_endpoint\_jdbc\_url](#output\_sql\_endpoint\_jdbc\_url)                     | JDBC connection string of SQL Endpoint  |
| <a name="output_sql_endpoint_data_source_id"></a> [sql\_endpoint\_data\_source\_id](#output\_sql\_endpoint\_data\_source\_id) | ID of the data source for this endpoint |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime-premium/blob/main/LICENSE)
