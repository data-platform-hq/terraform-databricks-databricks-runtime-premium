locals {
  secrets_acl_objects_list = flatten([for param in var.secret_scope : [
    for permission in param.acl : {
      scope = param.scope_name, principal = permission.principal, permission = permission.permission
    }] if param.acl != null
  ])
}

resource "databricks_permissions" "clusters" {
  for_each = {
    for v in var.clusters : (v.cluster_name) => v
    if length(v.permissions) != 0
  }

  cluster_id = databricks_cluster.cluster[each.key].id

  dynamic "access_control" {
    for_each = each.value.permissions
    content {
      group_name       = length(var.iam_account_groups) != 0 ? data.databricks_group.account_groups[access_control.value.group_name].display_name : databricks_group.this[access_control.value.group_name].display_name
      permission_level = access_control.value.permission_level
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for i in each.value.permissions : contains(var.iam_account_groups[*].group_name, i.group_name)])
      error_message = "Incorrect group_name set for permission 'databricks_cluster_configs' settings"
    }
  }
}

resource "databricks_permissions" "sql_endpoint" {
  for_each = {
    for endpoint in var.sql_endpoint : (endpoint.name) => endpoint
    if length(endpoint.permissions) != 0
  }

  sql_endpoint_id = databricks_sql_endpoint.this[each.key].id

  dynamic "access_control" {
    for_each = each.value.permissions
    content {
      group_name       = length(var.iam_account_groups) != 0 ? data.databricks_group.account_groups[access_control.value.group_name].display_name : databricks_group.this[access_control.value.group_name].display_name
      permission_level = access_control.value.permission_level
    }
  }

  lifecycle {
    precondition {
      condition     = alltrue([for i in each.value.permissions : contains(var.iam_account_groups[*].group_name, i.group_name)])
      error_message = "Incorrect group_name set for permission 'databricks_sql_endpoint' settings"
    }
  }
}

resource "databricks_secret_acl" "this" {
  for_each = { for entry in local.secrets_acl_objects_list : "${entry.scope}.${entry.principal}.${entry.permission}" => entry }

  scope      = databricks_secret_scope.this[each.value.scope].name
  principal  = length(var.iam_account_groups) != 0 ? data.databricks_group.account_groups[each.value.principal].display_name : databricks_group.this[each.value.principal].display_name
  permission = each.value.permission

  lifecycle {
    precondition {
      condition     = alltrue([contains(var.iam_account_groups[*].group_name, each.value.principal)])
      error_message = "Incorrect principal set for acl databricks_secret_scope settings"
    }
  }
}
