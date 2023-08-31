locals {
  mount_sp_secrets = {
    mount-sp-client-id = { value = var.mount_service_principal_client_id }
    mount-sp-secret    = { value = var.mount_service_principal_secret }
  }

  secrets_objects_list = flatten([for param in var.secret_scope : [
    for secret in param.secrets : {
      scope_name = param.scope_name, key = secret.key, string_value = secret.string_value
    }] if param.secrets != null
  ])
}

# Secret Scope with SP secrets for mounting Azure Data Lake Storage
resource "databricks_secret_scope" "main" {
  count = var.mount_enabled ? 1 : 0

  name                     = "main"
  initial_manage_principal = null
}

resource "databricks_secret" "main" {
  for_each = var.mount_enabled ? local.mount_sp_secrets : {}

  key          = each.key
  string_value = each.value["value"]
  scope        = databricks_secret_scope.main[0].id

  lifecycle {
    precondition {
      condition     = var.mount_enabled ? length(compact([var.mount_service_principal_client_id, var.mount_service_principal_secret, var.mount_service_principal_tenant_id])) == 3 : true
      error_message = "To mount ADLS Storage, please provide prerequisite Service Principal values - 'mount_service_principal_object_id', 'mount_service_principal_secret', 'mount_service_principal_tenant_id'."
    }
  }
}

# Custom additional Databricks Secret Scope
resource "databricks_secret_scope" "this" {
  for_each = {
    for param in var.secret_scope : (param.scope_name) => param
    if param.scope_name != null
  }

  name                     = each.key
  initial_manage_principal = null
}

resource "databricks_secret" "this" {
  for_each = { for entry in local.secrets_objects_list : "${entry.scope_name}.${entry.key}" => entry }

  key          = each.value.key
  string_value = each.value.string_value
  scope        = databricks_secret_scope.this[each.value.scope_name].id
}

# Azure Key Vault-backed Scope
resource "azurerm_key_vault_access_policy" "databricks" {
  for_each = var.create_databricks_access_policy_to_key_vault ? {
    for param in var.key_vault_secret_scope : (param.name) => param
    if length(param.name) != 0
  } : {}

  key_vault_id = each.value.key_vault_id
  object_id    = var.global_databricks_sp_object_id
  tenant_id    = each.value.tenant_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "databricks_secret_scope" "external" {
  for_each = {
    for param in var.key_vault_secret_scope : (param.name) => param
    if length(param.name) != 0
  }

  name = each.value.name
  keyvault_metadata {
    resource_id = each.value.key_vault_id
    dns_name    = each.value.dns_name
  }
  depends_on = [azurerm_key_vault_access_policy.databricks]
}

resource "databricks_secret_acl" "external" {
  for_each = {
    for param in var.key_vault_secret_scope : (param.name) => param
    if length(param.name) != 0
  }

  scope      = databricks_secret_scope.external[each.value.name].name
  principal  = "users"
  permission = "READ"
}
