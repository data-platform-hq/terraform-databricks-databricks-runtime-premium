locals {
  admin_user_map = var.workspace_admins.user == null ? {} : {
    for user in var.workspace_admins.user : "user.${user}" => user if user != null
  }

  admin_sp_map = var.workspace_admins.service_principal == null ? {} : {
    for sp in var.workspace_admins.service_principal : "service_principal.${sp}" => sp if sp != null
  }

  members_object_list = concat(
    flatten([for group, params in var.iam : [
      for pair in setproduct([group], params.user) : {
        type = "user", group = pair[0], member = pair[1]
      }] if params.user != null
    ]),
    flatten([for group, params in var.iam : [
      for pair in setproduct([group], params.service_principal) : {
        type = "service_principal", group = pair[0], member = pair[1]
      }] if params.service_principal != null
    ])
  )
  account_groups = { for group in var.account_groups : group.name => group if group.name != null }
  iam_map        = length(var.iam) != 0 ? { for group, params in var.iam : group => params if length(var.account_groups) == 0 } : {}
}

data "databricks_group" "account_groups" {
  for_each = local.account_groups

  display_name = each.key
}

data "databricks_group" "admin" {
  display_name = "admins"
}

resource "databricks_group" "this" {
  for_each = length(local.account_groups) != 0 ? [] : toset(keys(var.iam))

  display_name = each.key
  lifecycle { ignore_changes = [external_id, allow_cluster_create, allow_instance_pool_create, databricks_sql_access, workspace_access] }
}

resource "databricks_user" "this" {
  for_each = toset(flatten(concat(
    values({ for group, member in var.iam : group => member.user if member.user != null }),
    values(local.admin_user_map)
  )))

  user_name = each.key
  lifecycle { ignore_changes = [external_id, allow_cluster_create, allow_instance_pool_create, databricks_sql_access, workspace_access] }
}

resource "databricks_service_principal" "this" {
  for_each = toset(flatten(concat(
    values({ for group, member in var.iam : group => member.service_principal if member.service_principal != null }),
    values(local.admin_sp_map)
  )))

  display_name   = each.key
  application_id = lookup(var.user_object_ids, each.value)
  lifecycle { ignore_changes = [external_id, allow_cluster_create, allow_instance_pool_create, databricks_sql_access, workspace_access] }
}

resource "databricks_group_member" "admin" {
  for_each = length(local.account_groups) != 0 ? {} : merge(local.admin_user_map, local.admin_sp_map)

  group_id  = data.databricks_group.admin.id
  member_id = startswith(each.key, "user") ? databricks_user.this[each.value].id : databricks_service_principal.this[each.value].id
}

resource "databricks_group_member" "this" {
  for_each = length(local.account_groups) != 0 ? {} : {
    for entry in local.members_object_list : "${entry.type}.${entry.group}.${entry.member}" => entry
  }

  group_id  = databricks_group.this[each.value.group].id
  member_id = startswith(each.key, "user") ? databricks_user.this[each.value.member].id : databricks_service_principal.this[each.value.member].id
}

resource "databricks_entitlements" "this" {
  for_each = merge(local.account_groups, local.iam_map)

  group_id                   = length(local.account_groups) != 0 ? data.databricks_group.account_groups[each.key].id : databricks_group.this[each.key].id
  allow_cluster_create       = contains(coalesce(each.value.entitlements, ["none"]), "allow_cluster_create")
  allow_instance_pool_create = contains(coalesce(each.value.entitlements, ["none"]), "allow_instance_pool_create")
  databricks_sql_access      = contains(coalesce(each.value.entitlements, ["none"]), "databricks_sql_access")
  workspace_access           = true

  depends_on = [databricks_group_member.this]
}
