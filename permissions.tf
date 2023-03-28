locals {
  secrets_acl_objects_list = flatten([for param in var.secret_scope_object : [
    for permission in param.acl : {
      scope = param.scope_name, principal = permission.principal, permission = permission.permission
    }] if param.acl != null
  ])
}

resource "databricks_permissions" "default_cluster" {
  for_each = coalesce(flatten([values(var.iam)[*].default_cluster_permission, "none"])...) != "none" ? var.default_cluster_id : {}

  cluster_id = each.value

  dynamic "access_control" {
    for_each = { for k, v in var.iam : k => v.default_cluster_permission if v.default_cluster_permission != null }
    content {
      group_name       = databricks_group.this[access_control.key].display_name
      permission_level = access_control.value
    }
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

resource "databricks_permissions" "unity_cluster" {
  count = var.unity_cluster_config.permissions != null && var.unity_cluster_enabled ? 1 : 0

  cluster_id = databricks_cluster.this[0].id

  dynamic "access_control" {
    for_each = var.unity_cluster_config.permissions
    content {
      group_name       = databricks_group.this[access_control.value.group_name].display_name
      permission_level = access_control.value.permission_level
    }
  }
}

resource "databricks_permissions" "sql_endpoint" {
  for_each = {
    for endpoint in var.sql_endpoint : (endpoint.name) => endpoint
    if endpoint.permissions != null
  }

  sql_endpoint_id = databricks_sql_endpoint.this[each.key].id

  dynamic "access_control" {
    for_each = each.value.permissions
    content {
      group_name       = databricks_group.this[access_control.value.group_name].display_name
      permission_level = access_control.value.permission_level
    }
  }
}

resource "databricks_secret_acl" "this" {
  for_each = { for entry in local.secrets_acl_objects_list : "${entry.scope}.${entry.principal}.${entry.permission}" => entry }

  scope      = each.value.scope
  principal  = databricks_group.this[each.value.principal].display_name
  permission = each.value.permission
}
