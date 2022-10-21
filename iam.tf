data "databricks_group" "admins" {
  display_name = "admins"
}

resource "databricks_group" "this" {
  for_each = toset([for group in keys(var.iam) : group if group != "admins"])

  display_name = each.key
  lifecycle { ignore_changes = [external_id] }
}

resource "databricks_user" "this" {
  for_each = toset(flatten([for k, v in { for group, member in var.iam : group => member["user"] } : distinct(flatten(v))]))

  user_name             = each.value
  databricks_sql_access = true
  lifecycle { ignore_changes = [external_id] }
}

resource "databricks_service_principal" "this" {
  for_each = toset(flatten([for k, v in { for group, member in var.iam : group => member["service_principal"] } : distinct(flatten(v))]))

  display_name          = each.value
  application_id        = lookup(var.user_object_ids, each.value)
  databricks_sql_access = true
}

resource "databricks_group_member" "admin_users" {
  for_each = { for entry in flatten([for group, types in var.iam : [for type in types : [for member in type : {
    group = group, member = member
  } if group == "admins" && type == types["user"]]]]) : "${entry.group}.${entry.member}" => entry }

  group_id  = data.databricks_group.admins.id
  member_id = databricks_user.this[each.value.member].id
}

resource "databricks_group_member" "admin_service_principals" {
  for_each = { for entry in flatten([for group, types in var.iam : [for type in types : [for member in type : {
    group = group, member = member
  } if group == "admins" && type == types["service_principal"]]]]) : "${entry.group}.${entry.member}" => entry }

  group_id  = data.databricks_group.admins.id
  member_id = databricks_service_principal.this[each.value.member].id
}

resource "databricks_group_member" "users" {
  for_each = { for entry in flatten([for group, types in var.iam : [for type in types : [for member in type : {
    group = group, member = member
  } if group != "admins" && group != "users" && type == types["user"]]]]) : "${entry.group}.${entry.member}" => entry }

  group_id  = databricks_group.this[each.value.group].id
  member_id = databricks_user.this[each.value.member].id
}

resource "databricks_group_member" "service_principals" {
  for_each = { for entry in flatten([for group, types in var.iam : [for type in types : [for member in type : {
    group = group, member = member
  } if group != "admins" && group != "users" && type == types["service_principal"]]]]) : "${entry.group}.${entry.member}" => entry }

  group_id  = databricks_group.this[each.value.group].id
  member_id = databricks_service_principal.this[each.value.member].id
}

resource "databricks_permissions" "sql_endpoint" {
  for_each = { for entry in databricks_sql_endpoint.this : "${entry.name}" => "${entry.id}" }

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

resource "databricks_permissions" "token" {
  authorization = "tokens"

  dynamic "access_control" {
    for_each = { for entry in flatten([for resource, permissions in var.iam_permissions : [for permission, groups in permissions : [for group in groups : {
      resource = resource, permission = permission, group = group
    } if resource == "token"]]]) : "${entry.resource}.${entry.permission}.${entry.group}" => entry }
    content {
      group_name       = access_control.value.group
      permission_level = access_control.value.permission
    }
  }
  depends_on = [databricks_group.this]
}
