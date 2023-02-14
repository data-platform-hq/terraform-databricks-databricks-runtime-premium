locals {
  secrets_acl_objects_list = flatten([for param in var.secret_scope_object : [
    for permission in param.acl : {
      scope = param.scope_name, principal = permission.principal, permission = permission.permission
    }] if param.acl != null
  ])

  cluster_permissions_objects_list = [for k, v in var.iam : {
    cluster_id = var.default_cluster_id, group_name = k, permission_level = v.default_cluster_permission
    } if v.default_cluster_permission != null
  ]
}

resource "databricks_permissions" "default_cluster" {
  for_each = { for entry in local.cluster_permissions_objects_list : "${entry.group_name}.${entry.permission_level}" => entry }

  cluster_id = each.value.cluster_id

  access_control {
    group_name       = databricks_group.this[each.value.group_name].display_name
    permission_level = each.value.permission_level
  }
}

resource "databricks_permissions" "cluster_policy" {
  for_each = {
    for policy in var.cluster_policies_object : (policy.name) => policy
    if policy.can_use != null
  }

  cluster_policy_id = each.value.id

  dynamic "access_control" {
    for_each = each.value.can_use
    content {
      group_name       = databricks_group.this[access_control.value].display_name
      permission_level = "CAN_USE"
    }
  }
}

resource "databricks_permissions" "sql_endpoint" {
  for_each = { for entry in databricks_sql_endpoint.this : (entry.name) => (entry.id) }

  sql_endpoint_id = each.value

  dynamic "access_control" {
    for_each = { for entry in flatten([for resource, permissions in var.iam_permissions : [for permission, groups in permissions : [for group in groups : {
      resource = resource, permission = permission, group = group
    } if resource == "sql_endpoint"]]]) : "${entry.resource}.${entry.permission}.${entry.group}" => entry }
    content {
      group_name       = access_control.value.group
      permission_level = access_control.value.permission
    }
  }

  depends_on = [databricks_group.this]
}

resource "databricks_secret_acl" "this" {
  for_each = { for entry in local.secrets_acl_objects_list : "${entry.scope}.${entry.principal}.${entry.permission}" => entry }

  scope      = each.value.scope
  principal  = databricks_group.this[each.value.principal].display_name
  permission = each.value.permission
}
